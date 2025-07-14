import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:iconsax/iconsax.dart';
import '../../core/constants.dart';
import '../../models/user_model.dart';
import 'admin_dashboard_screen.dart';

class ManageUsersScreen extends ConsumerWidget {
  const ManageUsersScreen({super.key});

  Future<void> _updateUser(BuildContext context, String userId, UserModel user) async {
    final paidLeaveController = TextEditingController(text: user.leaveBalance.paidLeave.toString());
    final sickLeaveController = TextEditingController(text: user.leaveBalance.sickLeave.toString());
    final earnedLeaveController = TextEditingController(text: user.leaveBalance.earnedLeave.toString());
    final verified = user.verified;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Iconsax.edit,
                color: AppColors.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Edit ${user.name}',
                style: AppTextStyles.heading3,
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 16),
              TextField(
                controller: paidLeaveController,
                decoration: AppInputDecorations.textFieldDecoration(
                  labelText: 'Paid Leave',
                  prefixIcon: Icon(Iconsax.calendar_tick, color: AppColors.success),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: sickLeaveController,
                decoration: AppInputDecorations.textFieldDecoration(
                  labelText: 'Sick Leave',
                  prefixIcon: Icon(Iconsax.health, color: AppColors.warning),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: earnedLeaveController,
                decoration: AppInputDecorations.textFieldDecoration(
                  labelText: 'Earned Leave',
                  prefixIcon: Icon(Iconsax.medal_star, color: AppColors.info),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: verified ? AppColors.success.withOpacity(0.1) : AppColors.warning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: verified ? AppColors.success : AppColors.warning,
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      verified ? Iconsax.verify : Iconsax.warning_2,
                      color: verified ? AppColors.success : AppColors.warning,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      verified ? 'Verified User' : 'Unverified User',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: verified ? AppColors.success : AppColors.warning,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: AppButtonStyles.textButton,
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await FirebaseFirestore.instance.collection('users').doc(userId).update({
                  'leaveBalance': {
                    'paidLeave': int.parse(paidLeaveController.text),
                    'sickLeave': int.parse(sickLeaveController.text),
                    'earnedLeave': int.parse(earnedLeaveController.text),
                  },
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        Icon(Iconsax.tick_circle, color: Colors.white),
                        const SizedBox(width: 8),
                        const Text('User updated successfully'),
                      ],
                    ),
                    backgroundColor: AppColors.success,
                  ),
                );
                Navigator.pop(context);
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        Icon(Iconsax.warning_2, color: Colors.white),
                        const SizedBox(width: 8),
                        Text('Error: $e'),
                      ],
                    ),
                    backgroundColor: AppColors.error,
                  ),
                );
              }
            },
            style: AppButtonStyles.primaryButton,
            child: const Text('Save Changes'),
          ),
        ],
      ),
    );
  }

  Widget _buildUserCard(UserModel user, VoidCallback onEdit) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Icon(
                    Iconsax.profile_circle,
                    color: AppColors.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.name,
                        style: AppTextStyles.heading3,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Iconsax.sms,
                            size: 14,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            user.email,
                            style: AppTextStyles.bodySmall,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: user.verified ? AppColors.success : AppColors.warning,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        user.verified ? Iconsax.verify : Iconsax.warning_2,
                        color: Colors.white,
                        size: 12,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        user.verified ? 'Verified' : 'Pending',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(
                        Iconsax.profile_2user,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Role: ${user.role}',
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildLeaveInfo(
                          'Paid',
                          user.leaveBalance.paidLeave.toString(),
                          Iconsax.calendar_tick,
                          AppColors.success,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildLeaveInfo(
                          'Sick',
                          user.leaveBalance.sickLeave.toString(),
                          Iconsax.health,
                          AppColors.warning,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildLeaveInfo(
                          'Earned',
                          user.leaveBalance.earnedLeave.toString(),
                          Iconsax.medal_star,
                          AppColors.info,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onEdit,
                icon: Icon(Iconsax.edit, size: 18),
                label: const Text('Edit User'),
                style: AppButtonStyles.primaryButton,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeaveInfo(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: AppTextStyles.bodySmall,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersAsync = ref.watch(allUsersProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Manage Users', style: AppTextStyles.heading2.copyWith(color: Colors.white)),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Iconsax.arrow_left),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Iconsax.refresh),
            onPressed: () => ref.refresh(allUsersProvider),
          ),
        ],
      ),
      body: usersAsync.when(
        data: (users) {
          if (users.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Icon(
                      Iconsax.profile_2user,
                      size: 48,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No users found',
                    style: AppTextStyles.heading3,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'There are no users to manage at the moment',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return _buildUserCard(
                user,
                () => _updateUser(context, user.email, user),
              );
            },
          );
        },
        loading: () => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                color: AppColors.primary,
              ),
              const SizedBox(height: 16),
              Text(
                'Loading users...',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Icon(
                  Iconsax.warning_2,
                  size: 48,
                  color: AppColors.error,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Error loading users',
                style: AppTextStyles.heading3.copyWith(
                  color: AppColors.error,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Error: $e',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => ref.refresh(allUsersProvider),
                icon: Icon(Iconsax.refresh),
                label: const Text('Retry'),
                style: AppButtonStyles.primaryButton,
              ),
            ],
          ),
        ),
      ),
    );
  }
}