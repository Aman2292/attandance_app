// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attendance_record.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AttendanceRecord _$AttendanceRecordFromJson(Map<String, dynamic> json) =>
    _AttendanceRecord(
      id: json['id'] as String,
      userId: json['userId'] as String,
      date: DateTime.parse(json['date'] as String),
      status: json['status'] as String,
      remarks: json['remarks'] as String? ?? '',
      createdAt:
          const TimestampConverter().fromJson(json['createdAt'] as Timestamp?),
    );

Map<String, dynamic> _$AttendanceRecordToJson(_AttendanceRecord instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'date': instance.date.toIso8601String(),
      'status': instance.status,
      'remarks': instance.remarks,
      'createdAt': const TimestampConverter().toJson(instance.createdAt),
    };
