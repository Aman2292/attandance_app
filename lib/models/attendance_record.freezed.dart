// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'attendance_record.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AttendanceRecord {
  String get id;
  String get userId;
  DateTime get date;
  String get status; // 'present', 'absent', 'late'
  String get remarks;
  @TimestampConverter()
  DateTime? get createdAt;

  /// Create a copy of AttendanceRecord
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $AttendanceRecordCopyWith<AttendanceRecord> get copyWith =>
      _$AttendanceRecordCopyWithImpl<AttendanceRecord>(
          this as AttendanceRecord, _$identity);

  /// Serializes this AttendanceRecord to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is AttendanceRecord &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.remarks, remarks) || other.remarks == remarks) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, userId, date, status, remarks, createdAt);

  @override
  String toString() {
    return 'AttendanceRecord(id: $id, userId: $userId, date: $date, status: $status, remarks: $remarks, createdAt: $createdAt)';
  }
}

/// @nodoc
abstract mixin class $AttendanceRecordCopyWith<$Res> {
  factory $AttendanceRecordCopyWith(
          AttendanceRecord value, $Res Function(AttendanceRecord) _then) =
      _$AttendanceRecordCopyWithImpl;
  @useResult
  $Res call(
      {String id,
      String userId,
      DateTime date,
      String status,
      String remarks,
      @TimestampConverter() DateTime? createdAt});
}

/// @nodoc
class _$AttendanceRecordCopyWithImpl<$Res>
    implements $AttendanceRecordCopyWith<$Res> {
  _$AttendanceRecordCopyWithImpl(this._self, this._then);

  final AttendanceRecord _self;
  final $Res Function(AttendanceRecord) _then;

  /// Create a copy of AttendanceRecord
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? date = null,
    Object? status = null,
    Object? remarks = null,
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
      date: null == date
          ? _self.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      status: null == status
          ? _self.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      remarks: null == remarks
          ? _self.remarks
          : remarks // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: freezed == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _AttendanceRecord implements AttendanceRecord {
  const _AttendanceRecord(
      {required this.id,
      required this.userId,
      required this.date,
      required this.status,
      this.remarks = '',
      @TimestampConverter() this.createdAt});
  factory _AttendanceRecord.fromJson(Map<String, dynamic> json) =>
      _$AttendanceRecordFromJson(json);

  @override
  final String id;
  @override
  final String userId;
  @override
  final DateTime date;
  @override
  final String status;
// 'present', 'absent', 'late'
  @override
  @JsonKey()
  final String remarks;
  @override
  @TimestampConverter()
  final DateTime? createdAt;

  /// Create a copy of AttendanceRecord
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$AttendanceRecordCopyWith<_AttendanceRecord> get copyWith =>
      __$AttendanceRecordCopyWithImpl<_AttendanceRecord>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$AttendanceRecordToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _AttendanceRecord &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.remarks, remarks) || other.remarks == remarks) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, userId, date, status, remarks, createdAt);

  @override
  String toString() {
    return 'AttendanceRecord(id: $id, userId: $userId, date: $date, status: $status, remarks: $remarks, createdAt: $createdAt)';
  }
}

/// @nodoc
abstract mixin class _$AttendanceRecordCopyWith<$Res>
    implements $AttendanceRecordCopyWith<$Res> {
  factory _$AttendanceRecordCopyWith(
          _AttendanceRecord value, $Res Function(_AttendanceRecord) _then) =
      __$AttendanceRecordCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id,
      String userId,
      DateTime date,
      String status,
      String remarks,
      @TimestampConverter() DateTime? createdAt});
}

/// @nodoc
class __$AttendanceRecordCopyWithImpl<$Res>
    implements _$AttendanceRecordCopyWith<$Res> {
  __$AttendanceRecordCopyWithImpl(this._self, this._then);

  final _AttendanceRecord _self;
  final $Res Function(_AttendanceRecord) _then;

  /// Create a copy of AttendanceRecord
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? date = null,
    Object? status = null,
    Object? remarks = null,
    Object? createdAt = freezed,
  }) {
    return _then(_AttendanceRecord(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _self.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      date: null == date
          ? _self.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      status: null == status
          ? _self.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      remarks: null == remarks
          ? _self.remarks
          : remarks // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: freezed == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

// dart format on
