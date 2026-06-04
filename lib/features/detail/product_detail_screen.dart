import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
        body: SafeArea(
          child: Center(
            child: Text(
              'PRODUCT NOT FOUND',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [AppColors.bgBase, AppColors.bgSurface, AppColors.bgBase],
            ),
          ),
          child: ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            children: [
              _DetailTopBar(product: product, controller: controller),
              const SizedBox(height: 16),
              _ProductHero(product: product),
              const SizedBox(height: 18),
              _ProductHeader(product: product),
              const SizedBox(height: 18),
              _PurchasePanel(product: product),
              const SizedBox(height: 24),
              const _SectionHeader(title: 'Core Specs'),
              const SizedBox(height: 12),
              _SpecsGrid(specs: product.specs),
              const SizedBox(height: 24),
              const _SectionHeader(title: 'Benchmarks'),
              const SizedBox(height: 12),
              _BenchmarkPanel(product: product),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailTopBar extends StatelessWidget {
  const _DetailTopBar({required this.product, required this.controller});

  final ProductModel product;
  final AppController controller;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _CyberIconButton(icon: Icons.arrow_back, onTap: () => context.pop()),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                product.brand.toUpperCase(),
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: AppColors.cyan,
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                product.category.toUpperCase(),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textMuted,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        AnimatedBuilder(
          animation: controller,
          builder: (context, _) {
            final isFavorite = controller.isFavorite(product.id);
            return _CyberIconButton(
              icon: isFavorite ? Icons.favorite : Icons.favorite_border,
              color: isFavorite ? AppColors.magenta : AppColors.textMain,
              onTap: () => controller.toggleFavorite(product.id),
            );
          },
        ),
      ],
    );
  }
}

class _ProductHero extends StatelessWidget {
  const _ProductHero({required this.product});

  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    return _GradientBorder(
      borderRadius: 8,
      child: SizedBox(
        height: 312,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(7),
          child: Stack(
            children: [
              Positioned.fill(
                child: Hero(
                  tag: 'product-${product.id}',
                  child: Image.asset(
                    product.imageAsset,
                    fit: BoxFit.cover,
                    alignment: Alignment.center,
                    filterQuality: FilterQuality.high,
                    errorBuilder: (context, error, stackTrace) {
                      return const Center(
                        child: Icon(
                          Icons.image_outlined,
                          color: AppColors.cyan,
                          size: 92,
                        ),
                      );
                    },
                  ),
                ),
              ),
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        AppColors.bgBase.withValues(alpha: 0.08),
                        AppColors.bgBase.withValues(alpha: 0.22),
                        AppColors.bgBase.withValues(alpha: 0.84),
                      ],
                    ),
                  ),
                ),
              ),
              const Positioned.fill(child: _ScanlineOverlay()),
              Positioned(
                left: 14,
                top: 14,
                child: _NeonLabel(
                  label: product.isDeal ? 'RGB DEAL' : 'NEW DROP',
                  color: product.isDeal ? AppColors.magenta : AppColors.cyan,
                ),
              ),
              Positioned(
                left: 14,
                right: 14,
                bottom: 14,
                child: Row(
                  children: List.generate(
                    3,
                    (index) => Container(
                      width: index == 0 ? 60 : 44,
                      height: 42,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: AppColors.bgSurface.withValues(alpha: 0.76),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color:
                              (index == 0 ? AppColors.cyan : AppColors.violet)
                                  .withValues(alpha: index == 0 ? 0.54 : 0.2),
                        ),
                        image: index == 0
                            ? DecorationImage(
                                image: AssetImage(product.imageAsset),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: index == 0
                          ? null
                          : Icon(
                              Icons.grid_view,
                              color: AppColors.textMuted.withValues(alpha: 0.8),
                              size: 17,
                            ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProductHeader extends StatelessWidget {
  const _ProductHeader({required this.product});

  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          product.name.toUpperCase(),
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
            color: AppColors.textMain,
            fontSize: 30,
            fontWeight: FontWeight.w900,
            height: 1.08,
          ),
        ),
        const SizedBox(height: 12),
        _RatingRow(product: product),
      ],
    );
  }
}

