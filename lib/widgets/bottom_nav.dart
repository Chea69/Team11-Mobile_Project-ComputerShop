import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
      label: 'Builder',
      route: '/builder',
      icon: Icons.memory_outlined,
      selectedIcon: Icons.memory,
    ),
    _NavDestination(
      label: 'Favorites',
      route: '/favorites',
      icon: Icons.favorite_border,
      selectedIcon: Icons.favorite,
    ),
    _NavDestination(
      label: 'Map',
      route: '/map',
      icon: Icons.map_outlined,
      selectedIcon: Icons.map,
    ),
    _NavDestination(
      label: 'Deals',
      route: '/promotions',
      icon: Icons.local_offer_outlined,
      selectedIcon: Icons.local_offer,
    ),
    _NavDestination(
      label: 'Settings',
      route: '/settings',
      icon: Icons.settings_outlined,
      selectedIcon: Icons.settings,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final currentPath = GoRouterState.of(context).uri.path;
    final selectedIndex = _selectedIndexForPath(currentPath);

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) {
          final destination = _destinations[index];
          if (destination.route != currentPath) {
            context.go(destination.route);
          }
        },
        destinations: [
          for (final destination in _destinations)
            NavigationDestination(
              icon: Icon(destination.icon),
              selectedIcon: Icon(destination.selectedIcon),
              label: destination.label,
            ),
        ],
      ),
    );
  }

  int _selectedIndexForPath(String path) {
    final index = _destinations.indexWhere((item) => item.route == path);
    return index == -1 ? 0 : index;
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
