import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/constants.dart';
import '../../../models/user_model.dart';

class EditUserDialog {
  static Future<void> show(
      BuildContext context, String userEmail, UserModel user) async {
    // Check if context is still mounted before proceeding
    if (!context.mounted) return;

    final paidLeaveController =
        TextEditingController(text: user.leaveBalance.paidLeave.toString());
    final sickLeaveController =
        TextEditingController(text: user.leaveBalance.sickLeave.toString());
    final earnedLeaveController =
        TextEditingController(text: user.leaveBalance.earnedLeave.toString());
    bool isVerified = user.verified;
    bool isLoading = false;

    try {
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => StatefulBuilder(
          builder: (stateContext, setState) => WillPopScope(
            onWillPop: () async =>
                !isLoading, // Prevent back button during loading
            child: AlertDialog(
              backgroundColor: Colors.transparent,
              contentPadding: EdgeInsets.zero,
              content: Container(
                height: MediaQuery.of(dialogContext).size.height * 0.7,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.white, Colors.grey.shade50],
                  ),
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 30,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.surface,
                              AppColors.surface.withOpacity(0.8)
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(10),
                            topRight: Radius.circular(10),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Iconsax.edit,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Edit User',
                                    style: AppTextStyles.heading3.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    user.name,
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      color: Colors.white.withOpacity(0.9),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: isLoading
                                  ? null
                                  : () {
                                      if (Navigator.canPop(dialogContext)) {
                                        Navigator.pop(dialogContext);
                                      }
                                    },
                              icon: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Iconsax.close_square,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Content (keeping your existing UI code)
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // User Information Section
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.surface.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: AppColors.surface.withOpacity(0.1),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Iconsax.profile_circle,
                                        color: AppColors.surface,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'User Information',
                                        style:
                                            AppTextStyles.bodyMedium.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.surface,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Name',
                                              style: AppTextStyles.bodySmall
                                                  .copyWith(
                                                color: AppColors.textSecondary,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              user.name,
                                              style: AppTextStyles.bodyMedium
                                                  .copyWith(
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Email',
                                              style: AppTextStyles.bodySmall
                                                  .copyWith(
                                                color: AppColors.textSecondary,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              user.email,
                                              style: AppTextStyles.bodyMedium
                                                  .copyWith(
                                                fontWeight: FontWeight.w600,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 10),

                            // Verification Status
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [Colors.white, Colors.grey.shade50],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey.shade200),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: (isVerified
                                              ? AppColors.success
                                              : AppColors.warning)
                                          .withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      isVerified
                                          ? Iconsax.verify
                                          : Iconsax.warning_2,
                                      color: isVerified
                                          ? AppColors.success
                                          : AppColors.warning,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Verification Status',
                                          style:
                                              AppTextStyles.bodyMedium.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          isVerified
                                              ? 'User is verified'
                                              : 'User is pending verification',
                                          style:
                                              AppTextStyles.bodySmall.copyWith(
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Switch(
                                    value: isVerified,
                                    onChanged: isLoading
                                        ? null
                                        : (value) {
                                            setState(() {
                                              isVerified = value;
                                            });
                                          },
                                    activeColor: AppColors.success,
                                    inactiveTrackColor:
                                        AppColors.warning.withOpacity(0.3),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 14),

                            // Leave Balance Section
                            Text(
                              'Leave Balance',
                              style: AppTextStyles.heading3.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            _buildLeaveField(
                              'Paid Leave',
                              paidLeaveController,
                              Iconsax.calendar_tick,
                              AppColors.success,
                              'Default: ${AppConstants.defaultPaidLeaves}',
                              enabled: !isLoading,
                            ),
                            const SizedBox(height: 16),
                            _buildLeaveField(
                              'Sick Leave',
                              sickLeaveController,
                              Iconsax.health,
                              AppColors.warning,
                              'Default: ${AppConstants.defaultSickLeaves}',
                              enabled: !isLoading,
                            ),
                            const SizedBox(height: 16),
                            _buildLeaveField(
                              'Earned Leave',
                              earnedLeaveController,
                              Iconsax.medal_star,
                              AppColors.info,
                              'No default limit',
                              enabled: !isLoading,
                            ),
                          ],
                        ),
                      ),

                      // Footer buttons
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(24),
                            bottomRight: Radius.circular(24),
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Container(
                                height: 48,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border:
                                      Border.all(color: Colors.grey.shade300),
                                ),
                                child: TextButton(
                                  onPressed: isLoading
                                      ? null
                                      : () {
                                          if (Navigator.canPop(dialogContext)) {
                                            Navigator.pop(dialogContext);
                                          }
                                        },
                                  child: Text(
                                    'Cancel',
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      color: isLoading
                                          ? Colors.grey
                                          : AppColors.textSecondary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Container(
                                height: 48,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: isLoading
                                        ? [Colors.grey, Colors.grey]
                                        : [
                                            AppColors.primary,
                                            AppColors.primary.withOpacity(0.8)
                                          ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: isLoading
                                      ? []
                                      : [
                                          BoxShadow(
                                            color: AppColors.primary
                                                .withOpacity(0.3),
                                            blurRadius: 8,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                ),
                                child: ElevatedButton(
                                  // UPDATED onPressed method
                                  onPressed: isLoading ? null : () async {
                                    // Validate input first
                                    final paidLeave = int.tryParse(
                                            paidLeaveController.text) ?? 0;
                                    final sickLeave = int.tryParse(
                                            sickLeaveController.text) ?? 0;
                                    final earnedLeave = int.tryParse(
                                            earnedLeaveController.text) ?? 0;

                                    if (paidLeave < 0 ||
                                        sickLeave < 0 ||
                                        earnedLeave < 0) {
                                      if (stateContext.mounted) {
                                        ScaffoldMessenger.of(stateContext)
                                            .showSnackBar(
                                          SnackBar(
                                            content: const Text(
                                                'Leave values cannot be negative'),
                                            backgroundColor: AppColors.error,
                                          ),
                                        );
                                      }
                                      return;
                                    }

                                    setState(() {
                                      isLoading = true;
                                    });

                                    try {
                                      // FIND THE ACTUAL DOCUMENT ID BY EMAIL
                                      final userQuery = await FirebaseFirestore
                                          .instance
                                          .collection('users')
                                          .where('email', isEqualTo: userEmail)
                                          .limit(1)
                                          .get();

                                      if (userQuery.docs.isEmpty) {
                                        throw Exception(
                                            'User not found with email: $userEmail');
                                      }

                                      // Get the actual document ID
                                      final actualDocumentId = userQuery.docs.first.id;
                                      print('Found user document ID: $actualDocumentId for email: $userEmail');

                                      // Update the existing document using the correct ID
                                      await FirebaseFirestore.instance
                                          .collection('users')
                                          .doc(actualDocumentId) // Use the actual document ID
                                          .update({
                                        'verified': isVerified,
                                        'leaveBalance': {
                                          'paidLeave': paidLeave,
                                          'sickLeave': sickLeave,
                                          'earnedLeave': earnedLeave,
                                        },
                                      });

                                      // Close dialog first
                                      if (Navigator.canPop(dialogContext)) {
                                        Navigator.pop(dialogContext);
                                      }

                                      // Show success message
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Row(
                                              children: [
                                                Icon(Iconsax.tick_circle,
                                                    color: Colors.white),
                                                const SizedBox(width: 12),
                                                Text('User updated successfully'),
                                              ],
                                            ),
                                            backgroundColor: AppColors.success,
                                            behavior: SnackBarBehavior.floating,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                          ),
                                        );
                                      }
                                    } catch (e) {
                                      setState(() {
                                        isLoading = false;
                                      });

                                      print('Error updating user: $e');

                                      if (stateContext.mounted) {
                                        ScaffoldMessenger.of(stateContext)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Row(
                                              children: [
                                                Icon(Iconsax.warning_2,
                                                    color: Colors.white),
                                                const SizedBox(width: 12),
                                                Expanded(
                                                  child: Text(
                                                      'Error updating user: ${e.toString()}'),
                                                ),
                                              ],
                                            ),
                                            backgroundColor: AppColors.error,
                                            behavior: SnackBarBehavior.floating,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                          ),
                                        );
                                      }
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    foregroundColor: Colors.white,
                                    shadowColor: Colors.transparent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: isLoading
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                    Colors.white),
                                          ),
                                        )
                                      : Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            const SizedBox(width: 8),
                                            Text(
                                              'Update',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    } catch (e) {
      print('Dialog error: $e');
    } finally {
      // Safely dispose controllers
      try {
        paidLeaveController.dispose();
        sickLeaveController.dispose();
        earnedLeaveController.dispose();
      } catch (e) {
        print('Controller disposal error: $e');
      }
    }
  }

  static Widget _buildLeaveField(
    String label,
    TextEditingController controller,
    IconData icon,
    Color color,
    String helperText, {
    bool enabled = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 16),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: enabled ? null : Colors.grey,
              ),
            ),
            const Spacer(),
            Text(
              helperText,
              style: AppTextStyles.bodySmall.copyWith(
                color: enabled ? AppColors.textSecondary : Colors.grey,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          enabled: enabled,
          decoration: InputDecoration(
            hintText: '0',
            filled: true,
            fillColor: enabled ? Colors.white : Colors.grey.shade100,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: color.withOpacity(0.3)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: color.withOpacity(0.3)),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: color, width: 2),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          keyboardType: TextInputType.number,
        ),
      ],
    );
  }
}
