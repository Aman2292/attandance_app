import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../core/constants.dart';

class SummaryCards extends StatelessWidget {
  final Map<String, dynamic> data;
  final double cardHeight;
  final double cardWidth;

  const SummaryCards({
    super.key,
    required this.data,
    this.cardHeight = 90,
    this.cardWidth = 140,
  });

  Widget _buildSummaryCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    String? subtitle,
  }) {
    return SizedBox(
      height: cardHeight,
      width: cardWidth,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.02),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withOpacity(0.1),
            width: 1.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        color.withOpacity(0.1),
                        color.withOpacity(0.05),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: color.withOpacity(0.15),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    title,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.5,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Flexible(
                  child: Text(
                    value,
                    style: AppTextStyles.heading2.copyWith(
                      color: color,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      letterSpacing: -0.5,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      subtitle,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w400,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOvertimeCard({
    required String title,
    required String value,
    required IconData icon,
    required double? overtimeHours,
  }) {
    final isValid = overtimeHours != null && overtimeHours >= 0;
    final cardColor = isValid && overtimeHours > 0 ? const Color(0xFFFF4757) : AppColors.success;
    final isOvertime = isValid && overtimeHours > 0;

    return SizedBox(
      height: cardHeight + 8, // 8px taller than other cards
      width: cardWidth,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: cardColor.withOpacity(0.02),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: cardColor.withOpacity(0.1),
            width: 1.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Column(
             
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            cardColor.withOpacity(0.1),
                            cardColor.withOpacity(0.05),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: cardColor.withOpacity(0.15),
                          width: 1,
                        ),
                      ),
                      child: Icon(
                        icon,
                        color: cardColor,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        title,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.5,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                ),
                if (isOvertime)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 1),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          cardColor.withOpacity(0.9),
                          cardColor,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Iconsax.warning_2,
                          color: Colors.white,
                          size: 6,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          'OVERTIME',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 6,
                            letterSpacing: 0.5,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 6), // Reduced from 8 to 6
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Flexible(
                  child: Text(
                    value,
                    style: AppTextStyles.heading2.copyWith(
                      color: cardColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      letterSpacing: -0.5,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                if (isOvertime)
                  Icon(
                    Iconsax.flash_1,
                    color: cardColor,
                    size: 12,
                  )
                else
                  Flexible(
                    child: Text(
                      'hours',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w400,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Debug print to verify data
    print('SummaryCards data: $data');

    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 20,
              offset: const Offset(0, 10),
              spreadRadius: 0,
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
              spreadRadius: 0,
            ),
          ],
          border: Border.all(
            color: AppColors.primary.withOpacity(0.08),
            width: 1,
          ),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primary.withOpacity(0.1),
                            AppColors.primary.withOpacity(0.05),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Iconsax.chart_square,
                        color: AppColors.primary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Flexible(
                      child: Text(
                        'Work Summary',
                        style: AppTextStyles.heading3.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: cardWidth / (cardHeight + 8), // Adjusted for tallest card
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _buildSummaryCard(
                      title: 'Total \nHours',
                      value: data['totalHours'] != null && data['totalHours'] is num
                          ? '${data['totalHours'].toStringAsFixed(1)}'
                          : '-/-',
                      subtitle: 'hours',
                      icon: Iconsax.clock,
                      color: AppColors.primary,
                    ),
                    _buildSummaryCard(
                      title: 'Daily \nAverage',
                      value: data['averageHours'] != null && data['averageHours'] is num
                          ? '${data['averageHours'].toStringAsFixed(1)}'
                          : '-/-',
                      subtitle: 'h/day',
                      icon: Iconsax.chart_21,
                      color: AppColors.success,
                    ),
                    _buildSummaryCard(
                      title: 'Working \nDays',
                      value: data['workingDays'] != null && data['workingDays'] is int
                          ? '${data['workingDays']}'
                          : '-/-',
                      subtitle: 'days',
                      icon: Iconsax.calendar_2,
                      color: AppColors.warning,
                    ),
                    _buildOvertimeCard(
                      title: 'Total \nOvertime',
                      value: data['overtimeHours'] != null && data['overtimeHours'] is num
                          ? '${data['overtimeHours'].toStringAsFixed(1)}h'
                          : '-/-',
                      icon: Iconsax.timer_1,
                      overtimeHours: data['overtimeHours'] != null && data['overtimeHours'] is num
                          ? data['overtimeHours'].toDouble()
                          : null,
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}