import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import '../../core/constants.dart';
import '../../core/widgets/input_field.dart';
import '../../providers/leave_provider.dart';
import '../../providers/user_provider.dart';

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
    }
  }

  Future<void> _applyLeave() async {
    if (_leaveType == null || _startDate == null || _endDate == null || _reasonController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }
    try {
      await ref.read(leaveServiceProvider).applyLeave(
            userId: ref.read(authServiceProvider).currentUser!.uid,
            type: _leaveType!,
            startDate: _startDate!,
            endDate: _endDate!,
            reason: _reasonController.text.trim(),
          );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Leave applied successfully')),
      );
      context.pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Apply Leave', style: AppTextStyles.heading2),
        backgroundColor: AppColors.primary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DropdownButtonFormField<String>(
              decoration: AppInputDecorations.textFieldDecoration(labelText: 'Leave Type'),
              value: _leaveType,
              items: ['paid', 'sick', 'earned']
                  .map((type) => DropdownMenuItem(value: type, child: Text(type.capitalize())))
                  .toList(),
              onChanged: (value) => setState(() => _leaveType = value),
            ),
            const SizedBox(height: 16),
            AppInputField(
              labelText: 'Start Date',
              controller: TextEditingController(
                  text: _startDate != null ? DateFormat('yyyy-MM-dd').format(_startDate!) : ''),
              // readOnly: true,
              // onTap: () => _selectDate(context, true),
              prefixIcon: const Icon(Iconsax.calendar),
            ),
            const SizedBox(height: 16),
            AppInputField(
              labelText: 'End Date',
              controller: TextEditingController(
                  text: _endDate != null ? DateFormat('yyyy-MM-dd').format(_endDate!) : ''),
              // readOnly: true,
              // onTap: () => _selectDate(context, false),
              prefixIcon: const Icon(Iconsax.calendar),
            ),
            const SizedBox(height: 16),
            AppInputField(
              labelText: 'Reason',
              controller: _reasonController,
              // maxLines: 3,
              prefixIcon: const Icon(Iconsax.note),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              style: AppButtonStyles.primaryButton,
              onPressed: _applyLeave,
              child: const Text('Apply', style: AppTextStyles.button),
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