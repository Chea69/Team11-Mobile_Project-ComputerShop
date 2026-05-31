import 'package:flutter/material.dart';

import '../../models/product_model.dart';
import '../../state/app_controller.dart';
import '../../theme/app_colors.dart';

class ProductDetailScreen extends StatelessWidget {
  const ProductDetailScreen({required this.productId, super.key});

  final String productId;

  @override
  Widget build(BuildContext context) {
    final controller = AppControllerScope.of(context);
    final product = controller.productById(productId);

    if (product == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Product Detail')),
        body: const Center(child: Text('Product not found')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(product.brand)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _GalleryPlaceholder(product: product),
            const SizedBox(height: 18),
            AnimatedBuilder(
              animation: controller,
              builder: (context, _) {
                final isFavorite = controller.isFavorite(product.id);
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.name,
                            style: Theme.of(context).textTheme.displaySmall,
                          ),
                          const SizedBox(height: 8),
                          _RatingRow(product: product),
                        ],
                      ),
                    ),
                    IconButton.filledTonal(
                      tooltip: isFavorite ? 'Remove favorite' : 'Favorite',
                      onPressed: () => controller.toggleFavorite(product.id),
                      icon: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Text(
                  _formatPrice(product.price),
                  style: Theme.of(
                    context,
                  ).textTheme.displaySmall?.copyWith(color: AppColors.accent),
                ),
                const SizedBox(width: 10),
                if (product.oldPrice != null)
                  Text(
                    _formatPrice(product.oldPrice!),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            Text('Core Specs', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 10),
            _SpecsGrid(specs: product.specs),
            const SizedBox(height: 20),
            Text('Benchmarks', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 10),
            ...product.benchmarks.entries.map(
              (entry) => _BenchmarkBar(label: entry.key, value: entry.value),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.event_available),
              label: const Text('Buy / Reserve'),
            ),
          ],
        ),
      ),
    );
  }
}

class _GalleryPlaceholder extends StatelessWidget {
  const _GalleryPlaceholder({required this.product});

  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 250,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.35)),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.fromRGBO(14, 23, 42, 1),
            Color.fromRGBO(49, 20, 87, 1),
            Color.fromRGBO(7, 72, 82, 1),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Image Preview'),
          const Spacer(),
          Center(
            child: Icon(
              product.category.contains('Laptop')
                  ? Icons.laptop_mac
                  : Icons.desktop_windows_outlined,
              color: AppColors.primary,
              size: 92,
            ),
          ),
          const Spacer(),
          Row(
            children: List.generate(
              3,
              (index) => Container(
                width: 48,
                height: 36,
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: index == 0
                      ? AppColors.primary.withValues(alpha: 0.26)
                      : AppColors.darkSurface.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.darkSurfaceHigh),
                ),
                child: Icon(
                  Icons.image_outlined,
                  color: index == 0
                      ? AppColors.primary
                      : AppColors.darkMutedText,
                  size: 18,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RatingRow extends StatelessWidget {
  const _RatingRow({required this.product});

  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.star, color: AppColors.warning, size: 18),
        const SizedBox(width: 5),
        Text(
          '${product.rating} rating',
          style: Theme.of(context).textTheme.labelLarge,
        ),
        const SizedBox(width: 8),
        Text(
          '${product.reviewCount} mock ratings',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }
}

class _SpecsGrid extends StatelessWidget {
  const _SpecsGrid({required this.specs});

  final Map<String, String> specs;

  @override
  Widget build(BuildContext context) {
    return GridView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 1.5,
      ),
      children: [
        for (final entry in specs.entries)
          DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.darkSurface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.darkSurfaceHigh),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.key,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    entry.value,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _BenchmarkBar extends StatelessWidget {
  const _BenchmarkBar({required this.label, required this.value});

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(label, style: Theme.of(context).textTheme.labelLarge),
              const Spacer(),
              Text('$value%', style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
          const SizedBox(height: 7),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              minHeight: 9,
              value: value / 100,
              backgroundColor: AppColors.darkSurfaceHigh,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

String _formatPrice(double price) {
  return '\$${price.toStringAsFixed(0)}';
}
