import 'package:flutter/material.dart';
import '../../core/constants.dart';
import '../../core/widgets/empty_state.dart';

class LeaveHistoryScreen extends StatelessWidget {
  const LeaveHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title:  Text('Leave History', style: AppTextStyles.heading2),
        backgroundColor: AppColors.primary,
      ),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: EmptyState(message: 'No leave history found.'),
      ),
    );
  }
}