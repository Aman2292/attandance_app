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
        title: Text('Edit ${user.name}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: paidLeaveController,
                decoration: const InputDecoration(labelText: 'Paid Leave'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: sickLeaveController,
                decoration: const InputDecoration(labelText: 'Sick Leave'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: earnedLeaveController,
                decoration: const InputDecoration(labelText: 'Earned Leave'),
                keyboardType: TextInputType.number,
              ),
              CheckboxListTile(
                title: const Text('Verified'),
                value: verified,
                onChanged: null, // Read-only for now
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
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
                  const SnackBar(content: Text('User updated successfully')),
                );
                Navigator.pop(context);
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: $e')),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersAsync = ref.watch(allUsersProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title:  Text('Manage Users', style: AppTextStyles.heading2),
        backgroundColor: AppColors.primary,
      ),
      body: usersAsync.when(
        data: (users) => users.isEmpty
            ?  Center(child: Text('No users found', style: AppTextStyles.bodyMedium))
            : ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final user = users[index];
                  return Card(
                    color: AppColors.background,
                    child: ListTile(
                      title: Text(user.name),
                      subtitle: Text('Email: ${user.email}\nRole: ${user.role}\nVerified: ${user.verified}'),
                      trailing: IconButton(
                        icon: const Icon(Iconsax.edit),
                        onPressed: () => _updateUser(context, user.email, user),
                      ),
                    ),
                  );
                },
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.error))),
      ),
    );
  }
}