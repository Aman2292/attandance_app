import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/leave_service.dart';
import '../models/leave_record.dart';

final leaveServiceProvider = Provider<LeaveService>((ref) => LeaveService());

final leaveRecordsProvider = StreamProvider.family<List<LeaveRecord>, String>((ref, userId) {
  return ref.watch(leaveServiceProvider).getLeaveRecords(userId);
});