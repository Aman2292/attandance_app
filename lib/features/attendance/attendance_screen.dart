// ignore_for_file: unused_result

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:iconsax/iconsax.dart';
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
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 18),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.accent, width: 2),
        boxShadow: [
          BoxShadow(
            color: AppColors.accent.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        text,
        style: AppTextStyles.heading3.copyWith(color: AppColors.accent),
      ),
    );
  }
}

class _AttendanceScreenState extends ConsumerState<AttendanceScreen> {
  Stream<Position>? _positionStream;
  bool _isWithinRange = false;
  bool _isLoadingLocation = true;
  StreamSubscription<Position>? _positionSubscription;
  latlong.LatLng? _officeLocation;
  double? _officeRadius;
  Position? _currentPosition;
  double? _currentDistance;
  String? _notesController;

  @override
  void initState() {
    super.initState();
    _loadOfficeConfig();
    _loadUserPreference();
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    super.dispose();
  }

  Future<void> _loadOfficeConfig() async {
    try {
      final configDoc = await FirebaseFirestore.instance
          .collection('config')
          .doc('office')
          .get();

      if (configDoc.exists) {
        final data = configDoc.data() as Map<String, dynamic>;
        print('Raw config data from Firestore: $data');

        final lat = _parseCoordinate(data['latitude']);
        final lng = _parseCoordinate(data['longitude']);
        final radius = _parseCoordinate(data['radiusMeters']);

        if (lat != null && lng != null && radius != null) {
          setState(() {
            _officeLocation = latlong.LatLng(lat, lng);
            _officeRadius = radius;
          });
          print('Office config loaded successfully:');
          print('  Latitude: $lat');
          print('  Longitude: $lng');
          print('  Radius: $radius meters');
          await _startLocationStream();
        } else {
          print('Invalid coordinate data in Firestore config');
          _setDefaultLocation();
          await _startLocationStream();
        }
      } else {
        print('Office config document not found in config collection');
        _setDefaultLocation();
        await _startLocationStream();
      }
    } catch (e) {
      print('Error loading office config: $e');
      _setDefaultLocation();
      await _startLocationStream();
    }
  }

  double? _parseCoordinate(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  void _setDefaultLocation() {
    setState(() {
      _officeLocation = latlong.LatLng(AppConstants.officeLatitude, AppConstants.officeLongitude);
      _officeRadius = AppConstants.officeRadiusInMeters.toDouble();
    });
    print('Using default location: ${AppConstants.officeLatitude}, ${AppConstants.officeLongitude}');
  }

  Future<void> _startLocationStream() async {
    if (_officeLocation == null || _officeRadius == null) return;

    setState(() => _isLoadingLocation = true);

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showSnackBar('Please enable location services');
      setState(() {
        _isWithinRange = false;
        _isLoadingLocation = false;
      });
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _showSnackBar('Location permissions denied');
        setState(() {
          _isWithinRange = false;
          _isLoadingLocation = false;
        });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _showSnackBar('Location permissions are permanently denied');
      setState(() {
        _isWithinRange = false;
        _isLoadingLocation = false;
      });
      return;
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      final isWithinRange = await _checkLocation(position);

      setState(() {
        _currentPosition = position;
        _isWithinRange = isWithinRange;
        _isLoadingLocation = false;
      });

      _positionStream = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 5,
        ),
      );

