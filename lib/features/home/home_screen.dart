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
    final products = controller.products;
    final brands = [
      'Razer',
      'Corsair',
      'MSI',
      'Alienware',
      'ASUS ROG',
      'AORUS',
    ];
    final categories = [
      _CategoryItem('Laptops', Icons.laptop_mac),
      _CategoryItem('Desktops', Icons.desktop_windows_outlined),
      _CategoryItem('Components', Icons.memory),
      _CategoryItem('Peripherals', Icons.keyboard_alt_outlined),
      _CategoryItem('Monitors', Icons.monitor),
      _CategoryItem('Networking', Icons.router_outlined),
    ];

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
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
            children: [
              const _TopNavigation(),
              const SizedBox(height: 18),
              _HeroSection(onExplore: () => context.go('/builder')),
              const SizedBox(height: 20),
              _BrandStrip(brands: brands),
              const SizedBox(height: 24),
              _Reveal(
                delay: const Duration(milliseconds: 60),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _SectionHeader(title: 'Categories'),
                    const SizedBox(height: 12),
                    _CategoryGrid(categories: categories),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _Reveal(
                delay: const Duration(milliseconds: 140),
                child: _BuildOfMonth(onViewSpecs: () => context.go('/builder')),
              ),
              const SizedBox(height: 24),
              const _SectionHeader(title: 'Featured Deals'),
              const SizedBox(height: 12),
              SizedBox(
                height: 292,
                child: ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  scrollDirection: Axis.horizontal,
                  itemCount: products.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(width: 14),
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return _Reveal(
                      delay: Duration(milliseconds: 120 + (index * 70)),
                      child: _FeaturedDealCard(
                        product: product,
                        onTap: () => context.push('/detail/${product.id}'),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopNavigation extends StatelessWidget {
  const _TopNavigation();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [AppColors.cyan, AppColors.magenta, AppColors.violet],
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.cyan.withValues(alpha: 0.24),
                blurRadius: 16,
              ),
            ],
          ),
          child: const Icon(Icons.person, color: Colors.black, size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Row(
            children: [
              const Icon(Icons.bolt, color: AppColors.primary, size: 22),
              const SizedBox(width: 6),
              Text(
                'NEXUS',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: AppColors.darkText,
                  letterSpacing: 0,
                ),
              ),
            ],
          ),
        ),
        _TopIconButton(icon: Icons.search, onTap: () {}),
        const SizedBox(width: 8),
        _TopIconButton(icon: Icons.notifications_none, onTap: () {}),
        const SizedBox(width: 8),
        _TopIconButton(icon: Icons.shopping_bag_outlined, onTap: () {}),
      ],
    );
  }
}

class _TopIconButton extends StatelessWidget {
  const _TopIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Ink(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.darkSurfaceHigh.withValues(alpha: 0.72),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.cyan.withValues(alpha: 0.18)),
        ),
        child: Icon(icon, color: AppColors.darkText, size: 20),
      ),
    );
  }
}

class _HeroSection extends StatelessWidget {
  const _HeroSection({required this.onExplore});

