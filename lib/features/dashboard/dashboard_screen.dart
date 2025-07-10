import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants.dart';
import '../../providers/user_provider.dart';
import '../../providers/attendance_provider.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userProvider);
    final attendanceAsync = ref.watch(attendanceRecordsProvider(ref.watch(authServiceProvider).currentUser?.uid ?? ''));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Dashboard', style: AppTextStyles.heading2),
        backgroundColor: AppColors.primary,
      ),
      body: userAsync.when(
        data: (user) {
          if (user == null) {
            return const Center(child: Text('User not found', style: AppTextStyles.bodyLarge));
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Welcome, ${user.name}', style: AppTextStyles.heading3),
                const SizedBox(height: 16),
                Text('Leave Balance', style: AppTextStyles.bodyLarge),
                Card(
                  color: AppColors.textHint,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Text('Paid: ${user.leaveBalance.paidLeave}', style: AppTextStyles.bodyMedium),
                        Text('Sick: ${user.leaveBalance.sickLeave}', style: AppTextStyles.bodyMedium),
                        Text('Earned: ${user.leaveBalance.earnedLeave}', style: AppTextStyles.bodyMedium),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text('Recent Attendance', style: AppTextStyles.bodyLarge),
                attendanceAsync.when(
                  data: (records) => records.isEmpty
                      ? const Text('No attendance records', style: AppTextStyles.bodyMedium)
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: records.length > 3 ? 3 : records.length,
                          itemBuilder: (context, index) {
                            final record = records[index];
                            return ListTile(
                              title: Text('${record.date.toString().substring(0, 10)} - ${record.status}'),
                              subtitle: Text(record.remarks.isEmpty ? 'No remarks' : record.remarks),
                            );
                          },
                        ),
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Text('Error: $e', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.error)),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  style: AppButtonStyles.primaryButton,
                  onPressed: () => context.go('/employee/attendance'),
                  child: const Text('Mark Attendance', style: AppTextStyles.button),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.error))),
      ),
    );
  }
}