// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UserModel _$UserModelFromJson(Map<String, dynamic> json) => _UserModel(
      name: json['name'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
      verified: json['verified'] as bool,
      leaveBalance: json['leaveBalance'] == null
          ? const LeaveBalance()
          : LeaveBalance.fromJson(json['leaveBalance'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$UserModelToJson(_UserModel instance) =>
    <String, dynamic>{
      'name': instance.name,
      'email': instance.email,
      'role': instance.role,
      'verified': instance.verified,
      'leaveBalance': instance.leaveBalance,
    };

_LeaveBalance _$LeaveBalanceFromJson(Map<String, dynamic> json) =>
    _LeaveBalance(
      paidLeave: (json['paidLeave'] as num?)?.toInt() ??
          AppConstants.defaultPaidLeaves,
      sickLeave: (json['sickLeave'] as num?)?.toInt() ??
          AppConstants.defaultSickLeaves,
      earnedLeave: (json['earnedLeave'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$LeaveBalanceToJson(_LeaveBalance instance) =>
    <String, dynamic>{
      'paidLeave': instance.paidLeave,
      'sickLeave': instance.sickLeave,
      'earnedLeave': instance.earnedLeave,
    };
