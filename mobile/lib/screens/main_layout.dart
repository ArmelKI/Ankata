import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../config/app_theme.dart';

class MainLayout extends StatelessWidget {
  final Widget child;

  const MainLayout({Key? key, required this.child}) : super(key: key);

  int _calculateSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/home')) {
      return 0;
    }
    if (location.startsWith('/my-tickets') ||
        location.startsWith('/my-bookings')) {
      return 1;
    }
    if (location.startsWith('/companies')) {
      return 2;
    }
    if (location.startsWith('/profile')) {
      return 3;
    }
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/home');
        break;
      case 1:
        context.go('/my-tickets');
        break;
      case 2:
        context.go('/companies');
        break;
      case 3:
        context.go('/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        height: 64,
        decoration: const BoxDecoration(
          color: AppColors.white,
          border: Border(top: BorderSide(color: AppColors.border, width: 1)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(
              icon: Icons.home,
              label: 'Accueil',
              index: 0,
              currentIndex: _calculateSelectedIndex(context),
              onTap: () => _onItemTapped(0, context),
            ),
            _buildNavItem(
              icon: Icons.confirmation_number_outlined,
              label: 'Mes Billets',
              index: 1,
              currentIndex: _calculateSelectedIndex(context),
              onTap: () => _onItemTapped(1, context),
            ),
            _buildNavItem(
              icon: Icons.business,
              label: 'Compagnies',
              index: 2,
              currentIndex: _calculateSelectedIndex(context),
              onTap: () => _onItemTapped(2, context),
            ),
            _buildNavItem(
              icon: Icons.person_outline,
              label: 'Profil',
              index: 3,
              currentIndex: _calculateSelectedIndex(context),
              onTap: () => _onItemTapped(3, context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
    required int currentIndex,
    required VoidCallback onTap,
  }) {
    final isActive = index == currentIndex;
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isActive ? AppColors.primary : AppColors.gray,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: isActive ? AppColors.primary : AppColors.gray,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
