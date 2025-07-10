import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/leave_record.dart';
import '../models/user_model.dart';


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
      final leaveRecord = LeaveRecord(
        id: _firestore.collection('users').doc(userId).collection('leaves').doc().id,
        userId: userId,
        type: type,
        startDate: startDate,
        endDate: endDate,
        status: 'pending',
        reason: reason,
        createdAt: DateTime.now(),
      );
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('leaves')
          .doc(leaveRecord.id)
          .set(leaveRecord.toJson());
    } catch (e) {
      print('Error applying leave: $e');
      rethrow;
    }
  }

  // Approve or reject a leave (for admin)
  Future<void> updateLeaveStatus({
    required String userId,
    required String leaveId,
    required String status,
  }) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('leaves')
          .doc(leaveId)
          .update({'status': status});

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

  // Get leave records for a user
  Stream<List<LeaveRecord>> getLeaveRecords(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('leaves')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => LeaveRecord.fromFirestore(doc)).toList());
  }
}