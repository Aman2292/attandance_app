import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:iconsax/iconsax.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants.dart';
import 'working_hours_charts_widget.dart';
import 'date_selector_widget.dart';
import 'summary_cards_widget.dart';

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
    try {
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
        if (mounted) {
          setState(() {
            _availableDates = dates;
            _startDate = dates.first;
            _endDate = dates.last;
          });
        }
      }
    } catch (e) {
      debugPrint('Error fetching available dates: $e');
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
      debugPrint('Error fetching today\'s attendance: $e');
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

      final attendanceRecords = <Map<String, dynamic>>[];

      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        
        final dateStr = data['date'] as String?;
        if (dateStr == null) continue;
        
        DateTime recordDate;
        try {
          recordDate = DateTime.parse(dateStr);
        } catch (e) {
          continue;
        }

        if (recordDate.isBefore(_startDate) || recordDate.isAfter(_endDate.add(const Duration(days: 1)))) {
          continue;
        }

        final checkInTime = (data['checkInTime'] as Timestamp?)?.toDate();
        final checkOutTime = (data['checkOutTime'] as Timestamp?)?.toDate();
        final totalBreakDuration = (data['totalBreakDuration'] ?? 0) as num;

        if (checkInTime == null) continue;

        DateTime endTime = checkOutTime ?? DateTime.now();
        int totalMinutes = endTime.difference(checkInTime).inMinutes;
        int breakMinutes = totalBreakDuration.toInt();
        int workedMinutes = totalMinutes - breakMinutes;

        if (workedMinutes < 0) workedMinutes = 0;

        final workingHours = workedMinutes / 60.0;
        final breakHours = breakMinutes / 60.0;
        final isOvertime = workingHours > _standardWorkingHours;
        
        final regularHours = workingHours <= _standardWorkingHours ? workingHours : _standardWorkingHours;
        final overtimeHours = workingHours > _standardWorkingHours ? (workingHours - _standardWorkingHours) : 0.0;
        
        attendanceRecords.add({
          'date': recordDate,
          'hours': workingHours,
          'breakHours': breakHours,
          'regularHours': regularHours,
          'overtimeHours': overtimeHours,
          'formattedHours': _formatDuration(Duration(minutes: workedMinutes)),
          'formattedBreakHours': _formatDuration(Duration(minutes: breakMinutes)),
          'isOvertime': isOvertime,
          'totalMinutes': totalMinutes,
          'workedMinutes': workedMinutes,
          'breakMinutes': breakMinutes,
        });
      }

      attendanceRecords.sort((a, b) => (a['date'] as DateTime).compareTo(b['date'] as DateTime));

      final totalWorkedMinutes = attendanceRecords.fold(0.0, (sum, record) => sum + (record['hours'] as double) * 60);
      final totalBreakMinutes = attendanceRecords.fold(0.0, (sum, record) => sum + (record['breakHours'] as double) * 60);
      final workingDays = attendanceRecords.length;
      final averageHours = workingDays > 0 ? totalWorkedMinutes / 60.0 / workingDays : 0.0;
      final totalHours = totalWorkedMinutes / 60.0;
      final totalBreakHours = totalBreakMinutes / 60.0;
      final expectedHours = _standardWorkingHours * workingDays;
      final overtimeHours = totalHours > expectedHours ? (totalHours - expectedHours) : 0.0;

      return {
        'chartData': attendanceRecords,
        'totalHours': totalHours,
        'totalBreakHours': totalBreakHours,
        'averageHours': averageHours,
        'workingDays': workingDays,
        'overtimeHours': overtimeHours,
      };
    } catch (e) {
      debugPrint('Error fetching attendance data: $e');
      rethrow;
    }
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    
    if (hours == 0) {
      return '${minutes}m';
    } else if (minutes == 0) {
      return '${hours}h';
    } else {
      return '${hours}h ${minutes}m';
    }
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: AppColors.background,
    body: CustomScrollView(
      slivers: [
        _buildSliverAppBar(),
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: _userId == null
              ? SliverFillRemaining(
                  child: _buildNotLoggedInState(),
                )
              : SliverToBoxAdapter(
                  child: _buildReportContent(),
                ),
        ),
      ],
    ),
  );
}

Widget _buildSliverAppBar() {
  return SliverAppBar(
    expandedHeight: 100, // Increased for better shrinking effect
    floating: true,
    pinned: true,
    snap: true, 
    elevation: 0,
    backgroundColor: Colors.transparent,
    actions: [
      IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.surface.withOpacity(0.4),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Iconsax.refresh,
            color: Colors.white,
            size: 20,
          ),
        ),
        onPressed: () => setState(() {}),
      ),
      IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.surface.withOpacity(0.4),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Iconsax.document_download,
            color: Colors.white,
            size: 20,
          ),
        ),
        onPressed: () {
          // TODO: Implement export functionality
        },
      ),
      const SizedBox(width: 8),
    ],
    flexibleSpace: FlexibleSpaceBar(
      title: Text(
        'Reports',
        style: AppTextStyles.heading2.copyWith(
          color: AppColors.surface,
          fontWeight: FontWeight.w600,
        ),
      ),
      centerTitle: false,
      titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
      collapseMode: CollapseMode.parallax, // Added for better collapse effect
      background: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.warning,
              AppColors.warning.withOpacity(0.8),
              AppColors.primary.withOpacity(0.6),
              AppColors.accent.withOpacity(0.4),
            ],
          ),
        ),
      ),
    ),
  );
}

Widget _buildReportContent() {
  return FutureBuilder<List<Map<String, dynamic>>>(
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

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SummaryCards(data: reportData),
          const SizedBox(height: 24),
          DateSelector(
            startDate: _startDate,
            endDate: _endDate,
            onDateRangeChanged: _updateDateRange,
            availableDates: _availableDates,
          ),
          const SizedBox(height: 24),
          if (chartData.isNotEmpty) ...[
            WorkingHoursChart(chartData: chartData),
            const SizedBox(height: 24),
          ] else
            _buildNoChartDataState(),
        ],
      );
    },
  );
}


  Widget _buildNotLoggedInState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.error,
                  AppColors.error.withOpacity(0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(50),
            ),
            child: Icon(
              Iconsax.user,
              size: 48,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Authentication Required',
            style: AppTextStyles.heading3.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Please log in to view your reports',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
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
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.warning,
                  AppColors.warning.withOpacity(0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(30),
            ),
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Loading Reports...',
            style: AppTextStyles.heading3.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Please wait while we fetch your attendance data',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
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
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.error,
                  AppColors.error.withOpacity(0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Iconsax.warning_2,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Error Loading Data',
            style: AppTextStyles.heading3.copyWith(
              color: AppColors.error,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Something went wrong while loading your reports',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => setState(() {}),
            icon: const Icon(Iconsax.refresh, size: 18),
            label: const Text('Try Again'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.warning.withOpacity(0.1),
                  AppColors.warning.withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(50),
            ),
            child: Icon(
              Iconsax.document,
              size: 48,
              color: AppColors.warning.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No Attendance Data',
            style: AppTextStyles.heading3.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'No attendance records found for the selected date range.\nTry selecting a different date range.',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNoChartDataState() {
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
                      AppColors.warning,
                      AppColors.warning.withOpacity(0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Iconsax.chart,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Working Hours Chart',
                style: AppTextStyles.heading3.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
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
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Iconsax.chart,
                  size: 48,
                  color: AppColors.textSecondary.withOpacity(0.5),
                ),
                const SizedBox(height: 16),
                Text(
                  'No Chart Data',
                  style: AppTextStyles.heading3.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'No attendance data available for the selected date range.',
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
}
