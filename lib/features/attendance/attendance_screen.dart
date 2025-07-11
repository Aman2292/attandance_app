import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import '../../core/constants.dart';
import '../../providers/attendance_provider.dart';
import '../../providers/user_provider.dart';

class AttendanceScreen extends ConsumerStatefulWidget {
  const AttendanceScreen({super.key});

  @override
  ConsumerState<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends ConsumerState<AttendanceScreen> {
  Stream<Position>? _positionStream;
  bool _isWithinRange = false;
  Timer? _locationTimer;

  @override
  void initState() {
    super.initState();
    _startLocationStream();
  }

  @override
  void dispose() {
    _locationTimer?.cancel();
    super.dispose();
  }

  Future<void> _startLocationStream() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showSnackBar('Please enable location services');
      setState(() {
        _isWithinRange = false;
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
              _isWithinRange = false;
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
        _showSnackBar('Office location not configured');
        return false;
      }
      final data = doc.data()!;
      final officeLat = (data['latitude'] is num)
          ? (data['latitude'] as num).toDouble()
          : null;
      final officeLon = (data['longitude'] is num)
          ? (data['longitude'] as num).toDouble()
          : null;
      final radius = (data['radiusMeters'] is num)
          ? (data['radiusMeters'] as num).toDouble()
          : null;
      if (officeLat == null || officeLon == null || radius == null) {
        _showSnackBar('Invalid office location data');
        return false;
      }
      final distance = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        officeLat,
        officeLon,
      );
      return distance <= radius;
    } catch (e) {
      _showSnackBar('Error checking location: $e');
      return false;
    }
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
            onPressed: () => Navigator.pop(context, 'Traffic delay'),
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userId = ref.watch(authServiceProvider).currentUser?.uid ?? '';
    final attendanceAsync = ref.watch(attendanceProvider(userId));
    final attendanceNotifier = ref.watch(attendanceNotifierProvider(userId).notifier);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Attendance'),
        backgroundColor: AppColors.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Current Time: ${DateFormat('HH:mm a').format(DateTime.now())}',
              style: AppTextStyles.heading3,
            ),
            const SizedBox(height: 10),
            Text(
              _isWithinRange
                  ? 'You are within the office radius ✅'
                  : 'You are not within the office radius ❌',
              style: AppTextStyles.bodySmall.copyWith(
                color: _isWithinRange ? Colors.green : Colors.red,
              ),
            ),
            const SizedBox(height: 20),
            attendanceAsync.when(
              data: (attendance) {
                final now = DateTime.now();
                final isAfter930 = now.hour > 9 || (now.hour == 9 && now.minute >= 30);
                if (attendance == null || attendance.checkInTime == null) {
                  return Column(
                    children: [
                      ElevatedButton(
                        onPressed: _isWithinRange
                            ? () async {
                                final notes = isAfter930 ? await _showNotesDialog() : null;
                                await attendanceNotifier.checkIn(
                                    withinOfficeRadius: _isWithinRange, notes: notes);
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isWithinRange ? AppColors.primary : Colors.grey,
                        ),
                        child: const Text('Check In'),
                      ),
                    ],
                  );
                } else {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Check-in Time: ${DateFormat('HH:mm').format(attendance.checkInTime!)}',
                        style: AppTextStyles.bodySmall,
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: _isWithinRange && attendance.checkOutTime == null
                            ? () async {
                                await attendanceNotifier.checkOut();
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isWithinRange && attendance.checkOutTime == null
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
                            backgroundColor:
                                _isWithinRange ? AppColors.primary : Colors.grey,
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
                            backgroundColor:
                                _isWithinRange ? AppColors.primary : Colors.grey,
                          ),
                          child: const Text('End Break'),
                        ),
                      if (attendance.breakEndTime != null)
                        Text(
                          'Break Duration: ${attendance.totalBreakDuration ~/ 60} min',
                          style: AppTextStyles.bodySmall,
                        ),
                    ],
                  );
                }
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text('Error: $e',
                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.error)),
            ),
          ],
        ),
      ),
    );
  }
}