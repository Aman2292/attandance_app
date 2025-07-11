import 'package:attendance_app/features/leave/apply_leave_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import '../../core/constants.dart';
import '../../providers/leave_provider.dart';
import '../../models/leave_record.dart';
import 'admin_dashboard_screen.dart';

class ApproveLeaveScreen extends ConsumerWidget {
  const ApproveLeaveScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pendingLeavesAsync = ref.watch(pendingLeavesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Approve Leaves', style: AppTextStyles.heading2),
        backgroundColor: AppColors.primary,
      ),
      body: pendingLeavesAsync.when(
        data: (leaves) => leaves.isEmpty
            ? const Center(child: Text('No pending leaves', style: AppTextStyles.bodyMedium))
            : ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: leaves.length,
                itemBuilder: (context, index) {
                  final leaveData = leaves[index];
                  final leave = leaveData['leave'] as LeaveRecord;
                  return Card(
                    color: AppColors.background,
                    child: ListTile(
                      title: Text('${leave.type} Leave - ${leave.startDate.toString().substring(0, 10)} to ${leave.endDate.toString().substring(0, 10)}'),
                      subtitle: Text('Reason: ${leave.reason}\nUser ID: ${leave.userId}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Iconsax.tick_circle, color: Colors.green),
                            onPressed: () async {
                              try {
                                await ref.read(leaveServiceProvider).updateLeaveStatus(
                                      userId: leave.userId,
                                      leaveId: leave.id,
                                      status: 'approved',
                                    );
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Leave Approved')),
                                );
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Error: $e')),
                                );
                              }
                            },
                          ),
                          IconButton(
                            icon: const Icon(Iconsax.close_circle, color: Colors.red),
                            onPressed: () async {
                              try {
                                await ref.read(leaveServiceProvider).updateLeaveStatus(
                                      userId: leave.userId,
                                      leaveId: leave.id,
                                      status: 'rejected',
                                    );
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Leave Rejected')),
                                );
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Error: $e')),
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.error))),
      ),
    );
  }
}