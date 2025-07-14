import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/leave_record.dart';

final leaveServiceProvider = Provider<LeaveService>((ref) => LeaveService());

final leaveRecordsProvider = StreamProvider.family<List<LeaveRecord>, String>((ref, userId) {
  return ref.watch(leaveServiceProvider).getLeaveRecords(userId);
});

final allLeavesProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  try {
    final snapshot = await FirebaseFirestore.instance
        .collectionGroup('leaves')
        .orderBy('createdAt', descending: true)
        .get();
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
  } catch (e) {
    print('Error in allLeavesProvider: $e');
    rethrow;
  }
});

class LeaveService {
  Stream<List<LeaveRecord>> getLeaveRecords(String userId) {
    return FirebaseFirestore.instance
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
    final updateData = {'status': status};
    if (rejectionReason != null && rejectionReason.isNotEmpty) {
      updateData['rejectionReason'] = rejectionReason;
    }
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('leaves')
        .doc(leaveId)
        .update(updateData);
  }
}