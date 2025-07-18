import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import '../../core/constants.dart';
import '../../providers/leave_provider.dart';
import '../../models/leave_record.dart';
import 'widgets/leave_filter_chips.dart';
import 'widgets/leave_request_card.dart';
import '../../providers/user_provider.dart';

class ApproveLeaveScreen extends ConsumerStatefulWidget {
  const ApproveLeaveScreen({super.key});

  @override
  ConsumerState<ApproveLeaveScreen> createState() => _ApproveLeaveScreenState();
}

class _ApproveLeaveScreenState extends ConsumerState<ApproveLeaveScreen> with SingleTickerProviderStateMixin {
  String _selectedFilter = 'all';
  String _selectedStatusFilter = 'all';
  String searchQuery = '';
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  final Map<String, String> _filterOptions = {
    'all': 'All Types',
    'sick': 'Sick Leave',
    'paid': 'Paid Leave',
    'earned': 'Earned Leave',
  };
  final Map<String, String> _statusFilterOptions = {
    'all': 'All Statuses',
    'pending': 'Pending',
    'approved': 'Approved',
    'rejected': 'Rejected',
  };

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic));
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Widget _buildSearchAndFilter() {
    return Container(
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, Colors.grey.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primary.withOpacity(0.1)),
            ),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Enter user name or ID to search...',
                prefixIcon: Container(
                  margin: const EdgeInsets.all(8),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.surface, AppColors.surface.withOpacity(0.8)],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Iconsax.search_normal,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: AppColors.background,
                contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                labelStyle: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
                hintStyle: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary.withOpacity(0.7),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          LeaveFilterChips(
            selectedFilter: _selectedFilter,
            filterOptions: _filterOptions,
            selectedStatusFilter: _selectedStatusFilter,
            statusFilterOptions: _statusFilterOptions,
            onFilterChanged: (value) => setState(() => _selectedFilter = value),
            onStatusFilterChanged: (value) => setState(() => _selectedStatusFilter = value),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return SliverFillRemaining(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.success.withOpacity(0.1), AppColors.success.withOpacity(0.05)],
                ),
                borderRadius: BorderRadius.circular(50),
              ),
              child: Icon(
                Iconsax.tick_circle,
                color: AppColors.success,
                size: 64,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'No Leave Requests',
              style: AppTextStyles.heading3,
            ),
            const SizedBox(height: 8),
            Text(
              _selectedFilter == 'all' && _selectedStatusFilter == 'all' && searchQuery.isEmpty
                  ? 'No leave requests found.'
                  : 'No matching leave requests.',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return SliverFillRemaining(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.error.withOpacity(0.1), AppColors.error.withOpacity(0.05)],
                ),
                borderRadius: BorderRadius.circular(50),
              ),
              child: Icon(
                Iconsax.warning_2,
                color: AppColors.error,
                size: 64,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Something went wrong',
              style: AppTextStyles.heading3,
            ),
            const SizedBox(height: 8),
            Text(
              'Unable to load leave requests: $error',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
                ),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton.icon(
                onPressed: () => ref.refresh(allLeavesProvider),
                icon: const Icon(Iconsax.refresh, size: 18),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                ),
              ),
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
        backgroundColor: Colors.transparent,
        contentPadding: EdgeInsets.zero,
        content: Container(
          width: MediaQuery.of(context).size.width * 2 / 3,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.white, Colors.grey.shade50],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
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
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(15),
                      topRight: Radius.circular(15),
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
                        child: const Icon(Iconsax.filter, color: Colors.white, size: 20),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Filter Leave Requests',
                          style: AppTextStyles.heading3.copyWith(color: Colors.white),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Iconsax.close_square, color: Colors.white, size: 18),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Leave Type',
                        style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 10),
                      ..._filterOptions.entries.map((entry) {
                        return RadioListTile<String>(
                          title: Text(entry.value, style: AppTextStyles.bodyMedium),
                          value: entry.key,
                          groupValue: _selectedFilter,
                          activeColor: AppColors.primary,
                          onChanged: (value) {
                            setState(() {
                              _selectedFilter = value!;
                            });
                            Navigator.pop(context);
                          },
                        );
                      }).toList(),
                      const SizedBox(height: 10),
                      Text(
                        'Status',
                        style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 10),
                      ..._statusFilterOptions.entries.map((entry) {
                        return RadioListTile<String>(
                          title: Text(entry.value, style: AppTextStyles.bodyMedium),
                          value: entry.key,
                          groupValue: _selectedStatusFilter,
                          activeColor: AppColors.primary,
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
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(15),
                      bottomRight: Radius.circular(15),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            'Cancel',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w600,
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
    );
  }

  void _showRejectDialog(BuildContext context, LeaveRecord leave) {
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.transparent,
        contentPadding: EdgeInsets.zero,
        content: Container(
          width: MediaQuery.of(context).size.width * 2 / 3,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.white, Colors.grey.shade50],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
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
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.error, AppColors.error.withOpacity(0.8)],
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(15),
                      topRight: Radius.circular(15),
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
                        child: const Icon(Iconsax.close_circle, color: Colors.white, size: 20),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Reject Leave Request',
                          style: AppTextStyles.heading3.copyWith(color: Colors.white),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Iconsax.close_square, color: Colors.white, size: 18),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Are you sure you want to reject this leave request?',
                        style: AppTextStyles.bodyMedium,
                      ),
                      const SizedBox(height: 10),
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
                ),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(15),
                      bottomRight: Radius.circular(15),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(
                              'Cancel',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [AppColors.error, AppColors.error.withOpacity(0.8)],
                            ),
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.error.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                              _rejectLeave(leave, reasonController.text);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              foregroundColor: Colors.white,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            child: const Text('Reject'),
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
    );
  }

  Future<void> _approveLeave(LeaveRecord leave) async {
    final adminUser = ref.read(userProvider).valueOrNull;
    if (adminUser?.role != 'admin') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Only admins can approve leaves'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }
    final adminId = ref.read(authServiceProvider).currentUser?.uid;
    if (adminId == null) {
      debugPrint('Admin not authenticated');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Admin not authenticated'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }
    try {
      debugPrint('Approving leave: userId=${leave.userId}, leaveId=${leave.id}, adminId=$adminId');
      await ref.read(leaveServiceProvider).updateLeaveStatus(
            userId: leave.userId,
            leaveId: leave.id,
            status: 'approved',
            adminId: adminId,
          ).timeout(const Duration(seconds: 10), onTimeout: () {
        throw TimeoutException('Leave approval timed out');
      });
      ref.invalidate(userProvider);
      ref.refresh(allLeavesProvider);
      debugPrint('Providers refreshed after approval');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Iconsax.tick_circle, color: Colors.white, size: 18),
                const SizedBox(width: 8),
                Text('Leave request approved successfully', style: AppTextStyles.bodyMedium.copyWith(color: Colors.white)),
              ],
            ),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
      debugPrint('Leave approved successfully');
    } catch (e) {
      debugPrint('Approval error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Iconsax.warning_2, color: Colors.white, size: 18),
                const SizedBox(width: 8),
                Text('Error approving leave: $e', style: AppTextStyles.bodyMedium.copyWith(color: Colors.white)),
              ],
            ),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  Future<void> _rejectLeave(LeaveRecord leave, String reason) async {
    final adminUser = ref.read(userProvider).valueOrNull;
    if (adminUser?.role != 'admin') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Only admins can reject leaves'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }
    final adminId = ref.read(authServiceProvider).currentUser?.uid;
    if (adminId == null) {
      debugPrint('Admin not authenticated');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Admin not authenticated'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }
    try {
      debugPrint('Rejecting leave: userId=${leave.userId}, leaveId=${leave.id}, adminId=$adminId');
      await ref.read(leaveServiceProvider).updateLeaveStatus(
            userId: leave.userId,
            leaveId: leave.id,
            status: 'rejected',
            rejectionReason: reason.isNotEmpty ? reason : null,
            adminId: adminId,
          ).timeout(const Duration(seconds: 10), onTimeout: () {
        throw TimeoutException('Leave rejection timed out');
      });
      ref.refresh(allLeavesProvider);
      debugPrint('Providers refreshed after rejection');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Iconsax.close_circle, color: Colors.white, size: 18),
                const SizedBox(width: 8),
                Text('Leave request rejected', style: AppTextStyles.bodyMedium.copyWith(color: Colors.white)),
              ],
            ),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
      debugPrint('Leave rejected successfully');
    } catch (e) {
      debugPrint('Rejection error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Iconsax.warning_2, color: Colors.white, size: 18),
                const SizedBox(width: 8),
                Text('Error rejecting leave: $e', style: AppTextStyles.bodyMedium.copyWith(color: Colors.white)),
              ],
            ),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  List<Map<String, dynamic>> _filterLeaves(List<Map<String, dynamic>> leaves) {
    return leaves.where((leaveData) {
      final leave = leaveData['leave'] as LeaveRecord;
      final userName = leaveData['userName'] as String? ?? '';
      final typeMatch = _selectedFilter == 'all' || leave.type.toLowerCase() == _selectedFilter;
      final statusMatch = _selectedStatusFilter == 'all' || leave.status.toLowerCase() == _selectedStatusFilter;
      final searchMatch = searchQuery.isEmpty ||
          userName.toLowerCase().contains(searchQuery.toLowerCase()) ||
          leave.userId.toLowerCase().contains(searchQuery.toLowerCase());
      return typeMatch && statusMatch && searchMatch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final adminUser = ref.watch(userProvider).valueOrNull;

    if (adminUser?.role != 'admin') {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Iconsax.warning_2,
                color: AppColors.error,
                size: 64,
              ),
              const SizedBox(height: 10),
              Text(
                'Access Denied',
                style: AppTextStyles.heading3.copyWith(color: AppColors.error),
              ),
              const SizedBox(height: 8),
              Text(
                'Only admins can view this screen',
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        onRefresh: () async {
          ref.refresh(allLeavesProvider);
          ref.invalidate(userProvider);
        },
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 125,
              floating: false,
              pinned: true,
              elevation: 0,
              backgroundColor: AppColors.surface,
              foregroundColor: Colors.white,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.surface,
                        AppColors.surface.withOpacity(0.8),
                        AppColors.primary.withOpacity(0.2),
                      ],
                    ),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20 ,vertical: 20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          FadeTransition(
                            opacity: _fadeAnimation,
                            child: SlideTransition(
                              position: _slideAnimation,
                              child: Column(
                                
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Approve Leave Requests',
                                    style: AppTextStyles.heading1.copyWith(
                                      color: Colors.white,
                                      fontSize: 22,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Review and manage leave requests',
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      color: Colors.white.withOpacity(0.8),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              leading: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Iconsax.arrow_left,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
              actions: [
                IconButton(
                  onPressed: () => _showFilterDialog(context),
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Iconsax.filter,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                  tooltip: 'Filter Requests',
                ),
                IconButton(
                  onPressed: () {
                    ref.refresh(allLeavesProvider);
                    ref.invalidate(userProvider);
                  },
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Iconsax.refresh,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
              ],
            ),
            SliverToBoxAdapter(
              child: _buildSearchAndFilter(),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              sliver: ref.watch(allLeavesProvider).when(
                data: (leaves) {
                  final filteredLeaves = _filterLeaves(leaves);
                  if (filteredLeaves.isEmpty) {
                    return _buildEmptyState();
                  }
                  return SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final leaveData = filteredLeaves[index];
                        final leave = leaveData['leave'] as LeaveRecord;
                        return FadeTransition(
                          opacity: Tween<double>(
                            begin: 0.0,
                            end: 1.0,
                          ).animate(
                            CurvedAnimation(
                              parent: _animationController,
                              curve: Interval(
                                (index * 0.1).clamp(0.0, 1.0),
                                ((index * 0.1) + 0.3).clamp(0.0, 1.0),
                                curve: Curves.easeOutCubic,
                              ),
                            ),
                          ),
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0, 0.3),
                              end: Offset.zero,
                            ).animate(
                              CurvedAnimation(
                                parent: _animationController,
                                curve: Interval(
                                  (index * 0.1).clamp(0.0, 1.0),
                                  ((index * 0.1) + 0.3).clamp(0.0, 1.0),
                                  curve: Curves.easeOutCubic,
                                ),
                              ),
                            ),
                            child: LeaveRequestCard(
                              leave: leave,
                              onApprove: leave.status == 'pending' ? () => _approveLeave(leave) : null,
                              onReject: leave.status == 'pending' ? () => _showRejectDialog(context, leave) : null,
                              userName: leaveData['userName'] as String? ?? 'Unknown User',
                            ),
                          ),
                        );
                      },
                      childCount: filteredLeaves.length,
                    ),
                  );
                },
                loading: () => SliverToBoxAdapter(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Loading leave requests...',
                          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ),
                error: (e, _) => _buildErrorState(e.toString()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}