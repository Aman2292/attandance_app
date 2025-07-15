import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

part 'leave_record.freezed.dart';
part 'leave_record.g.dart';

class TimestampConverter implements JsonConverter<DateTime?, Timestamp?> {
  const TimestampConverter();

  @override
  DateTime? fromJson(Timestamp? timestamp) => timestamp?.toDate();

  @override
  Timestamp? toJson(DateTime? date) => date != null ? Timestamp.fromDate(date) : null;
}

class IsoDateConverter implements JsonConverter<DateTime, String> {
  const IsoDateConverter();

  @override
  DateTime fromJson(String isoString) => DateTime.parse(isoString);

  @override
  String toJson(DateTime date) => DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS").format(date);
}

@freezed
abstract class LeaveRecord with _$LeaveRecord {
  const factory LeaveRecord({
    required String id,
    required String userId,
    required String type, // e.g., 'sick', 'casual', 'earned'
    @IsoDateConverter() required DateTime startDate,
    @IsoDateConverter() required DateTime endDate,
    required String status, // 'pending', 'approved', 'rejected'
    @Default('') String reason,
    String? rejectionReason,
    @TimestampConverter() DateTime? createdAt,
  }) = _LeaveRecord;

  factory LeaveRecord.fromJson(Map<String, dynamic> json) => _$LeaveRecordFromJson(json);

  factory LeaveRecord.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return LeaveRecord.fromJson({'id': doc.id, ...data});
  }
}