import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/mock_data.dart';
import '../models/models.dart';
import '../models/view_state.dart';
import '../state/nexus_controller.dart';
import '../theme/nexus_fonts.dart';
import '../theme/nexus_palette.dart';
import '../widgets/network_image.dart';
import '../widgets/ui_kit.dart';

class ExploreMoreScreen extends StatelessWidget {
  const ExploreMoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.read<NexusController>();
    final muted = mutedOf(context);
    final items = <_MoreTile>[
      _MoreTile(
        ViewState.map,
        'BRANCH MAP',
        NexusPalette.cyan,
        Icons.place_rounded,
      ),
      _MoreTile(
        ViewState.nearby,
        'NEARBY STOCK',
        Colors.lightBlueAccent,
        Icons.navigation_rounded,
      ),
      _MoreTile(
        ViewState.promotions,
        'PROMOTIONS',
        NexusPalette.magenta,
        Icons.sell_rounded,
      ),
      _MoreTile(
        ViewState.booking,
        'BOOK REPAIR',
        Colors.purpleAccent,
        Icons.calendar_month_rounded,
      ),
      _MoreTile(
        ViewState.repairTracker,
        'REPAIR TRACKER',
        Colors.deepOrangeAccent,
        Icons.hardware_rounded,
      ),
      _MoreTile(
        ViewState.chat,
        'TECH SUPPORT',
        Colors.lightGreenAccent,
        Icons.chat_rounded,
      ),
      _MoreTile(
        ViewState.reviews,
        'REVIEWS',
        Colors.amberAccent,
        Icons.star_rounded,
      ),
      _MoreTile(
        ViewState.media,
        'SHOWCASES',
        Colors.pinkAccent,
        Icons.play_circle_outline,
      ),
    ];

