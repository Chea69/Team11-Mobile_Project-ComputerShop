import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/mock_data.dart';
import '../models/models.dart';
import '../models/view_state.dart';

class NexusController extends ChangeNotifier {
  NexusController(this._prefs) {
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
  static const String kSessionName = 'sessionName';
  static const String kSessionEmail = 'sessionEmail';
  final SharedPreferences _prefs;

  bool isDarkTheme = true;
  ViewState currentView = ViewState.splash;
  Map<String, dynamic>? viewParams;
  NexusUser? currentUser;

  final List<CartItem> cart = [];
  List<String> favorites = [];
  final List<String?> compareProductIds = [
    featuredProducts.first.id,
    featuredProducts.length > 1 ? featuredProducts[1].id : null,
  ];
  final List<BuilderState> savedBuilds = [];
  final List<NotificationEntry> notifications = [];

  bool get isSignedIn => currentUser != null;

  int get cartCount => cart.fold(0, (a, item) => a + item.qty);

  double get cartSubtotal =>
      cart.fold(0, (double sum, item) => sum + item.price * item.qty);

  int get unreadNotificationsCount =>
      notifications.where((n) => !n.read).length;

  Brightness get brightness => isDarkTheme ? Brightness.dark : Brightness.light;

  List<Product?> get compareProducts =>
      compareProductIds.map(productById).toList(growable: false);

  Future<void> signIn({required String email, required String password}) async {
    final normalizedEmail = email.trim().isEmpty
        ? 'demo@nexus.local'
        : email.trim();
    final user = NexusUser(
      name: _nameFromEmail(normalizedEmail),
      email: normalizedEmail,
    );
    currentUser = user;
    await _persistSession(user);
    notifyListeners();
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final user = NexusUser(
      name: name.trim().isEmpty ? 'Nexus Insider' : name.trim(),
      email: email.trim().isEmpty ? 'member@nexus.local' : email.trim(),
    );
    currentUser = user;
    await _persistSession(user);
    notifyListeners();
  }

  Future<void> signOut() async {
    currentUser = null;
    await _prefs.remove(kSessionName);
    await _prefs.remove(kSessionEmail);
    navigate(ViewState.login);
  }

  void toggleTheme() {
    isDarkTheme = !isDarkTheme;
    notifyListeners();
  }

  void navigate(ViewState view, {Map<String, dynamic>? params}) {
    currentView = view;
    viewParams = params;
    notifyListeners();
  }

  void completeSplash() {
    navigate(ViewState.onboarding);
  }

  Future<void> finishOnboarding() async {
    await _prefs.setBool(kHasSeenOnboarding, true);
    navigate(ViewState.login);
  }

  Future<void> skipOnboarding() async {
    await _prefs.setBool(kHasSeenOnboarding, true);
    navigate(ViewState.login);
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

  Product? productById(String? id) {
    if (id == null || id.isEmpty) return null;
    for (final product in allCatalogProducts) {
      if (product.id == id) return product;
    }
    return null;
  }

  void setCompareProduct(int slot, String productId) {
    if (slot < 0 || slot >= compareProductIds.length) return;
    compareProductIds[slot] = productId;
    notifyListeners();
  }

  void removeCompareProduct(int slot) {
    if (slot < 0 || slot >= compareProductIds.length) return;
    compareProductIds[slot] = null;
    notifyListeners();
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

  void removeFavorite(String productId) {
    favorites.remove(productId);
    notifyListeners();
  }

  void saveBuild(BuilderState build) {
    savedBuilds.add(build.copy());
    notifyListeners();
  }

  void removeSavedBuildAt(int index) {
    if (index < 0 || index >= savedBuilds.length) return;
    savedBuilds.removeAt(index);
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

  Future<void> _persistSession(NexusUser user) async {
    await _prefs.setString(kSessionName, user.name);
    await _prefs.setString(kSessionEmail, user.email);
  }

  String _nameFromEmail(String email) {
    final local = email.split('@').first.trim();
    if (local.isEmpty) return 'Nexus Insider';
    return local
        .split(RegExp(r'[._-]+'))
        .where((part) => part.isNotEmpty)
        .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
        .join(' ');
  }
}

class NexusUser {
  const NexusUser({required this.name, required this.email});

  final String name;
  final String email;

  String get initials {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty) return 'NX';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }
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
