import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants.dart';
import '../../providers/user_provider.dart';
import '../../providers/attendance_provider.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  String _filter = 'days'; // Default filter: days (last 30 days)
  Stream<Position>? _positionStream;
  bool _isWithinRange = false;
  Timer? _locationTimer;
  Timer? _timeUpdateTimer;

  @override
  void initState() {
    super.initState();
    _startLocationStream();
    // Update time and location every minute
    _timeUpdateTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      setState(() {}); // Trigger rebuild for real-time time and location
    });
  }

  @override
  void dispose() {
    _locationTimer?.cancel();
    _timeUpdateTimer?.cancel();
    super.dispose();
  }

  Future<void> _startLocationStream() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showSnackBar('Please enable location services');
      setState(() {
        _isWithinRange = false; // Default to not within range
      });
      _startLocationCheckTimer();
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _showSnackBar('Location permissions denied');
        setState(() {
          _isWithinRange = false;
        });
        _startLocationCheckTimer();
        return;
      }
    }

    _positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    );
    _startLocationCheckTimer();
  }

  void _startLocationCheckTimer() {
    // Check location every 10 seconds
    _locationTimer?.cancel();
    _locationTimer = Timer.periodic(const Duration(seconds: 10), (timer) async {
      if (_positionStream != null) {
        try {
          final position = await _positionStream!.first;
          final isWithinRange = await _checkLocation(position);
          if (mounted) {
            setState(() {
              _isWithinRange = isWithinRange;
            });
          }
        } catch (e) {
          print('Location stream error: $e');
          if (mounted) {
            setState(() {
              _isWithinRange = false; // Default to not within range on error
            });
          }
        }
      }
    });
  }

  void _showSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  Future<bool> _checkLocation(Position position) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('config')
          .doc('office')
          .get();
      if (!doc.exists) {
        print('Office config not found');
        _showSnackBar('Office location not configured');
        return false;
      }
      final data = doc.data()!;
      print('Firestore office config: $data'); // Debug log
      final officeLat = (data['latitude'] is num)
          ? (data['latitude'] as num).toDouble()
          : null;
      final officeLon = (data['longitude'] is num)
          ? (data['longitude'] as num).toDouble()
          : null;
      final radius = (data['radiusMeters'] is num)
          ? (data['radiusMeters'] as num).toDouble()
          : null;
      print(
          'Parsed values: lat=$officeLat, lon=$officeLon, radius=$radius'); // Debug log
      if (officeLat == null || officeLon == null || radius == null) {
        print('Invalid office config data');
        _showSnackBar('Invalid office location data');
        return false;
      }
      final distance = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        officeLat,
        officeLon,
      );
      print('Distance to office: $distance meters'); // Debug log
      return distance <= radius;
    } catch (e) {
      print('Error checking location: $e');
      _showSnackBar('Error checking location: $e');
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(userProvider);
    final userId = ref.watch(authServiceProvider).currentUser?.uid ?? '';
    final todayAttendanceAsync = ref.watch(attendanceProvider(userId));
    final attendanceSummaryAsync = ref.watch(attendanceSummaryProvider({
      'userId': userId,
      'start': _filter == 'days'
          ? DateTime.now().subtract(const Duration(days: 30))
          : DateTime.now().subtract(const Duration(days: 365)),
      'end': DateTime.now(),
    }));
    final attendanceNotifier = ref.watch(attendanceNotifierProvider(userId).notifier);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: userAsync.when(
        data: (user) {
          if (user == null) {
            context.go('/login');
            return const SizedBox();
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const CircleAvatar(
                          radius: 24,
                          backgroundColor: AppColors.primary,
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(user.name, style: AppTextStyles.heading3),
                            Text(user.role, style: AppTextStyles.bodySmall),
                          ],
                        ),
                      ],
                    ),
                    Text(
                      DateFormat('dd MMM, yyyy').format(DateTime.now()),
                      style: AppTextStyles.bodyMedium,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Today's Attendance", style: AppTextStyles.heading3),
                    Text(
                      DateFormat('EEEE, dd MMM yyyy').format(DateTime.now()),
                      style: AppTextStyles.bodyMedium,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 6,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Column(
                    children: [
                      todayAttendanceAsync.when(
                        data: (attendance) {
                          final now = DateTime.now();
                          final hours = now.hour.toString().padLeft(2, '0');
                          final minutes =
                              now.minute.toString().padLeft(2, '0');
                          final isAm = now.hour < 12;
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              TimeDisplay(time: hours),
                              TimeDisplay(time: minutes),
                              TimeDisplay(time: isAm ? 'AM' : 'PM'),
                            ],
                          );
                        },
                        loading: () => const CircularProgressIndicator(),
                        error: (e, _) => Text('Error: $e',
                            style: AppTextStyles.bodyMedium
                                .copyWith(color: AppColors.error)),
                      ),
                      const SizedBox(height: 10),
                      StreamBuilder<Position>(
                        stream: _positionStream,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Text('Fetching location...',
                                style: AppTextStyles.bodySmall);
                          }
                          if (snapshot.hasError) {
                            return Text('Unable to fetch location ❌',
                                style: AppTextStyles.bodySmall
                                    .copyWith(color: Colors.red));
                          }
                          if (!snapshot.hasData) {
                            return Text('Fetching location...',
                                style: AppTextStyles.bodySmall);
                          }
                          return Text(
                            _isWithinRange
                                ? 'You are within the location ✅'
                                : 'You are not within the location ❌',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: _isWithinRange ? Colors.green : Colors.red,
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 10),
                      todayAttendanceAsync.when(
                        data: (attendance) {
                          final now = DateTime.now();
                          final isAfter930 = now.hour > 9 ||
                              (now.hour == 9 && now.minute >= 30);
                          if (attendance == null || attendance.checkInTime == null) {
                            return Column(
                              children: [
                                ElevatedButton(
                                  onPressed: _isWithinRange
                                      ? () async {
                                          final notes = isAfter930
                                              ? await _showNotesDialog()
                                              : null;
                                          await attendanceNotifier.checkIn(
                                              withinOfficeRadius: _isWithinRange,
                                              notes: notes);
                                        }
                                      : null,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _isWithinRange
                                        ? AppColors.primary
                                        : Colors.grey,
                                  ),
                                  child: const Text('Check In'),
                                ),
                              ],
                            );
                          } else {
                            return Column(
                              children: [
                                Text(
                                  'Checked in at: ${DateFormat('HH:mm').format(attendance.checkInTime!)}',
                                  style: AppTextStyles.bodySmall,
                                ),
                                const SizedBox(height: 10),
                                ElevatedButton(
                                  onPressed: _isWithinRange &&
                                          attendance.checkOutTime == null
                                      ? () async {
                                          await attendanceNotifier.checkOut();
                                        }
                                      : null,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _isWithinRange &&
                                            attendance.checkOutTime == null
                                        ? AppColors.primary
                                        : Colors.grey,
                                  ),
                                  child: const Text('Checkout'),
                                ),
                                const SizedBox(height: 10),
                                if (attendance.checkOutTime == null &&
                                    attendance.breakStartTime == null)
                                  ElevatedButton(
                                    onPressed: _isWithinRange
                                        ? () async {
                                            await attendanceNotifier.startBreak();
                                          }
                                        : null,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: _isWithinRange
                                          ? AppColors.primary
                                          : Colors.grey,
                                    ),
                                    child: const Text('Start Break'),
                                  ),
                                if (attendance.breakStartTime != null &&
                                    attendance.breakEndTime == null)
                                  ElevatedButton(
                                    onPressed: _isWithinRange
                                        ? () async {
                                            await attendanceNotifier.endBreak();
                                          }
                                        : null,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: _isWithinRange
                                          ? AppColors.primary
                                          : Colors.grey,
                                    ),
                                    child: const Text('End Break'),
                                  ),
                              ],
                            );
                          }
                        },
                        loading: () => const CircularProgressIndicator(),
                        error: (e, _) => Text('Error: $e',
                            style: AppTextStyles.bodyMedium
                                .copyWith(color: AppColors.error)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Total Attendance (Days)',
                        style: AppTextStyles.heading3),
                    DropdownButton<String>(
                      value: _filter,
                      items: [
                        DropdownMenuItem(
                            value: 'days',
                            child: Text('Last 30 Days',
                                style: AppTextStyles.bodySmall)),
                        DropdownMenuItem(
                            value: 'months',
                            child: Text('Last 12 Months',
                                style: AppTextStyles.bodySmall)),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _filter = value;
                          });
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                attendanceSummaryAsync.when(
                  data: (summary) {
                    final present = summary['present'] ?? 0;
                    final late = summary['late'] ?? 0;
                    final absent = summary['absent'] ?? 0;
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        SummaryBox(
                          title: 'Present',
                          count: present,
                          color: AppColors.present,
                        ),
                        SummaryBox(
                          title: 'Late',
                          count: late,
                          color: AppColors.late,
                        ),
                        SummaryBox(
                          title: 'Absent',
                          count: absent,
                          color: AppColors.absent,
                        ),
                      ],
                    );
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Text(
                    'Error: $e',
                    style: AppTextStyles.bodyMedium
                        .copyWith(color: AppColors.error),
                  ),
                ),
                const SizedBox(height: 24),
                Text('Leave Balance', style: AppTextStyles.heading3),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    SummaryBox(
                      title: 'Paid',
                      count: user.leaveBalance.paidLeave,
                      color: Colors.blue,
                    ),
                    SummaryBox(
                      title: 'Sick',
                      count: user.leaveBalance.sickLeave,
                      color: Colors.purple,
                    ),
                    SummaryBox(
                      title: 'Earned',
                      count: user.leaveBalance.earnedLeave,
                      color: Colors.teal,
                    ),
                  ],
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Text(
            'Error: $e',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.error),
          ),
        ),
      ),
    );
  }

  Future<String?> _showNotesDialog() async {
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reason for Lateness'),
        content: TextField(
          decoration: const InputDecoration(hintText: 'Enter notes (e.g., Traffic delay)'),
          onChanged: (value) {},
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, 'Traffic delay'), // Default or user input
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }
}

class TimeDisplay extends StatelessWidget {
  final String time;
  const TimeDisplay({super.key, required this.time});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(time, style: AppTextStyles.heading2),
    );
  }
}

class SummaryBox extends StatelessWidget {
  final String title;
  final int count;
  final Color color;
  const SummaryBox({
    super.key,
    required this.title,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('$count', style: AppTextStyles.heading1.copyWith(color: color)),
          const SizedBox(height: 8),
          Text(title, style: AppTextStyles.bodySmall),
        ],
      ),
    );
  }
}