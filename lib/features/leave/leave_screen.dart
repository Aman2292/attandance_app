// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:intl/intl.dart';
import '../../core/constants.dart';
import '../../providers/holiday_provider.dart';
import '../../providers/leave_provider.dart';
import '../../providers/user_provider.dart';

class LeaveScreen extends ConsumerStatefulWidget {
  const LeaveScreen({super.key});

  @override
  _LeaveScreenState createState() => _LeaveScreenState();
}

class _LeaveScreenState extends ConsumerState<LeaveScreen> {
  final ValueNotifier<DateTime> _currentMonth = ValueNotifier(DateTime.now());
  final ValueNotifier<List<Map<String, dynamic>>> _holidayNotifier = ValueNotifier([]);
  final ValueNotifier<List<DateTime>> _leaveDatesNotifier = ValueNotifier([]);

  @override
  void initState() {
    super.initState();
    _updateHolidays();
    _updateLeaveDates();
  }

  bool _isListenerSet = false;

  void _updateHolidays() {
    final holidays = ref.read(holidayProvider).value ?? [];
    final currentMonthHolidays = holidays.where((h) =>
        h['date'].year == _currentMonth.value.year &&
        h['date'].month == _currentMonth.value.month).toList();
    _holidayNotifier.value = currentMonthHolidays;
  }

  void _updateLeaveDates() {
    final user = ref.read(authServiceProvider).currentUser;
    if (user == null) return;

    final leaveRecords = ref.read(leaveRecordsProvider(user.uid)).value ?? [];
    final leaveDates = <DateTime>[];

    for (var record in leaveRecords) {
      // Only include approved and pending leaves
      if (record.status == 'approved' || record.status == 'pending') {
        DateTime current = record.startDate;
        while (current.isBefore(record.endDate.add(const Duration(days: 1)))) {
          // Only add dates for current month
          if (current.year == _currentMonth.value.year &&
              current.month == _currentMonth.value.month) {
            leaveDates.add(DateTime(current.year, current.month, current.day));
          }
          current = current.add(const Duration(days: 1));
        }
      }
    }

    _leaveDatesNotifier.value = leaveDates;
  }

