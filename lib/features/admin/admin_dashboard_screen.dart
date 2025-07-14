import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants.dart';
import '../../core/widgets/confirmation_dialog.dart';
import '../../providers/user_provider.dart';
import '../../models/user_model.dart';
import '../../models/leave_record.dart';
import '../../services/auth_service.dart';

final allUsersProvider = StreamProvider<List<UserModel>>((ref) {
  return FirebaseFirestore.instance
      .collection('users')
      .snapshots()
      .map((snapshot) => snapshot.docs.map((doc) => UserModel.fromFirestore(doc)).toList());
});

final pendingLeavesProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  return FirebaseFirestore.instance
      .collectionGroup('leaves')
      .where('status', isEqualTo: 'pending')
      .snapshots()
      .map((snapshot) => snapshot.docs.map((doc) {
            final leave = LeaveRecord.fromFirestore(doc);
            return {
              'leave': leave,
              'userId': leave.userId,
            };
          }).toList());
});

class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  ConsumerState<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAdminAccess();
    });
  }

  Future<void> _checkAdminAccess() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');
    if (userId == null) {
      if (mounted) {
        context.go('/login');
      }
      return;
    }
    final userData = await ref.read(userProvider.future);
    if (userData?.role != 'admin') {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Access denied: Admin only', style: AppTextStyles.bodyMedium.copyWith(color: Colors.white)),
            backgroundColor: AppColors.error,
          ),
        );
        context.go('/employee/dashboard');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final usersAsync = ref.watch(allUsersProvider);
    final pendingLeavesAsync = ref.watch(pendingLeavesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: Text('Admin Dashboard', style: AppTextStyles.heading2.copyWith(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Iconsax.user_edit, color: Colors.white),
            onPressed: () => context.go('/admin/manage-users'),
            tooltip: 'Manage Users',
          ),
          IconButton(
            icon: const Icon(Iconsax.logout, color: Colors.white),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => ConfirmationDialog(
                  title: 'Logout',
                  content: 'Are you sure you want to logout?',
                  onConfirm: () async {
                    try {
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.clear(); 
                      await AuthService().signOut(); // Sign out from Firebase Auth
                      if (context.mounted) {
                        context.go('/login'); // Navigate to login
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error logging out: $e'),
                            backgroundColor: AppColors.error,
                          ),
                        );
                      }
                    }
                  },
                ),
              );
            },
            tooltip: 'Logout',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.refresh(allUsersProvider);
          ref.refresh(pendingLeavesProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Section
              _buildWelcomeSection(),
              const SizedBox(height: 24),
              
              // Statistics Cards
              _buildStatisticsSection(usersAsync, pendingLeavesAsync),
              const SizedBox(height: 24),
              
              // Quick Actions
              _buildQuickActionsSection(),
              const SizedBox(height: 24),
              
              // Pending Leaves Section
              _buildPendingLeavesSection(pendingLeavesAsync),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary.withOpacity(0.1), AppColors.accent.withOpacity(0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Iconsax.crown,
              color: AppColors.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome back, Admin!',
                  style: AppTextStyles.heading3,
                ),
                const SizedBox(height: 4),
                Text(
                  'Manage your team and oversee operations',
                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsSection(AsyncValue<List<UserModel>> usersAsync, AsyncValue<List<Map<String, dynamic>>> pendingLeavesAsync) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Overview', style: AppTextStyles.heading3),
        const SizedBox(height: 12),
        usersAsync.when(
          data: (users) {
            final employees = users.where((u) => u.role == 'employee').length;
            final admins = users.where((u) => u.role == 'admin').length;
            final totalUsers = users.length;
            final pendingLeaves = pendingLeavesAsync.value?.length ?? 0;

            return GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 1.2,
              children: [
                _buildStatCard(
                  'Total Users',
                  '$totalUsers',
                  Iconsax.people,
                  AppColors.info,
                ),
                _buildStatCard(
                  'Employees',
                  '$employees',
                  Iconsax.user,
                  AppColors.success,
                ),
                _buildStatCard(
                  'Admins',
                  '$admins',
                  Iconsax.crown,
                  AppColors.warning,
                ),
                _buildStatCard(
                  'Pending Leaves',
                  '$pendingLeaves',
                  Iconsax.clock,
                  AppColors.pending,
                ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, stackTrace) => _buildErrorCard('Failed to load statistics', () => ref.refresh(allUsersProvider)),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 35,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 10),
            Text(
              value,
              style: AppTextStyles.heading2.copyWith(color: color),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: AppTextStyles.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Quick Actions', style: AppTextStyles.heading3),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                'Manage Users',
                Iconsax.user_edit,
                AppColors.primary,
                () => context.go('/admin/manage-users'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                'Attendance',
                Iconsax.calendar,
                AppColors.success,
                () => context.go('/admin/attendance-overview'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                'Leave Requests',
                Iconsax.clipboard_text,
                AppColors.warning,
                () => context.go('/admin/approve-leave'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                'Reports',
                Iconsax.chart,
                AppColors.info,
                () => context.go('/admin/reports'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton(String title, IconData icon, Color color, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        elevation: 2,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 24),
          const SizedBox(height: 8),
          Text(title, style: AppTextStyles.bodyMedium.copyWith(color: Colors.white)),
        ],
      ),
    );
  }

  Widget _buildPendingLeavesSection(AsyncValue<List<Map<String, dynamic>>> pendingLeavesAsync) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Recent Leave Requests', style: AppTextStyles.heading3),
            TextButton.icon(
              onPressed: () => context.go('/admin/approve-leave'),
              icon: const Icon(Iconsax.arrow_right_3, size: 16),
              label: Text('View All', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.primary)),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: pendingLeavesAsync.when(
              data: (leaves) {
                if (leaves.isEmpty) {
                  return _buildEmptyState(
                    'No pending leave requests',
                    'All caught up! No pending leave requests at the moment.',
                    Iconsax.tick_circle,
                    AppColors.success,
                  );
                }
                
                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: leaves.length > 5 ? 5 : leaves.length, // Show max 5 items
                  separatorBuilder: (context, index) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final leaveData = leaves[index];
                    final leave = leaveData['leave'] as LeaveRecord;
                    return _buildLeaveRequestTile(leave);
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, stackTrace) => _buildErrorCard('Failed to load leave requests', () => ref.refresh(pendingLeavesProvider)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLeaveRequestTile(LeaveRecord leave) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.pending.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          Iconsax.calendar_2,
          color: AppColors.pending,
          size: 20,
        ),
      ),
      title: Text(
        '${leave.type.toUpperCase()} Leave',
        style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Text(
            'From: ${leave.startDate.toString().substring(0, 10)}',
            style: AppTextStyles.bodySmall,
          ),
          Text(
            'Employee ID: ${leave.userId}',
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.pending.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          'Pending',
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.pending),
        ),
      ),
      onTap: () => context.go('/admin/approve-leave'),
    );
  }

  Widget _buildEmptyState(String title, String message, IconData icon, Color color) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(50),
              ),
              child: Icon(icon, color: color, size: 48),
            ),
            const SizedBox(height: 16),
            Text(title, style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text(
              message,
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  
  

  Widget _buildErrorCard(String message, VoidCallback onRetry) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(
              Iconsax.warning_2,
              color: AppColors.error,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.error),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Iconsax.refresh),
              label: const Text('Retry'),
              style: AppButtonStyles.primaryButton,
            ),
          ],
        ),
      ),
    );
  }
}