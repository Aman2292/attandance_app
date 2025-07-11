import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import '../../core/constants.dart';

import '../../models/user_model.dart';
import '../../models/leave_record.dart';

final allUsersProvider = StreamProvider<List<UserModel>>((ref) {
  return FirebaseFirestore.instance
      .collection('users')
      .snapshots()
      .map((snapshot) => snapshot.docs.map((doc) => UserModel.fromFirestore(doc)).toList());
});

final pendingLeavesProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  return FirebaseFirestore.instance
      .collectionGroup('leaves')
      .where('status', isEqualTo: 'pending')
      .snapshots()
      .map((snapshot) => snapshot.docs.map((doc) {
            final leave = LeaveRecord.fromFirestore(doc);
            return {
              'leave': leave,
              'userId': leave.userId,
            };
          }).toList());
});

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersAsync = ref.watch(allUsersProvider);
    final pendingLeavesAsync = ref.watch(pendingLeavesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Admin Dashboard', style: AppTextStyles.heading2),
        backgroundColor: AppColors.primary,
        actions: [
          IconButton(
            icon: const Icon(Iconsax.user_edit),
            onPressed: () => context.go('/admin/manage-users'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Overview', style: AppTextStyles.heading3),
            const SizedBox(height: 16),
            usersAsync.when(
              data: (users) => Card(
                color: AppColors.background,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Total Employees: ${users.where((u) => u.role == 'employee').length}',
                          style: AppTextStyles.bodyMedium),
                      Text('Admins: ${users.where((u) => u.role == 'admin').length}',
                          style: AppTextStyles.bodyMedium),
                    ],
                  ),
                ),
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text('Error: $e', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.error)),
            ),
            const SizedBox(height: 16),
            const Text('Pending Leave Requests', style: AppTextStyles.bodyLarge),
            pendingLeavesAsync.when(
              data: (leaves) => leaves.isEmpty
                  ? const Text('No pending leaves', style: AppTextStyles.bodyMedium)
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: leaves.length,
                      itemBuilder: (context, index) {
                        final leaveData = leaves[index];
                        final leave = leaveData['leave'] as LeaveRecord;
                        return ListTile(
                          title: Text('${leave.type.capitalize()} Leave - ${leave.startDate.toString().substring(0, 10)}'),
                          subtitle: Text('User ID: ${leave.userId}'),
                          trailing: IconButton(
                            icon: const Icon(Iconsax.arrow_right_3),
                            onPressed: () => context.go('/admin/approve-leave'),
                          ),
                        );
                      },
                    ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text('Error: $e', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.error)),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: AppButtonStyles.primaryButton,
              onPressed: () => context.go('/admin/attendance-overview'),
              child: const Text('View Attendance', style: AppTextStyles.button),
            ),
          ],
        ),
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() => this[0].toUpperCase() + substring(1);
}