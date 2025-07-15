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

  Future<void> applyLeave({
    required String userId,
    required String type,
    required DateTime startDate,
    required DateTime endDate,
    required String reason,
  }) async {
    try {
      final leaveId = _firestore.collection('users').doc(userId).collection('leaves').doc().id;

      final leaveRecord = LeaveRecord(
        id: leaveId,
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
          .doc(leaveId)
          .set(leaveRecord.toJson());
      print('Leave applied: ${leaveRecord.toJson()}');
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

      // Update leave status
      final leaveRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('leaves')
          .doc(leaveId);
      await _firestore.runTransaction((transaction) async {
        final leaveDoc = await transaction.get(leaveRef);
        if (!leaveDoc.exists) {
          throw Exception('Leave document not found: $leaveId');
        }
        transaction.update(leaveRef, updateData);
      });
      print('Leave status updated: userId=$userId, leaveId=$leaveId, status=$status');

      if (status == 'approved') {
        // Fetch leave and user data within a transaction
        final userRef = _firestore.collection('users').doc(userId);
        await _firestore.runTransaction((transaction) async {
          final leaveDoc = await transaction.get(leaveRef);
          final userDoc = await transaction.get(userRef);

          if (!leaveDoc.exists || !userDoc.exists) {
            throw Exception('Leave or user document not found');
          }

          final leave = LeaveRecord.fromFirestore(leaveDoc);
          final user = UserModel.fromFirestore(userDoc);
          final leaveBalance = user.leaveBalance;

          // Map 'casual' to 'paid' for leave balance updates
          final leaveType = leave.type.toLowerCase() == 'casual' ? 'paid' : leave.type.toLowerCase();

          // Deduct 1 from the appropriate leave type
          final updatedBalance = leaveBalance.copyWith(
            paidLeave: leaveType == 'paid' ? (leaveBalance.paidLeave > 0 ? leaveBalance.paidLeave - 1 : 0) : leaveBalance.paidLeave,
            sickLeave: leaveType == 'sick' ? (leaveBalance.sickLeave > 0 ? leaveBalance.sickLeave - 1 : 0) : leaveBalance.sickLeave,
            earnedLeave: leaveType == 'earned' ? (leaveBalance.earnedLeave > 0 ? leaveBalance.earnedLeave - 1 : 0) : leaveBalance.earnedLeave,
          );

          print('Updating leave balance: Before=$leaveBalance, After=$updatedBalance');
          transaction.update(userRef, {'leaveBalance': updatedBalance.toJson()});
          print('Leave balance updated for userId=$userId: $updatedBalance');
        });
      }
    } catch (e) {
      print('Error updating leave status: $e');
      rethrow;
    }
  }

  Future<Map<String, int>> getApprovedLeavesCount(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('leaves')
          .where('status', isEqualTo: 'approved')
          .get();
      final records = snapshot.docs.map((doc) => LeaveRecord.fromFirestore(doc)).toList();
      final counts = {
        'paid': records.where((r) => r.type.toLowerCase() == 'paid' || r.type.toLowerCase() == 'casual').length,
        'sick': records.where((r) => r.type.toLowerCase() == 'sick').length,
        'earned': records.where((r) => r.type.toLowerCase() == 'earned').length,
      };
      print('Approved leaves count for userId=$userId: $counts');
      return counts;
    } catch (e) {
      print('Error getting approved leaves count: $e');
      rethrow;
    }
  }

  Future<void> syncLeaveBalance(String userId) async {
    try {
      final approvedLeaves = await getApprovedLeavesCount(userId);
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (!userDoc.exists) {
        throw Exception('User document does not exist: $userId');
      }
      final user = UserModel.fromFirestore(userDoc);

      // Define initial leave balance based on company policy
      const initialLeaveBalance = {
        'paid': 17,
        'sick': 6,
        'earned': 0,
      };

      final updatedBalance = LeaveBalance(
        paidLeave: initialLeaveBalance['paid']! - approvedLeaves['paid']!,
        sickLeave: initialLeaveBalance['sick']! - approvedLeaves['sick']!,
        earnedLeave: initialLeaveBalance['earned']! - approvedLeaves['earned']!,
      );

      print('Syncing leave balance for userId=$userId: $updatedBalance');
      await _firestore.collection('users').doc(userId).update({
        'leaveBalance': updatedBalance.toJson(),
      });
      print('Leave balance synced for userId=$userId');
    } catch (e) {
      print('Error syncing leave balance: $e');
      rethrow;
    }
  }
}
