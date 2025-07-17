import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/leave_record.dart';
import '../models/user_model.dart';
import 'package:intl/intl.dart';

final leaveServiceProvider = Provider<LeaveService>((ref) => LeaveService());

final leaveRecordsProvider =
    StreamProvider.family<List<LeaveRecord>, String>((ref, userId) {
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
      print('Server: Starting leave application for userId=$userId');
      // Server-side overlap check
      final startDateStr = DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS").format(startDate);
      final endDateStr = DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS").format(endDate);
      final existingLeavesSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('leaves')
          .where('status', whereIn: ['pending', 'approved'])
          .where('startDate', isLessThanOrEqualTo: endDateStr)
          .where('endDate', isGreaterThanOrEqualTo: startDateStr)
          .get()
          .timeout(const Duration(seconds: 10), onTimeout: () {
        throw TimeoutException('Server overlap check timed out');
      });

      if (existingLeavesSnapshot.docs.isNotEmpty) {
        print('Server: Overlap found: ${existingLeavesSnapshot.docs.length} conflicting leaves');
        throw Exception('A leave already exists for the selected dates');
      }
      print('Server: No overlapping leaves found');

      final leaveId = _firestore
          .collection('users')
          .doc(userId)
          .collection('leaves')
          .doc()
          .id;

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

      print('Server: Saving leave record: ${leaveRecord.toJson()}');
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('leaves')
          .doc(leaveId)
          .set(leaveRecord.toJson())
          .timeout(const Duration(seconds: 10), onTimeout: () {
        throw TimeoutException('Leave save timed out');
      });
      print('Server: Leave applied successfully: ${leaveRecord.toJson()}');
    } catch (e) {
      print('Server: Error applying leave: $e');
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
        .map((snapshot) => snapshot.docs
            .map((doc) => LeaveRecord.fromFirestore(doc))
            .toList());
  }

  Future<void> updateLeaveStatus({
    required String userId,
    required String leaveId,
    required String status,
    String? rejectionReason,
    required String adminId, // Added to track admin performing the action
  }) async {
    try {
      print('Starting leave status update: userId=$userId, leaveId=$leaveId, status=$status, adminId=$adminId');
      
      // Verify admin role
      final adminDoc = await _firestore.collection('users').doc(adminId).get();
      if (!adminDoc.exists || adminDoc.data()?['role'] != 'admin') {
        print('Admin check failed: adminId=$adminId');
        throw Exception('Only admins can update leave status');
      }
      print('Admin verified: adminId=$adminId');

      final updateData = {'status': status};
      if (rejectionReason != null && rejectionReason.isNotEmpty) {
        updateData['rejectionReason'] = rejectionReason;
      }

      final leaveRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('leaves')
          .doc(leaveId);
      final userRef = _firestore.collection('users').doc(userId);

      await _firestore.runTransaction((transaction) async {
        // Perform all reads
        final leaveDoc = await transaction.get(leaveRef);
        if (!leaveDoc.exists) {
          print('Leave document not found: userId=$userId, leaveId=$leaveId');
          throw Exception('Leave document not found: $leaveId');
        }
        final currentLeave = LeaveRecord.fromFirestore(leaveDoc);
        if (status == 'approved' && currentLeave.status == 'approved') {
          print('Leave already approved: userId=$userId, leaveId=$leaveId, skipping update');
          return;
        }

        final userDoc = await transaction.get(userRef);
        if (!userDoc.exists) {
          print('User document not found: userId=$userId');
          throw Exception('User document not found: $userId');
        }
        final user = UserModel.fromFirestore(userDoc);
        final leaveBalance = user.leaveBalance;
        final leaveType = currentLeave.type.toLowerCase() == 'casual' ? 'paid' : currentLeave.type.toLowerCase();
        final days = currentLeave.endDate.difference(currentLeave.startDate).inDays + 1;
        print('Calculated days for leave: $days, type: $leaveType, current balance: ${leaveBalance.toJson()}');

        // Perform all writes
        transaction.update(leaveRef, updateData);
        print('Leave status updated: userId=$userId, leaveId=$leaveId, status=$status');

        if (status == 'approved') {
          final updatedBalance = leaveBalance.copyWith(
            paidLeave: leaveType == 'paid'
                ? (leaveBalance.paidLeave - days).clamp(0, leaveBalance.paidLeave)
                : leaveBalance.paidLeave,
            sickLeave: leaveType == 'sick'
                ? (leaveBalance.sickLeave - days).clamp(0, leaveBalance.sickLeave)
                : leaveBalance.sickLeave,
            earnedLeave: leaveType == 'earned'
                ? (leaveBalance.earnedLeave - days).clamp(0, leaveBalance.earnedLeave)
                : leaveBalance.earnedLeave,
          );
          transaction.update(userRef, {'leaveBalance': updatedBalance.toJson()});
          print('Leave balance updated for userId=$userId: ${updatedBalance.toJson()}');
        }
      });
    } catch (e) {
      print('Error updating leave status: userId=$userId, leaveId=$leaveId, adminId=$adminId, error=$e');
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
      final records =
          snapshot.docs.map((doc) => LeaveRecord.fromFirestore(doc)).toList();
      final counts = {
        'paid': records
            .where((r) =>
                r.type.toLowerCase() == 'paid' ||
                r.type.toLowerCase() == 'casual')
            .length,
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
}