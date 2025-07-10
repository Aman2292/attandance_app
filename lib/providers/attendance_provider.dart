import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/attendance_service.dart';
import '../models/attendance_record.dart';
import '../services/auth_service.dart';

final attendanceServiceProvider = Provider<AttendanceService>((ref) => AttendanceService());

final attendanceRecordsProvider = StreamProvider.family<List<AttendanceRecord>, String>((ref, userId) {
  return ref.watch(attendanceServiceProvider).getAttendanceRecords(userId);
});