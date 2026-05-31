import 'package:go_router/go_router.dart';

import '../features/builder/pc_builder_screen.dart';
import '../features/detail/product_detail_screen.dart';
import '../features/favorites/favorites_screen.dart';
import '../features/home/home_screen.dart';
import '../features/map/map_screen.dart';
import '../features/promotions/promotions_screen.dart';
import '../features/settings/settings_screen.dart';
import '../widgets/bottom_nav.dart';

class AppRouter {
  const AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      ShellRoute(
        builder: (context, state, child) => BottomNav(child: child),
        routes: [
          GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
          GoRoute(
            path: '/builder',
            builder: (context, state) => const PcBuilderScreen(),
          ),
          GoRoute(
            path: '/favorites',
            builder: (context, state) => const FavoritesScreen(),
          ),
          GoRoute(path: '/map', builder: (context, state) => const MapScreen()),
          GoRoute(
            path: '/promotions',
            builder: (context, state) => const PromotionsScreen(),
          ),
          GoRoute(
            path: '/settings',
            builder: (context, state) => const SettingsScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/detail/:id',
        builder: (context, state) {
          final productId = state.pathParameters['id'] ?? 'unknown';
          return ProductDetailScreen(productId: productId);
        },
      ),
    ],
  );
}
