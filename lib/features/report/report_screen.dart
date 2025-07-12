import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../core/constants.dart';
import '../../providers/attendance_provider.dart';
import '../../providers/user_provider.dart';

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
        title: Text('Reports', style: AppTextStyles.bodyLarge),
        backgroundColor: AppColors.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
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
                  style: AppButtonStyles.outlinedButton,
                  child: Text('End: ${DateFormat('yyyy-MM-dd').format(_endDate)}'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text('Working Hours Report', style: AppTextStyles.heading3),
            const SizedBox(height: 16),
            Expanded(
              child: Consumer(
                builder: (context, ref, _) {
                  final workingHoursAsync = ref.watch(workingHoursStreamProvider({
                    'userId': userId,
                    'start': _startDate,
                    'end': _endDate,
                  }));
                  return workingHoursAsync.when(
                    data: (data) {
                      print('Working hours chart data: $data');
                      if (data.isEmpty) {
                        return const Center(child: Text('No working hours data available.'));
                      }
                      final allZero = data.every((d) => (d['hours'] ?? 0) == 0);
                      if (allZero) {
                        return const Center(child: Text('No working hours recorded for this range.'));
                      }
                      return SizedBox(
                        height: 300,
                        child: BarChart(
                          BarChartData(
                            alignment: BarChartAlignment.spaceAround,
                            titlesData: FlTitlesData(
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (value, _) {
                                    final idx = value.toInt();
                                    if (idx >= 0 && idx < data.length) {
                                      final date = data[idx]['date'] as DateTime;
                                      return Text(DateFormat('dd/MM').format(date), style: AppTextStyles.bodySmall);
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
                              for (int i = 0; i < data.length; i++)
                                BarChartGroupData(
                                  x: i,
                                  barRods: [
                                    BarChartRodData(
                                      toY: (data[i]['hours'] ?? 0).toDouble(),
                                      color: AppColors.primary,
                                      width: 18,
                                    ),
                                  ],
                                ),
                            ],
                            gridData: FlGridData(show: true),
                          ),
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
