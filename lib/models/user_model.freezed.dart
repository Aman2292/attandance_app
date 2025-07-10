// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$UserModel {
  String get name;
  String get email;
  String get role;
  bool get verified;
  LeaveBalance get leaveBalance;

  /// Create a copy of UserModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $UserModelCopyWith<UserModel> get copyWith =>
      _$UserModelCopyWithImpl<UserModel>(this as UserModel, _$identity);

  /// Serializes this UserModel to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is UserModel &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.role, role) || other.role == role) &&
            (identical(other.verified, verified) ||
                other.verified == verified) &&
            (identical(other.leaveBalance, leaveBalance) ||
                other.leaveBalance == leaveBalance));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, name, email, role, verified, leaveBalance);

  @override
  String toString() {
    return 'UserModel(name: $name, email: $email, role: $role, verified: $verified, leaveBalance: $leaveBalance)';
  }
}

/// @nodoc
abstract mixin class $UserModelCopyWith<$Res> {
  factory $UserModelCopyWith(UserModel value, $Res Function(UserModel) _then) =
      _$UserModelCopyWithImpl;
  @useResult
  $Res call(
      {String name,
      String email,
      String role,
      bool verified,
      LeaveBalance leaveBalance});

  $LeaveBalanceCopyWith<$Res> get leaveBalance;
}

/// @nodoc
class _$UserModelCopyWithImpl<$Res> implements $UserModelCopyWith<$Res> {
  _$UserModelCopyWithImpl(this._self, this._then);

  final UserModel _self;
  final $Res Function(UserModel) _then;

  /// Create a copy of UserModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? email = null,
    Object? role = null,
    Object? verified = null,
    Object? leaveBalance = null,
  }) {
    return _then(_self.copyWith(
      name: null == name
          ? _self.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      email: null == email
          ? _self.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      role: null == role
          ? _self.role
          : role // ignore: cast_nullable_to_non_nullable
              as String,
      verified: null == verified
          ? _self.verified
          : verified // ignore: cast_nullable_to_non_nullable
              as bool,
      leaveBalance: null == leaveBalance
          ? _self.leaveBalance
          : leaveBalance // ignore: cast_nullable_to_non_nullable
              as LeaveBalance,
    ));
  }

  /// Create a copy of UserModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $LeaveBalanceCopyWith<$Res> get leaveBalance {
    return $LeaveBalanceCopyWith<$Res>(_self.leaveBalance, (value) {
      return _then(_self.copyWith(leaveBalance: value));
    });
  }
}

/// @nodoc
@JsonSerializable()
class _UserModel implements UserModel {
  const _UserModel(
      {required this.name,
      required this.email,
      required this.role,
      required this.verified,
      this.leaveBalance = const LeaveBalance()});
  factory _UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  @override
  final String name;
  @override
  final String email;
  @override
  final String role;
  @override
  final bool verified;
  @override
  @JsonKey()
  final LeaveBalance leaveBalance;

  /// Create a copy of UserModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$UserModelCopyWith<_UserModel> get copyWith =>
      __$UserModelCopyWithImpl<_UserModel>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$UserModelToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _UserModel &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.role, role) || other.role == role) &&
            (identical(other.verified, verified) ||
                other.verified == verified) &&
            (identical(other.leaveBalance, leaveBalance) ||
                other.leaveBalance == leaveBalance));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, name, email, role, verified, leaveBalance);

  @override
  String toString() {
    return 'UserModel(name: $name, email: $email, role: $role, verified: $verified, leaveBalance: $leaveBalance)';
  }
}

/// @nodoc
abstract mixin class _$UserModelCopyWith<$Res>
    implements $UserModelCopyWith<$Res> {
  factory _$UserModelCopyWith(
          _UserModel value, $Res Function(_UserModel) _then) =
      __$UserModelCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String name,
      String email,
      String role,
      bool verified,
      LeaveBalance leaveBalance});

  @override
  $LeaveBalanceCopyWith<$Res> get leaveBalance;
}

/// @nodoc
class __$UserModelCopyWithImpl<$Res> implements _$UserModelCopyWith<$Res> {
  __$UserModelCopyWithImpl(this._self, this._then);

  final _UserModel _self;
  final $Res Function(_UserModel) _then;

  /// Create a copy of UserModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? name = null,
    Object? email = null,
    Object? role = null,
    Object? verified = null,
    Object? leaveBalance = null,
  }) {
    return _then(_UserModel(
      name: null == name
          ? _self.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      email: null == email
          ? _self.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      role: null == role
          ? _self.role
          : role // ignore: cast_nullable_to_non_nullable
              as String,
      verified: null == verified
          ? _self.verified
          : verified // ignore: cast_nullable_to_non_nullable
              as bool,
      leaveBalance: null == leaveBalance
          ? _self.leaveBalance
          : leaveBalance // ignore: cast_nullable_to_non_nullable
              as LeaveBalance,
    ));
  }

  /// Create a copy of UserModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $LeaveBalanceCopyWith<$Res> get leaveBalance {
    return $LeaveBalanceCopyWith<$Res>(_self.leaveBalance, (value) {
      return _then(_self.copyWith(leaveBalance: value));
    });
  }
}

