import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:iconsax/iconsax.dart';
import '../../core/constants.dart';
import '../../providers/attendance_provider.dart';

class AttendanceWidget extends ConsumerStatefulWidget {
  final String userId;

  const AttendanceWidget({super.key, required this.userId});

  @override
  ConsumerState<AttendanceWidget> createState() => _AttendanceWidgetState();
}

class _AttendanceWidgetState extends ConsumerState<AttendanceWidget> with TickerProviderStateMixin {
  Timer? _checkInTimer;
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _fadeController.forward();
    _scaleController.forward();
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _checkInTimer?.cancel();
    _fadeController.dispose();
    _scaleController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _startCheckInTimer(DateTime? checkInTime) {
    if (checkInTime != null) {
      _checkInTimer?.cancel();
      _checkInTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {});
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final todayAttendanceAsync = ref.watch(attendanceProvider(widget.userId));

    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header outside the container
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 12),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary,
                          AppColors.primary.withOpacity(0.8),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Iconsax.clock,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    "Today's Attendance",
                    style: AppTextStyles.heading3.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            // Main content container
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
                padding: const EdgeInsets.all(16),
                child: todayAttendanceAsync.when(
                  data: (attendance) => _buildAttendanceContent(attendance),
                  loading: () => _buildAttendanceLoader(),
                  error: (e, _) => _buildAttendanceError(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttendanceLoader() {
    return SizedBox(
      height: 150,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary,
                    AppColors.primary.withOpacity(0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(30),
              ),
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                strokeWidth: 3,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Loading attendance...',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttendanceError() {
    return SizedBox(
      height: 150,
      child: Center(
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
            const SizedBox(height: 16),
            Text(
              'Error loading attendance',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => ref.invalidate(attendanceProvider(widget.userId)),
              icon: const Icon(Iconsax.refresh, size: 18),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttendanceContent(attendance) {
    if (attendance == null || attendance.checkInTime == null) {
      return _buildCheckInPrompt();
    } else if (attendance.checkOutTime != null) {
      return _buildCompletedWork(attendance);
    } else {
      return _buildActiveWork(attendance);
    }
  }

  Widget _buildCheckInPrompt() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.accent.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _pulseAnimation.value,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.surface,
                            AppColors.surface.withOpacity(0.8),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Icon(
                        Iconsax.sun_1,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              Text(
                'Ready to Start Your Day?',
                style: AppTextStyles.heading3.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Tap the button below to check in and begin your work session',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        _buildAnimatedButton(
          onPressed: () => context.go('/employee/attendance'),
          icon: Iconsax.login,
          label: 'Check In',
          gradientColors: [const Color.fromARGB(255, 197, 145, 81), const Color.fromARGB(255, 158, 118, 69).withOpacity(0.8)],
        ),
      ],
    );
  }

  Widget _buildCompletedWork(attendance) {
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
            color: AppColors.success.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.success,
                      AppColors.success.withOpacity(0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Iconsax.tick_circle,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Work Completed',
                      style: AppTextStyles.heading3.copyWith(
                        color: AppColors.success,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'You have checked out for today',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
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
                DateFormat('h:mm a').format(checkInTime),
                Iconsax.login,
                [AppColors.accent, AppColors.accent.withOpacity(0.8)],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildTimeInfo(
                'Check Out',
                DateFormat('h:mm a').format(checkOutTime),
                Iconsax.logout,
                [AppColors.success, AppColors.success.withOpacity(0.8)],
              ),
            ),
          ],
        ),
        if (breakDuration.inMinutes > 0) ...[
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildTimeInfo(
                  'Total Work',
                  '${workedDuration.inHours}h ${workedDuration.inMinutes.remainder(60)}m',
                  Iconsax.clock,
                  [AppColors.primary, AppColors.primary.withOpacity(0.8)],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTimeInfo(
                  'Break Time',
                  '${breakDuration.inHours}h ${breakDuration.inMinutes.remainder(60)}m',
                  Iconsax.coffee,
                  [AppColors.warning, AppColors.warning.withOpacity(0.8)],
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildActiveWork(attendance) {
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
            color: AppColors.accent.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _pulseAnimation.value,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.accent,
                            AppColors.accent.withOpacity(0.8),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Icon(
                        Iconsax.play,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              Text(
                'Currently Working',
                style: AppTextStyles.heading3.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${workedDuration.inHours}h ${workedDuration.inMinutes.remainder(60)}m',
                style: AppTextStyles.heading1.copyWith(
                  color: AppColors.accent,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (overtime.inMinutes > 0) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.warning,
                        AppColors.warning.withOpacity(0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Overtime: ${overtime.inHours}h ${overtime.inMinutes.remainder(60)}m',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 16),
        _buildTimeInfo(
          'Started At',
          DateFormat('h:mm a').format(checkedInTime),
          Iconsax.clock,
          [AppColors.primary, AppColors.primary.withOpacity(0.8)],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildAnimatedButton(
                onPressed: () => context.go('/employee/attendance'),
                icon: Iconsax.coffee,
                label: 'Take Break',
                gradientColors: [AppColors.warning, AppColors.warning.withOpacity(0.8)],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildAnimatedButton(
                onPressed: () => context.go('/employee/attendance'),
                icon: Iconsax.logout,
                label: 'Check Out',
                gradientColors: [AppColors.error, AppColors.error.withOpacity(0.8)],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAnimatedButton({
    required VoidCallback onPressed,
    required IconData icon,
    required String label,
    required List<Color> gradientColors,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: Material(
        elevation: 2,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onPressed,
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: gradientColors,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.white, size: 18),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimeInfo(String label, String time, IconData icon, List<Color> gradientColors) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: gradientColors[0].withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: gradientColors[0].withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: gradientColors,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 18,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            time,
            style: AppTextStyles.bodyMedium.copyWith(
              color: gradientColors[0],
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
