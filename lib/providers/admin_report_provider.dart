// Provider for all users, including their Firestore document IDs
import 'package:attendance_app/models/attendance_record.dart' as models;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/admin/widgets/user_lists_widget.dart';
import '../models/leave_record.dart';
import '../models/user_model.dart';

final allUsersProvider = StreamProvider<List<UserWithId>>((ref) {
  return FirebaseFirestore.instance
      .collection('users')
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => UserWithId(
                user: UserModel.fromFirestore(doc),
                id: doc.id,
              ))
          .toList());
});

// Provider for user attendance records
final userAttendanceProvider =
    StreamProvider.family<List<models.AttendanceRecord>, String>((ref, userId) {
  return FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .collection('attendance')
      .orderBy('date', descending: true)
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => models.AttendanceRecord.fromFirestore(doc))
          .toList());
});

// Provider for user leave records
final userLeavesProvider =
    StreamProvider.family<List<LeaveRecord>, String>((ref, userId) {
  return FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .collection('leaves')
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snapshot) =>
          snapshot.docs.map((doc) => LeaveRecord.fromFirestore(doc)).toList());
});