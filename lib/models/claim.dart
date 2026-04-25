import 'package:cloud_firestore/cloud_firestore.dart';

class ClaimRequest {
  final String id;
  final String itemId;
  final String claimantId;
  final String claimantName;
  final String claimantRegId;
  final String message;
  final DateTime createdAt;
  final String status;

  ClaimRequest({
    required this.id,
    required this.itemId,
    required this.claimantId,
    required this.claimantName,
    required this.claimantRegId,
    required this.message,
    required this.createdAt,
    required this.status,
  });

  factory ClaimRequest.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return ClaimRequest(
      id: doc.id,
      itemId: d['itemId'] ?? '',
      claimantId: d['claimantId'] ?? '',
      claimantName: d['claimantName'] ?? '',
      claimantRegId: d['claimantRegId'] ?? '',
      message: d['message'] ?? '',
      createdAt: (d['createdAt'] as Timestamp).toDate(),
      status: d['status'] ?? 'Pending',
    );
  }

  Map<String, dynamic> toMap() => {
        'itemId': itemId,
        'claimantId': claimantId,
        'claimantName': claimantName,
        'claimantRegId': claimantRegId,
        'message': message,
        'createdAt': Timestamp.fromDate(createdAt),
        'status': status,
      };
}
