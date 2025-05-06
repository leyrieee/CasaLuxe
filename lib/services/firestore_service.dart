import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'users';

  Future<void> createUserProfile({
    required String uid,
    required String name,
    required String phone,
    required String email,
    required String signupMethod,
  }) async {
    final userRef = _firestore.collection(_collection).doc(uid);
    final snapshot = await userRef.get();

    final existingPhoneUser = await _firestore
        .collection(_collection)
        .where('phone', isEqualTo: phone)
        .limit(1)
        .get();

    if (existingPhoneUser.docs.isNotEmpty &&
        existingPhoneUser.docs.first.id != uid) {
      throw Exception('Phone number already in use by another account.');
    }

    if (!snapshot.exists) {
      await userRef.set({
        'uid': uid,
        'name': name,
        'phone': phone,
        'email': email,
        'signupMethod': signupMethod,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  Future<bool> userProfileExists(String uid) async {
    final doc = await _firestore.collection(_collection).doc(uid).get();
    return doc.exists;
  }

  Future<Map<String, dynamic>?> getUserProfile(String uid) async {
    final doc = await _firestore.collection(_collection).doc(uid).get();
    return doc.data();
  }

  Future<bool> phoneNumberExists(String phone) async {
    final result = await _firestore
        .collection(_collection)
        .where('phone', isEqualTo: phone)
        .limit(1)
        .get();

    return result.docs.isNotEmpty;
  }
}
