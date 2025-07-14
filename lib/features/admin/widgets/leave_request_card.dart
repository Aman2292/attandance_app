import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/constants.dart';
import '../../../models/leave_record.dart';

class LeaveRequestCard extends StatelessWidget {
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
  Widget build(BuildContext context) {
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
            if (leave.status == 'pending') ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: onReject,
                      icon: const Icon(Iconsax.close_circle),
                      label: const Text('Reject'),
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
                      onPressed: onApprove,
                      icon: const Icon(Iconsax.tick_circle),
                      label: const Text('Approve'),
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
              ),
            ],
          ],
        ),
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

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
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