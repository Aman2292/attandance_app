import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import '../../core/constants.dart';
import '../../providers/leave_provider.dart';
import '../../providers/user_provider.dart';

class LeaveScreen extends ConsumerWidget {
  const LeaveScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = ref.watch(authServiceProvider).currentUser?.uid ?? '';
    final leaveAsync = ref.watch(leaveRecordsProvider(userId));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Leave', style: AppTextStyles.heading2),
        backgroundColor: AppColors.primary,
        actions: [
          IconButton(
            icon: const Icon(Iconsax.add),
            onPressed: () => context.go('/employee/leave/apply'),
          ),
          IconButton(
            icon: const Icon(Iconsax.document),
            onPressed: () => context.go('/employee/leave/history'),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Recent Leave Requests', style: AppTextStyles.bodyLarge),
            leaveAsync.when(
              data: (records) => records.isEmpty
                  ? const Text('No leave records', style: AppTextStyles.bodyMedium)
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: records.length > 3 ? 3 : records.length,
                      itemBuilder: (context, index) {
                        final record = records[index];
                        return ListTile(
                          title: Text('${record.startDate.toString().substring(0, 10)} - ${record.type}'),
                          subtitle: Text('Status: ${record.status}'),
                        );
                      },
                    ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text('Error: $e', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.error)),
            ),
          ],
        ),
      ),
    );
  }
}