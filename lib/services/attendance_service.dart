import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/attendance_record.dart';

class AttendanceService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> checkIn({
    required String userId,
    required bool withinOfficeRadius,
    String? notes,
  }) async {
    try {
      final today = DateTime.now();
      final dateId = DateTime(today.year, today.month, today.day).toIso8601String().split('T')[0]; // e.g., "2025-07-11"
      final docRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('attendance')
          .doc(dateId);
      final docSnapshot = await docRef.get();
      final now = DateTime.now();
      final isLate = now.hour > 9 || (now.hour == 9 && now.minute >= 30);
      final record = AttendanceRecord(
        id: dateId,
        userId: userId,
        date: now,
        status: isLate ? 'late' : 'present',
        notes: isLate && notes == null ? 'Late without notes' : notes ?? '',
        createdAt: docSnapshot.exists ? docSnapshot.get('createdAt') as DateTime? : now,
        checkInTime: now,
        isLate: isLate,
        withinOfficeRadius: withinOfficeRadius,
      );
      await docRef.set(record.toJson(), SetOptions(merge: true));
    } catch (e) {
      print('Error checking in: $e');
      rethrow;
    }
  }

  Future<void> checkOut({
    required String userId,
  }) async {
    try {
      final today = DateTime.now();
      final dateId = DateTime(today.year, today.month, today.day).toIso8601String().split('T')[0];
      final docRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('attendance')
          .doc(dateId);
      final docSnapshot = await docRef.get();
      if (!docSnapshot.exists) {
        throw Exception('No check-in found for today');
      }
      final data = docSnapshot.data();
      if (data?['checkOutTime'] != null) {
        throw Exception('Checkout already exists for today');
      }
      await docRef.update({'checkOutTime': FieldValue.serverTimestamp()});
    } catch (e) {
      print('Error checking out: $e');
      rethrow;
    }
  }

  Future<void> startBreak({
    required String userId,
  }) async {
    try {
      final today = DateTime.now();
      final dateId = DateTime(today.year, today.month, today.day).toIso8601String().split('T')[0];
      final docRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('attendance')
          .doc(dateId);
      final docSnapshot = await docRef.get();
      if (!docSnapshot.exists) {
        throw Exception('No check-in found for today');
      }
      final data = docSnapshot.data();
      if (data?['breakStartTime'] != null) {
        throw Exception('Break already started for today');
      }
      await docRef.update({'breakStartTime': FieldValue.serverTimestamp()});
    } catch (e) {
      print('Error starting break: $e');
      rethrow;
    }
  }

  Future<void> endBreak({
    required String userId,
  }) async {
    try {
      final today = DateTime.now();
      final dateId = DateTime(today.year, today.month, today.day).toIso8601String().split('T')[0];
      final docRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('attendance')
          .doc(dateId);
      final docSnapshot = await docRef.get();
      if (!docSnapshot.exists) {
        throw Exception('No check-in found for today');
      }
      final data = docSnapshot.data();
      if (data?['breakEndTime'] != null) {
        throw Exception('Break already ended for today');
      }
      final breakStart = data?['breakStartTime'] as Timestamp?;
      if (breakStart == null) {
        throw Exception('No break started for today');
      }
      final breakDuration = DateTime.now().difference(breakStart.toDate()).inSeconds;
      final totalBreakDuration = breakDuration > 3600 ? 3600 : breakDuration;
      await docRef.update({
        'breakEndTime': FieldValue.serverTimestamp(),
        'totalBreakDuration': totalBreakDuration,
      });
    } catch (e) {
      print('Error ending break: $e');
      rethrow;
    }
  }

  Stream<List<AttendanceRecord>> getAttendanceRecords(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('attendance')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => AttendanceRecord.fromFirestore(doc)).toList());
  }

  Stream<List<AttendanceRecord>> getAttendanceForRange(String userId, DateTime start, DateTime end) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('attendance')
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('date', isLessThanOrEqualTo: Timestamp.fromDate(end))
        .orderBy('date')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => AttendanceRecord.fromFirestore(doc)).toList());
  }

  Future<Map<String, int>> getAttendanceSummary(String userId, DateTime start, DateTime end) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('attendance')
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(end))
          .get();
      final records = snapshot.docs.map((doc) => AttendanceRecord.fromFirestore(doc)).toList();
      return {
        'present': records.where((r) => r.status == 'present').length,
        'absent': records.where((r) => r.status == 'absent').length,
        'late': records.where((r) => r.status == 'late').length,
      };
    } catch (e) {
      print('Error getting attendance summary: $e');
      rethrow;
    }
  }

  Stream<Map<String, int>> getAttendanceSummaryStream(String userId, DateTime start, DateTime end) {
    return getAttendanceForRange(userId, start, end).map((records) {
      return {
        'present': records.where((r) => r.status == 'present').length,
        'late': records.where((r) => r.status == 'late').length,
        'absent': records.where((r) => r.status == 'absent').length,
      };
    });
  }

  Stream<AttendanceRecord?> getTodayAttendance(String userId) {
    final today = DateTime.now();
    final dateId = DateTime(today.year, today.month, today.day).toIso8601String().split('T')[0];
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('attendance')
        .doc(dateId)
        .snapshots()
        .map((snapshot) => snapshot.exists ? AttendanceRecord.fromFirestore(snapshot) : null);
  }
}