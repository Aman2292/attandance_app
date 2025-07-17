import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/constants.dart';
import '../../../models/leave_record.dart';
import '../admin_dashboard_screen.dart';
import '../utils/dashboard_utils.dart';

class PendingLeavesSectionWidget extends StatelessWidget {
  final AsyncValue<List<Map<String, dynamic>>> pendingLeavesAsync;

  const PendingLeavesSectionWidget({
    super.key,
    required this.pendingLeavesAsync,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  Iconsax.calendar_2,
                  color: AppColors.surface,
                  size: 30,
                ),
                const SizedBox(width: 12),
                Text(
                  'Leave Requests',
                  style: AppTextStyles.heading2.copyWith(fontSize: 20),
                ),
              ],
            ),
            Container(
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextButton.icon(
                onPressed: () => context.go('/admin/approve-leave'),
                icon: const Icon(Iconsax.arrow_right_3, size: 14),
                label: Text(
                  'View All',
                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.primary),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
            child: pendingLeavesAsync.when(
              data: (leaves) {
                if (leaves.isEmpty) {
                  return DashboardUtils.buildEmptyState(
                    'No pending leave requests',
                    'All caught up! No pending leave requests at the moment.',
                    Iconsax.tick_circle,
                    AppColors.success,
                  );
                }
                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: leaves.length > 5 ? 5 : leaves.length,
                  separatorBuilder: (context, index) => const Divider(height: 24),
                  itemBuilder: (context, index) {
                    final leaveData = leaves[index];
                    final leave = leaveData['leave'] as LeaveRecord;
                    return DashboardUtils.buildLeaveRequestTile(leave);
                  },
                );
              },
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
              error: (e, stackTrace) => DashboardUtils.buildErrorCard(
                  'Failed to load leave requests', () => ProviderScope.containerOf(context, listen: false).read(pendingLeavesProvider)),
            ),
          ),
        ),
      ],
    );
  }
}