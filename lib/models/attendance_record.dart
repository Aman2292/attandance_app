import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'attendance_record.freezed.dart';
part 'attendance_record.g.dart';

@freezed
abstract class AttendanceRecord with _$AttendanceRecord {
  const factory AttendanceRecord({
    required String id,
    required String userId,
    @TimestampConverter() required DateTime date,
    required String status, // 'present', 'absent', 'late'
    @Default('') String notes,
    @TimestampConverter() DateTime? createdAt,
    @TimestampConverter() DateTime? checkInTime,
    @TimestampConverter() DateTime? checkOutTime,
    @TimestampConverter() DateTime? breakStartTime,
    @TimestampConverter() DateTime? breakEndTime,
    @Default(0) int totalBreakDuration, // In seconds, max 3600 (1 hour)
    @Default(false) bool isLate, // True if after 9:30 AM
    @Default(false) bool withinOfficeRadius,
  }) = _AttendanceRecord;

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) =>
      _$AttendanceRecordFromJson(json);

  factory AttendanceRecord.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AttendanceRecord.fromJson({'id': doc.id, ...data}).copyWith(
      totalBreakDuration: (data['totalBreakDuration'] ?? 0) > 3600
          ? 3600
          : (data['totalBreakDuration'] ?? 0),
    );
  }
}

class TimestampConverter implements JsonConverter<DateTime?, Timestamp?> {
  const TimestampConverter();

  @override
  DateTime? fromJson(Timestamp? timestamp) => timestamp?.toDate();

  @override
  Timestamp? toJson(DateTime? date) => date != null ? Timestamp.fromDate(date) : null;
}