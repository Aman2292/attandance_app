import 'package:attendance_app/core/extensions/string_extensions.dart';
import 'package:attendance_app/features/leave/leave_history_screen.dart';
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
      if (record.status == 'approved' || record.status == 'pending') {
        DateTime current = record.startDate;
        while (current.isBefore(record.endDate.add(const Duration(days: 1)))) {
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
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Iconsax.user,
                size: 64,
                color: AppColors.textSecondary,
              ),
              const SizedBox(height: 16),
              Text(
                'Please log in to view this screen',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final userId = user.uid;
    final leaveAsync = ref.watch(leaveRecordsProvider(userId));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildRecentLeaveRequests(leaveAsync),
                const SizedBox(height: 24),
                _buildCalendarSection(),
                const SizedBox(height: 24),
                _buildHolidaysSection(),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 100,
      floating: true,
      pinned: true,
      elevation: 0,
      backgroundColor: const Color.fromARGB(55, 0, 0, 0),
      // leading: IconButton(
      //   icon: const Icon(
      //     Iconsax.arrow_left,
      //     color: AppColors.surface,
      //   ),
      //   onPressed: () => context.pop(),
      // ),
      actions: [
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.surface.withOpacity(0.4),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Iconsax.add,
              color: Colors.white,
              size: 20,
            ),
          ),
          onPressed: () => context.go('/employee/leave/apply'),
        ),
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.surface.withOpacity(0.4),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Iconsax.document_text,
              color: Colors.white,
              size: 20,
            ),
          ),
          onPressed: () => context.go('/employee/leave/history'),
        ),
        const SizedBox(width: 8),
      ],
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          'Leave',
          style: AppTextStyles.heading2.copyWith(
            color: AppColors.surface,
            fontWeight: FontWeight.w600,
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.success,
                AppColors.success.withOpacity(0.8),
                AppColors.accent.withOpacity(0.6),
                AppColors.primary.withOpacity(0.4),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecentLeaveRequests(AsyncValue<List<dynamic>> leaveAsync) {
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
                      AppColors.accent,
                      AppColors.accent.withOpacity(0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Iconsax.document,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Recent Leave Requests',
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
            padding: const EdgeInsets.all(16),
            child: leaveAsync.when(
              data: (records) => records.isEmpty
                  ? _buildEmptyState()
                  : _buildLeaveRequestsList(records),
              loading: () => _buildLeaveRequestsLoader(),
              error: (e, _) => _buildLeaveRequestsError(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      height: 120,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Iconsax.document_text,
              size: 48,
              color: AppColors.textSecondary.withOpacity(0.5),
            ),
            const SizedBox(height: 8),
            Text(
              'No leave requests yet',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeaveRequestsLoader() {
    return Container(
      height: 120,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.accent,
                    AppColors.accent.withOpacity(0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                strokeWidth: 3,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Loading leave requests...',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeaveRequestsError() {
    return Container(
      height: 120,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
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
                size: 24,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Error loading leave requests',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.error,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeaveRequestsList(List<dynamic> records) {
    final recentRecords = records.take(3).toList();
    return Column(
      children: recentRecords.map((record) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _getStatusColor(record.status).withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _getStatusColor(record.status).withOpacity(0.2),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _getStatusColor(record.status),
                      _getStatusColor(record.status).withOpacity(0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  _getLeaveTypeIcon(record.type),
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          record.type.toString().capitalize(),
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                _getStatusColor(record.status),
                                _getStatusColor(record.status).withOpacity(0.8),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            record.status.toString().capitalize(),
                            style: AppTextStyles.bodySmall.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${DateFormat('MMM dd').format(record.startDate)} - ${DateFormat('MMM dd').format(record.endDate)}',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCalendarSection() {
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
                      AppColors.primary,
                      AppColors.primary.withOpacity(0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Iconsax.calendar,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              ValueListenableBuilder<DateTime>(
                valueListenable: _currentMonth,
                builder: (context, currentMonth, child) {
                  return Text(
                    'Calendar (${DateFormat('MMMM yyyy').format(currentMonth)})',
                    style: AppTextStyles.heading3.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  );
                },
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
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildCalendarLegend(),
                const SizedBox(height: 16),
                ValueListenableBuilder<List<Map<String, dynamic>>>(
                  valueListenable: _holidayNotifier,
                  builder: (context, holidays, child) {
                    return ValueListenableBuilder<List<DateTime>>(
                      valueListenable: _leaveDatesNotifier,
                      builder: (context, leaveDates, child) {
                        return Container(
                          height: 300,
                          child: SfCalendar(
                            view: CalendarView.month,
                            initialDisplayDate: _currentMonth.value,
                            initialSelectedDate: DateTime.now(),
                            onViewChanged: _onViewChanged,
                            dataSource: CombinedDataSource(holidays, leaveDates),
                            monthViewSettings: const MonthViewSettings(
                              appointmentDisplayMode: MonthAppointmentDisplayMode.appointment,
                            ),
                            monthCellBuilder: (BuildContext context, MonthCellDetails details) {
                              return _buildCalendarCell(details, holidays, leaveDates);
                            },
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
      ],
    );
  }

  Widget _buildCalendarLegend() {
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: [
        _buildLegendItem(Colors.orange.shade200, 'Holiday'),
        _buildLegendItem(Colors.purple.shade200, 'Leave'),
        _buildLegendItem(Colors.blue.shade400, 'Today'),
        _buildLegendItem(Colors.red.shade100, 'Sunday'),
      ],
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
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildCalendarCell(MonthCellDetails details, List<Map<String, dynamic>> holidays, List<DateTime> leaveDates) {
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
  }

  Widget _buildHolidaysSection() {
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
                  Iconsax.calendar_2,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Upcoming Holidays',
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
            padding: const EdgeInsets.all(16),
            child: ValueListenableBuilder<List<Map<String, dynamic>>>(
              valueListenable: _holidayNotifier,
              builder: (context, holidays, child) {
                if (holidays.isEmpty) {
                  return Container(
                    height: 100,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Iconsax.emoji_happy,
                            size: 32,
                            color: AppColors.textSecondary.withOpacity(0.5),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'No holidays this month',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                return Column(
                  children: holidays.map((holiday) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.warning.withOpacity(0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.warning,
                                  AppColors.warning.withOpacity(0.8),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              holiday['icon'],
                              style: TextStyle(fontSize: 20),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  holiday['title'],
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  holiday['subtitle'],
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'approved':
        return AppColors.success;
      case 'pending':
        return AppColors.warning;
      case 'rejected':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }

  IconData _getLeaveTypeIcon(String type) {
    switch (type) {
      case 'paid':
        return Iconsax.card;
      case 'sick':
        return Iconsax.health;
      case 'earned':
        return Iconsax.star;
      default:
        return Iconsax.calendar;
    }
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
