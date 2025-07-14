import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import '../../core/constants.dart';
import '../../models/attendance_record.dart';
import 'widgets/attendance_summary_header.dart';
import 'widgets/attendance_card.dart';

final allAttendanceProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  return FirebaseFirestore.instance
      .collectionGroup('attendance')
      .orderBy('createdAt', descending: true)
      .snapshots()
      .asyncMap((snapshot) async {
        List<Map<String, dynamic>> result = [];
        for (var doc in snapshot.docs) {
          final attendance = AttendanceRecord.fromFirestore(doc);
          String userName = 'Unknown';
          try {
            final userDoc = await FirebaseFirestore.instance
                .collection('users')
                .doc(attendance.userId)
                .get();
            if (userDoc.exists) {
              final userData = userDoc.data();
              if (userData != null && userData.containsKey('name')) {
                userName = userData['name'] as String;
              }
            }
          } catch (e) {
            debugPrint('Error fetching user name for userId ${attendance.userId}: $e');
          }
          result.add({
            'attendance': attendance,
            'userName': userName,
          });
        }
        return result;
      });
});

class AttendanceOverviewScreen extends ConsumerWidget {
  const AttendanceOverviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final attendanceAsync = ref.watch(allAttendanceProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Attendance Overview', style: AppTextStyles.heading2.copyWith(color: Colors.white)),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Iconsax.export, color: Colors.white),
            onPressed: () {
              // Add export functionality
            },
          ),
        ],
      ),
      body: attendanceAsync.when(
        data: (records) => records.isEmpty
            ? _buildEmptyState()
            : Column(
                children: [
                  AttendanceSummaryHeader(records: records),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16.0),
                      itemCount: records.length,
                      itemBuilder: (context, index) {
                        final recordData = records[index];
                        final record = recordData['attendance'] as AttendanceRecord;
                        final userName = recordData['userName'] as String? ?? 'Unknown User';
                        return AttendanceCard(record: record, userName: userName);
                      },
                    ),
                  ),
                ],
              ),
        loading: () => _buildLoadingState(),
        error: (e, stackTrace) {
          debugPrint('AttendanceOverview Error: $e');
          debugPrint('AttendanceOverview StackTrace: $stackTrace');
          return _buildErrorState(e.toString());
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Iconsax.calendar_remove,
            size: 80,
            color: AppColors.textHint,
          ),
          const SizedBox(height: 16),
          Text(
            'No Attendance Records',
            style: AppTextStyles.heading3.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Attendance records will appear here once employees start checking in.',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textHint,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
          SizedBox(height: 16),
          Text('Loading attendance records...'),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Iconsax.warning_2,
            size: 80,
            color: AppColors.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Something went wrong',
            style: AppTextStyles.heading3.copyWith(
              color: AppColors.error,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              // Add retry functionality
            },
            icon: const Icon(Iconsax.refresh),
            label: const Text('Retry'),
            style: AppButtonStyles.primaryButton,
          ),
        ],
      ),
    );
  }
}