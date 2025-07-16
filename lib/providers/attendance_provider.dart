import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/attendance_record.dart';
import '../services/attendance_service.dart';

final attendanceProvider =
    StreamProvider.family<AttendanceRecord?, String>((ref, userId) {
  final service = AttendanceService();
  return service.getTodayAttendance(userId);
});

final workingHoursStreamProvider = StreamProvider.family<List<Map<String, dynamic>>, Map<String, dynamic>>((ref, params) {
  final service = AttendanceService();
  final userId = params['userId'] as String;
  final start = params['start'] as DateTime;
  final end = params['end'] as DateTime;
  return service.getAttendanceForRange(userId, start, end).map((records) {
    return records.map((r) {
      double hours = 0;
      if (r.checkInTime != null && r.checkOutTime != null) {
        final duration = r.checkOutTime!.difference(r.checkInTime!);
        hours = duration.inMinutes / 60.0 - (r.totalBreakDuration / 3600.0);
        if (hours < 0) hours = 0;
      }
      return {
        'date': r.date,
        'hours': double.parse(hours.toStringAsFixed(2)),
      };
    }).toList();
  });
});


final attendanceRecordsProvider =
    StreamProvider.family<List<AttendanceRecord>, String>((ref, userId) {
  final service = AttendanceService();
  return service.getAttendanceRecords(userId);
});

final attendanceSummaryStreamProvider = StreamProvider.family<Map<String, int>, Map<String, dynamic>>((ref, params) {
  final userId = params['userId'] as String;
  final start = params['start'] as DateTime;
  final end = params['end'] as DateTime;
  final service = AttendanceService();
  return service.getAttendanceSummaryStream(userId, start, end);
});

final attendanceNotifierProvider =
    StateNotifierProvider.family<AttendanceNotifier, void, String>((ref, userId) {
  return AttendanceNotifier(userId);
});

class AttendanceNotifier extends StateNotifier<void> {
  final String userId;
  final AttendanceService _service = AttendanceService();

  AttendanceNotifier(this.userId) : super(null);

  Future<void> checkIn({required bool withinOfficeRadius, String? notes}) async {
    try {
      await _service.checkIn(userId: userId, withinOfficeRadius: withinOfficeRadius, notes: notes);
    } catch (e) {
      print('Check-in failed: $e');
      rethrow;
    }
  }

  Future<void> checkOut() async {
    try {
      await _service.checkOut(userId: userId);
    } catch (e) {
      print('Checkout failed: $e');
      rethrow;
    }
  }

  Future<void> startBreak() async {
    try {
      await _service.startBreak(userId: userId);
    } catch (e) {
      print('Start break failed: $e');
      rethrow;
    }
  }

  Future<void> endBreak() async {
    try {
      await _service.endBreak(userId: userId);
    } catch (e) {
      print('End break failed: $e');
      rethrow;
    }
  }
}