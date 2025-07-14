import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import '../../core/constants.dart';
import '../../providers/leave_provider.dart';
import '../../models/leave_record.dart';
import 'widgets/leave_filter_chips.dart';
import 'widgets/leave_request_card.dart';

class ApproveLeaveScreen extends ConsumerStatefulWidget {
  const ApproveLeaveScreen({super.key});

  @override
  ConsumerState<ApproveLeaveScreen> createState() => _ApproveLeaveScreenState();
}

class _ApproveLeaveScreenState extends ConsumerState<ApproveLeaveScreen> {
  String _selectedFilter = 'all';
  String _selectedStatusFilter = 'all'; // New status filter
  final Map<String, String> _filterOptions = {
    'all': 'All Types',
    'sick': 'Sick Leave',
    'casual': 'Casual Leave',
    'earned': 'Earned Leave',
  };
  final Map<String, String> _statusFilterOptions = {
    'all': 'All Statuses',
    'pending': 'Pending',
    'approved': 'Approved',
    'rejected': 'Rejected',
  };

  @override
  Widget build(BuildContext context) {
    final leavesAsync = ref.watch(allLeavesProvider); // Updated to use allLeavesProvider

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: Text('Leave Requests', style: AppTextStyles.heading2.copyWith(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Iconsax.filter, color: Colors.white),
            onPressed: () => _showFilterDialog(context),
            tooltip: 'Filter Requests',
          ),
        ],
      ),
      body: Column(
        children: [
          LeaveFilterChips(
            selectedFilter: _selectedFilter,
            filterOptions: _filterOptions,
            selectedStatusFilter: _selectedStatusFilter,
            statusFilterOptions: _statusFilterOptions,
            onFilterChanged: (value) => setState(() => _selectedFilter = value),
            onStatusFilterChanged: (value) => setState(() => _selectedStatusFilter = value),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                ref.refresh(allLeavesProvider);
              },
              child: leavesAsync.when(
                data: (leaves) {
                  final filteredLeaves = _filterLeaves(leaves);
                  if (filteredLeaves.isEmpty) {
                    return _buildEmptyState();
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: filteredLeaves.length,
                    itemBuilder: (context, index) {
                      final leaveData = filteredLeaves[index];
                      final leave = leaveData['leave'] as LeaveRecord;
                      return LeaveRequestCard(
                        leave: leave,
                        onApprove: leave.status == 'pending' ? () => _approveLeave(leave) : null,
                        onReject: leave.status == 'pending' ? () => _showRejectDialog(context, leave) : null ,
                        userName: leaveData['userName'] as String? ?? 'Unknown User'
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => _buildErrorState(e.toString()),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                borderRadius: BorderRadius.circular(50),
              ),
              child: Icon(
                Iconsax.tick_circle,
                color: AppColors.success,
                size: 64,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No Leave Requests',
              style: AppTextStyles.heading3,
            ),
            const SizedBox(height: 8),
            Text(
              _selectedFilter == 'all' && _selectedStatusFilter == 'all'
                  ? 'No leave requests found.'
                  : 'No ${_filterOptions[_selectedFilter]?.toLowerCase() ?? 'leave'} requests with ${_statusFilterOptions[_selectedStatusFilter]?.toLowerCase() ?? 'selected'} status.',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
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
                color: AppColors.error,
                size: 64,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Something went wrong',
              style: AppTextStyles.heading3,
            ),
            const SizedBox(height: 8),
            Text(
              'Unable to load leave requests. Please try again.',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => ref.refresh(allLeavesProvider),
              icon: const Icon(Iconsax.refresh),
              label: const Text('Retry'),
              style: AppButtonStyles.primaryButton,
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Filter Leave Requests', style: AppTextStyles.heading3),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Leave Type', style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
              ..._filterOptions.entries.map((entry) {
                return RadioListTile<String>(
                  title: Text(entry.value, style: AppTextStyles.bodyMedium),
                  value: entry.key,
                  groupValue: _selectedFilter,
                  onChanged: (value) {
                    setState(() {
                      _selectedFilter = value!;
                    });
                    Navigator.pop(context);
                  },
                );
              }).toList(),
              const SizedBox(height: 16),
              Text('Status', style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
              ..._statusFilterOptions.entries.map((entry) {
                return RadioListTile<String>(
                  title: Text(entry.value, style: AppTextStyles.bodyMedium),
                  value: entry.key,
                  groupValue: _selectedStatusFilter,
                  onChanged: (value) {
                    setState(() {
                      _selectedStatusFilter = value!;
                    });
                    Navigator.pop(context);
                  },
                );
              }).toList(),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }

  void _showRejectDialog(BuildContext context, LeaveRecord leave) {
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Reject Leave Request', style: AppTextStyles.heading3),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Are you sure you want to reject this leave request?',
              style: AppTextStyles.bodyMedium,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: AppInputDecorations.textFieldDecoration(
                labelText: 'Reason for rejection (optional)',
                hintText: 'Enter reason...',
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _rejectLeave(leave, reasonController.text);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }

  Future<void> _approveLeave(LeaveRecord leave) async {
    try {
      await ref.read(leaveServiceProvider).updateLeaveStatus(
            userId: leave.userId,
            leaveId: leave.id,
            status: 'approved',
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Iconsax.tick_circle, color: Colors.white),
                const SizedBox(width: 8),
                Text('Leave request approved successfully'),
              ],
            ),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Iconsax.warning_2, color: Colors.white),
                const SizedBox(width: 8),
                Text('Error approving leave: $e'),
              ],
            ),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _rejectLeave(LeaveRecord leave, String reason) async {
    try {
      await ref.read(leaveServiceProvider).updateLeaveStatus(
            userId: leave.userId,
            leaveId: leave.id,
            status: 'rejected',
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Iconsax.close_circle, color: Colors.white),
                const SizedBox(width: 8),
                Text('Leave request rejected'),
              ],
            ),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Iconsax.warning_2, color: Colors.white),
                const SizedBox(width: 8),
                Text('Error rejecting leave: $e'),
              ],
            ),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  List<Map<String, dynamic>> _filterLeaves(List<Map<String, dynamic>> leaves) {
    return leaves.where((leaveData) {
      final leave = leaveData['leave'] as LeaveRecord;
      final typeMatch = _selectedFilter == 'all' || leave.type.toLowerCase() == _selectedFilter;
      final statusMatch = _selectedStatusFilter == 'all' || leave.status.toLowerCase() == _selectedStatusFilter;
      return typeMatch && statusMatch;
    }).toList();
  }
}