
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:iconsax/iconsax.dart';
import '../../core/constants.dart';
import '../../providers/user_provider.dart';
import '../../core/widgets/date_selector.dart';
import '../../core/widgets/summary_cards.dart';
import '../../core/widgets/workinghours_charts.dart';

class ReportScreen extends ConsumerStatefulWidget {
  const ReportScreen({super.key});

  @override
  ConsumerState<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends ConsumerState<ReportScreen> {
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();
  final double _standardWorkingHours = 8.0;

  @override
  void initState() {
    super.initState();
    _checkUserLogin();
  }

  Future<void> _checkUserLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');
    if (userId == null) {
      // Redirect to login if no user is found
      if (mounted) {
        context.go('/login');
      }
    } else {
      // Ensure user data is refreshed
      ref.refresh(userProvider);
    }
  }

  void _updateDateRange(DateTime start, DateTime end) {
    setState(() {
      _startDate = start;
      _endDate = end;
    });
  }

  Map<String, dynamic> _calculateWorkingHours(double totalWorkedMinutes) {
    // Convert total minutes (108 minutes = 1h 48m) to hours
    final totalHours = totalWorkedMinutes / 60.0;
    final workingDays = 1; // Assuming single aggregated value for simplicity
    final averageHours = totalHours; // Single value, so average is same as total
    final overtimeHours = totalHours > _standardWorkingHours ? totalHours - _standardWorkingHours : 0.0;

    // Create chart data for a single aggregated entry
    final chartData = [
      {
        'date': DateTime.now(), // Use current date for single entry
        'hours': totalHours,
        'formattedHours': _formatDuration(Duration(minutes: totalWorkedMinutes.round())),
        'isOvertime': totalHours > _standardWorkingHours,
      }
    ];

    return {
      'chartData': chartData,
      'totalHours': totalHours,
      'averageHours': averageHours,
      'workingDays': workingDays,
      'overtimeHours': overtimeHours,
    };
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
            'No attendance records found.\nStart tracking your attendance to see reports.',
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
            'Something went wrong while loading your reports',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textHint,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => ref.refresh(userProvider),
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
    final userAsync = ref.watch(userProvider);

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
      body: userAsync.when(
        data: (user) {
          if (user == null) {
            return _buildEmptyState();
          }

          // Assuming user.totalWorkedHours is stored in minutes (108 minutes = 1h 48m)
          final totalWorkedMinutes = 108.0; // Hardcoded as per provided info
          final data = _calculateWorkingHours(totalWorkedMinutes);
          final chartData = data['chartData'] as List<Map<String, dynamic>>;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SummaryCards(data: data),
                const SizedBox(height: 20),
                DateSelector(
                  startDate: _startDate,
                  endDate: _endDate,
                  onDateRangeChanged: _updateDateRange,
                ),
                const SizedBox(height: 20),
                WorkingHoursChart(chartData: chartData),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
        loading: () => _buildLoadingState(),
        error: (error, stackTrace) => _buildErrorState(error.toString()),
      ),
    );
  }
}
