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
      notes: json['notes'] as String? ?? '',
      createdAt:
          const TimestampConverter().fromJson(json['createdAt'] as Timestamp?),
      checkInTime: const TimestampConverter()
          .fromJson(json['checkInTime'] as Timestamp?),
      checkOutTime: const TimestampConverter()
          .fromJson(json['checkOutTime'] as Timestamp?),
      breakStartTime: const TimestampConverter()
          .fromJson(json['breakStartTime'] as Timestamp?),
      breakEndTime: const TimestampConverter()
          .fromJson(json['breakEndTime'] as Timestamp?),
      totalBreakDuration: (json['totalBreakDuration'] as num?)?.toInt() ?? 0,
      isLate: json['isLate'] as bool? ?? false,
      withinOfficeRadius: json['withinOfficeRadius'] as bool? ?? false,
    );

Map<String, dynamic> _$AttendanceRecordToJson(_AttendanceRecord instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'date': instance.date.toIso8601String(),
      'status': instance.status,
      'notes': instance.notes,
      'createdAt': const TimestampConverter().toJson(instance.createdAt),
      'checkInTime': const TimestampConverter().toJson(instance.checkInTime),
      'checkOutTime': const TimestampConverter().toJson(instance.checkOutTime),
      'breakStartTime':
          const TimestampConverter().toJson(instance.breakStartTime),
      'breakEndTime': const TimestampConverter().toJson(instance.breakEndTime),
      'totalBreakDuration': instance.totalBreakDuration,
      'isLate': instance.isLate,
      'withinOfficeRadius': instance.withinOfficeRadius,
    };
