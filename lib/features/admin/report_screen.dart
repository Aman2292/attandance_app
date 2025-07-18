import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import '../../core/constants.dart';
import '../../providers/admin_report_provider.dart';
import 'widgets/reports_searchbar_reports.dart';
import 'widgets/user_details_widget.dart';
import 'widgets/user_lists_widget.dart';

class ReportOverviewScreen extends ConsumerStatefulWidget {
  const ReportOverviewScreen({super.key});

  @override
  ConsumerState<ReportOverviewScreen> createState() => _ReportOverviewScreenState();
}

class _ReportOverviewScreenState extends ConsumerState<ReportOverviewScreen> with SingleTickerProviderStateMixin {
  String? selectedUserId;
  String searchQuery = '';
  String _selectedFilter = 'all';
  final TextEditingController _searchController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  final Map<String, String> _filterOptions = {
    'all': 'All Roles',
    'admin': 'Admin',
    'employee': 'Employee',
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
    _searchController.dispose();
    super.dispose();
  }

  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.transparent,
        contentPadding: EdgeInsets.zero,
        content: Container(
          width: MediaQuery.of(context).size.width * 0.5,
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
                          'Filter Users by Role',
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
                        'Role',
                        style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 5),
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

  @override
  Widget build(BuildContext context) {
    final usersAsync = ref.watch(allUsersProvider);
    final attendanceAsync = selectedUserId != null ? ref.watch(userAttendanceProvider(selectedUserId!)) : null;
    final leavesAsync = selectedUserId != null ? ref.watch(userLeavesProvider(selectedUserId!)) : null;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: () async {
              ref.refresh(allUsersProvider);
              if (selectedUserId != null) {
                ref.refresh(userAttendanceProvider(selectedUserId!));
                ref.refresh(userLeavesProvider(selectedUserId!));
              }
            },
            child: CustomScrollView(
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
                          padding: const EdgeInsets.symmetric(horizontal: 10),
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
                                        'User Activity Reports',
                                        style: AppTextStyles.heading1.copyWith(
                                          color: Colors.white,
                                          fontSize: 28,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'View employee attendance and leave reports',
                                        style: AppTextStyles.bodyMedium.copyWith(
                                          color: Colors.white.withOpacity(0.8),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  leading: IconButton(
                    onPressed: () => context.go('/admin'),
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
                      tooltip: 'Filter Users',
                    ),
                    IconButton(
                      onPressed: () {
                        ref.refresh(allUsersProvider);
                        if (selectedUserId != null) {
                          ref.refresh(userAttendanceProvider(selectedUserId!));
                          ref.refresh(userLeavesProvider(selectedUserId!));
                        }
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
                    IconButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Row(
                              children: [
                                const Icon(Iconsax.export, color: Colors.white, size: 18),
                                const SizedBox(width: 8),
                                Text(
                                  'Export functionality not implemented',
                                  style: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
                                ),
                              ],
                            ),
                            backgroundColor: AppColors.primary,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        );
                      },
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Iconsax.export,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                  ],
                ),
                SliverToBoxAdapter(
                  child: SearchBarWidget(
                    controller: _searchController,
                    searchQuery: searchQuery,
                    onChanged: (value) {
                      setState(() {
                        searchQuery = value.toLowerCase();
                      });
                    },
                    onClear: () {
                      _searchController.clear();
                      setState(() {
                        searchQuery = '';
                      });
                    },
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  sliver: UserListWidget(
                    usersAsync: usersAsync,
                    searchQuery: searchQuery,
                    selectedFilter: _selectedFilter,
                    onUserSelected: (userId) {
                      setState(() {
                        selectedUserId = userId;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          if (selectedUserId != null && attendanceAsync != null && leavesAsync != null)
            UserDetailsWidget(
              userId: selectedUserId!,
              attendanceAsync: attendanceAsync,
              leavesAsync: leavesAsync,
              usersAsync: usersAsync,
              onClose: () {
                setState(() {
                  selectedUserId = null;
                });
              },
            ),
        ],
      ),
    );
  }
}