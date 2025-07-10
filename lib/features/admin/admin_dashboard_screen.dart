import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import '../../core/constants.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Admin Dashboard', style: AppTextStyles.heading2),
        backgroundColor: AppColors.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              color: AppColors.surface,
              child: ListTile(
                leading: const Icon(Iconsax.user),
                title: const Text('Manage Users', style: AppTextStyles.bodyLarge),
                trailing: const Icon(Iconsax.arrow_right_3),
                onTap: () => context.go('/admin/manage-users'),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              color: AppColors.surface,
              child: ListTile(
                leading: const Icon(Iconsax.calendar),
                title: const Text('Approve Leave', style: AppTextStyles.bodyLarge),
                trailing: const Icon(Iconsax.arrow_right_3),
                onTap: () => context.go('/admin/approve-leave'),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              color: AppColors.surface,
              child: ListTile(
                leading: const Icon(Iconsax.chart),
                title: const Text('Attendance Overview', style: AppTextStyles.bodyLarge),
                trailing: const Icon(Iconsax.arrow_right_3),
                onTap: () => context.go('/admin/attendance-overview'),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              color: AppColors.surface,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Overview', style: AppTextStyles.heading3),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildStatChip('Total Users', '50', AppColors.info),
                        _buildStatChip('Leave Requests', '10', AppColors.warning),
                        _buildStatChip('Today\'s Attendance', '45', AppColors.success),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatChip(String label, String value, Color color) {
    return Chip(
      label: Column(
        children: [
          Text(label, style: AppTextStyles.bodySmall),
          Text(value, style: AppTextStyles.bodyMedium.copyWith(color: color)),
        ],
      ),
      backgroundColor: AppColors.surface,
      elevation: 2,
    );
  }
}