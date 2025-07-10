import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import '../../core/constants.dart';
import '../../core/widgets/empty_state.dart';

class LeaveScreen extends StatelessWidget {
  const LeaveScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Leave', style: AppTextStyles.heading2),
          backgroundColor: AppColors.primary,
          bottom: const TabBar(
            labelStyle: AppTextStyles.bodyMedium,
            unselectedLabelStyle: AppTextStyles.bodySmall,
            indicatorColor: AppColors.accent,
            tabs: [
              Tab(text: 'Request'),
              Tab(text: 'History'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ElevatedButton.icon(
                    style: AppButtonStyles.primaryButton,
                    onPressed: () => context.go('/employee/leave/apply'),
                    icon: const Icon(Iconsax.add),
                    label: const Text('Apply for Leave', style: AppTextStyles.button),
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: EmptyState(message: 'No leave history found.'),
            ),
          ],
        ),
      ),
    );
  }
}