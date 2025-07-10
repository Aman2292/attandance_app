import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'attendance_record.freezed.dart';
part 'attendance_record.g.dart';

@freezed
abstract class AttendanceRecord with _$AttendanceRecord {
  const factory AttendanceRecord({
    required String id,
    required String userId,
    required DateTime date,
    required String status, // 'present', 'absent', 'late'
    @Default('') String remarks,
    @TimestampConverter() DateTime? createdAt,
  }) = _AttendanceRecord;

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) => _$AttendanceRecordFromJson(json);

  factory AttendanceRecord.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AttendanceRecord.fromJson({'id': doc.id, ...data});
  }
}

class TimestampConverter implements JsonConverter<DateTime?, Timestamp?> {
  const TimestampConverter();

  @override
  DateTime? fromJson(Timestamp? timestamp) => timestamp?.toDate();

  @override
  Timestamp? toJson(DateTime? date) => date != null ? Timestamp.fromDate(date) : null;
}