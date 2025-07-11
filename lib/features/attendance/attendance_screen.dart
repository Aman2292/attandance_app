// ignore_for_file: unused_result

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as latlong;
import '../../core/constants.dart';
import '../../providers/attendance_provider.dart';
import '../../providers/user_provider.dart';

class AttendanceScreen extends ConsumerStatefulWidget {
  const AttendanceScreen({super.key});

  @override
  ConsumerState<AttendanceScreen> createState() => _AttendanceScreenState();
}

// TimeBlock widget for displaying time segments
class _TimeBlock extends StatelessWidget {
  final String text;
  const _TimeBlock({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue, width: 1),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.blue,
        ),
      ),
    );
  }
}

class _AttendanceScreenState extends ConsumerState<AttendanceScreen> {
  Stream<Position>? _positionStream;
  bool _isWithinRange = false;
  Timer? _locationTimer;
  final latlong.LatLng _officeLocation =
      const latlong.LatLng(19.194922, 72.945384); // Office coordinates
  final double _officeRadius = 100.0; // 100m radius

  @override
  void initState() {
    super.initState();
    _startLocationStream();
    _loadUserPreference();
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
    final distance = Geolocator.distanceBetween(
      position.latitude,
      position.longitude,
      _officeLocation.latitude,
      _officeLocation.longitude,
    );
    return distance <= _officeRadius;
  }

