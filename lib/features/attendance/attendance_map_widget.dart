import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as latlong;
import 'package:iconsax/iconsax.dart';
import 'package:geolocator/geolocator.dart';
import '../../../core/constants.dart';

class StatusTag extends StatelessWidget {
  final String text;
  final Color color;
  final IconData icon;

  const StatusTag({
    super.key,
    required this.text,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: 14,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: AppTextStyles.bodySmall.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class MapActionButton extends StatefulWidget {
  final String text;
  final IconData icon;
  final VoidCallback? onPressed;
  final Color backgroundColor;
  final bool isLoading;

  const MapActionButton({
    super.key,
    required this.text,
    required this.icon,
    this.onPressed,
    required this.backgroundColor,
    this.isLoading = false,
  });

  @override
  State<MapActionButton> createState() => _MapActionButtonState();
}

class _MapActionButtonState extends State<MapActionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: widget.backgroundColor,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: widget.backgroundColor.withOpacity(0.4),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(24),
                onTap: widget.onPressed,
                onTapDown: (_) => _controller.forward(),
                onTapUp: (_) => _controller.reverse(),
                onTapCancel: () => _controller.reverse(),
                child: Center(
                  child: widget.isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              widget.icon,
                              color: Colors.white,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              widget.text,
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class AttendanceMapWidget extends StatefulWidget {
  final double latitude;
  final double longitude;
  final double radiusMeters;
  final Position? currentPosition;
  final bool isWithinRange;
  final bool isLoadingLocation;
  final double? currentDistance;
  final VoidCallback? onRefresh;
  final Widget? actionButtons;
  final List<Widget>? statusTags;

  const AttendanceMapWidget({
    super.key,
    required this.latitude,
    required this.longitude,
    required this.radiusMeters,
    this.currentPosition,
    required this.isWithinRange,
    required this.isLoadingLocation,
    this.currentDistance,
    this.onRefresh,
    this.actionButtons,
    this.statusTags,
  });

  @override
  State<AttendanceMapWidget> createState() => _AttendanceMapWidgetState();
}

class _AttendanceMapWidgetState extends State<AttendanceMapWidget> {
  late MapController _mapController;
  double _currentZoom = 16.0;
  late latlong.LatLng _mapCenter;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _mapCenter = latlong.LatLng(widget.latitude, widget.longitude);
  }

  void _zoomIn() {
    setState(() {
      _currentZoom = (_currentZoom + 1).clamp(1.0, 18.0);
    });
    _mapController.move(_mapCenter, _currentZoom);
  }

  void _zoomOut() {
    setState(() {
      _currentZoom = (_currentZoom - 1).clamp(1.0, 18.0);
    });
    _mapController.move(_mapCenter, _currentZoom);
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final mapHeight = screenHeight * 0.6;

    return Container(
      height: mapHeight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Stack(
          children: [
            // Map
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _mapCenter,
                initialZoom: _currentZoom,
                onMapEvent: (event) {
                  if (event is MapEventMove) {
                    setState(() {
                      _mapCenter = event.camera.center;
                      _currentZoom = event.camera.zoom;
                    });
                  }
                },
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://mt1.google.com/vt/lyrs=s&x={x}&y={y}&z={z}',
                  subdomains: const ['mt0', 'mt1', 'mt2', 'mt3'],
                ),
                CircleLayer(
                  circles: [
                    CircleMarker(
                      point: latlong.LatLng(widget.latitude, widget.longitude),
                      radius: widget.radiusMeters,
                      color: AppColors.primary.withOpacity(0.2),
                      borderColor: AppColors.primary,
                      borderStrokeWidth: 2,
                    ),
                  ],
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: latlong.LatLng(widget.latitude, widget.longitude),
                      width: 40,
                      height: 40,
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Iconsax.buildings_2,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                    if (widget.currentPosition != null)
                      Marker(
                        point: latlong.LatLng(
                          widget.currentPosition!.latitude,
                          widget.currentPosition!.longitude,
                        ),
                        width: 30,
                        height: 30,
                        child: Container(
                          decoration: BoxDecoration(
                            color: widget.isWithinRange ? AppColors.success : AppColors.error,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 3),
                            boxShadow: [
                              BoxShadow(
                                color: (widget.isWithinRange ? AppColors.success : AppColors.error).withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Iconsax.location,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
            
            // Status Tags and Refresh Button
            Positioned(
              top: 20,
              left: 10,
              right: 20,
              child: Row(
                children: [
                  if (widget.statusTags != null && widget.statusTags!.isNotEmpty)
                    ...widget.statusTags!.map((tag) => Padding(
                      padding: const EdgeInsets.only(right: 5),
                      child: tag,
                    )).toList(),
                  
                  const Spacer(),
                  
                  // Refresh Button
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.surface.withOpacity(0.4),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: widget.onRefresh,
                        child: const Padding(
                          padding: EdgeInsets.all(8),
                          child: Icon(
                            Iconsax.refresh,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Zoom Controls
            Positioned(
              bottom: widget.actionButtons != null ? 150 : 80,
              right: 20,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Zoom In
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.4),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(8),
                        onTap: _zoomIn,
                        child: const Padding(
                          padding: EdgeInsets.all(8),
                          child: Icon(
                            Iconsax.add,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Zoom Out
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.4),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(8),
                        onTap: _zoomOut,
                        child: const Padding(
                          padding: EdgeInsets.all(8),
                          child: Icon(
                            Iconsax.minus,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Location Status Container
            Positioned(
              bottom: widget.actionButtons != null ? 90 : 20,
              left: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.95),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: widget.isWithinRange ? AppColors.success : AppColors.error,
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      widget.isLoadingLocation
                          ? Iconsax.timer_1
                          : widget.isWithinRange
                              ? Iconsax.location_tick
                              : Iconsax.location_cross,
                      color: widget.isLoadingLocation
                          ? AppColors.warning
                          : widget.isWithinRange
                              ? AppColors.success
                              : AppColors.error,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      widget.isLoadingLocation
                          ? 'Getting location...'
                          : widget.isWithinRange
                              ? 'Within office range'
                              : 'Outside office range',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: widget.isLoadingLocation
                            ? AppColors.warning
                            : widget.isWithinRange
                                ? AppColors.success
                                : AppColors.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (widget.currentDistance != null) ...[
                      const SizedBox(width: 4),
                      Text(
                        '(${widget.currentDistance!.toStringAsFixed(0)}m)',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            
            // Action Buttons
            if (widget.actionButtons != null)
              Positioned(
                bottom: 20,
                left: 20,
                right: 20,
                child: widget.actionButtons!,
              ),
          ],
        ),
      ),
    );
  }
}
