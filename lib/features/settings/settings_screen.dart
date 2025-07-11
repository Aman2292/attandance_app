import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import '../../core/constants.dart';
import '../../core/widgets/confirmation_dialog.dart';
import '../../services/auth_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title:  Text('Settings', style: AppTextStyles.heading2),
        backgroundColor: AppColors.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ListTile(
              leading: const Icon(Iconsax.user),
              title:  Text('Edit Profile', style: AppTextStyles.bodyLarge),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Edit Profile clicked')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Iconsax.moon),
              title:  Text('Toggle Theme', style: AppTextStyles.bodyLarge),
              trailing: const Icon(Iconsax.arrow_right_3),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Theme switch clicked')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Iconsax.logout),
              title:  Text('Logout', style: AppTextStyles.bodyLarge),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => ConfirmationDialog(
                    title: 'Logout',
                    content: 'Are you sure you want to logout?',
                    onConfirm: () async {
                      await AuthService().signOut();
                      if (context.mounted) context.go('/login');
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}