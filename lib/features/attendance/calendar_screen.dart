import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../core/constants.dart';
import '../../providers/attendance_provider.dart';
import '../../providers/user_provider.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {

    final userId = ref.watch(authServiceProvider).currentUser?.uid ?? '';
    final attendanceAsync = ref.watch(attendanceProvider(userId));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Attendance Calendar'),
        backgroundColor: AppColors.primary,
      ),
      body: attendanceAsync.when(
        data: (record) {
          Map<DateTime, List<String>> events = {};
          if (record != null) {
            final date = DateTime(record.date.year, record.date.month, record.date.day);
            events[date] = [record.status];
            if (record.isLate) events[date]?.add('Late');
            if (record.notes.isNotEmpty) events[date]?.add('Notes: ${record.notes}');
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                TableCalendar(
                  firstDay: DateTime.utc(2024, 1, 1),
                  lastDay: DateTime.utc(2026, 12, 31),
                  focusedDay: _focusedDay,
                  calendarFormat: _calendarFormat,
                  selectedDayPredicate: (day) {
                    return isSameDay(_selectedDay, day);
                  },
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });
                  },
                  onFormatChanged: (format) {
                    if (_calendarFormat != format) {
                      setState(() {
                        _calendarFormat = format;
                      });
                    }
                  },
                  onPageChanged: (focusedDay) {
                    _focusedDay = focusedDay;
                  },
                  calendarStyle: CalendarStyle(
                    todayDecoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    selectedDecoration: BoxDecoration(
                      color: AppColors.accent,
                      shape: BoxShape.circle,
                    ),
                    markerDecoration: BoxDecoration(
                      color: AppColors.late,
                      shape: BoxShape.circle,
                    ),
                  ),
                  eventLoader: (day) {
                    final date = DateTime(day.year, day.month, day.day);
                    return events[date] ?? [];
                  },
                ),
                if (_selectedDay != null && events[_selectedDay] != null)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Details for ${DateFormat('dd MMM yyyy').format(_selectedDay!)}',
                          style: AppTextStyles.heading3,
                        ),
                        ...events[_selectedDay]!.map((event) => Text(event,
                            style: AppTextStyles.bodySmall)),
                      ],
                    ),
                  ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Text('Error: $e',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.error)),
        ),
      ),
    );
  }
}

extension NullableExtensions<T> on T? {
  R? let<R>(R Function(T) op) {
    final self = this;
    if (self == null) return null;
    return op(self);
  }
}