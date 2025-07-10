import 'package:flutter/material.dart';
import '../../core/constants.dart';
import '../../core/widgets/empty_state.dart';

class AttendanceListScreen extends StatelessWidget {
  const AttendanceListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Attendance History', style: AppTextStyles.heading2),
        backgroundColor: AppColors.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: const [
            EmptyState(message: 'No attendance records found.'),
            // Placeholder for list items
          ],
        ),
      ),
    );
  }
}