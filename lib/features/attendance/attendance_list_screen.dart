import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/constants.dart';
import '../../providers/attendance_provider.dart';
import '../../providers/user_provider.dart';

class AttendanceListScreen extends ConsumerWidget {
  const AttendanceListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = ref.watch(authServiceProvider).currentUser?.uid ?? '';
    final attendanceRecords = ref.watch(attendanceProvider(userId));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Attendance History'),
        backgroundColor: AppColors.secondary,
      ),
      body: attendanceRecords.when(
        data: (records) {
          if (records == null ) {
            return const Center(child: Text('No attendance records found'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            
            itemBuilder: (context, index) {
              final record = records;
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  title: Text(
                    DateFormat('dd MMM yyyy').format(record.date),
                    style: AppTextStyles.heading3,
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Status: ${record.status}',
                          style: AppTextStyles.bodySmall),
                      if (record.checkInTime != null)
                        Text(
                            'Check-in: ${DateFormat('HH:mm').format(record.checkInTime!)}',
                            style: AppTextStyles.bodySmall),
                      if (record.checkOutTime != null)
                        Text(
                            'Checkout: ${DateFormat('HH:mm').format(record.checkOutTime!)}',
                            style: AppTextStyles.bodySmall),
                      if (record.breakStartTime != null)
                        Text(
                            'Break Start: ${DateFormat('HH:mm').format(record.breakStartTime!)}',
                            style: AppTextStyles.bodySmall),
                      if (record.breakEndTime != null)
                        Text(
                            'Break End: ${DateFormat('HH:mm').format(record.breakEndTime!)}',
                            style: AppTextStyles.bodySmall),
                      if (record.totalBreakDuration > 0)
                        Text(
                            'Break Duration: ${record.totalBreakDuration ~/ 60} min',
                            style: AppTextStyles.bodySmall),
                      if (record.notes.isNotEmpty)
                        Text('Notes: ${record.notes}',
                            style: AppTextStyles.bodySmall),
                      if (record.isLate)
                        Text('Late: Yes',
                            style: AppTextStyles.bodySmall.copyWith(color: AppColors.late)),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Text('Error: $e',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.error)),
        ),
      ),
    );
  }
}