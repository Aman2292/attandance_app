import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import '../constants.dart';

class BottomNavBar extends StatefulWidget {
  final StatefulNavigationShell navigationShell;

  const BottomNavBar({super.key, required this.navigationShell});

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  int _previousIndex = 0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onItemTapped(BuildContext context, int index) {
    if (index != widget.navigationShell.currentIndex) {
      setState(() {
        _previousIndex = widget.navigationShell.currentIndex;
      });
      _animationController.forward().then((_) {
        _animationController.reverse();
      });
      widget.navigationShell.goBranch(index);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: widget.navigationShell,
      bottomNavigationBar: _buildModernBottomNav(),
    );
  }

  Widget _buildModernBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: AppColors.textSecondary.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
            spreadRadius: 0,
          ),
        ],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        child: BottomNavigationBar(
          currentIndex: widget.navigationShell.currentIndex,
          onTap: (index) => _onItemTapped(context, index),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedLabelStyle: AppTextStyles.bodySmall.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 11,
          ),
          unselectedLabelStyle: AppTextStyles.bodySmall.copyWith(
            fontWeight: FontWeight.w400,
            fontSize: 10,
          ),
          selectedItemColor: AppColors.primary,
          unselectedItemColor: const Color.fromARGB(255, 254, 254, 255).withOpacity(0.8),
          items: [
            _buildNavItem(
              icon: Iconsax.home,
              activeIcon: Iconsax.home,
              label: 'Dashboard',
              index: 0,
            ),
            _buildNavItem(
              icon: Iconsax.clock,
              activeIcon: Iconsax.clock,
              label: 'Attendance',
              index: 1,
            ),
            _buildNavItem(
              icon: Iconsax.chart,
              activeIcon: Iconsax.chart,
              label: 'Report',
              index: 2,
            ),
            _buildNavItem(
              icon: Iconsax.calendar,
              activeIcon: Iconsax.calendar,
              label: 'Leave',
              index: 3,
            ),
            _buildNavItem(
              icon: Iconsax.setting,
              activeIcon: Iconsax.setting,
              label: 'Settings',
              index: 4,
            ),
          ],
        ),
      ),
    );
  }

  BottomNavigationBarItem _buildNavItem({
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required int index,
  }) {
    final isSelected = widget.navigationShell.currentIndex == index;
    
    return BottomNavigationBarItem(
      icon: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primary.withOpacity(0.15),
                    AppColors.primary.withOpacity(0.05),
                  ],
                )
              : null,
          borderRadius: BorderRadius.circular(12),
        ),
        child: AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Transform.scale(
              scale: isSelected ? 1.1 : 1.0,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Ripple effect
                  if (isSelected)
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primary.withOpacity(0.4),
                            AppColors.primary.withOpacity(0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  // Icon
                  Icon(
                    isSelected ? activeIcon : icon,
                    size: 24,
                    color: isSelected
                        ? AppColors.primary
                        : Colors.white.withOpacity(0.5),
                  ),
                ],
              ),
            );
          },
        ),
      ),
      label: label,
    );
  }
}
