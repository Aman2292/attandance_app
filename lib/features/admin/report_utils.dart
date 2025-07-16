
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../core/constants.dart';

class ReportUtils {
  static Color getAttendanceStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'present':
        return AppColors.present;
      case 'absent':
        return AppColors.absent;
      case 'late':
        return AppColors.late;
      case 'half_day':
      case 'halfday':
        return AppColors.halfDay;
      default:
        return AppColors.textSecondary;
    }
  }

  static IconData getAttendanceStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'present':
        return Iconsax.tick_circle;
      case 'absent':
        return Iconsax.close_circle;
      case 'late':
        return Iconsax.clock;
      case 'half_day':
      case 'halfday':
        return Iconsax.timer;
      default:
        return Iconsax.user;
    }
  }

  static Color getLeaveStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return AppColors.approved;
      case 'pending':
        return AppColors.pending;
      case 'rejected':
        return AppColors.rejected;
      default:
        return AppColors.textSecondary;
    }
  }

  static Widget buildModernSummaryCard(
      String title, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.textHint.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 18,
                ),
              ),
              const Spacer(),
              Text(
                value,
                style: AppTextStyles.heading3.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  static Widget buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.textHint.withOpacity(0.1),
              borderRadius: BorderRadius.circular(60),
            ),
            child: Icon(
              Iconsax.user_search,
              size: 60,
              color: AppColors.textHint,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No Users Found',
            style: AppTextStyles.heading3.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your search criteria',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textHint,
            ),
          ),
        ],
      ),
    );
  }

  static Widget buildErrorState(VoidCallback onRetry) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.error.withOpacity(0.1),
              borderRadius: BorderRadius.circular(60),
            ),
            child: Icon(
              Iconsax.warning_2,
              size: 60,
              color: AppColors.error,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Something went wrong',
            style: AppTextStyles.heading3.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Please try again later',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textHint,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onRetry,
            style: AppButtonStyles.primaryButton,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  static Widget buildEmptyTabContent(String message, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: AppColors.textHint),
          const SizedBox(height: 16),
          Text(
            message,
            style: AppTextStyles.heading3.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  static Widget buildErrorTabContent(String message) {
    return Center(
      child: Text(
        message,
        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.error),
      ),
    );
  }
}
