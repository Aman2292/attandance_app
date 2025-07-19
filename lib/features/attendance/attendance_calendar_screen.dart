import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../core/constants.dart';
import '../../providers/attendance_provider.dart';
import '../../providers/user_provider.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, Map<String, dynamic>> _attendanceData = {};

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
  }

  // Calculate overtime based on total working hours
  Map<String, dynamic> _calculateOvertime(DateTime? checkIn, DateTime? checkOut, double totalBreakDuration, DateTime date) {
    if (checkIn == null || checkOut == null) {
      return {
        'overtime': 0.0,
        'totalHours': 0.0,
        'regularHours': 0.0,
      };
    }

    // Calculate total working hours minus break time
    final totalMinutes = checkOut.difference(checkIn).inMinutes;
    final breakMinutes = (totalBreakDuration / 60).round(); // Convert seconds to minutes
    final workedMinutes = totalMinutes - breakMinutes;
    final totalHours = workedMinutes / 60.0;

    // Determine standard hours based on day of the week
    final isSaturday = date.weekday == DateTime.saturday;
    final standardHours = isSaturday ? 7.0 : 9.0;

    // Calculate overtime
    final regularHours = totalHours <= standardHours ? totalHours : standardHours;
    final overtimeHours = totalHours > standardHours ? (totalHours - standardHours) : 0.0;

    return {
      'overtime': double.parse(overtimeHours.toStringAsFixed(2)),
      'totalHours': double.parse(totalHours.toStringAsFixed(2)),
      'regularHours': double.parse(regularHours.toStringAsFixed(2)),
    };
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'present':
        return AppColors.success;
      case 'late':
        return AppColors.warning;
      case 'absent':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'present':
        return Iconsax.tick_circle;
      case 'late':
        return Iconsax.clock;
      case 'absent':
        return Iconsax.close_circle;
      default:
        return Iconsax.info_circle;
    }
  }

  String _getDisplayStatus(String status) {
    switch (status.toLowerCase()) {
      case 'present':
        return 'Present';
      case 'late':
        return 'Late';
      case 'absent':
        return 'Absent';
      default:
        return 'Unknown';
    }
  }

  @override
  Widget build(BuildContext context) {
    final userId = ref.watch(authServiceProvider).currentUser?.uid ?? '';
    final attendanceRecordsAsync = ref.watch(attendanceRecordsProvider(userId));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: attendanceRecordsAsync.when(
              data: (attendanceRecords) {
                // Convert attendance records to calendar format
                _attendanceData.clear();
                for (final record in attendanceRecords) {
                  final dateKey = DateTime(record.date.year, record.date.month, record.date.day);
                  
                  String status = 'absent';
                  if (record.checkInTime != null) {
                    // Check if late (after 9:30 AM)
                    final checkInTime = record.checkInTime!;
                    final isLate = checkInTime.hour > 9 || (checkInTime.hour == 9 && checkInTime.minute > 30);
                    status = isLate ? 'late' : 'present';
                  }

                  // Calculate overtime
                  final overtimeData = _calculateOvertime(
                    record.checkInTime,
                    record.checkOutTime,
                    record.totalBreakDuration.toDouble() ,
                    record.date,
                  );
                  
                  _attendanceData[dateKey] = {
                    'status': status,
                    'checkIn': record.checkInTime,
                    'checkOut': record.checkOutTime,
                    'notes': record.notes,
                    'overtime': overtimeData['overtime'],
                    'totalHours': overtimeData['totalHours'],
                    'regularHours': overtimeData['regularHours'],
                    'breakDuration': record.totalBreakDuration,
                  };
                }

                return Column(
                  children: [
                    // Calendar Header with Legend
                    _buildCalendarHeader(),
                    
                    // Calendar Section
                    _buildCalendarSection(),
                  ],
                );
              },
              loading: () => _buildLoadingState(),
              error: (error, stack) => _buildErrorState(error),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      floating: true,
      pinned: true,
      snap: true,
      elevation: 0,
      backgroundColor: AppColors.accent,
      automaticallyImplyLeading: false,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Iconsax.arrow_left,
            color: Colors.white,
            size: 20,
          ),
        ),
        onPressed: () => context.pop(),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.white.withOpacity(0.2),
                Colors.white.withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            onPressed: () {
              // Refresh calendar data
              final userId = ref.read(authServiceProvider).currentUser?.uid ?? '';
              ref.invalidate(attendanceRecordsProvider(userId));
            },
            icon: const Icon(
              Iconsax.refresh,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: false,
        titlePadding: const EdgeInsets.only(
          left: 60, // Space for back button
          bottom: 16,
          right: 72, // Space for refresh button
        ),
        title: Text(
          'Attendance Calendar',
          style: AppTextStyles.heading3.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.accent,
                AppColors.accent.withOpacity(0.9),
                AppColors.primary.withOpacity(0.7),
                AppColors.secondary.withOpacity(0.5),
              ],
            ),
          ),
        ),
        collapseMode: CollapseMode.parallax,
      ),
    );
  }

  Widget _buildCalendarHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.accent.withOpacity(0.1),
            AppColors.primary.withOpacity(0.05),
          ],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildLegendItem('Present', AppColors.success, Iconsax.tick_circle),
          _buildLegendItem('Late', AppColors.warning, Iconsax.clock),
          _buildLegendItem('Absent', AppColors.error, Iconsax.close_circle),
        ],
      ),
    );
  }

  Widget _buildCalendarSection() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.textSecondary.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Table Calendar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TableCalendar(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              eventLoader: (day) {
                final dateKey = DateTime(day.year, day.month, day.day);
                final attendance = _attendanceData[dateKey];
                return attendance != null ? [attendance['status']] : [];
              },
              calendarStyle: CalendarStyle(
                outsideDaysVisible: false,
                weekendTextStyle: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
                holidayTextStyle: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
                defaultTextStyle: AppTextStyles.bodyMedium,
                selectedDecoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.accent, AppColors.accent.withOpacity(0.8)],
                  ),
                  shape: BoxShape.circle,
                ),
                todayDecoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
                  ),
                  shape: BoxShape.circle,
                ),
                markerDecoration: BoxDecoration(
                  color: AppColors.success,
                  shape: BoxShape.circle,
                ),
              ),
              headerStyle: HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                titleTextStyle: AppTextStyles.heading3.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
                leftChevronIcon: Icon(
                  Iconsax.arrow_left_2,
                  color: AppColors.accent,
                ),
                rightChevronIcon: Icon(
                  Iconsax.arrow_right_2,
                  color: AppColors.accent,
                ),
              ),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
              calendarBuilders: CalendarBuilders(
                markerBuilder: (context, date, events) {
                  final dateKey = DateTime(date.year, date.month, date.day);
                  final attendance = _attendanceData[dateKey];
                  
                  if (attendance != null) {
                    final status = attendance['status'] as String;
                    final color = _getStatusColor(status);
                    
                    return Positioned(
                      bottom: 1,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: color.withOpacity(0.5),
                              blurRadius: 4,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  return null;
                },
              ),
            ),
          ),
          
          // Selected Day Details
          if (_selectedDay != null)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: _buildSelectedDayDetails(),
            ),
        ],
      ),
    );
  }

  Widget _buildSelectedDayDetails() {
    if (_selectedDay == null) return const SizedBox.shrink();
    
    final dateKey = DateTime(_selectedDay!.year, _selectedDay!.month, _selectedDay!.day);
    final attendance = _attendanceData[dateKey];
    
    if (attendance == null) {
      return Column(
        children: [
          Text(
            DateFormat('EEEE, MMMM d, yyyy').format(_selectedDay!),
            style: AppTextStyles.bodyLarge.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.textSecondary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Iconsax.close_circle,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'No attendance record',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    final status = attendance['status'] as String;
    final checkIn = attendance['checkIn'] as DateTime?;
    final checkOut = attendance['checkOut'] as DateTime?;
    final notes = attendance['notes'] as String?;
    final overtime = attendance['overtime'] as double;
    final totalHours = attendance['totalHours'] as double;
    final regularHours = attendance['regularHours'] as double;
    
    // Determine if it's Saturday for overtime calculation
    final isSaturday = _selectedDay!.weekday == DateTime.saturday;
    final standardHours = isSaturday ? 7.0 : 9.0;
    
    return Column(
      children: [
        Text(
          DateFormat('EEEE, MMMM d, yyyy').format(_selectedDay!),
          style: AppTextStyles.bodyLarge.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        
        // Status Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                _getStatusColor(status),
                _getStatusColor(status).withOpacity(0.8),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _getStatusIcon(status),
                color: Colors.white,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                _getDisplayStatus(status),
                style: AppTextStyles.bodyMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        
        if (checkIn != null || checkOut != null) ...[
          const SizedBox(height: 20),
          
          // Time Details Grid
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.accent.withOpacity(0.2),
              ),
            ),
            child: Column(
              children: [
                // Check-in and Check-out Row
                Row(
                  children: [
                    if (checkIn != null)
                      Expanded(
                        child: _buildTimeCard(
                          'Check In',
                          DateFormat('hh:mm a').format(checkIn),
                          Iconsax.login,
                          AppColors.success,
                        ),
                      ),
                    if (checkIn != null && checkOut != null)
                      const SizedBox(width: 12),
                    if (checkOut != null)
                      Expanded(
                        child: _buildTimeCard(
                          'Check Out',
                          DateFormat('hh:mm a').format(checkOut),
                          Iconsax.logout,
                          AppColors.error,
                        ),
                      ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Working Hours Summary
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total Hours:',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          Text(
                            '${totalHours.toStringAsFixed(2)}h',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Regular Hours:',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          Text(
                            '${regularHours.toStringAsFixed(2)}h',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.success,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      if (overtime > 0) ...[
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Iconsax.flash_1,
                                  color: AppColors.warning,
                                  size: 14,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Overtime:',
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: AppColors.warning,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              '${overtime.toStringAsFixed(2)}h',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.warning,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 8),
                      Text(
                        'Standard: ${standardHours.toInt()}h ${isSaturday ? "(Saturday)" : "(Weekday)"}',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
        
        if (notes != null && notes.isNotEmpty) ...[
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.warning.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppColors.warning.withOpacity(0.3),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Iconsax.message_text,
                  color: AppColors.warning,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Notes:',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.warning,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        notes,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildTimeCard(String label, String time, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 20,
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            time,
            style: AppTextStyles.bodyMedium.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color, IconData icon) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 6),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return Container(
      height: 600,
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
                    AppColors.accent,
                    AppColors.accent.withOpacity(0.8),
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
              'Loading Calendar...',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(Object error) {
    return Container(
      height: 400,
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
              'Error Loading Calendar',
              style: AppTextStyles.heading3.copyWith(
                color: AppColors.error,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Unable to load attendance data',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
