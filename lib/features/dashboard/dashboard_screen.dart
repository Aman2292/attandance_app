import 'package:flutter/material.dart';
import '../../core/constants.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Dashboard', style: AppTextStyles.heading2),
        backgroundColor: AppColors.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              color: AppColors.surface,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Today\'s Summary', style: AppTextStyles.heading3),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildStatusChip('Check-In', 'Not Checked In', AppColors.absent),
                        _buildStatusChip('Working Hours', '0h 0m', AppColors.info),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              color: AppColors.surface,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Leave Balance', style: AppTextStyles.heading3),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildLeaveChip('Paid Leave', AppConstants.defaultPaidLeaves, AppColors.success),
                        _buildLeaveChip('Sick Leave', AppConstants.defaultSickLeaves, AppColors.info),
                        _buildLeaveChip('Earned Leave', AppConstants.defaultEarnedLeaves, AppColors.warning),
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

  Widget _buildStatusChip(String label, String value, Color color) {
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

  Widget _buildLeaveChip(String label, int count, Color color) {
    return Chip(
      label: Column(
        children: [
          Text(label, style: AppTextStyles.bodySmall),
          Text('$count days', style: AppTextStyles.bodyMedium.copyWith(color: color)),
        ],
      ),
      backgroundColor: AppColors.surface,
      elevation: 2,
    );
  }
}