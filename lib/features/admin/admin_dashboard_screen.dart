import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:iconsax/iconsax.dart';
import '../../core/constants.dart';
import '../../core/widgets/confirmation_dialog.dart';
import '../../models/leave_record.dart';
import '../../models/user_model.dart';
import '../../providers/user_provider.dart';
import '../../services/auth_service.dart';
import 'utils/dashboard_utils.dart';
import 'widgets/pending_leaves_section_widget.dart';
import 'widgets/statistics_section_widget.dart';

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

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAdminAccess();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
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
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120,
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
                    padding: const EdgeInsets.symmetric(horizontal: 16),
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
                                  'Admin Dashboard',
                                  style: AppTextStyles.heading1.copyWith(
                                    color: Colors.white,
                                    fontSize: 28,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Manage your workforce efficiently',
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: Colors.white.withOpacity(0.8),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            actions: [
              Container(
                margin: const EdgeInsets.only(right: 8),
                child: IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Iconsax.user_edit, color: Colors.white, size: 20),
                  ),
                  onPressed: () => context.go('/admin/manage-users'),
                  tooltip: 'Manage Users',
                ),
              ),
              Container(
                margin: const EdgeInsets.only(right: 16),
                child: IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Iconsax.logout, color: Colors.white, size: 20),
                  ),
                  onPressed: () => _showLogoutDialog(),
                  tooltip: 'Logout',
                ),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildWelcomeSection(),
                          const SizedBox(height: 30),
                          // Wrap StatisticsSectionWidget in a constrained box
                          SizedBox(
                            width: constraints.maxWidth,
                            child: StatisticsSectionWidget(
                              usersAsync: usersAsync,
                              pendingLeavesAsync: pendingLeavesAsync,
                            ),
                          ),
                          const SizedBox(height: 40),
                          // Wrap QuickActionsSection in a constrained box
                          SizedBox(
                            width: constraints.maxWidth,
                            child: _buildQuickActionsSection(),
                          ),
                          const SizedBox(height: 10),
                          // Wrap PendingLeavesSectionWidget in a constrained box
                          SizedBox(
                            width: constraints.maxWidth,
                            child: PendingLeavesSectionWidget(
                              pendingLeavesAsync: pendingLeavesAsync,
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => ConfirmationDialog(
        title: 'Logout',
        content: 'Are you sure you want to logout?',
        onConfirm: () async {
          try {
            final prefs = await SharedPreferences.getInstance();
            await prefs.clear();
            await AuthService().signOut();
            if (context.mounted) {
              context.go('/login');
            }
          } catch (e) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error logging out: $e'),
                  backgroundColor: AppColors.error,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              );
            }
          }
        },
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withOpacity(0.1),
            AppColors.accent.withOpacity(0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.primary.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Iconsax.crown,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome, Admin!',
                  style: AppTextStyles.heading3.copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Monitor team performance and oversee daily operations with comprehensive insights.',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Iconsax.flash_1,
              color: AppColors.surface,
              size: 30,
            ),
            const SizedBox(width: 12),
            Text(
              'Quick Actions',
              style: AppTextStyles.heading2.copyWith(fontSize: 20),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 15),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: DashboardUtils.buildActionCard(
                      'Manage Users',
                      'Add, edit, or remove team members',
                      Iconsax.user_edit,
                      AppColors.primary,
                      () => context.go('/admin/manage-users'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DashboardUtils.buildActionCard(
                      'Attendance',
                      'Monitor team attendance patterns',
                      Iconsax.calendar,
                      AppColors.success,
                      () => context.go('/admin/attendance-overview'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: DashboardUtils.buildActionCard(
                      'Leave Requests',
                      'Review and approve leave applications',
                      Iconsax.clipboard_text,
                      AppColors.warning,
                      () => context.go('/admin/approve-leave'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DashboardUtils.buildActionCard(
                      'Reports',
                      'Generate comprehensive analytics',
                      Iconsax.chart,
                      const Color.fromARGB(255, 0, 140, 255),
                      () => context.go('/admin/report-overview'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}


