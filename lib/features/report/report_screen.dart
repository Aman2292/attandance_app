import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/constants.dart';

class ReportScreen extends StatelessWidget {
  const ReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Attendance Report', style: AppTextStyles.heading2),
        backgroundColor: AppColors.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Total Hours Worked', style: AppTextStyles.heading3),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  titlesData: FlTitlesData(show: false),
                  borderData: FlBorderData(show: false),
                  barGroups: [
                    BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: 40, color: AppColors.primary)]),
                    BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: 35, color: AppColors.primary)]),
                    BarChartGroupData(x: 3, barRods: [BarChartRodData(toY: 45, color: AppColors.primary)]),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text('Late Logins', style: AppTextStyles.heading3),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: [
                    PieChartSectionData(value: 5, color: AppColors.late, title: 'Late'),
                    PieChartSectionData(value: 20, color: AppColors.present, title: 'On Time'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}