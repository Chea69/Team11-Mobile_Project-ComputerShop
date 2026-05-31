class ProductModel {
  const ProductModel({
    required this.id,
    required this.name,
    required this.brand,
    required this.category,
    required this.price,
    required this.rating,
    required this.reviewCount,
    required this.specs,
    required this.benchmarks,
    this.oldPrice,
    this.isDeal = false,
    this.isHot = false,
  });

  final String id;
  final String name;
  final String brand;
  final String category;
  final double price;
  final double? oldPrice;
  final double rating;
  final int reviewCount;
  final Map<String, String> specs;
  final Map<String, int> benchmarks;
  final bool isDeal;
  final bool isHot;
}
