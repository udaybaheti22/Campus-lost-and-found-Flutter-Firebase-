import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/item.dart';
import '../models/claim.dart';

class ItemService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Items stream
  Stream<List<LostFoundItem>> getItems() {
    return _db
        .collection('items')
        .orderBy('date', descending: true)
        .snapshots()
        .map((s) => s.docs.map(LostFoundItem.fromFirestore).toList());
  }

  Future<void> addItem(LostFoundItem item, Uint8List? imageBytes,
      String? imageFileName) async {
    String? imageUrl;
    if (imageBytes != null && imageFileName != null) {
      final ref = _storage
          .ref()
          .child('items/${DateTime.now().millisecondsSinceEpoch}_$imageFileName');
      final task = await ref.putData(
          imageBytes, SettableMetadata(contentType: 'image/jpeg'));
      imageUrl = await task.ref.getDownloadURL();
    }
    final map = item.toMap();
    if (imageUrl != null) map['imageUrl'] = imageUrl;
    await _db.collection('items').add(map);
  }

  Future<void> updateItemStatus(String itemId, String status) async {
    await _db.collection('items').doc(itemId).update({'status': status});
  }

  // Claims
  Future<void> submitClaim(ClaimRequest claim) async {
    await _db.collection('claims').add(claim.toMap());
  }

  Stream<List<ClaimRequest>> getClaimsForItem(String itemId) {
    return _db
        .collection('claims')
        .where('itemId', isEqualTo: itemId)
        .snapshots()
        .map((s) => s.docs.map(ClaimRequest.fromFirestore).toList());
  }

  Future<bool> hasUserClaimed(String itemId, String userId) async {
    final snap = await _db
        .collection('claims')
        .where('itemId', isEqualTo: itemId)
        .where('claimantId', isEqualTo: userId)
        .get();
    return snap.docs.isNotEmpty;
  }

  Future<void> approveClaim(String claimId, String itemId) async {
    final batch = _db.batch();
    // Approve this claim
    batch.update(_db.collection('claims').doc(claimId), {'status': 'Approved'});
    // Close the item
    batch.update(_db.collection('items').doc(itemId), {'status': 'Closed'});
    await batch.commit();

    // Reject all other pending claims for this item
    final others = await _db
        .collection('claims')
        .where('itemId', isEqualTo: itemId)
        .where('status', isEqualTo: 'Pending')
        .get();
    for (final doc in others.docs) {
      if (doc.id != claimId) {
        await doc.reference.update({'status': 'Rejected'});
      }
    }
  }

  Future<void> rejectClaim(String claimId) async {
    await _db
        .collection('claims')
        .doc(claimId)
        .update({'status': 'Rejected'});
  }
}
