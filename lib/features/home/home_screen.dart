import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../models/product_model.dart';
import '../../state/app_controller.dart';
import '../../theme/app_colors.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = AppControllerScope.of(context);
    final textTheme = Theme.of(context).textTheme;
    final products = controller.products;
    final hotDeals = products.where((product) => product.isDeal).toList();
    final categories = [
      _CategoryItem('Laptops', Icons.laptop_mac),
      _CategoryItem('Desktops', Icons.desktop_windows_outlined),
      _CategoryItem('GPUs', Icons.memory),
      _CategoryItem('Monitors', Icons.monitor),
    ];
    final brands = ['ASUS ROG', 'Lenovo', 'MSI', 'Gigabyte', 'Corsair'];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Computer Shop'),
        actions: [
          IconButton(
            tooltip: 'Favorites',
            onPressed: () => context.go('/favorites'),
            icon: const Icon(Icons.favorite_border),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _HeroBanner(onStartBuilder: () => context.go('/builder')),
            const SizedBox(height: 20),
            Text('Categories', style: textTheme.titleLarge),
            const SizedBox(height: 12),
            GridView.builder(
              itemCount: categories.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 2.8,
              ),
              itemBuilder: (context, index) {
                final category = categories[index];
                return _CategoryTile(category: category);
              },
            ),
            const SizedBox(height: 20),
            _BrandStrip(brands: brands),
            const SizedBox(height: 20),
            _SectionHeader(title: 'Hot Deals', actionLabel: 'Sprint 2 mock'),
            const SizedBox(height: 12),
            SizedBox(
              height: 164,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: hotDeals.length,
                separatorBuilder: (context, index) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final product = hotDeals[index];
                  return _DealCard(
                    product: product,
                    onTap: () => context.push('/detail/${product.id}'),
                  );
                },
              ),
            ),
            const SizedBox(height: 22),
            _SectionHeader(title: 'Featured Gear', actionLabel: 'Local data'),
            const SizedBox(height: 12),
            ...products.map(
              (product) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _ProductCard(
                  product: product,
                  onTap: () => context.push('/detail/${product.id}'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroBanner extends StatelessWidget {
  const _HeroBanner({required this.onStartBuilder});

  final VoidCallback onStartBuilder;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.35)),
        gradient: const LinearGradient(
          colors: [
            Color.fromRGBO(16, 24, 44, 1),
            Color.fromRGBO(40, 18, 74, 1),
            Color.fromRGBO(8, 58, 65, 1),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _RgbChip(label: 'WEEK 2 SPRINT'),
          const SizedBox(height: 14),
          Text(
            'Build Your Dream Rig',
            style: Theme.of(context).textTheme.displaySmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Browse gamer/pro gear, check core specs, and start a basic PC build with local mock data.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: onStartBuilder,
            icon: const Icon(Icons.memory),
            label: const Text('Start PC Builder'),
          ),
        ],
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({required this.category});

  final _CategoryItem category;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.darkSurfaceHigh),
      ),
      child: Row(
        children: [
          const SizedBox(width: 12),
          Icon(category.icon, color: AppColors.accent),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              category.label,
              style: Theme.of(context).textTheme.labelLarge,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _BrandStrip extends StatelessWidget {
  const _BrandStrip({required this.brands});

  final List<String> brands;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: brands.length,
        separatorBuilder: (context, index) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          return Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: AppColors.darkSurfaceHigh,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: index.isEven
                    ? AppColors.primary.withValues(alpha: 0.45)
                    : AppColors.secondary.withValues(alpha: 0.45),
              ),
            ),
            child: Text(
              brands[index],
              style: Theme.of(context).textTheme.labelLarge,
            ),
          );
        },
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.actionLabel});

  final String title;
  final String actionLabel;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(title, style: Theme.of(context).textTheme.titleLarge),
        ),
        Text(actionLabel, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }
}

class _DealCard extends StatelessWidget {
  const _DealCard({required this.product, required this.onTap});

  final ProductModel product;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 250,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Ink(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.darkSurface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: AppColors.warning.withValues(alpha: 0.35),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _ProductIcon(product: product),
                  const Spacer(),
                  const _RgbChip(label: 'DEAL'),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                product.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontSize: 16),
              ),
              const Spacer(),
              Row(
                children: [
                  Text(
                    _formatPrice(product.price),
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(width: 8),
                  if (product.oldPrice != null)
                    Text(
                      _formatPrice(product.oldPrice!),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({required this.product, required this.onTap});

  final ProductModel product;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Ink(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.darkSurface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.darkSurfaceHigh),
        ),
        child: Row(
          children: [
            _ProductIcon(product: product, size: 72),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.brand,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(
                      context,
                    ).textTheme.titleLarge?.copyWith(fontSize: 17),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.star,
                        color: AppColors.warning,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${product.rating} (${product.reviewCount})',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Text(
              _formatPrice(product.price),
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductIcon extends StatelessWidget {
  const _ProductIcon({required this.product, this.size = 54});

  final ProductModel product;
  final double size;

  @override
  Widget build(BuildContext context) {
    final isLaptop = product.category.contains('Laptop');
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withValues(alpha: 0.28),
            AppColors.secondary.withValues(alpha: 0.34),
            AppColors.accent.withValues(alpha: 0.18),
          ],
        ),
      ),
      child: Icon(
        isLaptop ? Icons.laptop_mac : Icons.desktop_windows_outlined,
        color: AppColors.primary,
        size: size * 0.45,
      ),
    );
  }
}

class _RgbChip extends StatelessWidget {
  const _RgbChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.accent.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: AppColors.accent,
            fontSize: 11,
          ),
        ),
      ),
    );
  }
}

class _CategoryItem {
  const _CategoryItem(this.label, this.icon);

  final String label;
  final IconData icon;
}

String _formatPrice(double price) {
  return '\$${price.toStringAsFixed(0)}';
}
