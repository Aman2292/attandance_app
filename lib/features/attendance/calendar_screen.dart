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

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'present':
        return AppColors.success;
      case 'late':
        return AppColors.warning;
      case 'absent':
        return AppColors.error;
      default:
        return AppColors.textHint;
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
      appBar: AppBar(
        title: Text(
          'Attendance Calendar',
          style: AppTextStyles.heading2.copyWith(color: AppColors.surface),
        ),
        backgroundColor: AppColors.primary,
        leading: IconButton(
          icon: Icon(Iconsax.arrow_left, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        elevation: 0,
      ),
      body: attendanceRecordsAsync.when(
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
            
            _attendanceData[dateKey] = {
              'status': status,
              'checkIn': record.checkInTime,
              'checkOut': record.checkOutTime,
              'notes': record.notes,
            };
          }

          return Column(
            children: [
              // Calendar Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary,
                      AppColors.primary.withOpacity(0.8),
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
              ),
              
              // Calendar
              Expanded(
                child: Container(
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Table Calendar
                      TableCalendar(
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
                          weekendTextStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                          holidayTextStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                          defaultTextStyle: AppTextStyles.bodyMedium,
                          selectedDecoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          todayDecoration: BoxDecoration(
                            color: AppColors.accent,
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
                          titleTextStyle: AppTextStyles.heading3,
                          leftChevronIcon: Icon(Iconsax.arrow_left_2, color: AppColors.primary),
                          rightChevronIcon: Icon(Iconsax.arrow_right_2, color: AppColors.primary),
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
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: color,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              );
                            }
                            return null;
                          },
                        ),
                      ),
                      
                      // Selected Day Details
                      if (_selectedDay != null)
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(16),
                              bottomRight: Radius.circular(16),
                            ),
                          ),
                          child: _buildSelectedDayDetails(),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Iconsax.warning_2,
                size: 64,
                color: AppColors.error,
              ),
              const SizedBox(height: 16),
              Text(
                'Error loading calendar',
                style: AppTextStyles.bodyLarge.copyWith(color: AppColors.error),
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.textHint),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
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
            style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Iconsax.close_circle,
                color: AppColors.textHint,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                'No attendance record',
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textHint),
              ),
            ],
          ),
        ],
      );
    }

    final status = attendance['status'] as String;
    final checkIn = attendance['checkIn'] as DateTime?;
    final checkOut = attendance['checkOut'] as DateTime?;
    final notes = attendance['notes'] as String?;
    
    return Column(
      children: [
        Text(
          DateFormat('EEEE, MMMM d, yyyy').format(_selectedDay!),
          style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        
        // Status Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: _getStatusColor(status),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _getStatusIcon(status),
                color: Colors.white,
                size: 14,
              ),
              const SizedBox(width: 6),
              Text(
                _getDisplayStatus(status),
                style: AppTextStyles.bodySmall.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        
        if (checkIn != null || checkOut != null) ...[
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              if (checkIn != null)
                Column(
                  children: [
                    Icon(
                      Iconsax.login,
                      color: AppColors.success,
                      size: 16,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Check In',
                      style: AppTextStyles.bodySmall.copyWith(color: AppColors.success),
                    ),
                    Text(
                      DateFormat('hh:mm a').format(checkIn),
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.success,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              if (checkOut != null)
                Column(
                  children: [
                    Icon(
                      Iconsax.logout,
                      color: AppColors.error,
                      size: 16,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Check Out',
                      style: AppTextStyles.bodySmall.copyWith(color: AppColors.error),
                    ),
                    Text(
                      DateFormat('hh:mm a').format(checkOut),
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ],
        
        if (notes != null && notes.isNotEmpty) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.warning.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.warning.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(
                  Iconsax.message_text,
                  color: AppColors.surface,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    notes,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.surface,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppColors.surface, size: 16),
        const SizedBox(width: 4),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.surface),
        ),
      ],
    );
  }
}
