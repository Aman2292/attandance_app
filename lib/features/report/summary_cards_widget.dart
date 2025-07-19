import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../core/constants.dart';

class SummaryCards extends StatelessWidget {
  final Map<String, dynamic> data;

  const SummaryCards({
    super.key,
    required this.data,
  });

  Widget _buildSummaryCard({
    required String title,
    required String value,
    required IconData icon,
    required List<Color> gradientColors,
    String? subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: gradientColors[0].withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: gradientColors[0].withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: gradientColors,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: AppTextStyles.heading2.copyWith(
                  color: gradientColors[0],
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(width: 8),
                Text(
                  subtitle,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOvertimeCard({
    required String title,
    required String value,
    required IconData icon,
    required double? overtimeHours,
  }) {
    final isOvertime = overtimeHours != null && overtimeHours > 0;
    final gradientColors = isOvertime 
        ? [AppColors.error, AppColors.error.withOpacity(0.8)]
        : [AppColors.success, AppColors.success.withOpacity(0.8)];

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: gradientColors[0].withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: gradientColors[0].withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: gradientColors,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (isOvertime) ...[
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: gradientColors,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Iconsax.warning_2,
                              color: Colors.white,
                              size: 10,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'OVERTIME',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 8,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: AppTextStyles.heading2.copyWith(
                  color: gradientColors[0],
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 8),
              if (isOvertime)
                Icon(
                  Iconsax.flash_1,
                  color: gradientColors[0],
                  size: 16,
                )
              else
                Text(
                  'hours',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.warning,
                      AppColors.warning.withOpacity(0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Iconsax.chart_square,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Work Summary',
                style: AppTextStyles.heading3.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        Container(
          width: double.infinity,
          
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.textSecondary.withOpacity(0.08),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 10,
              childAspectRatio: 1.1,
              
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildSummaryCard(
                  title: 'Total Hours',
                  value: data['totalHours'] != null && data['totalHours'] is num
                      ? '${data['totalHours'].toStringAsFixed(1)}'
                      : '0.0',
                  subtitle: 'hours',
                  icon: Iconsax.clock,
                  gradientColors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
                ),
                _buildSummaryCard(
                  title: 'Daily Average',
                  value: data['averageHours'] != null && data['averageHours'] is num
                      ? '${data['averageHours'].toStringAsFixed(1)}'
                      : '0.0',
                  subtitle: 'h/day',
                  icon: Iconsax.chart_21,
                  gradientColors: [AppColors.success, AppColors.success.withOpacity(0.8)],
                ),
                _buildSummaryCard(
                  title: 'Working Days',
                  value: data['workingDays'] != null && data['workingDays'] is int
                      ? '${data['workingDays']}'
                      : '0',
                  subtitle: 'days',
                  icon: Iconsax.calendar_2,
                  gradientColors: [AppColors.accent, AppColors.accent.withOpacity(0.8)],
                ),
                _buildOvertimeCard(
                  title: 'Total Overtime',
                  value: data['overtimeHours'] != null && data['overtimeHours'] is num
                      ? '${data['overtimeHours'].toStringAsFixed(1)}'
                      : '0.0',
                  icon: Iconsax.timer_1,
                  overtimeHours: data['overtimeHours'] != null && data['overtimeHours'] is num
                      ? data['overtimeHours'].toDouble()
                      : 0.0,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
