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
              size: 26,
            ),
            const SizedBox(width: 10),
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

            return Padding(
              padding: const EdgeInsets.symmetric( vertical: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.17,
                    width: MediaQuery.of(context).size.width * 0.21,
                    child: Expanded(
                      child: DashboardUtils.buildStatCard(
                        'Total \nUsers',
                        '$totalUsers',
                        Iconsax.people,
                        const Color.fromARGB(255, 0, 82, 149),
                      ),
                    ),
                  ),
                  const SizedBox(width: 5),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.17,
                    width: MediaQuery.of(context).size.width * 0.21,
                    child: Expanded(
                      child: DashboardUtils.buildStatCard(
                        'Total \nEmployees',
                        '$employees',
                        Iconsax.user,
                        const Color.fromARGB(255, 0, 70, 2),
                      ),
                    ),
                  ),
                  const SizedBox(width: 5),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.17,
                    width: MediaQuery.of(context).size.width * 0.21,
                    child: Expanded(
                      child: DashboardUtils.buildStatCard(
                        'Total \nAdmins',
                        '$admins',
                        Iconsax.crown,
                        const Color.fromARGB(255, 113, 85, 0),
                      ),
                    ),
                  ),
                  const SizedBox(width: 5),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.17,
                    width: MediaQuery.of(context).size.width * 0.21,
                    child: Expanded(
                      child: DashboardUtils.buildStatCard(
                        'Pending Leaves',
                        '$pendingLeaves',
                        Iconsax.clock,
                        const Color.fromARGB(255, 0, 120, 138),
                      ),
                    ),
                  ),
                ],
              ),
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