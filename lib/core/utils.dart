// lib/core/utils.dart

import 'package:geolocator/geolocator.dart';
import 'package:attendance_app/core/constants.dart';

class LocationUtils {
  static Future<bool> isWithinOfficeRadius() async {
    final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    final distance = Geolocator.distanceBetween(
      AppConstants.officeLatitude,
      AppConstants.officeLongitude,
      position.latitude,
      position.longitude,
    );

    return distance <= AppConstants.officeRadiusInMeters;
  }

  static String formatTime(DateTime time) {
    return "${time.hour}:${time.minute.toString().padLeft(2, '0')}";
  }
}