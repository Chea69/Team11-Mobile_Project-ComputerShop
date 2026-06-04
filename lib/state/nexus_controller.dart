import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/mock_data.dart';
import '../models/models.dart';
import '../models/view_state.dart';

class NexusController extends ChangeNotifier {
  NexusController(this._prefs) {
    currentView = ViewState.home;
    cart.addAll([
      CartItem(
        id: 'cart-1',
        productId: featuredProducts.first.id,
        qty: 1,
        price: featuredProducts.first.price,
        configOptions: CartConfigOptions(ram: '64GB', storage: '2TB'),
      ),
      CartItem(
        id: 'cart-2',
        productId: featuredProducts.length > 1
            ? featuredProducts[1].id
            : featuredProducts.first.id,
        qty: 1,
        price: featuredProducts.length > 1
            ? featuredProducts[1].price
            : featuredProducts.first.price,
      ),
    ]);

    notifications.add(
      NotificationEntry(
        id: 'notif-1',
        title: 'Welcome to Nexus',
        message: 'Check out the new RTX 4090 Super builds in the Builder!',
        read: false,
        date: DateTime.now().toIso8601String(),
      ),
    );
  }

  static const String kHasSeenOnboarding = 'hasSeenOnboarding';
  final SharedPreferences _prefs;

  bool isDarkTheme = true;
  ViewState currentView = ViewState.onboarding;
  Map<String, dynamic>? viewParams;

  final List<CartItem> cart = [];
  List<String> favorites = [];
  final List<BuilderState> savedBuilds = [];
  final List<NotificationEntry> notifications = [];

  int get cartCount => cart.fold(0, (a, item) => a + item.qty);

  double get cartSubtotal =>
      cart.fold(0, (double sum, item) => sum + item.price * item.qty);

  int get unreadNotificationsCount =>
      notifications.where((n) => !n.read).length;

  Brightness get brightness => isDarkTheme ? Brightness.dark : Brightness.light;

  void toggleTheme() {
    isDarkTheme = !isDarkTheme;
    notifyListeners();
  }

  void navigate(ViewState view, {Map<String, dynamic>? params}) {
    currentView = view;
    viewParams = params;
    notifyListeners();
  }

  Future<void> finishOnboarding() async {
    await _prefs.setBool(kHasSeenOnboarding, true);
    navigate(ViewState.home);
  }

  Future<void> skipOnboarding() async {
    await _prefs.setBool(kHasSeenOnboarding, true);
    navigate(ViewState.home);
  }

  Product? featuredById(String? id) {
    if (id == null || id.isEmpty) return featuredProducts.first;
    if (id == buildOfTheMonthProduct.id) return buildOfTheMonthProduct;
    try {
      return featuredProducts.firstWhere((p) => p.id == id);
    } catch (_) {
      try {
        return allCatalogProducts.firstWhere((p) => p.id == id);
      } catch (_) {
        return featuredProducts.first;
      }
    }
  }

  void addToCart(NewCartPayload payload) {
    cart.add(
      CartItem(
        id: _randomId(),
        productId: payload.productId,
        qty: payload.qty,
        price: payload.price,
        configOptions: payload.configOptions,
      ),
    );
    notifyListeners();
  }

  void removeFromCart(String id) {
    cart.removeWhere((e) => e.id == id);
    notifyListeners();
  }

  void updateCartQty(String id, int qty) {
    if (qty < 1) {
      removeFromCart(id);
      return;
    }
    final idx = cart.indexWhere((e) => e.id == id);
    if (idx >= 0) {
      cart[idx] = CartItem(
        id: cart[idx].id,
        productId: cart[idx].productId,
        qty: qty,
        price: cart[idx].price,
        configOptions: cart[idx].configOptions,
      );
      notifyListeners();
    }
  }

  void clearCart() {
    cart.clear();
    notifyListeners();
  }

  void toggleFavorite(String productId) {
    if (favorites.contains(productId)) {
      favorites.remove(productId);
    } else {
      favorites.add(productId);
    }
    notifyListeners();
  }

  void saveBuild(BuilderState build) {
    savedBuilds.add(build.copy());
    notifyListeners();
  }

  BuilderState? get latestSavedBuild =>
      savedBuilds.isEmpty ? null : savedBuilds.last;

  void markNotificationRead(String id) {
    final i = notifications.indexWhere((n) => n.id == id);
    if (i >= 0) {
      notifications[i] = NotificationEntry(
        id: notifications[i].id,
        title: notifications[i].title,
        message: notifications[i].message,
        read: true,
        date: notifications[i].date,
      );
      notifyListeners();
    }
  }

  List<NexusBuilderPart> compatibleParts(BuilderStep step, BuilderState build) {
    switch (step) {
      case BuilderStep.cpu:
        return BuilderCatalog.cpus;
      case BuilderStep.motherboard:
        return BuilderCatalog.motherboards
            .where((mb) => build.cpu == null || mb.socket == build.cpu!.socket)
            .toList();
      case BuilderStep.ram:
        return BuilderCatalog.ram
            .where(
              (r) =>
                  build.motherboard == null ||
                  r.ramType == build.motherboard!.ramType,
            )
            .toList();
      case BuilderStep.gpu:
        return BuilderCatalog.gpus;
      case BuilderStep.storage:
        return BuilderCatalog.storage;
      case BuilderStep.psu:
        final est = (build.cpu?.tdp ?? 0) + (build.gpu?.tdp ?? 0) + 150;
        return BuilderCatalog.psus.where((p) => p.wattage >= est).toList();
      case BuilderStep.casePart:
        return BuilderCatalog.cases
            .where(
              (c) =>
                  build.motherboard == null ||
                  c.formFactors.contains(build.motherboard!.formFactor),
            )
            .toList();
    }
  }

  List<String> compatibilityIssues(BuilderState build) {
    final issues = <String>[];
    final cpu = build.cpu;
    final mb = build.motherboard;
    final ram = build.ram;
    final psu = build.psu;
    final casing = build.casePart;
    final gpu = build.gpu;

    if (cpu != null && mb != null && cpu.socket != mb.socket) {
      issues.add('CPU and Motherboard socket mismatch.');
    }
    if (mb != null && ram != null && mb.ramType != ram.ramType) {
      issues.add('RAM type not supported by Motherboard.');
    }
    final est = (cpu?.tdp ?? 0) + (gpu?.tdp ?? 0) + 150;
    if (psu != null && psu.wattage < est) {
      issues.add('PSU wattage too low. Need at least ${est}W.');
    }
    if (mb != null &&
        casing != null &&
        !casing.formFactors.contains(mb.formFactor)) {
      issues.add('Motherboard form factor does not fit in Case.');
    }
    return issues;
  }

  String _randomId() =>
      Random().nextInt(1 << 32).toRadixString(16).padLeft(8, '0');
}

class NewCartPayload {
  NewCartPayload({
    required this.productId,
    required this.qty,
    required this.price,
    this.configOptions,
  });

  final String productId;
  final int qty;
  final double price;
  final CartConfigOptions? configOptions;
}

enum BuilderStep { cpu, motherboard, ram, gpu, storage, psu, casePart }
