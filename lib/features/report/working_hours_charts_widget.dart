import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:iconsax/iconsax.dart';
import '../../core/constants.dart';

class WorkingHoursChart extends StatelessWidget {
  final List<Map<String, dynamic>> chartData;
  final double standardWorkingHours;

  const WorkingHoursChart({
    super.key,
    required this.chartData,
    this.standardWorkingHours = 8.0,
  });

  @override
  Widget build(BuildContext context) {
    if (chartData.isEmpty) {
      return _buildEmptyState();
    }

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
                      AppColors.accent,
                      AppColors.accent.withOpacity(0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Iconsax.chart_21,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Daily Working Hours',
                  style: AppTextStyles.heading3.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
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
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Track your productivity patterns',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 20),
                // Fixed height container for the chart
                SizedBox(
                  height: 280,
                  child: _buildChart(),
                ),
                const SizedBox(height: 20),
                _buildLegend(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
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
                      AppColors.accent,
                      AppColors.accent.withOpacity(0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Iconsax.chart_1,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Working Hours Chart',
                  style: AppTextStyles.heading3.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
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
            padding: const EdgeInsets.all(40),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.accent.withOpacity(0.1),
                        AppColors.accent.withOpacity(0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Icon(
                    Iconsax.chart_1,
                    size: 48,
                    color: AppColors.accent.withOpacity(0.5),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'No Data Available',
                  style: AppTextStyles.heading3.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'No working hours recorded for this range.',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChart() {
    if (chartData.isEmpty) {
      return Center(
        child: Text(
          'No data to display',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      );
    }

    final maxHours = chartData.fold<double>(standardWorkingHours, (max, data) {
      final workingHours = (data['hours'] as num?)?.toDouble() ?? 0.0;
      final breakHours = (data['breakHours'] as num?)?.toDouble() ?? 0.0;
      final totalHours = workingHours + breakHours;
      return totalHours > max ? totalHours : max;
    });
    
    final maxY = (maxHours * 1.2).ceilToDouble();

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, _) {
                final idx = value.toInt();
                if (idx >= 0 && idx < chartData.length) {
                  final date = chartData[idx]['date'] as DateTime;
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          DateFormat('dd').format(date),
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                            fontSize: 10,
                          ),
                        ),
                        Text(
                          DateFormat('MMM').format(date),
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                            fontSize: 8,
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
              reservedSize: 40,
              interval: maxY > 10 ? 2 : 1,
              getTitlesWidget: (value, _) {
                return Text(
                  '${value.toInt()}h',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 10,
                  ),
                );
              },
            ),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        gridData: FlGridData(
          show: true,
          drawHorizontalLine: true,
          drawVerticalLine: false,
          horizontalInterval: maxY > 10 ? 2 : 1,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: AppColors.textSecondary.withOpacity(0.1),
              strokeWidth: 1,
              dashArray: [5, 5],
            );
          },
        ),
        barGroups: _buildBarGroups(),
        maxY: maxY,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (group) => AppColors.surface,
            tooltipPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              if (groupIndex < chartData.length) {
                final data = chartData[groupIndex];
                final date = data['date'] as DateTime;
                final workingHours = (data['hours'] as num?)?.toDouble() ?? 0.0;
                final breakHours = (data['breakHours'] as num?)?.toDouble() ?? 0.0;
                final regularHours = workingHours <= standardWorkingHours ? workingHours : standardWorkingHours;
                final overtimeHours = workingHours > standardWorkingHours ? (workingHours - standardWorkingHours) : 0.0;
                
                String barType = '';
                double barValue = 0;
                
                switch (rodIndex) {
                  case 0:
                    barType = 'Regular \nHours';
                    barValue = regularHours;
                    break;
                  case 1:
                    barType = 'Overtime';
                    barValue = overtimeHours;
                    break;
                  case 2:
                    barType = 'Break \nTime';
                    barValue = breakHours;
                    break;
                }
                
                return BarTooltipItem(
                  '${DateFormat('dd MMM').format(date)}\n$barType: ${_formatHours(barValue)}',
                  const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    height: 1.2,
                  ),
                );
              }
              return null;
            },
          ),
        ),
      ),
    );
  }

  List<BarChartGroupData> _buildBarGroups() {
    return List.generate(chartData.length, (index) {
      final data = chartData[index];
      final workingHours = (data['hours'] as num?)?.toDouble() ?? 0.0;
      final breakHours = (data['breakHours'] as num?)?.toDouble() ?? 0.0;
      
      final regularHours = workingHours <= standardWorkingHours ? workingHours : standardWorkingHours;
      final overtimeHours = workingHours > standardWorkingHours ? (workingHours - standardWorkingHours) : 0.0;
      
      const barWidth = 8.0;
      const spacing = 2.0;
      
      return BarChartGroupData(
        x: index,
        barsSpace: spacing,
        barRods: [
          // Regular hours bar
          BarChartRodData(
            toY: regularHours,
            color: AppColors.primary,
            width: barWidth,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(4),
            ),
          ),
          // Overtime bar
          BarChartRodData(
            toY: overtimeHours,
            color: AppColors.error,
            width: barWidth,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(4),
            ),
          ),
          // Break time bar
          BarChartRodData(
            toY: breakHours,
            color: AppColors.warning,
            width: barWidth,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(4),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildLegend() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildLegendItem(
            color: AppColors.primary,
            label: 'Regular \nHours',
          ),
          _buildLegendItem(
            color: AppColors.error,
            label: 'Overtime \nHours',
          ),
          _buildLegendItem(
            color: AppColors.warning,
            label: 'Break \nTime',
          ),
        ],
      ),
    );
  }

  String _formatHours(double hours) {
    final totalMinutes = (hours * 60).round();
    final h = totalMinutes ~/ 60;
    final m = totalMinutes % 60;
    
    if (h == 0) {
      return '${m}m';
    } else if (m == 0) {
      return '${h}h';
    } else {
      return '${h}h ${m}m';
    }
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
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
