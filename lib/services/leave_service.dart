import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/leave_record.dart';
import '../models/user_model.dart';

final leaveServiceProvider = Provider<LeaveService>((ref) => LeaveService());

final leaveRecordsProvider = StreamProvider.family<List<LeaveRecord>, String>((ref, userId) {
  return ref.watch(leaveServiceProvider).getLeaveRecords(userId);
});

final allLeavesProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  return FirebaseFirestore.instance
      .collectionGroup('leaves')
      .orderBy('createdAt', descending: true)
      .snapshots()
      .asyncMap((snapshot) async {
        List<Map<String, dynamic>> result = [];
        for (var doc in snapshot.docs) {
          final leave = LeaveRecord.fromFirestore(doc);
          String userName = 'Unknown';
          try {
            final userDoc = await FirebaseFirestore.instance
                .collection('users')
                .doc(leave.userId)
                .get();
            if (userDoc.exists) {
              final userData = userDoc.data();
              if (userData != null && userData.containsKey('name')) {
                userName = userData['name'] as String;
              }
            }
          } catch (e) {
            print('Error fetching user name for userId ${leave.userId}: $e');
          }
          result.add({
            'leave': leave,
            'userName': userName,
          });
        }
        return result;
      });
});

class LeaveService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Apply for a leave
  Future<void> applyLeave({
  required String userId,
  required String type,
  required DateTime startDate,
  required DateTime endDate,
  required String reason,
}) async {
  try {
    final leaveId = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('leaves')
        .doc()
        .id;

    final leaveRecord = {
      'id': leaveId,
      'userId': userId,
      'type': type,
      'startDate': startDate,
      'endDate': endDate,
      'status': 'pending',
      'reason': reason,
      'createdAt': DateTime.now(),
    };

    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('leaves')
        .doc(leaveId)
        .set(leaveRecord);
  } catch (e) {
    print('Error applying leave: $e');
    rethrow;
  }
}

  Stream<List<LeaveRecord>> getLeaveRecords(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('leaves')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => LeaveRecord.fromFirestore(doc)).toList());
  }

  // Approve or reject a leave (for admin)
  Future<void> updateLeaveStatus({
    required String userId,
    required String leaveId,
    required String status,
    String? rejectionReason,
  }) async {
    try {
      final updateData = {'status': status};
      if (rejectionReason != null && rejectionReason.isNotEmpty) {
        updateData['rejectionReason'] = rejectionReason;
      }
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('leaves')
          .doc(leaveId)
          .update(updateData);

      if (status == 'approved') {
        final leaveDoc = await _firestore
            .collection('users')
            .doc(userId)
            .collection('leaves')
            .doc(leaveId)
            .get();
        final leave = LeaveRecord.fromFirestore(leaveDoc);
        final days = leave.endDate.difference(leave.startDate).inDays + 1;

        final userDoc = await _firestore.collection('users').doc(userId).get();
        final user = UserModel.fromFirestore(userDoc);
        final leaveBalance = user.leaveBalance;

        final updatedBalance = leaveBalance.copyWith(
          paidLeave: leave.type == 'paid' ? leaveBalance.paidLeave - days : leaveBalance.paidLeave,
          sickLeave: leave.type == 'sick' ? leaveBalance.sickLeave - days : leaveBalance.sickLeave,
          earnedLeave: leave.type == 'earned' ? leaveBalance.earnedLeave - days : leaveBalance.earnedLeave,
        );

        await _firestore.collection('users').doc(userId).update({
          'leaveBalance': updatedBalance.toJson(),
        });
      }
    } catch (e) {
      print('Error updating leave status: $e');
      rethrow;
    }
  }

  // Get leave summary for reports
  Future<Map<String, int>> getLeaveSummary(String userId, DateTime start, DateTime end) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('leaves')
          .where('startDate', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
          .where('startDate', isLessThanOrEqualTo: Timestamp.fromDate(end))
          .get();
      final records = snapshot.docs.map((doc) => LeaveRecord.fromFirestore(doc)).toList();
      return {
        'paid': records.where((r) => r.type == 'paid' && r.status == 'approved').length,
        'sick': records.where((r) => r.type == 'sick' && r.status == 'approved').length,
        'earned': records.where((r) => r.type == 'earned' && r.status == 'approved').length,
      };
    } catch (e) {
      print('Error getting leave summary: $e');
      rethrow;
    }
  }
}