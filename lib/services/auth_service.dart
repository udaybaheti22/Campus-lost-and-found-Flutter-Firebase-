import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // We append this suffix internally for Firebase Auth
  static const _suffix = '@mahe.campus';

  User? get currentUser => _auth.currentUser;

  String get currentUserId => _auth.currentUser?.uid ?? '';

  String get currentRegId =>
      _auth.currentUser?.email?.replaceAll(_suffix, '') ?? '';

  Future<String> getDisplayName() async {
    final uid = currentUserId;
    if (uid.isEmpty) return '';
    final doc = await _db.collection('users').doc(uid).get();
    return doc.data()?['name'] ?? '';
  }

  Future<void> register(String regId, String password, String name) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: '$regId$_suffix',
        password: password,
      );

      // Wait for auth token to propagate
      await cred.user!.getIdToken(true);

      await _db.collection('users').doc(cred.user!.uid).set({
        'name': name,
        'regId': regId,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        throw Exception('This Registration ID is already registered.');
      }
      rethrow;
    }
  }

  Future<void> login(String regId, String password) async {
    await _auth.signInWithEmailAndPassword(
      email: '$regId$_suffix',
      password: password,
    );
  }

  Future<void> logout() async {
    await _auth.signOut();
  }
}
