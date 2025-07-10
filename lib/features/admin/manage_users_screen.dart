import 'package:flutter/material.dart';
import '../../core/constants.dart';
import '../../core/widgets/empty_state.dart';
import 'package:iconsax/iconsax.dart';

class ManageUsersScreen extends StatelessWidget {
  const ManageUsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Manage Users', style: AppTextStyles.heading2),
        backgroundColor: AppColors.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              decoration: AppInputDecorations.textFieldDecoration(
                labelText: 'Search Users',
                prefixIcon: const Icon(Iconsax.search_normal),
              ),
            ),
            const SizedBox(height: 16),
            const EmptyState(message: 'No users found.'),
          ],
        ),
      ),
    );
  }
}