import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../core/constants.dart';
import '../../providers/attendance_provider.dart';
import '../../providers/user_provider.dart';
// import '../../services/auth_service.dart';

class ReportScreen extends ConsumerStatefulWidget {
  const ReportScreen({super.key});

  @override
  ConsumerState<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends ConsumerState<ReportScreen> {
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? _startDate : _endDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {

    final userId = ref.watch(authServiceProvider).currentUser?.uid ?? '';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title:  Text('Reports', style: AppTextStyles.heading2),
        backgroundColor: AppColors.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () => _selectDate(context, true),
                  style: AppButtonStyles.outlinedButton,
                  child: Text('Start: ${DateFormat('yyyy-MM-dd').format(_startDate)}'),
                ),
                ElevatedButton(
                  onPressed: () => _selectDate(context, false),
                  style: AppButtonStyles.outlinedButton ,
                  child: Text('End: ${DateFormat('yyyy-MM-dd').format(_endDate)}'),
                ),
              ],
            ),
            const SizedBox(height: 24),
             Text('Attendance Report', style: AppTextStyles.heading3),
            const SizedBox(height: 16),
            Expanded(
              child: Consumer(
                builder: (context, ref, _) {
                  final summary = ref.watch(attendanceSummaryStreamProvider({
                    'userId': userId,
                    'start': _startDate,
                    'end': _endDate,
                  }));
                  return summary.when(
                    data: (data) {
                      final double present = data['present']?.toDouble() ?? 0;
                      final double absent = data['absent']?.toDouble() ?? 0;
                      final double late = data['late']?.toDouble() ?? 0;
                      return BarChart(
                        BarChartData(
                          alignment: BarChartAlignment.spaceAround,
                          titlesData: FlTitlesData(
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, _) {
                                  switch (value.toInt()) {
                                    case 0:
                                      return Text('Present', style: AppTextStyles.bodySmall);
                                    case 1:
                                      return Text('Absent', style: AppTextStyles.bodySmall);
                                    case 2:
                                      return Text('Late', style: AppTextStyles.bodySmall);
                                  }
                                  return const SizedBox();
                                },
                              ),
                            ),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: true, reservedSize: 40),
                            ),
                            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          ),
                          borderData: FlBorderData(show: false),
                          barGroups: [
                            BarChartGroupData(
                              x: 0,
                              barRods: [
                                BarChartRodData(toY: present, color: AppColors.present, width: 22),
                              ],
                            ),
                            BarChartGroupData(
                              x: 1,
                              barRods: [
                                BarChartRodData(toY: absent, color: AppColors.absent, width: 22),
                              ],
                            ),
                            BarChartGroupData(
                              x: 2,
                              barRods: [
                                BarChartRodData(toY: late, color: AppColors.late, width: 22),
                              ],
                            ),
                          ],
                          gridData: FlGridData(show: true),
                        ),
                      );
                    },
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Text('Error: $e', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.error)),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
