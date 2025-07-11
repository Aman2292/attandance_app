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
  @TimestampConverter()
  DateTime get date;
  String get status; // 'present', 'absent', 'late'
  String get notes;
  @TimestampConverter()
  DateTime? get createdAt;
  @TimestampConverter()
  DateTime? get checkInTime;
  @TimestampConverter()
  DateTime? get checkOutTime;
  @TimestampConverter()
  DateTime? get breakStartTime;
  @TimestampConverter()
  DateTime? get breakEndTime;
  int get totalBreakDuration; // In seconds, max 3600 (1 hour)
  bool get isLate; // True if after 9:30 AM
  bool get withinOfficeRadius;

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
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.checkInTime, checkInTime) ||
                other.checkInTime == checkInTime) &&
            (identical(other.checkOutTime, checkOutTime) ||
                other.checkOutTime == checkOutTime) &&
            (identical(other.breakStartTime, breakStartTime) ||
                other.breakStartTime == breakStartTime) &&
            (identical(other.breakEndTime, breakEndTime) ||
                other.breakEndTime == breakEndTime) &&
            (identical(other.totalBreakDuration, totalBreakDuration) ||
                other.totalBreakDuration == totalBreakDuration) &&
            (identical(other.isLate, isLate) || other.isLate == isLate) &&
            (identical(other.withinOfficeRadius, withinOfficeRadius) ||
                other.withinOfficeRadius == withinOfficeRadius));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      userId,
      date,
      status,
      notes,
      createdAt,
      checkInTime,
      checkOutTime,
      breakStartTime,
      breakEndTime,
      totalBreakDuration,
      isLate,
      withinOfficeRadius);

  @override
  String toString() {
    return 'AttendanceRecord(id: $id, userId: $userId, date: $date, status: $status, notes: $notes, createdAt: $createdAt, checkInTime: $checkInTime, checkOutTime: $checkOutTime, breakStartTime: $breakStartTime, breakEndTime: $breakEndTime, totalBreakDuration: $totalBreakDuration, isLate: $isLate, withinOfficeRadius: $withinOfficeRadius)';
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
      @TimestampConverter() DateTime date,
      String status,
      String notes,
      @TimestampConverter() DateTime? createdAt,
      @TimestampConverter() DateTime? checkInTime,
      @TimestampConverter() DateTime? checkOutTime,
      @TimestampConverter() DateTime? breakStartTime,
      @TimestampConverter() DateTime? breakEndTime,
      int totalBreakDuration,
      bool isLate,
      bool withinOfficeRadius});
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
    Object? notes = null,
    Object? createdAt = freezed,
    Object? checkInTime = freezed,
    Object? checkOutTime = freezed,
    Object? breakStartTime = freezed,
    Object? breakEndTime = freezed,
    Object? totalBreakDuration = null,
    Object? isLate = null,
    Object? withinOfficeRadius = null,
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
      notes: null == notes
          ? _self.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: freezed == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      checkInTime: freezed == checkInTime
          ? _self.checkInTime
          : checkInTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      checkOutTime: freezed == checkOutTime
          ? _self.checkOutTime
          : checkOutTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      breakStartTime: freezed == breakStartTime
          ? _self.breakStartTime
          : breakStartTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      breakEndTime: freezed == breakEndTime
          ? _self.breakEndTime
          : breakEndTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      totalBreakDuration: null == totalBreakDuration
          ? _self.totalBreakDuration
          : totalBreakDuration // ignore: cast_nullable_to_non_nullable
              as int,
      isLate: null == isLate
          ? _self.isLate
          : isLate // ignore: cast_nullable_to_non_nullable
              as bool,
      withinOfficeRadius: null == withinOfficeRadius
          ? _self.withinOfficeRadius
          : withinOfficeRadius // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _AttendanceRecord implements AttendanceRecord {
  const _AttendanceRecord(
      {required this.id,
      required this.userId,
      @TimestampConverter() required this.date,
      required this.status,
      this.notes = '',
      @TimestampConverter() this.createdAt,
      @TimestampConverter() this.checkInTime,
      @TimestampConverter() this.checkOutTime,
      @TimestampConverter() this.breakStartTime,
      @TimestampConverter() this.breakEndTime,
      this.totalBreakDuration = 0,
      this.isLate = false,
      this.withinOfficeRadius = false});
  factory _AttendanceRecord.fromJson(Map<String, dynamic> json) =>
      _$AttendanceRecordFromJson(json);

  @override
  final String id;
  @override
  final String userId;
  @override
  @TimestampConverter()
  final DateTime date;
  @override
  final String status;
