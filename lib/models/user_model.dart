import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/constants.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

@freezed
abstract class UserModel with _$UserModel {
  const factory UserModel({
    required String name,
    required String email,
    required String role,
    required bool verified,
    @Default(LeaveBalance()) LeaveBalance leaveBalance,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) => _$UserModelFromJson(json);

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel.fromJson(data);
  }
}

@freezed
abstract class LeaveBalance with _$LeaveBalance {
  const factory LeaveBalance({
    @Default(AppConstants.defaultPaidLeaves) int paidLeave,
    @Default(AppConstants.defaultSickLeaves) int sickLeave,
    @Default(AppConstants.defaultEarnedLeaves) int earnedLeave,
  }) = _LeaveBalance;

  factory LeaveBalance.fromJson(Map<String, dynamic> json) => _$LeaveBalanceFromJson(json);
}