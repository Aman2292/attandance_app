import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:iconsax/iconsax.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/constants.dart';
import '../../core/widgets/workinghours_charts.dart';
import '../../core/widgets/date_selector.dart';
import '../../core/widgets/summary_cards.dart';
import '../../core/widgets/today_report_card.dart'; // Import the new widget

class ReportScreen extends ConsumerStatefulWidget {
  const ReportScreen({super.key});

  @override
  ConsumerState<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends ConsumerState<ReportScreen> {
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();
  final double _standardWorkingHours = 8.0;
  String? _userId;
  List<DateTime>? _availableDates;

  @override
  void initState() {
    super.initState();
    _checkUserLogin();
  }

  Future<void> _checkUserLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');
    if (userId == null) {
      if (mounted) {
        context.go('/login');
      }
    } else {
      setState(() {
        _userId = userId;
      });
      await _fetchAvailableDates(userId);
    }
  }

  Future<void> _fetchAvailableDates(String userId) async {
    if (userId.isEmpty) return;
    final querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('attendance')
        .get();
    final dates = querySnapshot.docs.map((doc) {
      final dateStr = doc.data()['date'] as String;
      return DateTime.parse(dateStr);
    }).toSet().toList();
    if (dates.isNotEmpty) {
      dates.sort((a, b) => a.compareTo(b));
      setState(() {
        _availableDates = dates;
        _startDate = dates.first;
        _endDate = dates.last;
      });
    }
  }

  void _updateDateRange(DateTime start, DateTime end) {
    setState(() {
      _startDate = start;
      _endDate = end;
    });
  }

  Future<Map<String, dynamic>> _fetchTodayAttendance(String userId) async {
    if (userId.isEmpty) {
      return {
        'isCheckedIn': false,
        'checkInTime': null,
        'checkOutTime': null,
        'totalBreakDuration': 0,
        'currentWorkingHours': 0.0,
        'status': 'Not Started',
        'isOnBreak': false,
      };
    }

    try {
      final today = DateTime.now();
      final todayStr = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
      
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('attendance')
          .where('date', isGreaterThanOrEqualTo: todayStr)
          .where('date', isLessThan: '${todayStr}T23:59:59')
          .get();

      if (querySnapshot.docs.isEmpty) {
        return {
          'isCheckedIn': false,
          'checkInTime': null,
          'checkOutTime': null,
          'totalBreakDuration': 0,
          'currentWorkingHours': 0.0,
          'status': 'Not Started',
          'isOnBreak': false,
        };
      }

      final doc = querySnapshot.docs.first;
      final data = doc.data();
      
      final checkInTime = (data['checkInTime'] as Timestamp?)?.toDate();
      final checkOutTime = (data['checkOutTime'] as Timestamp?)?.toDate();
      final totalBreakDuration = (data['totalBreakDuration'] ?? 0) as num;
      final breakStartTime = (data['breakStartTime'] as Timestamp?)?.toDate();
      final breakEndTime = (data['breakEndTime'] as Timestamp?)?.toDate();
      
      final isOnBreak = breakStartTime != null && breakEndTime == null;
      final isCheckedIn = checkInTime != null && checkOutTime == null;
      
      double currentWorkingHours = 0.0;
      String status = 'Not Started';
      
      if (checkInTime != null) {
        final endTime = checkOutTime ?? DateTime.now();
        final totalMinutes = endTime.difference(checkInTime).inMinutes;
        final breakMinutes = totalBreakDuration.toInt();
        final workedMinutes = totalMinutes - breakMinutes;
        currentWorkingHours = workedMinutes / 60.0;
        
        if (checkOutTime != null) {
          status = 'Completed';
        } else if (isOnBreak) {
          status = 'On Break';
        } else {
          status = 'Working';
        }
      }
      
      return {
        'isCheckedIn': isCheckedIn,
        'checkInTime': checkInTime,
        'checkOutTime': checkOutTime,
        'totalBreakDuration': totalBreakDuration.toInt(),
        'currentWorkingHours': currentWorkingHours,
        'status': status,
        'isOnBreak': isOnBreak,
      };
    } catch (e) {
      print('Error fetching today\'s attendance: $e');
      return {
        'isCheckedIn': false,
        'checkInTime': null,
        'checkOutTime': null,
        'totalBreakDuration': 0,
        'currentWorkingHours': 0.0,
        'status': 'Error',
        'isOnBreak': false,
      };
    }
  }

