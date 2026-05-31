import 'package:flutter/material.dart';

import 'router/app_router.dart';
import 'state/app_controller.dart';
import 'theme/app_theme.dart';

class ComputerShopApp extends StatefulWidget {
  const ComputerShopApp({super.key});

  @override
  State<ComputerShopApp> createState() => _ComputerShopAppState();
}

class _ComputerShopAppState extends State<ComputerShopApp> {
  final AppController _controller = AppController();

  @override
  Widget build(BuildContext context) {
    return AppControllerScope(
      controller: _controller,
      child: MaterialApp.router(
        title: 'Computer Shop',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: ThemeMode.dark,
        routerConfig: AppRouter.router,
      ),
    );
  }
}