    return ListView(
      physics: const ClampingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.fromLTRB(24, 36, 24, 112),
      children: [
        Text(
          'EXPLORE',
          style: GoogleFonts.jetBrainsMono(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'SERVICES • STORE TOOLS • COMMUNITY',
          style: GoogleFonts.jetBrainsMono(
            fontSize: 10,
            letterSpacing: 1.8,
            color: muted.withValues(alpha: .95),
          ),
        ),
        const SizedBox(height: 22),
        ...items.map(
          (tile) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => store.navigate(tile.target),
                child: BorderGradientPanel(
                  radius: 16,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 18,
                    ),
                    child: Row(
                      children: [
                        DecoratedBox(
                          decoration: BoxDecoration(
                            color: muted.withValues(alpha: .25),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Icon(tile.icon, color: tile.tint),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            tile.label,
                            style: GoogleFonts.jetBrainsMono(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        Icon(Icons.chevron_right, color: muted),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Color mutedOf(BuildContext context) =>
      Theme.of(context).dividerColor.withValues(alpha: .65);
}

class _MoreTile {
  _MoreTile(this.target, this.label, this.tint, this.icon);

  final ViewState target;
  final String label;
  final Color tint;
  final IconData icon;
}

class SavedHubScreen extends StatefulWidget {
  const SavedHubScreen({super.key});

  @override
  State<SavedHubScreen> createState() => _SavedHubScreenState();
}

class _SavedHubScreenState extends State<SavedHubScreen> {
  bool productsTab = true;

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<NexusController>();
    final muted = Theme.of(context).dividerColor.withValues(alpha: .6);
    final border = Theme.of(context).dividerColor.withValues(alpha: .55);

    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.9),
            border: Border(bottom: BorderSide(color: border)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'SAVED',
                style: GoogleFonts.jetBrainsMono(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: muted.withValues(alpha: .3),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _TinyTab(
                        text: 'PRODUCTS (${controller.favorites.length})',
                        active: productsTab,
                        onTap: () => setState(() => productsTab = true),
                      ),
                    ),
                    Expanded(
                      child: _TinyTab(
                        text: 'CUSTOM (${controller.savedBuilds.length})',
                        active: !productsTab,
                        onTap: () => setState(() => productsTab = false),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: productsTab
              ? ProductFavorites(controller: controller)
              : BuildFavorites(controller: controller),
        ),
      ],
    );
  }
}

class ProductFavorites extends StatelessWidget {
  const ProductFavorites({super.key, required this.controller});

  final NexusController controller;

  @override
  Widget build(BuildContext context) {
    final muted = Theme.of(context).dividerColor.withValues(alpha: .6);
    final list = allCatalogProducts
        .where((p) => controller.favorites.contains(p.id))
        .toList(growable: false);

    if (list.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(26),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.favorite_outline, size: 44, color: muted),
              const SizedBox(height: 16),
              Text(
                'NO SAVED PRODUCTS',
                style: GoogleFonts.jetBrainsMono(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Text(
                'Tap the heart icon while browsing.',
                style: Theme.of(context).textTheme.bodySmall!.copyWith(
                  color: muted.withValues(alpha: .9),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return GridView.count(
      primary: false,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(20),
      crossAxisCount: 2,
      childAspectRatio: .68,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      children: [
        ...list.map(
          (product) => Dismissible(
            key: ValueKey('favorite-${product.id}'),
            direction: DismissDirection.horizontal,
            background: const _SwipeRemoveBackground(
              alignment: Alignment.centerLeft,
            ),
            secondaryBackground: const _SwipeRemoveBackground(
              alignment: Alignment.centerRight,
            ),
            onDismissed: (_) {
              controller.removeFavorite(product.id);
              showNexusToast(context, 'REMOVED FROM SAVED');
            },
            child: ProductCardMini(
              product,
              fav: controller.favorites.contains(product.id),
              onTap: () => controller.navigate(
                ViewState.product,
                params: {'id': product.id},
              ),
              toggleFavorite: () => controller.toggleFavorite(product.id),
            ),
          ),
        ),
      ],
    );
  }
}

class BuildFavorites extends StatelessWidget {
  const BuildFavorites({super.key, required this.controller});

  final NexusController controller;

  double total(List<double> parts) => parts.fold(0.0, (a, x) => a + x);

  @override
  Widget build(BuildContext context) {
    final muted = Theme.of(context).dividerColor.withValues(alpha: .6);
    if (controller.savedBuilds.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(26),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'NO CUSTOM BUILDS YET',
                style: GoogleFonts.jetBrainsMono(fontWeight: FontWeight.bold),
              ),
              Text(
                'Finish the wizard to stash setups here.',
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall!.copyWith(color: muted),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () => controller.navigate(ViewState.builder),
                child: Text('OPEN BUILDER', style: GoogleFonts.jetBrainsMono()),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      physics: const ClampingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      padding: const EdgeInsets.all(22),
      itemCount: controller.savedBuilds.length,
      separatorBuilder: (_, _) => const SizedBox(height: 14),
      itemBuilder: (context, i) {
        final build = controller.savedBuilds[i];
        final dollars = total([
          build.cpu?.price ?? 0,
          build.motherboard?.price ?? 0,
          build.ram?.price ?? 0,
          build.gpu?.price ?? 0,
          build.storage?.price ?? 0,
          build.psu?.price ?? 0,
          build.casePart?.price ?? 0,
        ]);

        line(String tag, String? value) {
          if (value == null) return const SizedBox.shrink();
          return Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              children: [
                Text(
                  tag,
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 9,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    value,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall!.copyWith(color: muted),
                  ),
                ),
              ],
            ),
          );
        }

        return Dismissible(
          key: ValueKey('saved-build-$i-${build.cpu?.id}-${build.gpu?.id}'),
          direction: DismissDirection.horizontal,
          background: const _SwipeRemoveBackground(
            alignment: Alignment.centerLeft,
          ),
          secondaryBackground: const _SwipeRemoveBackground(
            alignment: Alignment.centerRight,
          ),
          onDismissed: (_) {
            controller.removeSavedBuildAt(i);
            showNexusToast(context, 'BUILD REMOVED');
          },
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: muted.withValues(alpha: .5)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Custom Rig #${i + 1}',
                      style: Theme.of(context).textTheme.titleSmall!.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '\$ ${dollars.toStringAsFixed(2)}',
                      style: GoogleFonts.jetBrainsMono(
                        fontWeight: FontWeight.bold,
                        color: NexusPalette.cyan,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                line('CPU', build.cpu?.name),
                line('GPU', build.gpu?.name),
                Align(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: OutlinedButton(
                      onPressed: () => controller.navigate(ViewState.builder),
                      child: Text(
                        'LOAD IN BUILDER',
                        style: GoogleFonts.jetBrainsMono(fontSize: 10),
                      ),
                    ),
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

class _SwipeRemoveBackground extends StatelessWidget {
  const _SwipeRemoveBackground({required this.alignment});

  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.redAccent.withValues(alpha: .22),
        border: Border.all(color: Colors.redAccent.withValues(alpha: .45)),
      ),
      child: const Icon(Icons.delete_rounded, color: Colors.redAccent),
    );
  }
}

class CompareScreen extends StatelessWidget {
  const CompareScreen({super.key});

  static const _specs = [
    _CompareSpec(
      label: 'PRICE',
      key: 'price',
      isNumber: true,
      lowerIsBetter: true,
    ),
    _CompareSpec(label: 'CPU', key: 'cpu'),
    _CompareSpec(label: 'GPU', key: 'gpu'),
    _CompareSpec(label: 'RAM', key: 'ram'),
    _CompareSpec(label: 'STORAGE', key: 'storage'),
    _CompareSpec(label: 'GAMING FPS', key: 'gaming', isNumber: true),
    _CompareSpec(label: 'PROD SCORE', key: 'productivity', isNumber: true),
  ];

  static dynamic _value(Product? product, String key) {
    if (product == null) return null;
    switch (key) {
      case 'price':
        return product.price;
      case 'gaming':
      case 'productivity':
        return product.benchmarks != null
            ? (key == 'gaming'
                  ? product.benchmarks!.gaming
                  : product.benchmarks!.productivity)
            : null;
      default:
        return switch (key) {
          'cpu' => product.specs.cpu,
          'gpu' => product.specs.gpu,
          'ram' => product.specs.ram,
          'storage' => product.specs.storage,
          _ => null,
        };
    }
  }

  static String _displayValue(dynamic value, String key) {
    if (value == null) return '-';
    if (key == 'price' && value is num) {
      return '\$${value.toStringAsFixed(0)}';
    }
    return '$value';
  }

  static int _winner(dynamic v1, dynamic v2, {required bool lowerIsBetter}) {
    if (v1 is! num || v2 is! num) return 0;
    if (v1 == v2) return 0;
    if (lowerIsBetter) return v1 < v2 ? 1 : 2;
    return v1 > v2 ? 1 : 2;
  }

  Widget _compareProductCard(
    BuildContext context,
    NexusController controller, {
    required int slot,
    required Product? product,
  }) {
    final muted = NexusPalette.textMuted(context);
    final left = slot == 0;

    return Expanded(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context).dividerColor.withValues(alpha: .55),
              ),
              color: Theme.of(context).colorScheme.surface,
            ),
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _CompareProductSelector(
                  value: product?.id,
                  onChanged: (id) => controller.setCompareProduct(slot, id),
                ),
                const SizedBox(height: 10),
                if (product == null) ...[
                  AspectRatio(
                    aspectRatio: 1,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: .28),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Theme.of(
                            context,
                          ).dividerColor.withValues(alpha: .45),
                        ),
                      ),
                      child: Icon(
                        Icons.add_rounded,
                        color: muted.withValues(alpha: .8),
                        size: 34,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 70,
                    child: Center(
                      child: Text(
                        'SELECT PRODUCT',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 11,
                          color: muted,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ] else ...[
                  AspectRatio(
                    aspectRatio: 1,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: .5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: NexusNetworkImage(
                          imageUrl: product.image,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    product.category.toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 10,
                      color: muted,
                    ),
                  ),
                  const SizedBox(height: 4),
                  SizedBox(
                    height: 32,
                    child: Text(
                      product.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '\$${product.price.toStringAsFixed(2)}',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: NexusPalette.cyan,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (product != null)
            Positioned(
              top: 0,
              left: left ? -8 : null,
              right: left ? null : -8,
              child: Material(
                color: Theme.of(context).colorScheme.secondary,
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () {
                    controller.removeCompareProduct(slot);
                    showNexusToast(context, 'ITEM REMOVED FROM COMPARISON');
                  },
                  child: Container(
                    width: 24,
                    height: 24,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Theme.of(
                          context,
                        ).dividerColor.withValues(alpha: .55),
                      ),
                    ),
                    child: Icon(Icons.close, size: 14, color: muted),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _specRow(
    BuildContext context,
    _CompareSpec spec,
    Product? p1,
    Product? p2, {
    required bool isLast,
  }) {
    final muted = NexusPalette.textMuted(context);
    final v1 = _value(p1, spec.key);
    final v2 = _value(p2, spec.key);
    final different = v1 != null && v2 != null && '$v1' != '$v2';
    final winner = spec.isNumber && p1 != null && p2 != null
        ? _winner(v1, v2, lowerIsBetter: spec.lowerIsBetter)
        : 0;

    Widget valueCell(dynamic value, int side) {
      final isWinner = winner == side;
      final isDiff = different && !spec.isNumber;
      final tone = side == 1 ? NexusPalette.cyan : NexusPalette.magenta;
      final text = _displayValue(value, spec.key);

      return Expanded(
        child: Container(
          padding: EdgeInsets.only(bottom: isWinner || isDiff ? 4 : 0),
          decoration: isWinner || isDiff
              ? BoxDecoration(
                  border: Border(bottom: BorderSide(color: tone, width: 1)),
                )
              : null,
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: GoogleFonts.jetBrainsMono(
              fontSize: 12,
              fontWeight: isWinner || isDiff
                  ? FontWeight.bold
                  : FontWeight.normal,
              color: isWinner || isDiff
                  ? tone
                  : Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(
                bottom: BorderSide(
                  color: Theme.of(context).dividerColor.withValues(alpha: .35),
                ),
              ),
      ),
      child: Column(
        children: [
          Text(
            spec.label,
            style: GoogleFonts.jetBrainsMono(
              fontSize: 10,
              letterSpacing: 2.4,
              color: different ? NexusPalette.cyan : muted,
              fontWeight: different ? FontWeight.bold : FontWeight.normal,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              valueCell(v1, 1),
              Container(
                width: 1,
                height: 16,
                margin: const EdgeInsets.symmetric(horizontal: 8),
                color: Theme.of(context).dividerColor.withValues(alpha: .55),
              ),
              valueCell(v2, 2),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<NexusController>();
    final compared = controller.compareProducts;
    final p1 = compared[0];
    final p2 = compared[1];
    final surface = Theme.of(context).colorScheme.surface;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: surface.withValues(alpha: 0.82),
            border: Border(
              bottom: BorderSide(
                color: Theme.of(context).dividerColor.withValues(alpha: .45),
              ),
            ),
          ),
          child: Text(
            'COMPARE',
            style: GoogleFonts.jetBrainsMono(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _compareProductCard(context, controller, slot: 0, product: p1),
              const SizedBox(width: 16),
              _compareProductCard(context, controller, slot: 1, product: p2),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 112),
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Theme.of(
                      context,
                    ).dividerColor.withValues(alpha: .45),
                  ),
                  color: surface.withValues(alpha: .95),
                ),
                child: Column(
                  children: [
                    for (var i = 0; i < _specs.length; i++)
                      _specRow(
                        context,
                        _specs[i],
                        p1,
                        p2,
                        isLast: i == _specs.length - 1,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CompareProductSelector extends StatelessWidget {
  const _CompareProductSelector({required this.value, required this.onChanged});

  final String? value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final muted = NexusPalette.textMuted(context);
    return Container(
      height: 38,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Theme.of(context).colorScheme.secondary.withValues(alpha: .72),
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha: .45),
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          hint: Text(
            'Select',
            style: GoogleFonts.jetBrainsMono(fontSize: 11, color: muted),
          ),
          dropdownColor: Theme.of(context).colorScheme.surface,
          icon: Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: muted),
          items: allCatalogProducts
              .map(
                (product) => DropdownMenuItem(
                  value: product.id,
                  child: Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.jetBrainsMono(fontSize: 11),
                  ),
                ),
              )
              .toList(),
          onChanged: (id) {
            if (id != null) onChanged(id);
          },
        ),
      ),
    );
  }
}

class _CompareSpec {
  const _CompareSpec({
    required this.label,
    required this.key,
    this.isNumber = false,
    this.lowerIsBetter = false,
  });

  final String label;
  final String key;
  final bool isNumber;
  final bool lowerIsBetter;
}

class _TinyTab extends StatelessWidget {
  const _TinyTab({
    required this.text,
    required this.active,
    required this.onTap,
  });

  final String text;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final surface = Theme.of(context).colorScheme.surface;
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Ink(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: active ? surface : Colors.transparent,
          boxShadow: active
              ? [
                  BoxShadow(
                    blurRadius: 10,
                    color: Colors.black.withValues(alpha: .15),
                  ),
                ]
              : null,
        ),
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Center(
          child: Text(
            text,
            style: GoogleFonts.jetBrainsMono(
              fontWeight: active ? FontWeight.bold : FontWeight.normal,
              fontSize: 9,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

class ProductCardMini extends StatelessWidget {
  const ProductCardMini(
    this.product, {
    super.key,
    required this.fav,
    required this.onTap,
    required this.toggleFavorite,
  });

  final Product product;
  final bool fav;
  final VoidCallback onTap;
  final VoidCallback toggleFavorite;

  @override
  Widget build(BuildContext context) {
    final border = Theme.of(context).dividerColor.withValues(alpha: .55);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: border),
          color: Theme.of(context).colorScheme.surface.withValues(alpha: .9),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: NexusNetworkImage(
                        fit: BoxFit.cover,
                        imageUrl: product.image,
                      ),
                    ),
                  ),
                  Positioned(
                    right: 6,
                    top: 6,
                    child: Material(
                      shape: const CircleBorder(),
                      color: Colors.black38,
                      child: IconButton(
                        visualDensity: VisualDensity.compact,
                        iconSize: 18,
                        onPressed: toggleFavorite,
                        icon: Icon(
                          Icons.favorite,
                          color: fav ? NexusPalette.magenta : Colors.white70,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.category.toUpperCase(),
                    style: GoogleFonts.jetBrainsMono(fontSize: 10),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall!.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '\$ ${product.price.toStringAsFixed(2)}',
                    style: GoogleFonts.jetBrainsMono(
                      color: NexusPalette.cyan,
                      fontWeight: FontWeight.bold,
                    ),
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