      _positionSubscription?.cancel();
      _positionSubscription = _positionStream!.listen((position) async {
        final isWithinRange = await _checkLocation(position);
        if (mounted) {
          setState(() {
            _currentPosition = position;
            _isWithinRange = isWithinRange;
          });
        }
      }, onError: (e) {
        print('Location stream error: $e');
        if (mounted) setState(() => _isWithinRange = false);
      });
    } catch (e) {
      print('Error starting location stream: $e');
      setState(() => _isLoadingLocation = false);
      _showSnackBar('Failed to get location: $e');
    }
  }

  Future<void> _refreshLocation() async {
    setState(() => _isLoadingLocation = true);
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      final isWithinRange = await _checkLocation(position);

      setState(() {
        _currentPosition = position;
        _isWithinRange = isWithinRange;
        _isLoadingLocation = false;
      });
      _showSnackBar('Location refreshed successfully');
    } catch (e) {
      print('Error refreshing location: $e');
      setState(() => _isLoadingLocation = false);
      _showSnackBar('Failed to refresh location: $e');
    }
  }

  void _showSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message, style: AppTextStyles.bodyMedium.copyWith(color: Colors.white)),
          backgroundColor: AppColors.info,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<bool> _checkLocation(Position position) async {
    if (_officeLocation == null || _officeRadius == null) return false;

    final distance = Geolocator.distanceBetween(
      position.latitude,
      position.longitude,
      _officeLocation!.latitude,
      _officeLocation!.longitude,
    );

    setState(() => _currentDistance = distance);
    print('Current distance from office: ${distance.toStringAsFixed(2)} meters');
    return distance <= _officeRadius!;
  }

  Future<void> _loadUserPreference() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = ref.read(authServiceProvider).currentUser?.uid;
    if (userId != null) await prefs.setString('userId', userId);
  }

  Future<String?> _showNotesDialog() async {
    final TextEditingController controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Reason for Lateness', style: AppTextStyles.heading3),
        content: TextField(
          controller: controller,
          decoration: AppInputDecorations.textFieldDecoration(
            labelText: 'Enter reason',
            hintText: 'e.g., Traffic delay',
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            style: AppButtonStyles.outlinedButton,
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: AppTextStyles.button.copyWith(color: AppColors.primary)),
          ),
          TextButton(
            style: AppButtonStyles.primaryButton,
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: Text('Submit', style: AppTextStyles.button),
          ),
        ],
      ),
    );
  }

  Future<bool?> _showConfirmationDialog(String action) async {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm $action', style: AppTextStyles.heading3),
        content: Text('Are you sure you want to $action?', style: AppTextStyles.bodyMedium),
        actions: [
          TextButton(
            style: AppButtonStyles.outlinedButton,
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: AppTextStyles.button.copyWith(color: AppColors.primary)),
          ),
          TextButton(
            style: AppButtonStyles.primaryButton,
            onPressed: () => Navigator.pop(context, true),
            child: Text('Confirm', style: AppTextStyles.button),
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
        title: Text(
          'Attendance',
          style: AppTextStyles.heading2.copyWith(color: AppColors.surface),
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
        
      
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Current Time and Attendance Actions Card
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      colors: [AppColors.primary, AppColors.accent],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Current Time Section
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Current Time',
                              style: AppTextStyles.heading3.copyWith(color: Colors.white),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _TimeBlock(text: DateFormat('h').format(DateTime.now())),
                                const SizedBox(width: 8),
                                Text(
                                  ':',
                                  style: AppTextStyles.heading2.copyWith(color: Colors.white),
                                ),
                                const SizedBox(width: 8),
                                _TimeBlock(text: DateFormat('mm').format(DateTime.now())),
                                const SizedBox(width: 8),
                                _TimeBlock(text: DateFormat('a').format(DateTime.now())),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Center(
                              child: Text(
                                DateFormat('EEEE, MMMM d, yyyy').format(DateTime.now()),
                                style: AppTextStyles.bodyMedium.copyWith(color: Colors.white70),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Attendance Actions Section
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.surface.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Attendance Actions',
                              style: AppTextStyles.heading3.copyWith(color: Colors.white),
                            ),
                            const SizedBox(height: 16),
                            attendanceAsync.when(
                              data: (attendance) {
                                final now = DateTime.now();
                                final isAfter930 = now.hour > 9 || (now.hour == 9 && now.minute >= 30);

                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Status chips
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      children: [
                                        Chip(
                                          label: Text(
                                            attendance?.checkInTime != null ? 'Checked In' : 'Not Checked In',
                                            style: AppTextStyles.bodySmall.copyWith(color: Colors.white),
                                          ),
                                          backgroundColor: attendance?.checkInTime != null
                                              ? AppColors.present
                                              : AppColors.textHint,
                                          side: BorderSide.none,
                                        ),
                                        if (attendance?.isLate == true)
                                          Chip(
                                            label: Text(
                                              'Late',
                                              style: AppTextStyles.bodySmall.copyWith(color: Colors.white),
                                            ),
                                            backgroundColor: AppColors.late,
                                            side: BorderSide.none,
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),

                                    // Action buttons
                                    if (attendance?.checkInTime == null)
                                      SizedBox(
                                        width: double.infinity,
                                        child: ElevatedButton.icon(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: _isWithinRange ? AppColors.success : AppColors.textHint,
                                            foregroundColor: Colors.white,
                                            textStyle: AppTextStyles.button,
                                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                          ),
                                          onPressed: _isWithinRange
                                              ? () async {
                                                  final confirm = await _showConfirmationDialog('Check In');
                                                  if (confirm == true) {
                                                    try {
                                                      final notes = isAfter930 ? await _showNotesDialog() : null;
                                                      await attendanceNotifier.checkIn(
                                                        withinOfficeRadius: _isWithinRange,
                                                        notes: notes,
                                                      );
                                                      await Future.delayed(const Duration(milliseconds: 500));
                                                      ref.refresh(attendanceProvider(userId));
                                                      _showSnackBar('Checked in successfully!');
                                                    } catch (e) {
                                                      _showSnackBar('Error checking in: $e');
                                                    }
                                                  }
                                                }
                                              : null,
                                          icon: const Icon(Iconsax.login),
                                          label: Text('Check In', style: AppTextStyles.button),
                                        ),
                                      )
                                    else if (attendance?.checkOutTime == null) ...[
                                      Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: AppColors.present.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(color: AppColors.present),
                                        ),
                                        child: Text(
                                          'Checked In at: ${DateFormat('HH:mm').format(attendance!.checkInTime!)}',
                                          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.present),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                      const SizedBox(height: 16),

                                      if (attendance.breakStartTime == null)
                                        SizedBox(
                                          width: double.infinity,
                                          child: ElevatedButton.icon(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: _isWithinRange ? AppColors.warning : AppColors.textHint,
                                              foregroundColor: Colors.white,
                                              textStyle: AppTextStyles.button,
                                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                            ),
                                            onPressed: _isWithinRange
                                                ? () async {
                                                    final confirm = await _showConfirmationDialog('Start Break');
                                                    if (confirm == true) {
                                                      try {
                                                        await attendanceNotifier.startBreak();
                                                        await Future.delayed(const Duration(milliseconds: 500));
                                                        ref.refresh(attendanceProvider(userId));
                                                        _showSnackBar('Break started!');
                                                      } catch (e) {
                                                        _showSnackBar('Error starting break: $e');
                                                      }
                                                    }
                                                  }
                                                : null,
                                            icon: const Icon(Iconsax.pause),
                                            label: Text('Start Break', style: AppTextStyles.button),
                                          ),
                                        ),
                                      if (attendance.breakStartTime != null && attendance.breakEndTime == null)
                                        SizedBox(
                                          width: double.infinity,
                                          child: ElevatedButton.icon(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: _isWithinRange ? AppColors.info : AppColors.textHint,
                                              foregroundColor: Colors.white,
                                              textStyle: AppTextStyles.button,
                                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                            ),
                                            onPressed: _isWithinRange
                                                ? () async {
                                                    final confirm = await _showConfirmationDialog('End Break');
                                                    if (confirm == true) {
                                                      try {
                                                        await attendanceNotifier.endBreak();
                                                        await Future.delayed(const Duration(milliseconds: 500));
                                                        ref.refresh(attendanceProvider(userId));
                                                        _showSnackBar('Break ended!');
                                                      } catch (e) {
                                                        _showSnackBar('Error ending break: $e');
                                                      }
                                                    }
                                                  }
                                                : null,
                                            icon: const Icon(Iconsax.play),
                                            label: Text('End Break', style: AppTextStyles.button),
                                          ),
                                        ),
                                      if (attendance.breakEndTime != null)
                                        SizedBox(
                                          width: double.infinity,
                                          child: ElevatedButton.icon(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: _isWithinRange ? AppColors.error : AppColors.textHint,
                                              foregroundColor: Colors.white,
                                              textStyle: AppTextStyles.button,
                                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                            ),
                                            onPressed: _isWithinRange
                                                ? () async {
                                                    final confirm = await _showConfirmationDialog('Check Out');
                                                    if (confirm == true) {
                                                      try {
                                                        await attendanceNotifier.checkOut();
                                                        await Future.delayed(const Duration(milliseconds: 500));
                                                        ref.refresh(attendanceProvider(userId));
                                                        _showSnackBar('Checked out successfully!');
                                                      } catch (e) {
                                                        _showSnackBar('Error checking out: $e');
                                                      }
                                                    }
                                                  }
                                                : null,
                                            icon: const Icon(Iconsax.logout),
                                            label: Text('Check Out', style: AppTextStyles.button),
                                          ),
                                        ),
                                      if (attendance.breakEndTime != null)
                                        Container(
                                          width: double.infinity,
                                          padding: const EdgeInsets.all(12),
                                          margin: const EdgeInsets.only(top: 16),
                                          decoration: BoxDecoration(
                                            color: AppColors.info.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(8),
                                            border: Border.all(color: AppColors.info),
                                          ),
                                          child: Text(
                                            'Break Duration: ${attendance.totalBreakDuration ~/ 60} minutes',
                                            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.info),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                    ],
                                  ],
                                );
                              },
                              loading: () => const Center(child: CircularProgressIndicator(color: Colors.white)),
                              error: (e, _) => Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: AppColors.error.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: AppColors.error),
                                ),
                                child: Text(
                                  'Error: $e',
                                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.error),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Location Status Card
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: Colors.white,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Location Status',
                          style: AppTextStyles.heading3.copyWith(color: AppColors.textPrimary),
                        ),
                        const SizedBox(height: 16),
                        if (_isLoadingLocation)
                          Center(
                            child: Column(
                              children: [
                                CircularProgressIndicator(color: AppColors.primary),
                                const SizedBox(height: 8),
                                Text(
                                  'Getting your location...',
                                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                          )
                        else ...[
                          Row(
                            children: [
                              Icon(
                                _isWithinRange ? Icons.check_circle : Icons.cancel,
                                color: _isWithinRange ? AppColors.success : AppColors.error,
                                size: 24,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _isWithinRange ? 'Within Office Area' : 'Outside Office Area',
                                      style: AppTextStyles.bodyLarge.copyWith(
                                        color: _isWithinRange ? AppColors.success : AppColors.error,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    if (_currentDistance != null)
                                      Text(
                                        'Distance: ${_currentDistance!.toStringAsFixed(0)}m from office',
                                        style: AppTextStyles.bodySmall.copyWith(color: AppColors.textHint),
                                      ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Iconsax.refresh),
                                color: AppColors.primary,
                                onPressed: _refreshLocation,
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.textHint),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: SizedBox(
                                height: 200,
                                width: double.infinity,
                                child: _officeLocation != null && _officeRadius != null
                                    ? FlutterMap(
                                        options: MapOptions(
                                          initialCenter: _officeLocation!,
                                          initialZoom: 16,
                                          maxZoom: 18,
                                        ),
                                        children: [
                                          TileLayer(
                                            urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                                            subdomains: const ['a', 'b', 'c'],
                                          ),
                                          CircleLayer(
                                            circles: [
                                              CircleMarker(
                                                point: _officeLocation!,
                                                radius: _officeRadius!,
                                                useRadiusInMeter: true,
                                                color: AppColors.accent.withOpacity(0.2),
                                                borderColor: AppColors.accent,
                                                borderStrokeWidth: 2,
                                              ),
                                            ],
                                          ),
                                          MarkerLayer(
                                            markers: [
                                              Marker(
                                                point: _officeLocation!,
                                                width: 40,
                                                height: 40,
                                                child: Icon(
                                                  Icons.business,
                                                  color: AppColors.accent,
                                                  size: 30,
                                                ),
                                              ),
                                              if (_currentPosition != null)
                                                Marker(
                                                  point: latlong.LatLng(
                                                    _currentPosition!.latitude,
                                                    _currentPosition!.longitude,
                                                  ),
                                                  width: 40,
                                                  height: 40,
                                                  child: Icon(
                                                    Icons.my_location,
                                                    color: AppColors.error,
                                                    size: 30,
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ],
                                      )
                                    : Center(
                                        child: Text(
                                          'Loading map...',
                                          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                                        ),
                                      ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}