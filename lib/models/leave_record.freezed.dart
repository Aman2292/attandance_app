// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'leave_record.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$LeaveRecord {
  String get id;
  String get userId;
  String get type; // e.g., 'sick', 'casual', 'earned'
  DateTime get startDate;
  DateTime get endDate;
  String get status; // 'pending', 'approved', 'rejected'
  String get reason;
  String? get rejectionReason; // Added to support rejection reasons
  @TimestampConverter()
  DateTime? get createdAt;

  /// Create a copy of LeaveRecord
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $LeaveRecordCopyWith<LeaveRecord> get copyWith =>
      _$LeaveRecordCopyWithImpl<LeaveRecord>(this as LeaveRecord, _$identity);

  /// Serializes this LeaveRecord to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is LeaveRecord &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.startDate, startDate) ||
                other.startDate == startDate) &&
            (identical(other.endDate, endDate) || other.endDate == endDate) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.reason, reason) || other.reason == reason) &&
            (identical(other.rejectionReason, rejectionReason) ||
                other.rejectionReason == rejectionReason) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, userId, type, startDate,
      endDate, status, reason, rejectionReason, createdAt);

  @override
  String toString() {
    return 'LeaveRecord(id: $id, userId: $userId, type: $type, startDate: $startDate, endDate: $endDate, status: $status, reason: $reason, rejectionReason: $rejectionReason, createdAt: $createdAt)';
  }
}

/// @nodoc
abstract mixin class $LeaveRecordCopyWith<$Res> {
  factory $LeaveRecordCopyWith(
          LeaveRecord value, $Res Function(LeaveRecord) _then) =
      _$LeaveRecordCopyWithImpl;
  @useResult
  $Res call(
      {String id,
      String userId,
      String type,
      DateTime startDate,
      DateTime endDate,
      String status,
      String reason,
      String? rejectionReason,
      @TimestampConverter() DateTime? createdAt});
}

/// @nodoc
class _$LeaveRecordCopyWithImpl<$Res> implements $LeaveRecordCopyWith<$Res> {
  _$LeaveRecordCopyWithImpl(this._self, this._then);

  final LeaveRecord _self;
  final $Res Function(LeaveRecord) _then;

  /// Create a copy of LeaveRecord
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? type = null,
    Object? startDate = null,
    Object? endDate = null,
    Object? status = null,
    Object? reason = null,
    Object? rejectionReason = freezed,
    Object? createdAt = freezed,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _self.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _self.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      startDate: null == startDate
          ? _self.startDate
          : startDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      endDate: null == endDate
          ? _self.endDate
          : endDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      status: null == status
          ? _self.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      reason: null == reason
          ? _self.reason
          : reason // ignore: cast_nullable_to_non_nullable
              as String,
      rejectionReason: freezed == rejectionReason
          ? _self.rejectionReason
          : rejectionReason // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _LeaveRecord implements LeaveRecord {
  const _LeaveRecord(
      {required this.id,
      required this.userId,
      required this.type,
      required this.startDate,
      required this.endDate,
      required this.status,
      this.reason = '',
      this.rejectionReason,
      @TimestampConverter() this.createdAt});
  factory _LeaveRecord.fromJson(Map<String, dynamic> json) =>
      _$LeaveRecordFromJson(json);

  @override
  final String id;
  @override
  final String userId;
  @override
  final String type;
// e.g., 'sick', 'casual', 'earned'
  @override
  final DateTime startDate;
  @override
  final DateTime endDate;
  @override
  final String status;
// 'pending', 'approved', 'rejected'
  @override
  @JsonKey()
  final String reason;
  @override
  final String? rejectionReason;
// Added to support rejection reasons
  @override
  @TimestampConverter()
  final DateTime? createdAt;

  /// Create a copy of LeaveRecord
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$LeaveRecordCopyWith<_LeaveRecord> get copyWith =>
      __$LeaveRecordCopyWithImpl<_LeaveRecord>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$LeaveRecordToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _LeaveRecord &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.startDate, startDate) ||
                other.startDate == startDate) &&
            (identical(other.endDate, endDate) || other.endDate == endDate) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.reason, reason) || other.reason == reason) &&
            (identical(other.rejectionReason, rejectionReason) ||
                other.rejectionReason == rejectionReason) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, userId, type, startDate,
      endDate, status, reason, rejectionReason, createdAt);

  @override
  String toString() {
    return 'LeaveRecord(id: $id, userId: $userId, type: $type, startDate: $startDate, endDate: $endDate, status: $status, reason: $reason, rejectionReason: $rejectionReason, createdAt: $createdAt)';
  }
}

/// @nodoc
abstract mixin class _$LeaveRecordCopyWith<$Res>
    implements $LeaveRecordCopyWith<$Res> {
  factory _$LeaveRecordCopyWith(
          _LeaveRecord value, $Res Function(_LeaveRecord) _then) =
      __$LeaveRecordCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id,
      String userId,
      String type,
      DateTime startDate,
      DateTime endDate,
      String status,
      String reason,
      String? rejectionReason,
      @TimestampConverter() DateTime? createdAt});
}

/// @nodoc
class __$LeaveRecordCopyWithImpl<$Res> implements _$LeaveRecordCopyWith<$Res> {
  __$LeaveRecordCopyWithImpl(this._self, this._then);

  final _LeaveRecord _self;
  final $Res Function(_LeaveRecord) _then;

  /// Create a copy of LeaveRecord
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? type = null,
    Object? startDate = null,
    Object? endDate = null,
    Object? status = null,
    Object? reason = null,
    Object? rejectionReason = freezed,
    Object? createdAt = freezed,
  }) {
    return _then(_LeaveRecord(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _self.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _self.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      startDate: null == startDate
          ? _self.startDate
          : startDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      endDate: null == endDate
          ? _self.endDate
          : endDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      status: null == status
          ? _self.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      reason: null == reason
          ? _self.reason
          : reason // ignore: cast_nullable_to_non_nullable
              as String,
      rejectionReason: freezed == rejectionReason
          ? _self.rejectionReason
          : rejectionReason // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

// dart format on
