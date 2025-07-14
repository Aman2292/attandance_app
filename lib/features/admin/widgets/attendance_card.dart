import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import '../../../core/constants.dart';
import '../../../models/attendance_record.dart';

class AttendanceCard extends StatelessWidget {
  final AttendanceRecord record;
  final String userName;

  const AttendanceCard({super.key, required this.record, required this.userName});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userName,
                        style: AppTextStyles.bodyLarge.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'ID: ${record.userId}',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        DateFormat('EEEE, MMM dd, yyyy').format(record.date),
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textHint,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildStatusChip(record.status),
              ],
            ),
            if (record.checkInTime != null || record.checkOutTime != null) ...[
              const SizedBox(height: 16),
              const Divider(color: AppColors.textHint),
              const SizedBox(height: 16),
              Row(
                children: [
                  if (record.checkInTime != null) ...[
                    Expanded(
                      child: _buildTimeInfo(
                        icon: Iconsax.login,
                        label: 'Check In',
                        time: record.checkInTime!,
                        color: AppColors.success,
                      ),
                    ),
                  ],
                  if (record.checkInTime != null && record.checkOutTime != null)
                    const SizedBox(width: 16),
                  if (record.checkOutTime != null) ...[
                    Expanded(
                      child: _buildTimeInfo(
                        icon: Iconsax.logout,
                        label: 'Check Out',
                        time: record.checkOutTime!,
                        color: AppColors.error,
                      ),
                    ),
                  ],
                  if (record.checkInTime != null && record.checkOutTime != null) ...[
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildWorkingHours(record.checkInTime!, record.checkOutTime!),
                    ),
                  ],
                ],
              ),
            ],
            if (record.notes.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Divider(color: AppColors.textHint),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Iconsax.note,
                    color: AppColors.textSecondary,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Notes',
                          style: AppTextStyles.bodySmall.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          record.notes,
                          style: AppTextStyles.bodySmall.copyWith(
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'present':
        color = AppColors.present;
        break;
      case 'absent':
        color = AppColors.absent;
        break;
      case 'late':
        color = AppColors.late;
        break;
      case 'half-day':
        color = AppColors.halfDay;
        break;
      default:
        color = AppColors.textSecondary;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        status.toUpperCase(),
        style: AppTextStyles.bodySmall.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 10,
        ),
      ),
    );
  }

  Widget _buildTimeInfo({
    required IconData icon,
    required String label,
    required DateTime time,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 6),
            Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          DateFormat('h:mm a').format(time),
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildWorkingHours(DateTime checkIn, DateTime checkOut) {
    final duration = checkOut.difference(checkIn);
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Iconsax.clock, color: AppColors.info, size: 16),
            const SizedBox(width: 6),
            Text(
              'Working \nHours',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          '${hours}h ${minutes}m',
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.info,
          ),
        ),
      ],
    );
  }
}