import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import '../../../core/constants.dart';
import '../../../models/user_model.dart';
import '../admin_dashboard_screen.dart';

class UserWithId {
  final UserModel user;
  final String id;

  UserWithId({required this.user, required this.id});
}

class UserListWidget extends ConsumerWidget {
  final AsyncValue<List<UserWithId>> usersAsync;
  final String searchQuery;
  final String selectedFilter;
  final ValueChanged<String> onUserSelected;

  const UserListWidget({
    super.key,
    required this.usersAsync,
    required this.searchQuery,
    required this.selectedFilter,
    required this.onUserSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return usersAsync.when(
      data: (usersWithId) {
        final filteredUsers = usersWithId.where((userWithId) {
          final matchesSearch = searchQuery.isEmpty ||
              userWithId.user.name.toLowerCase().contains(searchQuery) ||
              userWithId.user.email.toLowerCase().contains(searchQuery);
          final matchesFilter = selectedFilter == 'all' ||
              userWithId.user.role.toLowerCase() == selectedFilter;
          return matchesSearch && matchesFilter;
        }).toList();

        if (filteredUsers.isEmpty) {
          return SliverFillRemaining(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.textHint.withOpacity(0.1), AppColors.textHint.withOpacity(0.05)],
                      ),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Icon(
                      Iconsax.user_remove,
                      color: AppColors.textHint,
                      size: 64,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'No Users Found',
                    style: AppTextStyles.heading3,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    searchQuery.isEmpty && selectedFilter == 'all'
                        ? 'No users available.'
                        : 'No users match the search or filter criteria.',
                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final userWithId = filteredUsers[index];
              return FadeTransition(
                opacity: Tween<double>(
                  begin: 0.0,
                  end: 1.0,
                ).animate(
                  CurvedAnimation(
                    parent: AnimationController(
                      duration: const Duration(milliseconds: 800),
                      vsync: Navigator.of(context),
                    )..forward(),
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
                      parent: AnimationController(
                        duration: const Duration(milliseconds: 800),
                        vsync: Navigator.of(context),
                      )..forward(),
                      curve: Interval(
                        (index * 0.1).clamp(0.0, 1.0),
                        ((index * 0.1) + 0.3).clamp(0.0, 1.0),
                        curve: Curves.easeOutCubic,
                      ),
                    ),
                  ),
                  child: _buildModernUserCard(context, userWithId),
                ),
              );
            },
            childCount: filteredUsers.length,
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
                'Loading users...',
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      ),
      error: (e, stackTrace) {
        print('Error loading users: $e, StackTrace: $stackTrace');
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
                  'Unable to load users: $e',
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
                    onPressed: () => ref.refresh(allUsersProvider),
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
      },
    );
  }

  Widget _buildModernUserCard(BuildContext context, UserWithId userWithId) {
    final user = userWithId.user;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
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
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onUserSelected(userWithId.id),
          borderRadius: BorderRadius.circular(15),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary.withOpacity(0.05),
                      AppColors.primary.withOpacity(0.02),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(15),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppColors.primary, AppColors.accent],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                          style: AppTextStyles.heading3.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.name,
                            style: AppTextStyles.heading3.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            user.email,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            user.role == 'admin' ? AppColors.warning : AppColors.primary,
                            user.role == 'admin' ? AppColors.warning.withOpacity(0.8) : AppColors.primary.withOpacity(0.8),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: (user.role == 'admin' ? AppColors.warning : AppColors.primary).withOpacity(0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            user.role == 'admin' ? Iconsax.shield : Iconsax.user,
                            color: Colors.white,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            user.role.toUpperCase(),
                            style: AppTextStyles.bodySmall.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.background, Colors.grey.shade50],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(15),
                    bottomRight: Radius.circular(15),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            user.verified ? AppColors.success.withOpacity(0.1) : AppColors.error.withOpacity(0.1),
                            user.verified ? AppColors.success.withOpacity(0.05) : AppColors.error.withOpacity(0.05),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        user.verified ? Iconsax.verify : Iconsax.close_circle,
                        color: user.verified ? AppColors.success : AppColors.error,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      user.verified ? 'Verified' : 'Not Verified',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: user.verified ? AppColors.success : AppColors.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      Iconsax.arrow_right_3,
                      color: AppColors.textHint,
                      size: 18,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}