  Future<void> _loadUserPreference() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = ref.read(authServiceProvider).currentUser?.uid;
    if (userId != null) {
      await prefs.setString('userId', userId);
    }
  }

  Future<String?> _showNotesDialog() async {
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reason for Lateness'),
        content: TextField(
          decoration: const InputDecoration(
              hintText: 'Enter notes (e.g., Traffic delay)'),
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
    final attendanceNotifier =
        ref.watch(attendanceNotifierProvider(userId).notifier);

    return Scaffold(
     backgroundColor: AppColors.background,
      appBar: AppBar(
        title:  Text('Attendance', style: AppTextStyles.heading2),
        backgroundColor: AppColors.primary,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Current Time and Location
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              elevation: 6,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text('Mark Your Attendance', style: AppTextStyles.heading3),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _TimeBlock(
                            text: DateFormat('hh').format(DateTime.now())),
                        const SizedBox(width: 6),
                        _TimeBlock(
                            text: DateFormat('mm').format(DateTime.now())),
                        const SizedBox(width: 6),
                        _TimeBlock(
                            text: DateFormat('a').format(DateTime.now())),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Location status
                    StreamBuilder<Position>(
                      stream: _positionStream,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Text('Fetching location...',
                              style: AppTextStyles.bodySmall);
                        }
                        if (snapshot.hasError || !snapshot.hasData) {
                          return Text('Location not available ❌',
                              style: AppTextStyles.bodySmall
                                  .copyWith(color: Colors.red));
                        }
                        return Text(
                          _isWithinRange
                              ? 'Within Office Radius ✅'
                              : 'Outside Office Radius ❌',
                          style: AppTextStyles.bodySmall.copyWith(
                              color:
                                  _isWithinRange ? Colors.green : Colors.red),
                        );
                      },
                    ),
                    const SizedBox(height: 10),

                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: SizedBox(
                        height: 180,
                        width: double.infinity,
                        child: Stack(
                          children: [
                            FlutterMap(
                              options: MapOptions(
                                initialCenter: _officeLocation,
                                initialZoom: 16,
                                maxZoom: 18,
                              ),
                              children: [
                                TileLayer(
                                  urlTemplate:
                                      'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                                  subdomains: ['a', 'b', 'c'],
                                ),
                                CircleLayer(
                                  circles: [
                                    CircleMarker(
                                      point: _officeLocation,
                                      radius: _officeRadius,
                                      useRadiusInMeter: true,
                                      color: Colors.blue.withOpacity(0.2),
                                      borderColor: Colors.blue,
                                      borderStrokeWidth: 2,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Center(
                              child: Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.blue.withOpacity(0.1),
                                  border:
                                      Border.all(color: Colors.blue, width: 2),
                                ),
                                child: const Center(
                                  child: Icon(Icons.my_location,
                                      color: Colors.blue),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    attendanceAsync.when(
                      data: (attendance) {
                        print('Attendance state: $attendance'); // Debug log
                        final now = DateTime.now();
                        final isAfter930 =
                            now.hour > 9 || (now.hour == 9 && now.minute >= 30);

                        if (attendance == null ||
                            attendance.checkInTime == null) {
                          return ElevatedButton.icon(
                            onPressed: _isWithinRange
                                ? () async {
                                    final notes = isAfter930
                                        ? await _showNotesDialog()
                                        : null;
                                    await attendanceNotifier.checkIn(
                                        withinOfficeRadius: _isWithinRange,
                                        notes: notes);
                                    await Future.delayed(const Duration(
                                        milliseconds:
                                            500)); // Allow stream to update
                                    ref.refresh(attendanceProvider(
                                        userId)); // Force refresh
                                  }
                                : null,
                            icon: const Icon(Icons.fingerprint),
                            label: const Text('Check In'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  _isWithinRange ? Colors.green : Colors.grey,
                              padding: const EdgeInsets.symmetric(
                                  vertical: 12, horizontal: 32),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              textStyle: const TextStyle(fontSize: 16),
                            ),
                          );
                        } else {
                          return Column(
                            children: [
                              Text(
                                'Checked In at: ${DateFormat('HH:mm').format(attendance.checkInTime!)}',
                                style: AppTextStyles.bodySmall,
                              ),
                              const SizedBox(height: 10),
                              if (attendance.checkOutTime == null &&
                                  attendance.breakStartTime == null)
                                ElevatedButton.icon(
                                  onPressed: _isWithinRange
                                      ? () async {
                                          await attendanceNotifier.startBreak();
                                          await Future.delayed(const Duration(
                                              milliseconds:
                                                  500)); // Allow stream to update
                                          ref.refresh(attendanceProvider(
                                              userId)); // Force refresh
                                        }
                                      : null,
                                  icon: const Icon(Icons.pause),
                                  label: const Text('Start Break'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _isWithinRange
                                        ? Colors.orange
                                        : Colors.grey,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12, horizontal: 32),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12)),
                                    textStyle: const TextStyle(fontSize: 16),
                                  ),
                                ),
                              if (attendance.breakStartTime != null &&
                                  attendance.breakEndTime == null)
                                ElevatedButton.icon(
                                  onPressed: _isWithinRange
                                      ? () async {
                                          await attendanceNotifier.endBreak();
                                          await Future.delayed(const Duration(
                                              milliseconds:
                                                  500)); // Allow stream to update
                                          ref.refresh(attendanceProvider(
                                              userId)); // Force refresh
                                        }
                                      : null,
                                  icon: const Icon(Icons.play_arrow),
                                  label: const Text('End Break'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _isWithinRange
                                        ? Colors.orange
                                        : Colors.grey,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12, horizontal: 32),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12)),
                                    textStyle: const TextStyle(fontSize: 16),
                                  ),
                                ),
                              if (attendance.breakEndTime != null &&
                                  attendance.checkOutTime == null)
                                ElevatedButton.icon(
                                  onPressed: _isWithinRange
                                      ? () async {
                                          await attendanceNotifier.checkOut();
                                          await Future.delayed(const Duration(
                                              milliseconds:
                                                  500)); // Allow stream to update
                                          ref.refresh(attendanceProvider(
                                              userId)); // Force refresh
                                        }
                                      : null,
                                  icon: const Icon(Icons.logout),
                                  label: const Text('Checkout'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _isWithinRange
                                        ? Colors.red
                                        : Colors.grey,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12, horizontal: 32),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12)),
                                  ),
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
                      loading: () => const CircularProgressIndicator(),
                      error: (e, _) => Text('Error: $e',
                          style: AppTextStyles.bodyMedium
                              .copyWith(color: AppColors.error)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
