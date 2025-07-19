import 'dart:async';
import 'package:attendance_app/core/extensions/string_extensions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import '../../core/constants.dart';
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
  final _formKey = GlobalKey<FormState>();
  String? _leaveType;
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
          if (_endDate != null && _endDate!.isBefore(picked)) {
            _endDate = null;
          }
        } else {
          _endDate = picked;
        }
      });
      _performRealtimeValidation();
    }
  }

  Future<void> _performRealtimeValidation() async {
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
              .timeout(const Duration(seconds: 10));
          
          if (existingLeavesSnapshot.docs.isNotEmpty && mounted) {
            _showValidationSnackBar('Selected dates overlap with existing leaves', AppColors.error);
          }
        } catch (e) {
          debugPrint('Error in real-time overlap check: $e');
        }
      }
    }
  }

  void _showValidationSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Iconsax.warning_2,
              color: Colors.white,
              size: 14,
            ),
            
            Text(message),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Future<void> _applyLeave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final userId = ref.read(authServiceProvider).currentUser?.uid;
      if (userId == null) {
        _showValidationSnackBar('User not authenticated', AppColors.error);
        return;
      }

      if (_leaveType == null || _startDate == null || _endDate == null) {
        _showValidationSnackBar('Please fill all fields', AppColors.error);
        return;
      }

      if (_startDate!.isAfter(_endDate!)) {
        _showValidationSnackBar('Start date must be before end date', AppColors.error);
        return;
      }

      if (_startDate!.weekday == DateTime.sunday || _endDate!.weekday == DateTime.sunday) {
        _showValidationSnackBar('Leave cannot be applied on Sundays', AppColors.error);
        return;
      }

      // Holiday validation
      final holidaysAsync = ref.read(holidayProvider);
      final holidays = holidaysAsync.when(
        data: (holidays) => holidays,
        error: (e, _) => [],
        loading: () => [],
      );

      final isHoliday = holidays.any((holiday) {
        final holidayDate = (holiday['date'] as DateTime);
        return (_startDate!.isSameDate(holidayDate) || _endDate!.isSameDate(holidayDate));
      });

      if (isHoliday) {
        _showValidationSnackBar('Leave cannot be applied on holidays', AppColors.error);
        return;
      }

      // Balance validation
      final userAsync = ref.read(userProvider);
      final user = userAsync.when(
        data: (user) => user,
        error: (e, _) => null,
        loading: () => null,
      );

      if (user == null) {
        _showValidationSnackBar('Error: User data not found', AppColors.error);
        return;
      }

      final leaveBalance = user.leaveBalance;
      final leaveType = _leaveType!.toLowerCase() == 'casual' ? 'paid' : _leaveType!.toLowerCase();
      final days = _endDate!.difference(_startDate!).inDays + 1;

      bool hasSufficientBalance = false;
      String errorMessage = '';

      switch (leaveType) {
        case 'paid':
          hasSufficientBalance = leaveBalance.paidLeave >= days;
          errorMessage = 'Insufficient paid leave balance (${leaveBalance.paidLeave} days available)';
          break;
        case 'sick':
          hasSufficientBalance = leaveBalance.sickLeave >= days;
          errorMessage = 'Insufficient sick leave balance (${leaveBalance.sickLeave} days available)';
          break;
        case 'earned':
          hasSufficientBalance = leaveBalance.earnedLeave >= days;
          errorMessage = 'Insufficient earned leave balance (${leaveBalance.earnedLeave} days available)';
          break;
      }

      if (!hasSufficientBalance) {
        _showValidationSnackBar(errorMessage, AppColors.error);
        return;
      }

      // Overlap validation
      final existingLeavesSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('leaves')
          .where('status', whereIn: ['pending', 'approved'])
          .where('startDate', isLessThanOrEqualTo: DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS").format(_endDate!))
          .where('endDate', isGreaterThanOrEqualTo: DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS").format(_startDate!))
          .get()
          .timeout(const Duration(seconds: 10));

      if (existingLeavesSnapshot.docs.isNotEmpty) {
        _showValidationSnackBar('Leave already exists for the selected dates', AppColors.error);
        return;
      }

      // Apply leave
      await ref.read(leaveServiceProvider).applyLeave(
        userId: userId,
        type: leaveType,
        startDate: _startDate!,
        endDate: _endDate!,
        reason: _reasonController.text.trim(),
      ).timeout(const Duration(seconds: 10));

      _showValidationSnackBar('Leave applied successfully!', AppColors.success);
      context.pop();
    } catch (e) {
      _showValidationSnackBar('Error applying leave: $e', AppColors.error);
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverFillRemaining(
              hasScrollBody: false,
              child: _buildApplyLeaveForm(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 100,
      floating: true,
      pinned: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
      leading: IconButton(
        icon: const Icon(
          Iconsax.arrow_left,
          color: Colors.white,
        ),
        onPressed: () => context.pop(),
      ),
      actions: [
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Iconsax.document_text,
              color: Colors.white,
              size: 20,
            ),
          ),
          onPressed: () => context.go('/employee/leave/history'),
        ),
        const SizedBox(width: 8),
      ],
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          'Apply Leave',
          style: AppTextStyles.heading2.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.accent,
                AppColors.accent.withOpacity(0.8),
                AppColors.primary.withOpacity(0.6),
                AppColors.success.withOpacity(0.4),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildApplyLeaveForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.accent,
                        AppColors.accent.withOpacity(0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Iconsax.edit,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Leave Application Form',
                  style: AppTextStyles.heading3.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.textSecondary.withOpacity(0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildLeaveTypeDropdown(),
                  const SizedBox(height: 20),
                  _buildDateFields(),
                  const SizedBox(height: 20),
                  _buildReasonField(),
                  const SizedBox(height: 24),
                  _buildDurationInfo(),
                  const SizedBox(height: 24),
                  _buildApplyButton(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaveTypeDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Leave Type',
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          decoration: AppInputDecorations.textFieldDecoration(
            labelText: 'Select leave type',
          ).copyWith(
            prefixIcon: Icon(Iconsax.category, color: AppColors.primary),
          ),
          value: _leaveType,
          items: ['paid', 'sick', 'earned']
              .map((type) => DropdownMenuItem(
                  value: type,
                  child: Text(type.toString().capitalize())))
              .toList(),
          onChanged: (value) => setState(() => _leaveType = value),
          validator: (value) {
            if (value == null) return 'Please select a leave type';
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildDateFields() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Start Date',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                decoration: AppInputDecorations.textFieldDecoration(
                  labelText: 'Select start date',
                ).copyWith(
                  prefixIcon: Icon(Iconsax.calendar, color: AppColors.primary),
                ),
                controller: TextEditingController(
                  text: _startDate != null
                      ? DateFormat('MMM dd, yyyy').format(_startDate!)
                      : '',
                ),
                readOnly: true,
                onTap: () => _selectDate(context, true),
                validator: (value) {
                  if (_startDate == null) return 'Please select start date';
                  return null;
                },
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'End Date',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                decoration: AppInputDecorations.textFieldDecoration(
                  labelText: 'Select end date',
                ).copyWith(
                  prefixIcon: Icon(Iconsax.calendar, color: AppColors.primary),
                ),
                controller: TextEditingController(
                  text: _endDate != null
                      ? DateFormat('MMM dd, yyyy').format(_endDate!)
                      : '',
                ),
                readOnly: true,
                onTap: () => _selectDate(context, false),
                validator: (value) {
                  if (_endDate == null) return 'Please select end date';
                  return null;
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReasonField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Reason for Leave',
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _reasonController,
          decoration: AppInputDecorations.textFieldDecoration(
            labelText: 'Enter reason for leave',
          ).copyWith(
            prefixIcon: Icon(Iconsax.message_text, color: AppColors.primary),
          ),
          maxLines: 3,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter a reason for leave';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildDurationInfo() {
    if (_startDate == null || _endDate == null) return const SizedBox();

    final duration = _endDate!.difference(_startDate!).inDays + 1;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.accent.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.accent.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.accent,
                  AppColors.accent.withOpacity(0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Iconsax.clock,
              color: Colors.white,
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'Duration: $duration day${duration > 1 ? 's' : ''}',
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApplyButton() {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.accent,
            AppColors.accent.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: _isSubmitting ? null : _applyLeave,
        child: _isSubmitting
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Applying...',
                    style: AppTextStyles.button.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Iconsax.send,
                    color: Colors.white,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Apply Leave',
                    style: AppTextStyles.button.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}


extension DateTimeExtension on DateTime {
  bool isSameDate(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }
}
