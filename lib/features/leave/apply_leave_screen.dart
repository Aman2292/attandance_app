import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import '../../core/constants.dart';
import '../../core/widgets/input_field.dart';
import '../../providers/holiday_provider.dart';
import '../../providers/user_provider.dart';
import '../../services/leave_service.dart';

class ApplyLeaveScreen extends ConsumerStatefulWidget {
  const ApplyLeaveScreen({super.key});

  @override
  ConsumerState<ApplyLeaveScreen> createState() => _ApplyLeaveScreenState();
}

class _ApplyLeaveScreenState extends ConsumerState<ApplyLeaveScreen> {
  final _reasonController = TextEditingController();
  String? _leaveType;
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isSubmitting = false;

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
      // Real-time overlap check
      if (_startDate != null && _endDate != null && mounted) {
        final userId = ref.read(authServiceProvider).currentUser?.uid;
        if (userId != null) {
          try {
            final existingLeavesSnapshot = await FirebaseFirestore.instance
                .collection('users')
                .doc(userId)
                .collection('leaves')
                .where('status', whereIn: ['pending', 'approved'])
                .where('startDate', isLessThanOrEqualTo: DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS").format(_endDate!))
                .where('endDate', isGreaterThanOrEqualTo: DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS").format(_startDate!))
                .get()
                .timeout(const Duration(seconds: 10), onTimeout: () {
              throw TimeoutException('Overlap check timed out');
            });
            if (existingLeavesSnapshot.docs.isNotEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Selected dates overlap with existing leaves')),
              );
            }
          } catch (e) {
            debugPrint('Error in real-time overlap check: $e');
          }
        }
      }
    }
  }

  Future<void> _applyLeave() async {
    setState(() => _isSubmitting = true);
    debugPrint('Starting leave application process');

    final userId = ref.read(authServiceProvider).currentUser?.uid;
    if (userId == null) {
      debugPrint('User not authenticated');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not authenticated')),
      );
      setState(() => _isSubmitting = false);
      return;
    }
    debugPrint('User authenticated: $userId');

    if (_leaveType == null ||
        _startDate == null ||
        _endDate == null ||
        _reasonController.text.isEmpty) {
      debugPrint('Validation failed: Missing fields');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      setState(() => _isSubmitting = false);
      return;
    }
    debugPrint('Fields validated: type=$_leaveType, startDate=$_startDate, endDate=$_endDate');

    if (_startDate!.isAfter(_endDate!)) {
      debugPrint('Validation failed: Start date after end date');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Start date must be before end date')),
      );
      setState(() => _isSubmitting = false);
      return;
    }

    if (_startDate!.weekday == DateTime.sunday ||
        _endDate!.weekday == DateTime.sunday) {
      debugPrint('Validation failed: Leave on Sunday');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Leave cannot be applied on Sundays')),
      );
      setState(() => _isSubmitting = false);
      return;
    }

    debugPrint('Fetching holidays');
    final holidaysAsync = ref.read(holidayProvider);
    final holidays = holidaysAsync.when(
      data: (holidays) => holidays,
      error: (e, _) {
        debugPrint('Holiday provider error: $e');
        return [];
      },
      loading: () {
        debugPrint('Holiday provider loading');
        return [];
      },
    );
    final uniqueHolidays = holidays.toSet();
    final isHoliday = uniqueHolidays.any((holiday) {
      final holidayDate = (holiday['date'] as DateTime);
      return (_startDate!.isSameDate(holidayDate) ||
          _endDate!.isSameDate(holidayDate));
    });
    if (isHoliday) {
      debugPrint('Validation failed: Leave on holiday');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Leave cannot be applied on holidays')),
      );
      setState(() => _isSubmitting = false);
      return;
    }
    debugPrint('No holiday conflicts');

    debugPrint('Fetching user data');
    final userAsync = ref.read(userProvider);
    final user = userAsync.when(
      data: (user) => user,
      error: (e, _) {
        debugPrint('User provider error: $e');
        return null;
      },
      loading: () {
        debugPrint('User provider loading');
        return null;
      },
    );
    if (user == null) {
      debugPrint('User data not found for userId=$userId');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: User data not found')),
      );
      setState(() => _isSubmitting = false);
      return;
    }
    debugPrint('User data fetched: ${user.toJson()}');

    final leaveBalance = user.leaveBalance;
    final leaveType = _leaveType!.toLowerCase() == 'casual' ? 'paid' : _leaveType!.toLowerCase();
    final days = _endDate!.difference(_startDate!).inDays + 1;

    bool hasSufficientBalance;
    String errorMessage = '';
    switch (leaveType) {
      case 'paid':
        hasSufficientBalance = leaveBalance.paidLeave >= days;
        errorMessage = 'Insufficient paid leave balance';
        break;
      case 'sick':
        hasSufficientBalance = leaveBalance.sickLeave >= days;
        errorMessage = 'Insufficient sick leave balance';
        break;
      case 'earned':
        hasSufficientBalance = leaveBalance.earnedLeave >= days;
        errorMessage = 'Insufficient earned leave balance';
        break;
      default:
        hasSufficientBalance = false;
        errorMessage = 'Invalid leave type';
    }

    if (!hasSufficientBalance) {
      debugPrint('Leave application failed: $errorMessage, balance=$leaveBalance');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
      setState(() => _isSubmitting = false);
      return;
    }
    debugPrint('Sufficient leave balance: $leaveBalance');

    debugPrint('Checking for overlapping leaves');
    try {
      final existingLeavesSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('leaves')
          .where('status', whereIn: ['pending', 'approved'])
          .where('startDate', isLessThanOrEqualTo: DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS").format(_endDate!))
          .where('endDate', isGreaterThanOrEqualTo: DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS").format(_startDate!))
          .get()
          .timeout(const Duration(seconds: 10), onTimeout: () {
        throw TimeoutException('Overlap check timed out');
      });

      if (existingLeavesSnapshot.docs.isNotEmpty) {
        debugPrint('Overlap found: ${existingLeavesSnapshot.docs.length} conflicting leaves');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Leave already exists for the selected dates')),
        );
        setState(() => _isSubmitting = false);
        return;
      }
      debugPrint('No overlapping leaves found');
    } catch (e) {
      debugPrint('Error checking overlaps: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error checking existing leaves: $e')),
      );
      setState(() => _isSubmitting = false);
      return;
    }

    debugPrint('Applying leave');
    try {
      await ref.read(leaveServiceProvider).applyLeave(
            userId: userId,
            type: leaveType,
            startDate: _startDate!,
            endDate: _endDate!,
            reason: _reasonController.text.trim(),
          ).timeout(const Duration(seconds: 10), onTimeout: () {
        throw TimeoutException('Leave application timed out');
      });
      debugPrint('Leave applied successfully');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Leave applied successfully')),
      );
      context.pop();
    } catch (e) {
      debugPrint('Leave application failed: userId=$userId, type=$leaveType, error=$e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error applying leave: $e')),
      );
    } finally {
      debugPrint('Resetting submitting state');
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Apply Leave', style: AppTextStyles.heading2),
        backgroundColor: AppColors.primary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DropdownButtonFormField<String>(
              decoration: AppInputDecorations.textFieldDecoration(
                  labelText: 'Leave Type'),
              value: _leaveType,
              items: ['paid', 'sick', 'earned']
                  .map((type) => DropdownMenuItem(
                      value: type, child: Text(type.capitalize())))
                  .toList(),
              onChanged: (value) => setState(() => _leaveType = value),
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: AppInputDecorations.textFieldDecoration(
                      labelText: 'Start Date')
                  .copyWith(prefixIcon: const Icon(Iconsax.calendar)),
              controller: TextEditingController(
                  text: _startDate != null
                      ? DateFormat('yyyy-MM-dd').format(_startDate!)
                      : ''),
              readOnly: true,
              onTap: () => _selectDate(context, true),
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration:
                  AppInputDecorations.textFieldDecoration(labelText: 'End Date')
                      .copyWith(prefixIcon: const Icon(Iconsax.calendar)),
              controller: TextEditingController(
                  text: _endDate != null
                      ? DateFormat('yyyy-MM-dd').format(_endDate!)
                      : ''),
              readOnly: true,
              onTap: () => _selectDate(context, false),
            ),
            const SizedBox(height: 16),
            AppInputField(
              labelText: 'Reason',
              controller: _reasonController,
              prefixIcon: const Icon(Iconsax.note),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              style: AppButtonStyles.primaryButton,
              onPressed: _isSubmitting ? null : _applyLeave,
              child: _isSubmitting
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text('Apply', style: AppTextStyles.button),
            ),
          ],
        ),
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() => this[0].toUpperCase() + substring(1);
}

extension DateTimeExtension on DateTime {
  bool isSameDate(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }
}