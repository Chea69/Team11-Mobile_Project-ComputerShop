import 'package:flutter/material.dart';
import '../models/models.dart';
import '../theme/nexus_fonts.dart';
import '../theme/nexus_palette.dart';
import 'network_image.dart';
import 'ui_kit.dart';

class ProductCardTile extends StatelessWidget {
  const ProductCardTile({
    super.key,
    required this.product,
    required this.isFavorite,
    required this.onTap,
    required this.onToggleFavorite,
    this.surface,
    this.border,
    this.showBenchmarks = false,
  });

  final Product product;
  final bool isFavorite;
  final VoidCallback onTap;
  final VoidCallback onToggleFavorite;
  final Color? surface;
  final Color? border;
  final bool showBenchmarks;

  @override
  Widget build(BuildContext context) {
    final muted = Theme.of(context).dividerColor.withValues(alpha: .8);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: border ?? muted),
            color:
                surface ??
                Theme.of(context).colorScheme.surface.withValues(alpha: 0.9),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: showBenchmarks ? 4 : 5,
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      NexusNetworkImage(
                        imageUrl: product.image,
                        fit: BoxFit.cover,
                        color: Colors.white.withValues(alpha: .8),
                        colorBlendMode: BlendMode.modulate,
                      ),
                      Positioned(
                        top: 10,
                        right: 10,
                        child: Material(
                          color: Colors.black.withValues(alpha: .45),
                          shape: const CircleBorder(),
                          child: IconButton(
                            visualDensity: VisualDensity.compact,
                            splashRadius: 18,
                            onPressed: () {
                              onToggleFavorite();
                            },
                            icon: Icon(
                              Icons.favorite,
                              size: 18,
                              color: isFavorite ? NexusPalette.magenta : muted,
                            ),
                          ),
                        ),
                      ),
                      if (product.isNew == true)
                        _badge(
                          topLeft: true,
                          label: 'NEW',
                          hue: NexusPalette.cyan,
                        ),
                      if (product.isDeal == true)
                        _badge(
                          topLeft: product.isNew != true,
                          label: 'DEAL',
                          hue: NexusPalette.magenta,
                        ),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: showBenchmarks ? 5 : 4,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.category.toUpperCase(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 10,
                          color: Theme.of(context).textTheme.bodySmall?.color,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Expanded(
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            product.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleSmall!
                                .copyWith(
                                  fontSize: 13,
                                  height: 1.08,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '\$${_fmt(product.price)}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: NexusPalette.cyan,
                        ),
                      ),
                      if (showBenchmarks && product.benchmarks != null) ...[
                        const SizedBox(height: 10),
                        NexusBenchmarkStrip(
                          gaming: product.benchmarks!.gaming,
                          productivity: product.benchmarks!.productivity,
                          compact: true,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _badge({
    required bool topLeft,
    required String label,
    required Color hue,
  }) {
    final align = topLeft ? Alignment.topLeft : Alignment.topLeft;
    final pad = EdgeInsets.only(left: topLeft ? 10 : 10, top: 10);
    return Align(
      alignment: align,
      child: Padding(
        padding: pad,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: hue.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: hue.withValues(alpha: .45)),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            child: Text(
              label,
              style: GoogleFonts.jetBrainsMono(
                fontSize: 9,
                letterSpacing: 2,
                color: hue,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _fmt(double v) => v.toStringAsFixed(2);
}
