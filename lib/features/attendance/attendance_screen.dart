import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:latlong2/latlong.dart' as latlong;
import 'package:go_router/go_router.dart';
import '../../core/constants.dart';
import '../../providers/attendance_provider.dart';
import '../../providers/user_provider.dart';
import 'attendance_map_widget.dart';


class AttendanceScreen extends ConsumerStatefulWidget {
  const AttendanceScreen({super.key});

  @override
  ConsumerState<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends ConsumerState<AttendanceScreen>
    with TickerProviderStateMixin {
  // Location configuration
  static const double _officeLatitude = 19.194614;
  static const double _officeLongitude = 72.945651;
  static const double _officeRadiusMeters = 200;

  // State variables
  bool _isWithinRange = false;
  bool _isLoadingLocation = true;
  bool _isActionLoading = false;
  StreamSubscription<Position>? _positionSubscription;
  Position? _currentPosition;
  double? _currentDistance;
  Timer? _timeUpdateTimer;
  latlong.LatLng? _officeLocation;
  double? _officeRadius;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadOfficeConfig();
    _loadUserPreference();
    _startTimeUpdateTimer();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _fadeController.forward();
  }

  void _startTimeUpdateTimer() {
    _timeUpdateTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    _timeUpdateTimer?.cancel();
    _fadeController.dispose();
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
        final lat = _parseCoordinate(data['latitude']);
        final lng = _parseCoordinate(data['longitude']);
        final radius = _parseCoordinate(data['radiusMeters']);

        if (lat != null && lng != null && radius != null) {
          setState(() {
            _officeLocation = latlong.LatLng(lat, lng);
            _officeRadius = radius;
          });
          await _startLocationStream();
        } else {
          _setDefaultLocation();
          await _startLocationStream();
        }
      } else {
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
      _officeLocation = latlong.LatLng(_officeLatitude, _officeLongitude);
      _officeRadius = _officeRadiusMeters;
    });
  }

  Future<void> _startLocationStream() async {
    if (_officeLocation == null || _officeRadius == null) return;

    setState(() => _isLoadingLocation = true);

    try {
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

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      
      final isWithinRange = await _checkLocation(position);
      setState(() {
        _currentPosition = position;
        _isWithinRange = isWithinRange;
        _isLoadingLocation = false;
      });

      _positionSubscription = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 5,
        ),
      ).listen((position) async {
        final isWithinRange = await _checkLocation(position);
        if (mounted) {
          setState(() {
            _currentPosition = position;
            _isWithinRange = isWithinRange;
          });
        }
      });
    } catch (e) {
      print('Error starting location stream: $e');
      setState(() => _isLoadingLocation = false);
      _showSnackBar('Failed to get location: $e');
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
    return distance <= _officeRadius!;
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
      _showSnackBar('Failed to refresh location: $e');
      setState(() => _isLoadingLocation = false);
    }
  }

  void _showSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(
                Iconsax.info_circle,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  message,
                  style: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
                ),
              ),
            ],
          ),
          backgroundColor: AppColors.info,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(10),
          elevation: 6,
        ),
      );
    }
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.warning.withOpacity(0.1),
                    AppColors.warning.withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Iconsax.clock, color: AppColors.warning),
            ),
            const SizedBox(width: 10),
            Text('Reason for Lateness', style: AppTextStyles.heading3),
          ],
        ),
        content: TextField(
          controller: controller,
          decoration: AppInputDecorations.textFieldDecoration(
            labelText: 'Enter reason',
            hintText: 'e.g., Traffic delay, Personal emergency',
            prefixIcon: const Icon(Iconsax.message_text),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: AppTextStyles.button.copyWith(color: AppColors.primary)),
          ),
          ElevatedButton(
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(1),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withOpacity(0.1),
                    AppColors.primary.withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Icon(
                action.toLowerCase().contains('check in') ? Iconsax.login :
                action.toLowerCase().contains('check out') ? Iconsax.logout :
                action.toLowerCase().contains('break') ? Iconsax.cup :
                Iconsax.tick_circle,
                color: AppColors.surface,
              ),
            ),
            const SizedBox(width: 10),
            Text('Confirm $action', style: AppTextStyles.heading3),
          ],
        ),
        content: Text(
          'Are you sure you want to $action?',
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: AppTextStyles.button.copyWith(color: AppColors.primary)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Confirm', style: AppTextStyles.button.copyWith(color: AppColors.surface)),
          ),
        ],
      ),
    );
  }

  Widget _buildSimplifiedSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 100,
      floating: true,
      pinned: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
      leading: IconButton(
        icon: const Icon(
          Iconsax.arrow_left,
          color: Colors.white,
        ),
        onPressed: () => context.pop(),
      ),
      actions: [
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.surface.withOpacity(0.8),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Iconsax.calendar,
              color: AppColors.primary,
              size: 20,
            ),
          ),
          onPressed: () => context.push('/employee/attendance/calendar'),
        ),
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.surface.withOpacity(0.8),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Iconsax.document_text,
              color: AppColors.primary,
              size: 20,
            ),
          ),
          onPressed: () => context.push('/employee/attendance/list'),
        ),
        const SizedBox(width: 8),
      ],
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          'Attendance',
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
                AppColors.primary,
                AppColors.primary.withOpacity(0.8),
                const Color.fromARGB(255, 0, 84, 181).withOpacity(0.6),
                const Color.fromARGB(255, 0, 24, 181).withOpacity(0.4),
              ],
            ),
          ),
        ),
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
      body: CustomScrollView(
        slivers: [
          _buildSimplifiedSliverAppBar(),
          
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Current Time Section
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 20),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Colors.white,
                            Color(0xFFF8F9FA),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.surface.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.surface.withOpacity(0.5),
                                  AppColors.surface.withOpacity(0.5),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Iconsax.clock,
                              color: AppColors.primary,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  DateFormat('hh:mm a').format(DateTime.now()),
                                  style: AppTextStyles.heading2.copyWith(
                                    color: AppColors.surface,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  DateFormat('EEEE, MMM d').format(DateTime.now()),
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

                    // Enhanced Map with Action Buttons
                    attendanceAsync.when(
                      data: (attendance) {
                        final now = DateTime.now();
                        final isAfter930 = now.hour > 9 || (now.hour == 9 && now.minute >= 30);
                        
                        // Determine status tags
                        List<Widget> statusTags = [];
                        if (attendance?.checkInTime != null) {
                          final checkInTime = attendance!.checkInTime!;
                          final isLate = checkInTime.hour > 9 || (checkInTime.hour == 9 && checkInTime.minute > 30);
                          
                          statusTags.add(
                            StatusTag(
                              text: isLate ? 'Late Arrival' : 'On Time',
                              color: isLate ? AppColors.warning : AppColors.success,
                              icon: isLate ? Iconsax.clock : Iconsax.tick_circle,
                            ),
                          );
                          
                          if (attendance.checkInTime != null && attendance.checkOutTime == null) {
                            final workingHours = DateTime.now().difference(attendance.checkInTime!);
                            final hours = workingHours.inHours;
                            final minutes = workingHours.inMinutes.remainder(60);
                            
                            statusTags.add(
                              StatusTag(
                                text: 'Working ${hours}h ${minutes}m',
                                color: AppColors.info,
                                icon: Iconsax.timer_1,
                              ),
                            );
                          }
                        }

                        // Determine action buttons
                        Widget? actionButtons;
                        if (attendance?.checkInTime == null) {
                          actionButtons = MapActionButton(
                            text: 'Check In',
                            icon: Iconsax.login,
                            backgroundColor: _isWithinRange ? AppColors.success : AppColors.textHint,
                            onPressed: _isWithinRange
                                ? () async {
                                    final confirm = await _showConfirmationDialog('Check In');
                                    if (confirm == true) {
                                      setState(() => _isActionLoading = true);
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
                                      } finally {
                                        setState(() => _isActionLoading = false);
                                      }
                                    }
                                  }
                                : null,
                            isLoading: _isActionLoading,
                          );
                        } else if (attendance?.checkOutTime == null) {
                          actionButtons = Row(
                            children: [
                              if (attendance!.breakStartTime == null)
                                Expanded(
                                  child: MapActionButton(
                                    text: 'Break',
                                    icon: Iconsax.cup,
                                    backgroundColor: _isWithinRange ? AppColors.warning : AppColors.textHint,
                                    onPressed: _isWithinRange
                                        ? () async {
                                            final confirm = await _showConfirmationDialog('Start Break');
                                            if (confirm == true) {
                                              setState(() => _isActionLoading = true);
                                              try {
                                                await attendanceNotifier.startBreak();
                                                await Future.delayed(const Duration(milliseconds: 500));
                                                ref.refresh(attendanceProvider(userId));
                                                _showSnackBar('Break started!');
                                              } catch (e) {
                                                _showSnackBar('Error starting break: $e');
                                              } finally {
                                                setState(() => _isActionLoading = false);
                                              }
                                            }
                                          }
                                        : null,
                                    isLoading: _isActionLoading,
                                  ),
                                ),
                              if (attendance.breakStartTime != null && attendance.breakEndTime == null)
                                Expanded(
                                  child: MapActionButton(
                                    text: 'End Break',
                                    icon: Iconsax.play,
                                    backgroundColor: _isWithinRange ? AppColors.info : AppColors.textHint,
                                    onPressed: _isWithinRange
                                        ? () async {
                                            final confirm = await _showConfirmationDialog('End Break');
                                            if (confirm == true) {
                                              setState(() => _isActionLoading = true);
                                              try {
                                                await attendanceNotifier.endBreak();
                                                await Future.delayed(const Duration(milliseconds: 500));
                                                ref.refresh(attendanceProvider(userId));
                                                _showSnackBar('Break ended!');
                                              } catch (e) {
                                                _showSnackBar('Error ending break: $e');
                                              } finally {
                                                setState(() => _isActionLoading = false);
                                              }
                                            }
                                          }
                                        : null,
                                    isLoading: _isActionLoading,
                                  ),
                                ),
                              if (attendance.breakEndTime != null) ...[
                                const SizedBox(width: 12),
                                Expanded(
                                  child: MapActionButton(
                                    text: 'Check Out',
                                    icon: Iconsax.logout,
                                    backgroundColor: _isWithinRange ? AppColors.error : AppColors.textHint,
                                    onPressed: _isWithinRange
                                        ? () async {
                                            final confirm = await _showConfirmationDialog('Check Out');
                                            if (confirm == true) {
                                              setState(() => _isActionLoading = true);
                                              try {
                                                await attendanceNotifier.checkOut();
                                                await Future.delayed(const Duration(milliseconds: 500));
                                                ref.refresh(attendanceProvider(userId));
                                                _showSnackBar('Checked out successfully!');
                                              } catch (e) {
                                                _showSnackBar('Error checking out: $e');
                                              } finally {
                                                setState(() => _isActionLoading = false);
                                              }
                                            }
                                          }
                                        : null,
                                    isLoading: _isActionLoading,
                                  ),
                                ),
                              ],
                            ],
                          );
                        }

                        return AttendanceMapWidget(
                          latitude: _officeLatitude,
                          longitude: _officeLongitude,
                          radiusMeters: _officeRadiusMeters,
                          currentPosition: _currentPosition,
                          isWithinRange: _isWithinRange,
                          isLoadingLocation: _isLoadingLocation,
                          currentDistance: _currentDistance,
                          onRefresh: _refreshLocation,
                          actionButtons: actionButtons,
                          statusTags: statusTags,
                        );
                      },
                      loading: () => AttendanceMapWidget(
                        latitude: _officeLatitude,
                        longitude: _officeLongitude,
                        radiusMeters: _officeRadiusMeters,
                        currentPosition: _currentPosition,
                        isWithinRange: _isWithinRange,
                        isLoadingLocation: _isLoadingLocation,
                        currentDistance: _currentDistance,
                        onRefresh: _refreshLocation,
                      ),
                      error: (error, stack) => AttendanceMapWidget(
                        latitude: _officeLatitude,
                        longitude: _officeLongitude,
                        radiusMeters: _officeRadiusMeters,
                        currentPosition: _currentPosition,
                        isWithinRange: _isWithinRange,
                        isLoadingLocation: _isLoadingLocation,
                        currentDistance: _currentDistance,
                        onRefresh: _refreshLocation,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