/// @nodoc
mixin _$LeaveBalance {
  int get paidLeave;
  int get sickLeave;
  int get earnedLeave;

  /// Create a copy of LeaveBalance
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $LeaveBalanceCopyWith<LeaveBalance> get copyWith =>
      _$LeaveBalanceCopyWithImpl<LeaveBalance>(
          this as LeaveBalance, _$identity);

  /// Serializes this LeaveBalance to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is LeaveBalance &&
            (identical(other.paidLeave, paidLeave) ||
                other.paidLeave == paidLeave) &&
            (identical(other.sickLeave, sickLeave) ||
                other.sickLeave == sickLeave) &&
            (identical(other.earnedLeave, earnedLeave) ||
                other.earnedLeave == earnedLeave));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, paidLeave, sickLeave, earnedLeave);

  @override
  String toString() {
    return 'LeaveBalance(paidLeave: $paidLeave, sickLeave: $sickLeave, earnedLeave: $earnedLeave)';
  }
}

/// @nodoc
abstract mixin class $LeaveBalanceCopyWith<$Res> {
  factory $LeaveBalanceCopyWith(
          LeaveBalance value, $Res Function(LeaveBalance) _then) =
      _$LeaveBalanceCopyWithImpl;
  @useResult
  $Res call({int paidLeave, int sickLeave, int earnedLeave});
}

/// @nodoc
class _$LeaveBalanceCopyWithImpl<$Res> implements $LeaveBalanceCopyWith<$Res> {
  _$LeaveBalanceCopyWithImpl(this._self, this._then);

  final LeaveBalance _self;
  final $Res Function(LeaveBalance) _then;

  /// Create a copy of LeaveBalance
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? paidLeave = null,
    Object? sickLeave = null,
    Object? earnedLeave = null,
  }) {
    return _then(_self.copyWith(
      paidLeave: null == paidLeave
          ? _self.paidLeave
          : paidLeave // ignore: cast_nullable_to_non_nullable
              as int,
      sickLeave: null == sickLeave
          ? _self.sickLeave
          : sickLeave // ignore: cast_nullable_to_non_nullable
              as int,
      earnedLeave: null == earnedLeave
          ? _self.earnedLeave
          : earnedLeave // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _LeaveBalance implements LeaveBalance {
  const _LeaveBalance(
      {this.paidLeave = 12, this.sickLeave = 8, this.earnedLeave = 4});
  factory _LeaveBalance.fromJson(Map<String, dynamic> json) =>
      _$LeaveBalanceFromJson(json);

  @override
  @JsonKey()
  final int paidLeave;
  @override
  @JsonKey()
  final int sickLeave;
  @override
  @JsonKey()
  final int earnedLeave;

  /// Create a copy of LeaveBalance
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$LeaveBalanceCopyWith<_LeaveBalance> get copyWith =>
      __$LeaveBalanceCopyWithImpl<_LeaveBalance>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$LeaveBalanceToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _LeaveBalance &&
            (identical(other.paidLeave, paidLeave) ||
                other.paidLeave == paidLeave) &&
            (identical(other.sickLeave, sickLeave) ||
                other.sickLeave == sickLeave) &&
            (identical(other.earnedLeave, earnedLeave) ||
                other.earnedLeave == earnedLeave));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, paidLeave, sickLeave, earnedLeave);

  @override
  String toString() {
    return 'LeaveBalance(paidLeave: $paidLeave, sickLeave: $sickLeave, earnedLeave: $earnedLeave)';
  }
}

/// @nodoc
abstract mixin class _$LeaveBalanceCopyWith<$Res>
    implements $LeaveBalanceCopyWith<$Res> {
  factory _$LeaveBalanceCopyWith(
          _LeaveBalance value, $Res Function(_LeaveBalance) _then) =
      __$LeaveBalanceCopyWithImpl;
  @override
  @useResult
  $Res call({int paidLeave, int sickLeave, int earnedLeave});
}

/// @nodoc
class __$LeaveBalanceCopyWithImpl<$Res>
    implements _$LeaveBalanceCopyWith<$Res> {
  __$LeaveBalanceCopyWithImpl(this._self, this._then);

  final _LeaveBalance _self;
  final $Res Function(_LeaveBalance) _then;

  /// Create a copy of LeaveBalance
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? paidLeave = null,
    Object? sickLeave = null,
    Object? earnedLeave = null,
  }) {
    return _then(_LeaveBalance(
      paidLeave: null == paidLeave
          ? _self.paidLeave
          : paidLeave // ignore: cast_nullable_to_non_nullable
              as int,
      sickLeave: null == sickLeave
          ? _self.sickLeave
          : sickLeave // ignore: cast_nullable_to_non_nullable
              as int,
      earnedLeave: null == earnedLeave
          ? _self.earnedLeave
          : earnedLeave // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

// dart format on
