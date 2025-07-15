import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:iconsax/iconsax.dart';
import '../../core/constants.dart';

class WorkingHoursChart extends StatelessWidget {
  final List<Map<String, dynamic>> chartData;

  const WorkingHoursChart({super.key, required this.chartData});

  @override
  Widget build(BuildContext context) {
    if (chartData.isEmpty) {
      return Container(
        height: 430,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary.withOpacity(0.08),
                      AppColors.primary.withOpacity(0.12),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  Iconsax.chart_1,
                  size: 56,
                  color: AppColors.primary.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'No Data Available',
                style: AppTextStyles.heading3.copyWith(
                  color: const Color(0xFF1A1D29),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'No working hours recorded for this range.',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: const Color(0xFF6B7280),
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    final maxHours = chartData.map((d) => d['hours'] as double).reduce((a, b) => a > b ? a : b);
    final maxY = (maxHours * 1.15).ceilToDouble();

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Section
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary.withOpacity(0.1),
                      AppColors.primary.withOpacity(0.15),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  Iconsax.chart_21,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Daily Working Hours',
                      style: AppTextStyles.heading3.copyWith(
                        color: const Color(0xFF1A1D29),
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Track your productivity patterns',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: const Color(0xFF6B7280),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Chart Section
          SizedBox(
            height: 300,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 50,
                      getTitlesWidget: (value, _) {
                        final idx = value.toInt();
                        if (idx >= 0 && idx < chartData.length) {
                          final date = chartData[idx]['date'] as DateTime;
                          return Padding(
                            padding: const EdgeInsets.only(top: 12.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  DateFormat('dd').format(date),
                                  style: TextStyle(
                                    color: const Color(0xFF374151),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  DateFormat('MMM').format(date),
                                  style: TextStyle(
                                    color: const Color(0xFF9CA3AF),
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                        return const SizedBox();
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 60,
                      interval: maxY > 10 ? 2 : 1,
                      getTitlesWidget: (value, _) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 12.0),
                          child: Text(
                            '${value.toInt()}h',
                            style: TextStyle(
                              color: const Color(0xFF6B7280),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                gridData: FlGridData(
                  show: true,
                  drawHorizontalLine: true,
                  drawVerticalLine: false,
                  horizontalInterval: maxY > 10 ? 2 : 1,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: const Color(0xFFF3F4F6),
                      strokeWidth: 1,
                      dashArray: [5, 5],
                    );
                  },
                ),
                barGroups: [
                  for (int i = 0; i < chartData.length; i++)
                    BarChartGroupData(
                      x: i,
                      barRods: [
                        BarChartRodData(
                          toY: chartData[i]['hours'] as double,
                          gradient: LinearGradient(
                            colors: chartData[i]['isOvertime'] == true
                                ? [
                                    const Color(0xFFFF6B6B).withOpacity(0.8),
                                    const Color(0xFFFF6B6B),
                                    const Color(0xFFE63946),
                                  ]
                                : [
                                    AppColors.primary.withOpacity(0.7),
                                    AppColors.primary,
                                    AppColors.primary.withOpacity(0.9),
                                  ],
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                          ),
                          width: 10,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(5),
                            topRight: Radius.circular(5),
                          ),
                        ),
                      ],
                    ),
                ],
                maxY: maxY,
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (group) => const Color(0xFF1F2937),
                    
                    tooltipPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      if (groupIndex < chartData.length) {
                        final data = chartData[groupIndex];
                        final date = data['date'] as DateTime;
                        final hours = data['formattedHours'] as String;
                        final isOvertime = data['isOvertime'] as bool;
                        return BarTooltipItem(
                          '${DateFormat('dd MMM yyyy').format(date)}\n$hours${isOvertime ? ' (Overtime)' : ''}',
                          const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            height: 1.4,
                          ),
                        );
                      }
                      return null;
                    },
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          
          // Legend Section
          Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFFE5E7EB),
                width: 1,

              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegendItem(
                  color: AppColors.primary,
                  label: 'Regular Hours',
                ),
                const SizedBox(width: 12),
                _buildLegendItem(
                  color: const Color(0xFFFF6B6B),
                  label: 'Overtime Hours',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem({required Color color, required String label}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF374151),
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}