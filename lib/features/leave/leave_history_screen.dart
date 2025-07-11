import 'package:flutter/material.dart';
import '../../core/constants.dart';
import '../../core/widgets/empty_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/leave_provider.dart';
import '../../providers/user_provider.dart';
import 'leave_screen.dart';

class LeaveHistoryScreen extends ConsumerWidget {
  const LeaveHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authServiceProvider).currentUser;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Leave History', style: AppTextStyles.heading2),
        backgroundColor: AppColors.primary,
      ),
      body: user == null
          ? const Center(child: Text('Please log in to view leave history'))
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: ref.watch(leaveRecordsProvider(user.uid)).when(
                data: (records) {
                  if (records.isEmpty) {
                    return const EmptyState(message: 'No leave history found.');
                  }
                  return ListView.separated(
                    itemCount: records.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final record = records[index];
                      Color statusColor;
                      String statusLabel;
                      switch (record.status) {
                        case 'approved':
                          statusColor = Colors.green;
                          statusLabel = 'Approved';
                          break;
                        case 'pending':
                          statusColor = Colors.orange;
                          statusLabel = 'Pending';
                          break;
                        case 'rejected':
                          statusColor = Colors.red;
                          statusLabel = 'Rejected';
                          break;
                        default:
                          statusColor = Colors.grey;
                          statusLabel = record.status.capitalize();
                      }
                      IconData typeIcon;
                      switch (record.type) {
                        case 'paid':
                          typeIcon = Icons.attach_money;
                          break;
                        case 'sick':
                          typeIcon = Icons.healing;
                          break;
                        case 'earned':
                          typeIcon = Icons.card_giftcard;
                          break;
                        default:
                          typeIcon = Icons.event;
                      }
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.08),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: const EdgeInsets.all(10),
                                child: Icon(typeIcon, color: AppColors.primary, size: 28),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          record.type.capitalize(),
                                          style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold),
                                        ),
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: statusColor.withOpacity(0.15),
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: Text(
                                            statusLabel,
                                            style: AppTextStyles.bodySmall.copyWith(color: statusColor, fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'From: ${record.startDate.toString().substring(0, 10)}',
                                      style: AppTextStyles.bodySmall,
                                    ),
                                    Text(
                                      'To:   ${record.endDate.toString().substring(0, 10)}',
                                      style: AppTextStyles.bodySmall,
                                    ),
                                    if (record.reason.isNotEmpty) ...[
                                      const SizedBox(height: 8),
                                      Text('Reason:', style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.bold)),
                                      Text(record.reason, style: AppTextStyles.bodySmall),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Error: $e', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.error))),
              ),
            ),
    );
  }
}