import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import '../../../core/constants.dart';
import '../../../models/attendance_record.dart';

class AttendanceSummaryHeader extends StatelessWidget {
  final List<Map<String, dynamic>> records;

  const AttendanceSummaryHeader({super.key, required this.records});

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final todayRecords = records.where((record) {
      final attendance = record['attendance'] as AttendanceRecord;
      return attendance.date.year == today.year &&
          attendance.date.month == today.month &&
          attendance.date.day == today.day;
    }).toList();

    final presentCount = todayRecords.where((record) {
      final attendance = record['attendance'] as AttendanceRecord;
      return attendance.status == 'present';
    }).length;

    final absentCount = todayRecords.where((record) {
      final attendance = record['attendance'] as AttendanceRecord;
      return attendance.status == 'absent';
    }).length;

    final lateCount = todayRecords.where((record) {
      final attendance = record['attendance'] as AttendanceRecord;
      return attendance.status == 'late';
    }).length;

    final totalEmployees = records.fold<Set<String>>({}, (set, record) {
      final attendance = record['attendance'] as AttendanceRecord;
      set.add(attendance.userId);
      return set;
    }).length;

    return Container(
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, Colors.grey.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary.withOpacity(0.5), AppColors.primary.withOpacity(0.5)],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Iconsax.calendar, color: AppColors.surface, size: 16),
              ),
              const SizedBox(width: 8),
              Text(
                'Today\'s Attendance',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.surface,
                ),
              ),
              const Spacer(),
              Text(
                DateFormat('dd-MMM-yyyy').format(today),
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildSummaryItem(
                  icon: Iconsax.tick_circle,
                  color: AppColors.present,
                  label: 'Present',
                  count: presentCount,
                ),
              ),
              Expanded(
                child: _buildSummaryItem(
                  icon: Iconsax.close_circle,
                  color: AppColors.absent,
                  label: 'Absent',
                  count: absentCount,
                ),
              ),
              Expanded(
                child: _buildSummaryItem(
                  icon: Iconsax.warning_2,
                  color: AppColors.late,
                  label: 'Late',
                  count: lateCount,
                ),
              ),
              Expanded(
                child: _buildSummaryItem(
                  icon: Iconsax.people,
                  color: AppColors.info,
                  label: 'Total',
                  count: totalEmployees,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem({
    required IconData icon,
    required Color color,
    required String label,
    required int count,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color.withOpacity(0.3), color.withOpacity(0.3)],
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          count.toString(),
          style: AppTextStyles.heading3.copyWith(color: color),
        ),
        Text(
          label,
          style: AppTextStyles.bodySmall,
        ),
      ],
    );
  }
}