class _PurchasePanel extends StatelessWidget {
  const _PurchasePanel({required this.product});

  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    return _GradientBorder(
      borderRadius: 8,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.bgSurface,
          borderRadius: BorderRadius.circular(7),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'LIVE PRICE',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: AppColors.textMuted,
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text(
                        _formatPrice(product.price),
                        style: Theme.of(context).textTheme.displaySmall
                            ?.copyWith(
                              color: AppColors.cyan,
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                            ),
                      ),
                      if (product.oldPrice != null) ...[
                        const SizedBox(width: 10),
                        Text(
                          _formatPrice(product.oldPrice!),
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: AppColors.textMuted,
                                decoration: TextDecoration.lineThrough,
                                decorationColor: AppColors.magenta,
                              ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            _GradientActionButton(
              label: 'Reserve',
              icon: Icons.event_available,
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}

class _RatingRow extends StatelessWidget {
  const _RatingRow({required this.product});

  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        _NeonLabel(
          label: '${product.rating} STAR',
          color: AppColors.warning,
          icon: Icons.star,
        ),
        _NeonLabel(
          label: '${product.reviewCount} MOCK RATINGS',
          color: AppColors.violet,
          icon: Icons.forum_outlined,
        ),
        if (product.isHot)
          const _NeonLabel(
            label: 'HOT DROP',
            color: AppColors.magenta,
            icon: Icons.local_fire_department,
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
    return GridView.builder(
      itemCount: specs.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 1.36,
      ),
      itemBuilder: (context, index) {
        final entry = specs.entries.elementAt(index);
        final color = index.isEven ? AppColors.cyan : AppColors.magenta;
        return _GradientBorder(
          borderRadius: 8,
          colors: [
            color.withValues(alpha: 0.72),
            AppColors.violet.withValues(alpha: 0.32),
          ],
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.bgSurfaceLight,
              borderRadius: BorderRadius.circular(7),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(_iconForSpec(entry.key), color: color, size: 22),
                const Spacer(),
                Text(
                  entry.key.toUpperCase(),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textMuted,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  entry.value,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: AppColors.textMain,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _BenchmarkPanel extends StatelessWidget {
  const _BenchmarkPanel({required this.product});

  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    return _GradientBorder(
      borderRadius: 8,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.bgSurface,
          borderRadius: BorderRadius.circular(7),
        ),
        child: Column(
          children: [
            for (final entry in product.benchmarks.entries)
              _BenchmarkBar(label: entry.key, value: entry.value),
          ],
        ),
      ),
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
              Text(
                label.toUpperCase(),
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: AppColors.textMain,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const Spacer(),
              Text(
                '$value%',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: AppColors.cyan),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Stack(
              children: [
                Container(height: 10, color: AppColors.bgSurfaceLight),
                FractionallySizedBox(
                  widthFactor: value / 100,
                  child: Container(
                    height: 10,
                    decoration: BoxDecoration(
                      gradient: AppColors.rgbGradient,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.cyan.withValues(alpha: 0.5),
                          blurRadius: 14,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            gradient: AppColors.rgbGradient,
            borderRadius: BorderRadius.circular(99),
            boxShadow: [
              BoxShadow(
                color: AppColors.cyan.withValues(alpha: 0.55),
                blurRadius: 10,
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title.toUpperCase(),
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: AppColors.textMain,
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

class _CyberIconButton extends StatelessWidget {
  const _CyberIconButton({
    required this.icon,
    required this.onTap,
    this.color = AppColors.textMain,
  });

  final IconData icon;
  final VoidCallback onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return _GradientBorder(
      borderRadius: 8,
      colors: [
        color.withValues(alpha: 0.64),
        AppColors.violet.withValues(alpha: 0.32),
      ],
      child: Material(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(7),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(7),
          child: SizedBox(
            width: 42,
            height: 42,
            child: Icon(icon, color: color, size: 21),
          ),
        ),
      ),
    );
  }
}

class _GradientActionButton extends StatelessWidget {
  const _GradientActionButton({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: AppColors.rgbGradient,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: AppColors.magenta.withValues(alpha: 0.22),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: Colors.black, size: 18),
                const SizedBox(width: 7),
                Text(
                  label.toUpperCase(),
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Colors.black,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NeonLabel extends StatelessWidget {
  const _NeonLabel({required this.label, required this.color, this.icon});

  final String label;
  final Color color;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.46)),
        boxShadow: [
          BoxShadow(color: color.withValues(alpha: 0.16), blurRadius: 14),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 13, color: color),
              const SizedBox(width: 5),
            ],
            Text(
              label.toUpperCase(),
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: color,
                fontSize: 10,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GradientBorder extends StatelessWidget {
  const _GradientBorder({
    required this.child,
    required this.borderRadius,
    this.colors,
  });

  final Widget child;
  final double borderRadius;
  final List<Color>? colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(1.2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        gradient: LinearGradient(
          colors: colors ?? AppColors.rgbBorderGradient.colors,
        ),
      ),
      child: child,
    );
  }
}

class _ScanlineOverlay extends StatelessWidget {
  const _ScanlineOverlay();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _ScanlinePainter());
  }
}

class _ScanlinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.042)
      ..strokeWidth = 1;
    for (double y = 0; y < size.height; y += 5) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

IconData _iconForSpec(String key) {
  switch (key.toLowerCase()) {
    case 'cpu':
      return Icons.developer_board;
    case 'gpu':
      return Icons.memory;
    case 'ram':
      return Icons.view_module;
    case 'storage':
      return Icons.storage;
    case 'display':
      return Icons.monitor;
    default:
      return Icons.tune;
  }
}

String _formatPrice(double price) {
  return '\$${price.toStringAsFixed(0)}';
}
