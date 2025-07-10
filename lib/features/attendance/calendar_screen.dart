import 'package:flutter/material.dart';
import '../../core/constants.dart';
import '../../core/widgets/empty_state.dart';

class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Attendance Calendar', style: AppTextStyles.heading2),
        backgroundColor: AppColors.primary,
      ),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: EmptyState(message: 'Calendar view will be implemented here.'),
      ),
    );
  }
}