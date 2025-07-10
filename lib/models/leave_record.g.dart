// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'leave_record.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_LeaveRecord _$LeaveRecordFromJson(Map<String, dynamic> json) => _LeaveRecord(
      id: json['id'] as String,
      userId: json['userId'] as String,
      type: json['type'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      status: json['status'] as String,
      reason: json['reason'] as String? ?? '',
      createdAt:
          const TimestampConverter().fromJson(json['createdAt'] as Timestamp?),
    );

Map<String, dynamic> _$LeaveRecordToJson(_LeaveRecord instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'type': instance.type,
      'startDate': instance.startDate.toIso8601String(),
      'endDate': instance.endDate.toIso8601String(),
      'status': instance.status,
      'reason': instance.reason,
      'createdAt': const TimestampConverter().toJson(instance.createdAt),
    };
