import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/driver_model.dart';
import '../models/review_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> ensureUserDocument({
    required String userId,
    required String email,
  }) {
    return _firestore.collection('users').doc(userId).set(
      {'email': email},
      SetOptions(merge: true),
    );
  }

  Future<void> saveEmergencyContact({
    required String userId,
    required String contactName,
    required String contactPhone,
  }) {
    return _firestore.collection('users').doc(userId).set(
      {
        'emergencyContactName': contactName,
        'emergencyContactPhone': contactPhone,
      },
      SetOptions(merge: true),
    );
  }

  Future<bool> hasEmergencyContact(String userId) async {
    final snapshot = await _firestore.collection('users').doc(userId).get();
    if (!snapshot.exists) return false;

    final data = snapshot.data() ?? {};
    return (data['emergencyContactName'] as String?)?.isNotEmpty == true &&
        (data['emergencyContactPhone'] as String?)?.isNotEmpty == true;
  }

  Future<DriverModel> getDriverByCabNumber(String cabNumber) async {
    final doc = await _firestore.collection('drivers').doc(cabNumber).get();

    if (!doc.exists) {
      throw Exception('Driver not found for cab number $cabNumber');
    }

    return DriverModel.fromMap(doc.id, doc.data()!);
  }

  Future<void> submitReview(ReviewModel review) {
    return _firestore.collection('reviews').add(review.toMap());
  }
}
