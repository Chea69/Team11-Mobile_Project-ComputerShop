import 'package:flutter/widgets.dart';

import '../data/mock_products.dart';
import '../models/pc_part_model.dart';
import '../models/product_model.dart';

class AppController extends ChangeNotifier {
  final Set<String> _favoriteIds = <String>{};
  final Map<PcPartType, PcPartModel> _selectedParts = {};

  List<ProductModel> get products => mockProducts;

  Map<PcPartType, PcPartModel> get selectedParts =>
      Map.unmodifiable(_selectedParts);

  ProductModel? productById(String id) {
    for (final product in products) {
      if (product.id == id) {
        return product;
      }
    }
    return null;
  }

  bool isFavorite(String productId) => _favoriteIds.contains(productId);

  void toggleFavorite(String productId) {
    if (!_favoriteIds.add(productId)) {
      _favoriteIds.remove(productId);
    }
    notifyListeners();
  }

  void selectPart(PcPartModel part) {
    _selectedParts[part.type] = part;
    notifyListeners();
  }

  double get buildTotal {
    return _selectedParts.values.fold<double>(
      0,
      (total, part) => total + part.price,
    );
  }

  int get estimatedWattage {
    return _selectedParts.values.fold<int>(
      0,
      (total, part) => total + (part.tdp ?? 0),
    );
  }

  bool get isBuildComplete {
    return PcPartType.values.every(_selectedParts.containsKey);
  }

  bool get isBuildCompatible => compatibilityIssues.isEmpty;

  String get compatibilityMessage {
    if (compatibilityIssues.isEmpty) {
      return isBuildComplete
          ? 'All selected parts look compatible.'
          : 'No conflicts found yet. Select all parts to finish the build.';
    }
    return compatibilityIssues.first;
  }

  List<String> get compatibilityIssues {
    final issues = <String>[];
    final cpu = _selectedParts[PcPartType.cpu];
    final motherboard = _selectedParts[PcPartType.motherboard];
    final ram = _selectedParts[PcPartType.ram];
    final psu = _selectedParts[PcPartType.psu];

    if (cpu?.socket != null &&
        motherboard?.socket != null &&
        cpu!.socket != motherboard!.socket) {
      issues.add(
        'CPU socket ${cpu.socket} does not match motherboard '
        '${motherboard.socket}.',
      );
    }

    if (motherboard?.ramType != null &&
        ram?.ramType != null &&
        motherboard!.ramType != ram!.ramType) {
      issues.add(
        'RAM type ${ram.ramType} does not match motherboard '
        '${motherboard.ramType}.',
      );
    }

    if (psu?.wattage != null && estimatedWattage > 0) {
      final recommended = (estimatedWattage * 1.35).ceil();
      if (psu!.wattage! < recommended) {
        issues.add('PSU should be at least ${recommended}W for this CPU/GPU.');
      }
    }

    return issues;
  }
}

class AppControllerScope extends InheritedNotifier<AppController> {
  const AppControllerScope({
    required AppController controller,
    required super.child,
    super.key,
  }) : super(notifier: controller);

  static AppController of(BuildContext context) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<AppControllerScope>();
    assert(scope != null, 'AppControllerScope was not found in the tree.');
    return scope!.notifier!;
  }
}
