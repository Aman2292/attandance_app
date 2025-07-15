
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:iconsax/iconsax.dart';
import '../../core/constants.dart';
import '../../models/user_model.dart';
import '../../providers/user_provider.dart';
import '../../providers/attendance_provider.dart';
import '../../services/leave_service.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  Timer? _timeUpdateTimer;
  Timer? _checkInTimer;

  @override
  void initState() {
    super.initState();
    _loadUserPreference();
    _timeUpdateTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _timeUpdateTimer?.cancel();
    _checkInTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadUserPreference() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = ref.read(authServiceProvider).currentUser?.uid;
    if (userId != null) {
      await prefs.setString('userId', userId);
      // Sync leave balance on initialization
      await ref.read(leaveServiceProvider).syncLeaveBalance(userId);
    }
  }


  void _startCheckInTimer(DateTime? checkInTime) {
    if (checkInTime != null) {
      _checkInTimer?.cancel();
      _checkInTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(userProvider);
    final userId = ref.watch(authServiceProvider).currentUser?.uid ?? '';
    final todayAttendanceAsync = ref.watch(attendanceProvider(userId));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.primary,
        title: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: Colors.white,
              child: Text(
                userAsync.valueOrNull?.name.substring(0, 1).toUpperCase() ?? '',
                style: AppTextStyles.heading2.copyWith(color: AppColors.primary),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userAsync.valueOrNull?.name ?? '',
                  style: AppTextStyles.heading2.copyWith(color: Colors.white),
                ),
                Text(
                  userAsync.valueOrNull?.role ?? '',
                  style: AppTextStyles.bodySmall.copyWith(color: Colors.white70),
                ),
              ],
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: userAsync.when(
          data: (user) {
            if (user == null) {
              context.go('/login');
              return const SizedBox();
            }

            return RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(userProvider);
                ref.invalidate(attendanceProvider(userId));
                await ref.read(leaveServiceProvider).syncLeaveBalance(userId);
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _buildCurrentTimeCard(),
                          const SizedBox(height: 20),
                          _buildAttendanceCard(todayAttendanceAsync),
                          const SizedBox(height: 20),
                          _buildLeaveBalance(user),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Iconsax.info_circle, size: 64, color: AppColors.error),
                const SizedBox(height: 16),
                Text('Something went wrong', style: AppTextStyles.heading3),
                const SizedBox(height: 8),
                Text('$e', style: AppTextStyles.bodyMedium),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    ref.invalidate(userProvider);
                  },
                  style: AppButtonStyles.primaryButton,
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentTimeCard() {
    final now = DateTime.now();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                DateFormat('EEEE').format(now),
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
              ),
              Text(
                DateFormat('dd MMM yyyy').format(now),
                style: AppTextStyles.heading3,
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                DateFormat('h:mm').format(now),
                style: AppTextStyles.heading1.copyWith(color: AppColors.primary),
              ),
              Text(
                DateFormat('a').format(now),
                style: AppTextStyles.bodySmall,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceCard(AsyncValue todayAttendanceAsync) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Icon(Iconsax.clock, color: AppColors.primary, size: 24),
                const SizedBox(width: 8),
                Text("Today's Attendance", style: AppTextStyles.heading3),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(20),
            child: todayAttendanceAsync.when(
              data: (attendance) => _buildAttendanceContent(attendance),
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (e, _) => Center(
                child: Column(
                  children: [
                    Icon(Iconsax.info_circle, color: AppColors.error, size: 32),
                    const SizedBox(height: 8),
                    Text('Error loading attendance', style: AppTextStyles.bodyMedium),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceContent(attendance) {
    if (attendance == null || attendance.checkInTime == null) {
      return Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.info.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Icon(Iconsax.clock, color: AppColors.info, size: 48),
                const SizedBox(height: 16),
                Text(
                  'Ready to Start Your Day?',
                  style: AppTextStyles.heading3.copyWith(color: AppColors.info),
                ),
                const SizedBox(height: 8),
                Text(
                  'Tap the button below to check in',
                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                context.go('/employee/attendance');
              },
              icon: const Icon(Iconsax.login, size: 24),
              label: const Text('Check In'),
              style: AppButtonStyles.primaryButton.copyWith(
                padding: MaterialStateProperty.all(const EdgeInsets.all(16)),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    context.go('/employee/attendance');
                  },
                  icon: const Icon(Iconsax.element_plus, size: 20),
                  label: const Text('Start Break'),
                  style: AppButtonStyles.secondaryButton,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    context.go('/employee/attendance');
                  },
                  icon: const Icon(Iconsax.logout, size: 20),
                  label: const Text('Check Out'),
                  style: AppButtonStyles.primaryButton,
                ),
              ),
            ],
          ),
        ],
      );
    } else if (attendance.checkOutTime != null) {
      _checkInTimer?.cancel();
      final checkOutTime = attendance.checkOutTime!;
      final checkInTime = attendance.checkInTime!;
      final workedDuration = checkOutTime.difference(checkInTime);
      final breakDuration = attendance.breakEndTime != null && attendance.breakStartTime != null
          ? attendance.breakEndTime!.difference(attendance.breakStartTime!)
          : Duration.zero;

      return Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Iconsax.check, color: AppColors.success, size: 32),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Work Completed',
                        style: AppTextStyles.heading3.copyWith(color: AppColors.success),
                      ),
                      Text(
                        'You have successfully checked out for today',
                        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildTimeInfo(
                  'Check In',
                  DateFormat('HH:mm').format(checkInTime),
                  Iconsax.login,
                  AppColors.info,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTimeInfo(
                  'Check Out',
                  DateFormat('HH:mm').format(checkOutTime),
                  Iconsax.logout,
                  AppColors.success,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildTimeInfo(
                  'Total Work',
                  '${workedDuration.inHours}h ${workedDuration.inMinutes.remainder(60)}m',
                  Iconsax.clock,
                  AppColors.primary,
                ),
              ),
              if (breakDuration.inMinutes > 0) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTimeInfo(
                    'Break Time',
                    '${breakDuration.inHours}h ${breakDuration.inMinutes.remainder(60)}m',
                    Iconsax.clock,
                    AppColors.warning,
                  ),
                ),
              ],
            ],
          ),
        ],
      );
    } else {
      _startCheckInTimer(attendance.checkInTime);
      final checkedInTime = attendance.checkInTime!;
      final now = DateTime.now();
      final workedDuration = now.difference(checkedInTime);
      final overtime = workedDuration.inMinutes > 540
          ? Duration(minutes: workedDuration.inMinutes - 540)
          : Duration.zero;

      return Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary.withOpacity(0.1), AppColors.primary.withOpacity(0.05)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Iconsax.play, color: AppColors.primary, size: 32),
                    const SizedBox(width: 12),
                    Text(
                      'Currently Working',
                      style: AppTextStyles.heading3.copyWith(color: AppColors.primary),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  '${workedDuration.inHours}h ${workedDuration.inMinutes.remainder(60)}m',
                  style: AppTextStyles.heading1.copyWith(color: AppColors.primary),
                ),
                if (overtime.inMinutes > 0) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      'Overtime: ${overtime.inHours}h ${overtime.inMinutes.remainder(60)}m',
                      style: AppTextStyles.bodySmall.copyWith(color: AppColors.warning),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildTimeInfo(
            'Checked In At',
            DateFormat('h:mm a').format(checkedInTime),
            Iconsax.login,
            AppColors.success,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    context.go('/employee/attendance');
                  },
                  icon: const Icon(Iconsax.element_plus, size: 20),
                  label: const Text('Start Break'),
                  style: AppButtonStyles.secondaryButton,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    context.go('/employee/attendance');
                  },
                  icon: const Icon(Iconsax.logout, size: 20),
                  label: const Text('Check Out'),
                  style: AppButtonStyles.primaryButton,
                ),
              ),
            ],
          ),
        ],
      );
    }
  }

  Widget _buildTimeInfo(String label, String time, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            time,
            style: AppTextStyles.heading3.copyWith(color: color),
          ),
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaveBalance(UserModel user) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Iconsax.calendar, color: AppColors.primary, size: 24),
              const SizedBox(width: 8),
              Text('Leave Balance', style: AppTextStyles.heading3),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: EnhancedSummaryBox(
                  title: 'Paid Leave',
                  count: user.leaveBalance.paidLeave,
                  icon: Iconsax.sun,
                  color: AppColors.info,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: EnhancedSummaryBox(
                  title: 'Sick Leave',
                  count: user.leaveBalance.sickLeave,
                  icon: Iconsax.health,
                  color: AppColors.error,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: EnhancedSummaryBox(
                  title: 'Earned Leave',
                  count: user.leaveBalance.earnedLeave,
                  icon: Iconsax.star,
                  color: AppColors.success,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class EnhancedSummaryBox extends StatelessWidget {
  final String title;
  final int count;
  final IconData icon;
  final Color color;

  const EnhancedSummaryBox({
    super.key,
    required this.title,
    required this.count,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            '$count',
            style: AppTextStyles.heading2.copyWith(color: color),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
