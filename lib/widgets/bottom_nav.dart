import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/app_colors.dart';

class BottomNav extends StatelessWidget {
  const BottomNav({required this.child, super.key});

  final Widget child;

  static const List<_NavDestination> _destinations = [
    _NavDestination(
      label: 'Home',
      route: '/',
      icon: Icons.home_outlined,
      selectedIcon: Icons.home,
    ),
    _NavDestination(
      label: 'Build',
      route: '/builder',
      icon: Icons.memory_outlined,
      selectedIcon: Icons.memory,
    ),
    _NavDestination(
      label: 'Compare',
      route: '/promotions',
      icon: Icons.compare_arrows,
      selectedIcon: Icons.compare_arrows,
    ),
    _NavDestination(
      label: 'Saved',
      route: '/favorites',
      icon: Icons.favorite_border,
      selectedIcon: Icons.favorite,
    ),
    _NavDestination(
      label: 'More',
      route: '/settings',
      icon: Icons.grid_view_outlined,
      selectedIcon: Icons.grid_view,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final currentPath = GoRouterState.of(context).uri.path;
    final selectedIndex = _selectedIndexForPath(currentPath);

    return Scaffold(
      body: child,
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          height: 78,
          margin: const EdgeInsets.fromLTRB(14, 0, 14, 12),
          padding: const EdgeInsets.all(1.2),
          decoration: BoxDecoration(
            gradient: AppColors.rgbBorderGradient,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.08),
                blurRadius: 22,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: AppColors.secondary.withValues(alpha: 0.08),
                blurRadius: 26,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.bgSurface.withValues(alpha: 0.96),
              borderRadius: BorderRadius.circular(7),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 7),
              child: Row(
                children: [
                  for (var index = 0; index < _destinations.length; index++)
                    Expanded(
                      child: _NavItem(
                        destination: _destinations[index],
                        isSelected: selectedIndex == index,
                        index: index,
                        onTap: () {
                          final destination = _destinations[index];
                          if (destination.route != currentPath) {
                            context.go(destination.route);
                          }
                        },
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  int _selectedIndexForPath(String path) {
    if (path == '/map') {
      return 4;
    }
    final index = _destinations.indexWhere((item) => item.route == path);
    return index == -1 ? 0 : index;
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.destination,
    required this.isSelected,
    required this.index,
    required this.onTap,
  });

  final _NavDestination destination;
  final bool isSelected;
  final int index;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final selectedColor = switch (index % 3) {
      0 => AppColors.cyan,
      1 => AppColors.magenta,
      _ => AppColors.violet,
    };
    final color = isSelected ? selectedColor : AppColors.darkMutedText;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            width: isSelected ? 30 : 0,
            height: 2,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(999),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: color.withValues(alpha: 0.7),
                        blurRadius: 12,
                      ),
                    ]
                  : null,
            ),
          ),
          const SizedBox(height: 7),
          AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            width: 34,
            height: 28,
            alignment: Alignment.center,
            decoration: isSelected
                ? BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: color.withValues(alpha: 0.32)),
                    boxShadow: [
                      BoxShadow(
                        color: color.withValues(alpha: 0.28),
                        blurRadius: 14,
                      ),
                    ],
                  )
                : null,
            child: Icon(
              isSelected ? destination.selectedIcon : destination.icon,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            destination.label.toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: color,
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );
  }
}

class _NavDestination {
  const _NavDestination({
    required this.label,
    required this.route,
    required this.icon,
    required this.selectedIcon,
  });

  final String label;
  final String route;
  final IconData icon;
  final IconData selectedIcon;
}