  final VoidCallback onExplore;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 324,
      padding: const EdgeInsets.all(1.2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        gradient: AppColors.rgbBorderGradient,
        boxShadow: [
          BoxShadow(
            color: AppColors.magenta.withValues(alpha: 0.16),
            blurRadius: 32,
            offset: const Offset(0, 14),
          ),
          BoxShadow(
            color: AppColors.cyan.withValues(alpha: 0.12),
            blurRadius: 26,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(7),
        child: Stack(
          children: [
            const Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(color: AppColors.bgSurface),
              ),
            ),
            Positioned.fill(
              child: Image.asset(
                'assets/images/rtx_4090.png',
                fit: BoxFit.cover,
                alignment: Alignment.centerRight,
                filterQuality: FilterQuality.high,
                errorBuilder: (context, error, stackTrace) {
                  return const Center(
                    child: Icon(
                      Icons.memory,
                      color: AppColors.primary,
                      size: 96,
                    ),
                  );
                },
              ),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      AppColors.bgBase.withValues(alpha: 0.95),
                      AppColors.bgSurface.withValues(alpha: 0.62),
                      AppColors.bgBase.withValues(alpha: 0.16),
                    ],
                    stops: const [0, 0.48, 1],
                  ),
                ),
              ),
            ),
            const Positioned.fill(child: _ScanlineOverlay()),
            Positioned(
              right: 18,
              top: 24,
              child: Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withValues(alpha: 0.06),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.24),
                      blurRadius: 44,
                      spreadRadius: 8,
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _NeonLabel(
                    label: 'BEYOND FAST',
                    color: AppColors.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'RTX 4090\nBATTLESTATION',
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      fontSize: 34,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      height: 1.02,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: 168,
                    child: Text(
                      'Extreme frame rates, creator power, and RGB-ready builds.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.darkMutedText,
                        height: 1.35,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      _GradientActionButton(
                        onPressed: onExplore,
                        icon: const Icon(Icons.arrow_forward),
                        label: 'Explore',
                      ),
                      const Spacer(),
                      const _CarouselDots(),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GradientActionButton extends StatelessWidget {
  const _GradientActionButton({
    required this.onPressed,
    required this.icon,
    required this.label,
  });

  final VoidCallback onPressed;
  final Widget icon;
  final String label;

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
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconTheme(
                  data: const IconThemeData(color: Colors.black, size: 18),
                  child: icon,
                ),
                const SizedBox(width: 8),
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
      ..color = Colors.white.withValues(alpha: 0.045)
      ..strokeWidth = 1;
    for (double y = 0; y < size.height; y += 5) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
    }

    final glowPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          AppColors.cyan.withValues(alpha: 0.05),
          Colors.transparent,
          AppColors.magenta.withValues(alpha: 0.05),
        ],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, glowPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _CarouselDots extends StatelessWidget {
  const _CarouselDots();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(3, (index) {
        final isActive = index == 0;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 260),
          width: isActive ? 18 : 7,
          height: 7,
          margin: const EdgeInsets.only(left: 6),
          decoration: BoxDecoration(
            color: isActive
                ? AppColors.cyan
                : AppColors.darkMutedText.withValues(alpha: 0.35),
            borderRadius: BorderRadius.circular(99),
          ),
        );
      }),
    );
  }
}

class _BrandStrip extends StatelessWidget {
  const _BrandStrip({required this.brands});

