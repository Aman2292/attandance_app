import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/attendance_record.dart';

class AttendanceService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Mark attendance for a user
  Future<void> markAttendance({
    required String userId,
    required String status,
    String remarks = '',
  }) async {
    try {
      final record = AttendanceRecord(
        id: _firestore.collection('users').doc(userId).collection('attendance').doc().id,
        userId: userId,
        date: DateTime.now(),
        status: status,
        remarks: remarks,
        createdAt: DateTime.now(),
      );
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('attendance')
          .doc(record.id)
          .set(record.toJson());
    } catch (e) {
      print('Error marking attendance: $e');
      rethrow;
    }
  }

  // Get attendance records for a user
  Stream<List<AttendanceRecord>> getAttendanceRecords(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('attendance')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => AttendanceRecord.fromFirestore(doc)).toList());
  }
}