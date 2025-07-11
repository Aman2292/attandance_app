import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants.dart';
import '../../models/attendance_record.dart';

final allAttendanceProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  return FirebaseFirestore.instance
      .collectionGroup('attendance')
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snapshot) => snapshot.docs.map((doc) {
            final attendance = AttendanceRecord.fromFirestore(doc);
            return {
              'attendance': attendance,
              'userId': attendance.userId,
            };
          }).toList());
});

class AttendanceOverviewScreen extends ConsumerWidget {
  const AttendanceOverviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final attendanceAsync = ref.watch(allAttendanceProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Attendance Overview', style: AppTextStyles.heading2),
        backgroundColor: AppColors.primary,
      ),
      body: attendanceAsync.when(
        data: (records) => records.isEmpty
            ? const Center(child: Text('No attendance records', style: AppTextStyles.bodyMedium))
            : ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: records.length,
                itemBuilder: (context, index) {
                  final recordData = records[index];
                  final record = recordData['attendance'] as AttendanceRecord;
                  return Card(
                    color: AppColors.background,
                    child: ListTile(
                      title: Text('${record.date.toString().substring(0, 10)} - ${record.status}'),
                      subtitle: Text('User ID: ${record.userId}\nRemarks: ${record.notes.isEmpty ? 'None' : record.notes}'),
                    ),
                  );
                },
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.error))),
      ),
    );
  }
}