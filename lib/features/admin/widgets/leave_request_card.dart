import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/constants.dart';
import '../../../models/leave_record.dart';
import '../../../models/user_model.dart';
import '../../../providers/leave_provider.dart';
import '../../../providers/user_provider.dart';

class LeaveRequestCard extends ConsumerWidget {
  final LeaveRecord leave;
  final String userName;
  final VoidCallback? onApprove;
  final VoidCallback? onReject;

  const LeaveRequestCard({
    super.key,
    required this.leave,
    required this.userName,
    this.onApprove,
    this.onReject,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ValueNotifier<bool> isProcessing = ValueNotifier(false);

    return FutureBuilder<UserModel?>(
      future: _fetchUser(leave.userId),
      builder: (context, snapshot) {
        final user = snapshot.data;

        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _getLeaveTypeColor(leave.type).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        _getLeaveTypeIcon(leave.type),
                        color: _getLeaveTypeColor(leave.type),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${leave.type.toUpperCase()} Leave',
                            style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Icon(
                                Iconsax.profile_circle,
                                size: 14,
                                color: AppColors.textSecondary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                userName,
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Icon(
                                Iconsax.card,
                                size: 14,
                                color: AppColors.textSecondary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'ID: ${leave.userId.length > 10 ? "${leave.userId.substring(0, 10)}..." : leave.userId}',
                                style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getStatusColor(leave.status).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _getStatusColor(leave.status).withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _getStatusIcon(leave.status),
                            size: 12,
                            color: _getStatusColor(leave.status),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            leave.status.toUpperCase(),
                            style: AppTextStyles.bodySmall.copyWith(
                              color: _getStatusColor(leave.status),
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
                    border: Border.all(
                      color: AppColors.textHint.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      _buildDetailRow(
                        'Duration',
                        '${_formatDate(leave.startDate)} to ${_formatDate(leave.endDate)}',
                        Iconsax.calendar,
                      ),
                      const SizedBox(height: 8),
                      _buildDetailRow(
                        'Total Days',
                        '${leave.endDate.difference(leave.startDate).inDays + 1} days',
                        Iconsax.clock,
                      ),
                      if (leave.reason.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        _buildDetailRow(
                          'Reason',
                          leave.reason,
                          Iconsax.document_text,
                        ),
                      ],
                      if (leave.status == 'rejected' && leave.rejectionReason != null && leave.rejectionReason!.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        _buildDetailRow(
                          'Rejection Reason',
                          leave.rejectionReason!,
                          Iconsax.warning_2,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                if (user != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppColors.textHint.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Requestor\'s Leave Balance',
                          style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildBalanceItem('Paid', user.leaveBalance.paidLeave, AppColors.info, Iconsax.sun),
                            _buildBalanceItem('Sick', user.leaveBalance.sickLeave, AppColors.error, Iconsax.health),
                            _buildBalanceItem('Earned', user.leaveBalance.earnedLeave, AppColors.success, Iconsax.star),
                          ],
                        ),
                      ],
                    ),
                  )
                else if (snapshot.connectionState == ConnectionState.waiting)
                  const Center(child: CircularProgressIndicator())
                else
                   Text(
                    'Unable to load requestor\'s balance',
                    style: AppTextStyles.bodySmall,
                  ),
                if (leave.status == 'pending') ...[
                  const SizedBox(height: 16),
                  ValueListenableBuilder<bool>(
                    valueListenable: isProcessing,
                    builder: (context, processing, child) {
                      return Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: processing
                                  ? null
                                  : () async {
                                      isProcessing.value = true;
                                      try {
                                        final rejectionReason = await _showRejectionDialog(context);
                                        if (rejectionReason != null) {
                                          await ref.read(leaveServiceProvider).updateLeaveStatus(
                                                userId: leave.userId,
                                                leaveId: leave.id,
                                                status: 'rejected',
                                                rejectionReason: rejectionReason,
                                              );
                                          ref.invalidate(allLeavesProvider);
                                          onReject?.call();
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                              content: Text('Leave rejected successfully'),
                                              backgroundColor: AppColors.success,
                                            ),
                                          );
                                        }
                                      } catch (e) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text('Error rejecting leave: $e'),
                                            backgroundColor: AppColors.error,
                                          ),
                                        );
                                      } finally {
                                        isProcessing.value = false;
                                      }
                                    },
                              icon: const Icon(Iconsax.close_circle),
                              label: processing ? const CircularProgressIndicator() : const Text('Reject'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.error,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                elevation: 0,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: processing
                                  ? null
                                  : () async {
                                      isProcessing.value = true;
                                      try {
                                        // Check leave balance before approving
                                        if (user == null) {
                                          throw Exception('User data not loaded');
                                        }
                                        final leaveType = leave.type.toLowerCase() == 'casual' ? 'paid' : leave.type.toLowerCase();
                                        final balance = user.leaveBalance;
                                        bool canApprove = false;
                                        switch (leaveType) {
                                          case 'paid':
                                            canApprove = balance.paidLeave > 0;
                                            break;
                                          case 'sick':
                                            canApprove = balance.sickLeave > 0;
                                            break;
                                          case 'earned':
                                            canApprove = balance.earnedLeave > 0;
                                            break;
                                          default:
                                            throw Exception('Invalid leave type: $leaveType');
                                        }

                                        if (!canApprove) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text('Cannot approve: Insufficient $leaveType leave balance'),
                                              backgroundColor: AppColors.error,
                                            ),
                                          );
                                          return;
                                        }

                                        await ref.read(leaveServiceProvider).updateLeaveStatus(
                                              userId: leave.userId,
                                              leaveId: leave.id,
                                              status: 'approved',
                                            );
                                        ref.invalidate(userProvider); // Refresh user data
                                        ref.invalidate(allLeavesProvider); // Refresh leave records
                                        onApprove?.call();
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text('Leave approved successfully'),
                                            backgroundColor: AppColors.success,
                                          ),
                                        );
                                      } catch (e) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text('Error approving leave: $e'),
                                            backgroundColor: AppColors.error,
                                          ),
                                        );
                                      } finally {
                                        isProcessing.value = false;
                                      }
                                    },
                              icon: const Icon(Iconsax.tick_circle),
                              label: processing ? const CircularProgressIndicator() : const Text('Approve'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.success,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                elevation: 0,
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Future<UserModel?> _fetchUser(String userId) async {
    final doc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
    return doc.exists ? UserModel.fromFirestore(doc) : null;
  }

  Future<String?> _showRejectionDialog(BuildContext context) async {
    TextEditingController reasonController = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Iconsax.close_circle, color: AppColors.error, size: 24),
            const SizedBox(width: 8),
            const Text('Reject Leave'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Please provide a reason for rejecting the leave',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              maxLines: 3,
              decoration: AppInputDecorations.textFieldDecoration(
                labelText: 'Rejection Reason',
                hintText: 'e.g., Insufficient leave balance',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final reason = reasonController.text.trim();
              if (reason.isNotEmpty) {
                Navigator.pop(context, reason);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please provide a rejection reason'),
                    backgroundColor: AppColors.error,
                  ),
                );
              }
            },
            style: AppButtonStyles.primaryButton,
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: AppTextStyles.bodySmall.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: AppTextStyles.bodySmall,
          ),
        ),
      ],
    );
  }

  Widget _buildBalanceItem(String type, int count, Color color, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(height: 4),
            Text(
              '$count',
              style: AppTextStyles.bodyMedium.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              type,
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return Iconsax.tick_circle;
      case 'rejected':
        return Iconsax.close_circle;
      case 'pending':
        return Iconsax.clock;
      default:
        return Iconsax.info_circle;
    }
  }

  Color _getLeaveTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'sick':
        return AppColors.error;
      case 'casual':
        return AppColors.info;
      case 'earned':
        return AppColors.success;
      case 'maternity':
      case 'paternity':
        return AppColors.warning;
      default:
        return AppColors.primary;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return AppColors.success;
      case 'rejected':
        return AppColors.error;
      case 'pending':
        return AppColors.pending;
      default:
        return AppColors.textSecondary;
    }
  }

  IconData _getLeaveTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'sick':
        return Iconsax.health;
      case 'casual':
        return Iconsax.coffee;
      case 'earned':
        return Iconsax.medal_star;
      case 'maternity':
      case 'paternity':
        return Iconsax.group;
      default:
        return Iconsax.calendar;
    }
  }
}
