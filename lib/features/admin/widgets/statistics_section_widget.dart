import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/constants.dart';
import '../../../models/user_model.dart';
import '../admin_dashboard_screen.dart';
import '../utils/dashboard_utils.dart';

class StatisticsSectionWidget extends StatelessWidget {
  final AsyncValue<List<UserModel>> usersAsync;
  final AsyncValue<List<Map<String, dynamic>>> pendingLeavesAsync;

  const StatisticsSectionWidget({
    super.key,
    required this.usersAsync,
    required this.pendingLeavesAsync,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Iconsax.chart_1,
              color: AppColors.surface,
              size: 30,
            ),
            const SizedBox(width: 12),
            Text(
              'Overview Statistics',
              style: AppTextStyles.heading2.copyWith(fontSize: 20),
            ),
          ],
        ),
        usersAsync.when(
          data: (users) {
            final employees = users.where((u) => u.role == 'employee').length;
            final admins = users.where((u) => u.role == 'admin').length;
            final totalUsers = users.length;
            final pendingLeaves = pendingLeavesAsync.value?.length ?? 0;

            return GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 0.95, // Lower ratio = taller card
              children: [
                DashboardUtils.buildStatCard(
                  'Total Users',
                  '$totalUsers',
                  Iconsax.people,
                  AppColors.info,
                  'Active in system',
                ),
                DashboardUtils.buildStatCard(
                  'Employees',
                  '$employees',
                  Iconsax.user,
                  AppColors.success,
                  'Team members',
                ),
                DashboardUtils.buildStatCard(
                  'Administrators',
                  '$admins',
                  Iconsax.crown,
                  AppColors.warning,
                  'System admins',
                ),
                DashboardUtils.buildStatCard(
                  'Pending Leaves',
                  '$pendingLeaves',
                  Iconsax.clock,
                  AppColors.pending,
                  'Awaiting approval',
                ),
              ],
            );
          },
          loading: () => DashboardUtils.buildStatsLoading(),
          error: (e, stackTrace) => DashboardUtils.buildErrorCard(
            'Failed to load statistics',
            () => ProviderScope.containerOf(context, listen: false)
                .read(allUsersProvider),
          ),
        ),
      ],
    );
  }
}
