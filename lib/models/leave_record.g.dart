// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'leave_record.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_LeaveRecord _$LeaveRecordFromJson(Map<String, dynamic> json) => _LeaveRecord(
      id: json['id'] as String,
      userId: json['userId'] as String,
      type: json['type'] as String,
      startDate: const IsoDateConverter().fromJson(json['startDate'] as String),
      endDate: const IsoDateConverter().fromJson(json['endDate'] as String),
      status: json['status'] as String,
      reason: json['reason'] as String? ?? '',
      rejectionReason: json['rejectionReason'] as String?,
      createdAt:
          const TimestampConverter().fromJson(json['createdAt'] as Timestamp?),
    );

Map<String, dynamic> _$LeaveRecordToJson(_LeaveRecord instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'type': instance.type,
      'startDate': const IsoDateConverter().toJson(instance.startDate),
      'endDate': const IsoDateConverter().toJson(instance.endDate),
      'status': instance.status,
      'reason': instance.reason,
      'rejectionReason': instance.rejectionReason,
      'createdAt': const TimestampConverter().toJson(instance.createdAt),
    };
