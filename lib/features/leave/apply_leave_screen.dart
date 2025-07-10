import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../core/constants.dart';
import '../../core/widgets/input_field.dart';

class ApplyLeaveScreen extends StatefulWidget {
  const ApplyLeaveScreen({super.key});

  @override
  State<ApplyLeaveScreen> createState() => _ApplyLeaveScreenState();
}

class _ApplyLeaveScreenState extends State<ApplyLeaveScreen> {
  final _reasonController = TextEditingController();
  String? _leaveType;
  DateTime? _fromDate;
  DateTime? _toDate;

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
              items: const [
                DropdownMenuItem(value: 'paidLeave', child: Text('Paid Leave')),
                DropdownMenuItem(value: 'sickLeave', child: Text('Sick Leave')),
                DropdownMenuItem(value: 'earnedLeave', child: Text('Earned Leave')),
              ],
              onChanged: (value) => setState(() => _leaveType = value),
            ),
            const SizedBox(height: 16),
            // AppInputField(
            //   labelText: 'From Date',
            //   prefixIcon: const Icon(Iconsax.calendar),
            //   readOnly: true,
            //   onTap: () async {
            //     final date = await showDatePicker(
            //       context: context,
            //       initialDate: DateTime.now(),
            //       firstDate: DateTime.now(),
            //       lastDate: DateTime.now().add(const Duration(days: 365)),
            //     );
            //     if (date != null) setState(() => _fromDate = date);
            //   },
            //   hintText: _fromDate?.toString().split(' ')[0] ?? 'Select Date',
            // ),
            const SizedBox(height: 16),
            // AppInputField(
            //   labelText: 'To Date',
            //   prefixIcon: const Icon(Iconsax.calendar),
            //   readOnly: true,
            //   onTap: () async {
            //     final date = await showDatePicker(
            //       context: context,
            //       initialDate: DateTime.now(),
            //       firstDate: DateTime.now(),
            //       lastDate: DateTime.now().add(const Duration(days: 365)),
            //     );
            //     if (date != null) setState(() => _toDate = date);
            //   },
            //   hintText: _toDate?.toString().split(' ')[0] ?? 'Select Date',
            // ),
            // const SizedBox(height: 16),
            // AppInputField(
            //   labelText: 'Reason',
            //   controller: _reasonController,
            //   keyboardType: TextInputType.multiline,
            //   maxLines: 3,
            // ),
            // const SizedBox(height: 24),
            // ElevatedButton(
            //   style: AppButtonStyles.primaryButton,
            //   onPressed: () {
            //     ScaffoldMessenger.of(context).showSnackBar(
            //       const SnackBar(content: Text('Leave Applied')),
            //     );
            //   },
            //   child: const Text('Submit', style: AppTextStyles.button),
            // ),
          ],
        ),
      ),
    );
  }
}