  final List<String> brands;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView.separated(
        physics: const BouncingScrollPhysics(),
        scrollDirection: Axis.horizontal,
        itemCount: brands.length,
        separatorBuilder: (context, index) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          return Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 18),
            decoration: BoxDecoration(
              color: AppColors.bgSurfaceLight.withValues(alpha: 0.84),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: (index.isEven ? AppColors.cyan : AppColors.magenta)
                    .withValues(alpha: 0.22),
              ),
            ),
            child: Text(
              brands[index],
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: AppColors.darkText,
                fontSize: 14,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _CategoryGrid extends StatelessWidget {
  const _CategoryGrid({required this.categories});

  final List<_CategoryItem> categories;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      itemCount: categories.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 0.98,
      ),
      itemBuilder: (context, index) {
        return _CategoryCard(category: categories[index], index: index);
      },
    );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({required this.category, required this.index});

  final _CategoryItem category;
  final int index;

  @override
  Widget build(BuildContext context) {
    final accent = index.isEven ? AppColors.primary : AppColors.secondary;
    return _GradientBorder(
      borderRadius: 8,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.bgSurfaceLight.withValues(alpha: 0.84),
          borderRadius: BorderRadius.circular(7),
          boxShadow: [
            BoxShadow(
              color: accent.withValues(alpha: 0.07),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(category.icon, color: accent, size: 23),
            ),
            const SizedBox(height: 10),
            Text(
              category.label.toUpperCase(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: AppColors.darkText,
                fontSize: 11,
                letterSpacing: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BuildOfMonth extends StatelessWidget {
  const _BuildOfMonth({required this.onViewSpecs});

  final VoidCallback onViewSpecs;

  @override
  Widget build(BuildContext context) {
    return _GradientBorder(
      borderRadius: 8,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.darkSurface,
          borderRadius: BorderRadius.circular(7),
          boxShadow: [
            BoxShadow(
              color: AppColors.secondary.withValues(alpha: 0.12),
              blurRadius: 28,
              offset: const Offset(0, 14),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _NeonLabel(
                    label: 'BUILD OF THE MONTH',
                    color: AppColors.accent,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'NEON PHANTOM',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Ryzen 7 7800X3D, RTX 4070 Ti Super, 32GB DDR5, 2TB Gen4 SSD.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.darkMutedText,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _GradientActionButton(
                    onPressed: onViewSpecs,
                    icon: const Icon(Icons.tune),
                    label: 'View Specs',
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: 112,
                height: 142,
                child: Image.asset(
                  'assets/images/neon_phantom.png',
                  fit: BoxFit.cover,
                  alignment: Alignment.center,
                  filterQuality: FilterQuality.high,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeaturedDealCard extends StatelessWidget {
  const _FeaturedDealCard({required this.product, required this.onTap});

  final ProductModel product;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final label = product.isDeal ? 'DEAL' : 'NEW';
    final labelColor = product.isDeal ? AppColors.secondary : AppColors.accent;

    return SizedBox(
      width: 212,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: _GradientBorder(
          borderRadius: 8,
          child: Ink(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.darkSurface,
              borderRadius: BorderRadius.circular(7),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    _ProductVisual(product: product),
                    Positioned(
                      top: 9,
                      left: 9,
                      child: _NeonLabel(label: label, color: labelColor),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: AppColors.darkBackground.withValues(
                            alpha: 0.72,
                          ),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.08),
                          ),
                        ),
                        child: const Icon(
                          Icons.favorite_border,
                          color: AppColors.darkText,
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  product.category,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.primary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  product.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
                const Spacer(),
                Row(
                  children: [
                    Text(
                      _formatPrice(product.price),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.accent,
                        fontSize: 19,
                      ),
                    ),
                    const Spacer(),
                    const Icon(
                      Icons.arrow_forward,
                      color: AppColors.primary,
                      size: 18,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProductVisual extends StatelessWidget {
  const _ProductVisual({required this.product});

  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Container(
        height: 142,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF12182B), Color(0xFF1C1238), Color(0xFF062A35)],
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.10),
              blurRadius: 22,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Image.asset(
          product.imageAsset,
          width: double.infinity,
          height: double.infinity,
          fit: BoxFit.cover,
          alignment: Alignment.center,
          filterQuality: FilterQuality.high,
          errorBuilder: (context, error, stackTrace) {
            return const Icon(Icons.image_outlined, color: AppColors.primary);
          },
        ),
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
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(99),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.65),
                blurRadius: 10,
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title.toUpperCase(),
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.7,
          ),
        ),
      ],
    );
  }
}

class _NeonLabel extends StatelessWidget {
  const _NeonLabel({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.42)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: color,
            fontSize: 10,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class _Reveal extends StatefulWidget {
  const _Reveal({required this.child, this.delay = Duration.zero});

  final Widget child;
  final Duration delay;

  @override
  State<_Reveal> createState() => _RevealState();
}

class _RevealState extends State<_Reveal> {
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    Future<void>.delayed(widget.delay, () {
      if (mounted) {
        setState(() => _visible = true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSlide(
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOutCubic,
      offset: _visible ? Offset.zero : const Offset(0, 0.08),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 420),
        curve: Curves.easeOutCubic,
        opacity: _visible ? 1 : 0,
        child: widget.child,
      ),
    );
  }
}

class _GradientBorder extends StatelessWidget {
  const _GradientBorder({required this.child, required this.borderRadius});

  final Widget child;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(1.2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.62),
            AppColors.secondary.withValues(alpha: 0.42),
            AppColors.purple.withValues(alpha: 0.45),
          ],
        ),
      ),
      child: child,
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
