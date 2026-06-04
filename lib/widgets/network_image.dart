import 'package:flutter/material.dart';

class NexusNetworkImage extends StatelessWidget {
  const NexusNetworkImage({
    super.key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
    this.color,
    this.colorBlendMode,
  });

  final String imageUrl;
  final BoxFit fit;
  final Color? color;
  final BlendMode? colorBlendMode;

  @override
  Widget build(BuildContext context) {
    final muted = Theme.of(context).dividerColor.withValues(alpha: .45);

    Widget placeholder() => ColoredBox(
      color: muted,
      child: Icon(
        Icons.image_outlined,
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: .35),
      ),
    );

    return RepaintBoundary(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final dpr = MediaQuery.devicePixelRatioOf(context).clamp(1.0, 2.0);
          int? cacheExtent(double value) {
            if (!value.isFinite || value <= 0) return null;
            return (value * dpr).round().clamp(64, 1200);
          }

          return Image.network(
            imageUrl,
            fit: fit,
            color: color,
            colorBlendMode: colorBlendMode,
            cacheWidth: cacheExtent(constraints.maxWidth),
            cacheHeight: cacheExtent(constraints.maxHeight),
            filterQuality: FilterQuality.low,
            gaplessPlayback: true,
            frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
              if (wasSynchronouslyLoaded || frame != null) return child;
              return placeholder();
            },
            errorBuilder: (context, error, stackTrace) {
              return ColoredBox(
                color: muted,
                child: Icon(
                  Icons.image_not_supported_outlined,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: .5),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