  Future<Map<String, dynamic>> _fetchAttendanceData(String userId) async {
    if (userId.isEmpty) {
      return {
        'chartData': [],
        'totalHours': 0.0,
        'averageHours': 0.0,
        'workingDays': 0,
        'overtimeHours': 0.0,
      };
    }

    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('attendance')
          .get();

      print('Total documents found: ${querySnapshot.docs.length}');

      final attendanceRecords = <Map<String, dynamic>>[];

      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        print('Processing document: ${doc.id}');
        print('Document data: $data');
        
        final dateStr = data['date'] as String?;
        if (dateStr == null) {
          print('No date field found in document ${doc.id}');
          continue;
        }
        
        DateTime recordDate;
        try {
          recordDate = DateTime.parse(dateStr);
        } catch (e) {
          print('Error parsing date $dateStr: $e');
          continue;
        }

        if (recordDate.isBefore(_startDate) || recordDate.isAfter(_endDate.add(const Duration(days: 1)))) {
          continue;
        }

        final checkInTime = (data['checkInTime'] as Timestamp?)?.toDate();
        final checkOutTime = (data['checkOutTime'] as Timestamp?)?.toDate();
        final totalBreakDuration = (data['totalBreakDuration'] ?? 0) as num;

        if (checkInTime == null) {
          print('No check-in time found for document ${doc.id}');
          continue;
        }

        DateTime endTime = checkOutTime ?? DateTime.now();
        int totalMinutes = endTime.difference(checkInTime).inMinutes;
        int breakMinutes = totalBreakDuration.toInt();
        int workedMinutes = totalMinutes - breakMinutes;

        if (workedMinutes < 0) workedMinutes = 0;

        final hours = workedMinutes / 60.0;
        final isOvertime = hours > _standardWorkingHours;
        
        attendanceRecords.add({
          'date': recordDate,
          'hours': hours,
          'formattedHours': _formatDuration(Duration(minutes: workedMinutes)),
          'isOvertime': isOvertime,
        });
      }

      print('Filtered attendance records: ${attendanceRecords.length}');

      attendanceRecords.sort((a, b) => (a['date'] as DateTime).compareTo(b['date'] as DateTime));

      final totalWorkedMinutes = attendanceRecords.fold(0.0, (sum, record) => sum + (record['hours'] as double) * 60);
      final workingDays = attendanceRecords.length;
      final averageHours = workingDays > 0 ? totalWorkedMinutes / 60.0 / workingDays : 0.0;
      final totalHours = totalWorkedMinutes / 60.0;
      final expectedHours = _standardWorkingHours * workingDays;
      final overtimeHours = totalHours > expectedHours ? (totalHours - expectedHours) : 0.0;

      return {
        'chartData': attendanceRecords,
        'totalHours': totalHours,
        'averageHours': averageHours,
        'workingDays': workingDays,
        'overtimeHours': overtimeHours,
      };
    } catch (e) {
      print('Error fetching attendance data: $e');
      rethrow;
    }
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    return '${hours}h ${minutes}m';
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: AppColors.textHint.withOpacity(0.1),
              borderRadius: BorderRadius.circular(60),
            ),
            child: Icon(
              Iconsax.document,
              size: 60,
              color: AppColors.textHint,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No Attendance Data',
            style: AppTextStyles.heading3.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'No attendance records found for the selected date range.\nTry selecting a different date range.',
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
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(50),
            ),
            child: CircularProgressIndicator(
              color: AppColors.primary,
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Loading Reports...',
            style: AppTextStyles.heading3.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Please wait while we fetch your attendance data',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textHint,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.error.withOpacity(0.1),
              borderRadius: BorderRadius.circular(50),
            ),
            child: Icon(
              Iconsax.warning_2,
              size: 60,
              color: AppColors.error,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Error Loading Data',
            style: AppTextStyles.heading3.copyWith(
              color: AppColors.error,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Something went wrong while loading your reports\n$error',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textHint,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => setState(() {}),
            icon: Icon(Iconsax.refresh),
            label: const Text('Try Again'),
            style: AppButtonStyles.primaryButton,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Reports',
          style: AppTextStyles.heading3.copyWith(
            color: AppColors.surface,
          ),
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
        centerTitle: false,
      ),
      body: _userId == null
          ? _buildLoadingState()
          : FutureBuilder<List<Map<String, dynamic>>>(
              future: Future.wait([
                _fetchTodayAttendance(_userId!),
                _fetchAttendanceData(_userId!),
              ]),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return _buildLoadingState();
                }
                if (snapshot.hasError) {
                  return _buildErrorState(snapshot.error?.toString() ?? 'Unknown error');
                }
                if (!snapshot.hasData) {
                  return _buildEmptyState();
                }

                
                final reportData = snapshot.data![1];
                final chartData = reportData['chartData'] as List<Map<String, dynamic>>;

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // TodayReportCard(todayData: todayData), // Use the new widget
                      SummaryCards(data: reportData),
                      const SizedBox(height: 20),
                      DateSelector(
                        startDate: _startDate,
                        endDate: _endDate,
                        onDateRangeChanged: _updateDateRange,
                        availableDates: _availableDates,
                      ),
                      const SizedBox(height: 20),
                      if (chartData.isNotEmpty) ...[
                        WorkingHoursChart(chartData: chartData),
                        const SizedBox(height: 20),
                      ] else ...[
                        Container(
                          padding: const EdgeInsets.all(40),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Iconsax.chart,
                                size: 48,
                                color: AppColors.textHint,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No Chart Data',
                                style: AppTextStyles.heading3.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'No attendance data available for the selected date range.',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.textHint,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ],
                  ),
                );
              },
            ),
    );
  }
}