// 'present', 'absent', 'late'
  @override
  @JsonKey()
  final String notes;
  @override
  @TimestampConverter()
  final DateTime? createdAt;
  @override
  @TimestampConverter()
  final DateTime? checkInTime;
  @override
  @TimestampConverter()
  final DateTime? checkOutTime;
  @override
  @TimestampConverter()
  final DateTime? breakStartTime;
  @override
  @TimestampConverter()
  final DateTime? breakEndTime;
  @override
  @JsonKey()
  final int totalBreakDuration;
// In seconds, max 3600 (1 hour)
  @override
  @JsonKey()
  final bool isLate;
// True if after 9:30 AM
  @override
  @JsonKey()
  final bool withinOfficeRadius;

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
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.checkInTime, checkInTime) ||
                other.checkInTime == checkInTime) &&
            (identical(other.checkOutTime, checkOutTime) ||
                other.checkOutTime == checkOutTime) &&
            (identical(other.breakStartTime, breakStartTime) ||
                other.breakStartTime == breakStartTime) &&
            (identical(other.breakEndTime, breakEndTime) ||
                other.breakEndTime == breakEndTime) &&
            (identical(other.totalBreakDuration, totalBreakDuration) ||
                other.totalBreakDuration == totalBreakDuration) &&
            (identical(other.isLate, isLate) || other.isLate == isLate) &&
            (identical(other.withinOfficeRadius, withinOfficeRadius) ||
                other.withinOfficeRadius == withinOfficeRadius));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      userId,
      date,
      status,
      notes,
      createdAt,
      checkInTime,
      checkOutTime,
      breakStartTime,
      breakEndTime,
      totalBreakDuration,
      isLate,
      withinOfficeRadius);

  @override
  String toString() {
    return 'AttendanceRecord(id: $id, userId: $userId, date: $date, status: $status, notes: $notes, createdAt: $createdAt, checkInTime: $checkInTime, checkOutTime: $checkOutTime, breakStartTime: $breakStartTime, breakEndTime: $breakEndTime, totalBreakDuration: $totalBreakDuration, isLate: $isLate, withinOfficeRadius: $withinOfficeRadius)';
  }
  
  @override
  where(bool Function(dynamic r) param0) {
    // TODO: implement where
    throw UnimplementedError();
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
      @TimestampConverter() DateTime date,
      String status,
      String notes,
      @TimestampConverter() DateTime? createdAt,
      @TimestampConverter() DateTime? checkInTime,
      @TimestampConverter() DateTime? checkOutTime,
      @TimestampConverter() DateTime? breakStartTime,
      @TimestampConverter() DateTime? breakEndTime,
      int totalBreakDuration,
      bool isLate,
      bool withinOfficeRadius});
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
    Object? notes = null,
    Object? createdAt = freezed,
    Object? checkInTime = freezed,
    Object? checkOutTime = freezed,
    Object? breakStartTime = freezed,
    Object? breakEndTime = freezed,
    Object? totalBreakDuration = null,
    Object? isLate = null,
    Object? withinOfficeRadius = null,
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
      notes: null == notes
          ? _self.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: freezed == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      checkInTime: freezed == checkInTime
          ? _self.checkInTime
          : checkInTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      checkOutTime: freezed == checkOutTime
          ? _self.checkOutTime
          : checkOutTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      breakStartTime: freezed == breakStartTime
          ? _self.breakStartTime
          : breakStartTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      breakEndTime: freezed == breakEndTime
          ? _self.breakEndTime
          : breakEndTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      totalBreakDuration: null == totalBreakDuration
          ? _self.totalBreakDuration
          : totalBreakDuration // ignore: cast_nullable_to_non_nullable
              as int,
      isLate: null == isLate
          ? _self.isLate
          : isLate // ignore: cast_nullable_to_non_nullable
              as bool,
      withinOfficeRadius: null == withinOfficeRadius
          ? _self.withinOfficeRadius
          : withinOfficeRadius // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

// dart format on
