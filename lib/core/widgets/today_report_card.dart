import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../core/constants.dart';

class TodayReportCard extends StatelessWidget {
  final Map<String, dynamic> todayData;

  const TodayReportCard({super.key, required this.todayData});

  // Standard working hours constant
  static const double _standardWorkingHours = 8.0;

  // Format duration for display
  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    return '${hours}h ${minutes}m';
  }

  Widget _buildTodayInfoTile(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: color,
                size: 16,
              ),
              const SizedBox(width: 6),
              Text(
                title,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textHint,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final status = todayData['status'] as String;
    final checkInTime = todayData['checkInTime'] as DateTime?;
    final checkOutTime = todayData['checkOutTime'] as DateTime?;
    final currentWorkingHours = todayData['currentWorkingHours'] as double;
    final totalBreakDuration = todayData['totalBreakDuration'] as int;
    final isOnBreak = todayData['isOnBreak'] as bool;

    Color statusColor = AppColors.textHint;
    IconData statusIcon = Iconsax.clock;

    switch (status) {
      case 'Working':
        statusColor = AppColors.success;
        statusIcon = Iconsax.play;
        break;
      case 'On Break':
        statusColor = AppColors.warning;
        statusIcon = Iconsax.pause;
        break;
      case 'Completed':
        statusColor = AppColors.primary;
        statusIcon = Iconsax.tick_circle;
        break;
      case 'Not Started':
        statusColor = AppColors.textHint;
        statusIcon = Iconsax.clock;
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 255, 255, 255),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(255, 255, 255, 255).withOpacity(0.05),
            blurRadius: 10,
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
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Iconsax.calendar,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Today\'s Report',
                    style: AppTextStyles.heading3.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    '${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textHint,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      statusIcon,
                      color: statusColor,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      status,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildTodayInfoTile(
                  'Check In',
                  checkInTime != null
                      ? '${checkInTime.hour.toString().padLeft(2, '0')}:${checkInTime.minute.toString().padLeft(2, '0')}'
                      : '--:--',
                  Iconsax.login,
                  AppColors.success,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTodayInfoTile(
                  'Check Out',
                  checkOutTime != null
                      ? '${checkOutTime.hour.toString().padLeft(2, '0')}:${checkOutTime.minute.toString().padLeft(2, '0')}'
                      : '--:--',
                  Iconsax.logout,
                  AppColors.error,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildTodayInfoTile(
                  'Working Hours',
                  _formatDuration(Duration(minutes: (currentWorkingHours * 60).round())),
                  Iconsax.clock,
                  AppColors.primary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTodayInfoTile(
                  'Break Time',
                  _formatDuration(Duration(minutes: totalBreakDuration)),
                  Iconsax.pause,
                  AppColors.warning,
                ),
              ),
            ],
          ),
          if (currentWorkingHours > 0) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: currentWorkingHours >= _standardWorkingHours
                    ? AppColors.success.withOpacity(0.1)
                    : AppColors.warning.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    currentWorkingHours >= _standardWorkingHours
                        ? Iconsax.tick_circle
                        : Iconsax.info_circle,
                    color: currentWorkingHours >= _standardWorkingHours
                        ? AppColors.success
                        : AppColors.warning,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      currentWorkingHours >= _standardWorkingHours
                          ? 'You\'ve completed your standard working hours!'
                          : 'Remaining: ${_formatDuration(Duration(minutes: ((_standardWorkingHours - currentWorkingHours) * 60).round()))}',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: currentWorkingHours >= _standardWorkingHours
                            ? AppColors.success
                            : AppColors.warning,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}