  void _onViewChanged(ViewChangedDetails details) {
    final middleIndex = (details.visibleDates.length / 2).floor();
    final middleDate = details.visibleDates[middleIndex];
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _currentMonth.value = DateTime(middleDate.year, middleDate.month);
      _updateHolidays();
      _updateLeaveDates();
    });
  }

  @override
  void dispose() {
    _currentMonth.dispose();
    _holidayNotifier.dispose();
    _leaveDatesNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isListenerSet) {
      _isListenerSet = true;
      ref.listen(holidayProvider, (previous, next) {
        if (next.hasValue) {
          _updateHolidays();
        }
      });
      
      // Listen to leave records changes
      final user = ref.read(authServiceProvider).currentUser;
      if (user != null) {
        ref.listen(leaveRecordsProvider(user.uid), (previous, next) {
          if (next.hasValue) {
            _updateLeaveDates();
          }
        });
      }
    }
    
    final user = ref.read(authServiceProvider).currentUser;
    if (user == null) {
      return const Center(child: Text('Please log in to view this screen'));
    }

    final userId = user.uid;
    final leaveAsync = ref.watch(leaveRecordsProvider(userId));

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Leave', style: AppTextStyles.heading2),
        backgroundColor: AppColors.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Recent Leave Requests
              Text('Recent Leave Requests', style: AppTextStyles.bodyLarge),
              leaveAsync.when(
                data: (records) => records.isEmpty
                    ? Text('No leave records', style: AppTextStyles.bodyMedium)
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: records.length > 3 ? 3 : records.length,
                        itemBuilder: (context, index) {
                          final record = records[index];
                          final isPending = record.status == 'pending';
                          final isApproved = record.status == 'approved';
                          return Container(
                            margin: EdgeInsets.only(bottom: screenHeight * 0.02),
                            padding: EdgeInsets.all(screenWidth * 0.04),
                            decoration: BoxDecoration(
                              color: isPending
                                  ? const Color.fromARGB(255, 255, 245, 156)
                                  : isApproved
                                      ? const Color.fromARGB(255, 187, 255, 189)
                                      : Colors.white,
                              borderRadius: BorderRadius.circular(screenWidth * 0.03),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.1),
                                  spreadRadius: 2,
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: screenWidth * 0.12,
                                  height: screenWidth * 0.12,
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(screenWidth * 0.02),
                                  ),
                                  child: Center(
                                    child: Icon(
                                      Icons.event,
                                      color: AppColors.primary,
                                      size: screenWidth * 0.06,
                                    ),
                                  ),
                                ),
                                SizedBox(width: screenWidth * 0.04),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${record.startDate.toString().substring(0, 10)} - ${record.type.capitalize()}',
                                        style: TextStyle(
                                          fontSize: screenWidth * 0.04,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      SizedBox(height: screenWidth * 0.01),
                                      Text(
                                        'Status: ${record.status}',
                                        style: TextStyle(
                                          fontSize: screenWidth * 0.035,
                                          color: isPending
                                              ? Colors.orange
                                              : isApproved
                                                  ? Colors.green
                                                  : Colors.grey[600],
                                          fontWeight: isPending || isApproved ? FontWeight.bold : FontWeight.normal,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Text('Error: $e', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.error)),
              ),
              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    icon: const Icon(Iconsax.add),
                    label: const Text('Apply Leave'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.06,
                        vertical: screenHeight * 0.015,
                      ),
                    ),
                    onPressed: () => context.go('/employee/leave/apply'),
                  ),
                  ElevatedButton.icon(
                    icon: const Icon(Iconsax.document),
                    label: const Text('View History'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.06,
                        vertical: screenHeight * 0.015,
                      ),
                    ),
                    onPressed: () => context.go('/employee/leave/history'),
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.02),
              // Calendar Section
              Container(
                margin: EdgeInsets.only(bottom: screenHeight * 0.02),
                padding: EdgeInsets.all(screenWidth * 0.04),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(screenWidth * 0.04),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 2,
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ValueListenableBuilder<DateTime>(
                      valueListenable: _currentMonth,
                      builder: (context, currentMonth, child) {
                        return Text(
                          'Calendar (${DateFormat('MMMM yyyy').format(currentMonth)})',
                          style: TextStyle(
                            fontSize: screenWidth * 0.045,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        );
                      },
                    ),
                    SizedBox(height: screenHeight * 0.01),
                    // Add legend
                    Wrap(
                      spacing: 16,
                      runSpacing: 8,
                      children: [
                        _buildLegendItem(Colors.orange.shade200, 'Holiday'),
                        _buildLegendItem(Colors.purple.shade200, 'Leave'),
                        _buildLegendItem(Colors.blue.shade400, 'Today'),
                        _buildLegendItem(Colors.red.shade100, 'Sunday'),
                      ],
                    ),
                    SizedBox(height: screenHeight * 0.01),
                    ValueListenableBuilder<List<Map<String, dynamic>>>(
                      valueListenable: _holidayNotifier,
                      builder: (context, holidays, child) {
                        return ValueListenableBuilder<List<DateTime>>(
                          valueListenable: _leaveDatesNotifier,
                          builder: (context, leaveDates, child) {
                            return SfCalendar(
                              view: CalendarView.month,
                              initialDisplayDate: _currentMonth.value,
                              initialSelectedDate: DateTime.now(),
                              onViewChanged: _onViewChanged,
                              dataSource: CombinedDataSource(holidays, leaveDates),
                              monthViewSettings: const MonthViewSettings(
                                appointmentDisplayMode: MonthAppointmentDisplayMode.appointment,
                              ),
                              blackoutDates: holidays
                                  .where((h) => h['date'].isBefore(DateTime.now()))
                                  .map((h) => h['date'] as DateTime)
                                  .toList(),
                              monthCellBuilder: (BuildContext context, MonthCellDetails details) {
                                final isHoliday = holidays.any((h) =>
                                  h['date'].year == details.date.year &&
                                  h['date'].month == details.date.month &&
                                  h['date'].day == details.date.day);
                                
                                final isLeaveDate = leaveDates.any((l) =>
                                  l.year == details.date.year &&
                                  l.month == details.date.month &&
                                  l.day == details.date.day);
                                
                                final now = DateTime.now();
                                final isCurrentMonth = _currentMonth.value.year == details.date.year && 
                                                     _currentMonth.value.month == details.date.month;
                                final isToday = isCurrentMonth && 
                                              now.year == details.date.year && 
                                              now.month == details.date.month && 
                                              now.day == details.date.day;
                                
                                Color? bgColor;
                                Color textColor = Colors.black;
                                FontWeight fontWeight = FontWeight.normal;
                                BoxBorder? border;
                                final isSunday = details.date.weekday == DateTime.sunday;
                                
                                // Priority: Today > Holiday > Leave > Sunday
                                if (isToday) {
                                  bgColor = Colors.blue.shade400;
                                  textColor = Colors.white;
                                  fontWeight = FontWeight.bold;
                                  if (isHoliday || isLeaveDate) {
                                    border = Border.all(
                                      color: isHoliday ? Colors.orange : Colors.purple, 
                                      width: 2
                                    );
                                  }
                                } else if (isHoliday && isLeaveDate) {
                                  // Both holiday and leave - show striped or mixed color
                                  bgColor = Colors.orange.shade200;
                                  border = Border.all(color: Colors.purple, width: 2);
                                  textColor = Colors.white;
                                  fontWeight = FontWeight.bold;
                                } else if (isHoliday) {
                                  bgColor = Colors.orange.shade200;
                                  textColor = Colors.white;
                                  fontWeight = FontWeight.bold;
                                } else if (isLeaveDate) {
                                  bgColor = Colors.purple.shade200;
                                  textColor = Colors.white;
                                  fontWeight = FontWeight.bold;
                                } else if (isSunday) {
                                  bgColor = Colors.red.shade100;
                                  textColor = Colors.red.shade700;
                                  fontWeight = FontWeight.bold;
                                }
                                
                                return Padding(
                                  padding: const EdgeInsets.all(2),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: bgColor,
                                      borderRadius: BorderRadius.circular(8),
                                      border: border,
                                    ),
                                    child: Center(
                                      child: Text(
                                        '${details.date.day}',
                                        style: TextStyle(
                                          color: textColor,
                                          fontWeight: fontWeight,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
              // Holidays List
              ValueListenableBuilder<DateTime>(
                valueListenable: _currentMonth,
                builder: (context, currentMonth, child) {
                  return Text('Upcoming Holidays', style: AppTextStyles.bodyLarge);
                },
              ),
              ValueListenableBuilder<List<Map<String, dynamic>>>(
                valueListenable: _holidayNotifier,
                builder: (context, holidays, child) {
                  if (holidays.isEmpty) {
                    return Padding(
                      padding: EdgeInsets.symmetric(vertical: screenHeight * 0.02),
                      child: Text('No holidays 😢', style: AppTextStyles.bodyMedium),
                    );
                  }
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: holidays.length,
                    itemBuilder: (context, index) {
                      final holiday = holidays[index];
                      return Container(
                        margin: EdgeInsets.only(bottom: screenHeight * 0.02),
                        padding: EdgeInsets.all(screenWidth * 0.04),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(screenWidth * 0.03),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              spreadRadius: 2,
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: screenWidth * 0.12,
                              height: screenWidth * 0.12,
                              decoration: BoxDecoration(
                                color: Colors.orange.shade100,
                                borderRadius: BorderRadius.circular(screenWidth * 0.02),
                              ),
                              child: Center(
                                child: Text(
                                  holiday['icon'],
                                  style: TextStyle(fontSize: screenWidth * 0.06),
                                ),
                              ),
                            ),
                            SizedBox(width: screenWidth * 0.04),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    holiday['title'],
                                    style: TextStyle(
                                      fontSize: screenWidth * 0.04,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  SizedBox(height: screenWidth * 0.01),
                                  Text(
                                    holiday['subtitle'],
                                    style: TextStyle(
                                      fontSize: screenWidth * 0.035,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }
}

// Combined Data Source for both holidays and leave dates
class CombinedDataSource extends CalendarDataSource {
  CombinedDataSource(List<Map<String, dynamic>> holidays, List<DateTime> leaveDates) {
    List<Appointment> allAppointments = [];
    
    // Add holiday appointments
    allAppointments.addAll(holidays.map((h) {
      Color color;
      if (h['icon'] == '🇮🇳') color = Colors.blue;
      else if (h['icon'] == '🎉' || h['icon'] == '🌊') color = Colors.orange;
      else color = Colors.red;
      
      return Appointment(
        startTime: h['date'],
        endTime: h['date'].add(const Duration(hours: 24)),
        subject: h['title'],
        color: color,
        isAllDay: true,
      );
    }).toList());
    
    // Add leave appointments
    allAppointments.addAll(leaveDates.map((leaveDate) {
      return Appointment(
        startTime: leaveDate,
        endTime: leaveDate.add(const Duration(hours: 24)),
        subject: 'Leave',
        color: Colors.purple,
        isAllDay: true,
      );
    }).toList());
    
    appointments = allAppointments;
  }
}

extension StringExtension on String {
  String capitalize() => this[0].toUpperCase() + substring(1);
}