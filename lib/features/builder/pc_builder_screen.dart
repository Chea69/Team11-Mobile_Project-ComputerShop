import 'package:flutter/material.dart';

import '../../data/mock_products.dart';
import '../../models/pc_part_model.dart';
import '../../state/app_controller.dart';
import '../../theme/app_colors.dart';

class PcBuilderScreen extends StatelessWidget {
  const PcBuilderScreen({super.key});

  static const _partOrder = [
    PcPartType.cpu,
    PcPartType.motherboard,
    PcPartType.ram,
    PcPartType.gpu,
    PcPartType.storage,
    PcPartType.psu,
    PcPartType.pcCase,
  ];

  @override
  Widget build(BuildContext context) {
    final controller = AppControllerScope.of(context);

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
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 22),
            children: [
              const _BuilderHeader(),
              const SizedBox(height: 16),
              _BuildSummary(controller: controller),
              const SizedBox(height: 24),
              const _SectionHeader(title: 'Component Matrix'),
              const SizedBox(height: 12),
              for (final type in _partOrder)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _PartSelector(
                    type: type,
                    parts: builderParts[type] ?? const [],
                    selected: controller.selectedParts[type],
                    onChanged: controller.selectPart,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BuilderHeader extends StatelessWidget {
  const _BuilderHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            gradient: AppColors.rgbGradient,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: AppColors.cyan.withValues(alpha: 0.22),
                blurRadius: 18,
              ),
            ],
          ),
          child: const Icon(Icons.memory, color: Colors.black, size: 23),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'PC BUILDER',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.textMain,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'LIVE COMPATIBILITY CHECK',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textMuted,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        const _NeonLabel(label: 'SPRINT 2', color: AppColors.violet),
      ],
    );
  }
}

class _BuildSummary extends StatelessWidget {
  const _BuildSummary({required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final isCompatible = controller.isBuildCompatible;
    final issues = controller.compatibilityIssues;
    final statusColor = isCompatible ? AppColors.cyan : AppColors.danger;

    return _GradientBorder(
      borderRadius: 8,
      colors: [
        statusColor.withValues(alpha: 0.8),
        AppColors.magenta.withValues(alpha: 0.44),
        AppColors.violet.withValues(alpha: 0.42),
      ],
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.bgSurface,
          borderRadius: BorderRadius.circular(7),
          boxShadow: [
            BoxShadow(
              color: statusColor.withValues(alpha: 0.12),
              blurRadius: 28,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'CUSTOM RIG STATUS',
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      color: AppColors.textMain,
                      fontSize: 27,
                      fontWeight: FontWeight.w900,
                      height: 1.05,
                    ),
                  ),
                ),
                _CompatibilityBadge(isCompatible: isCompatible),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              controller.compatibilityMessage,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textMuted,
                height: 1.35,
              ),
            ),
            if (issues.length > 1) ...[
              const SizedBox(height: 8),
              for (final issue in issues.skip(1))
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    issue,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                ),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _SummaryMetric(
                    label: 'Live Total',
                    value: _formatPrice(controller.buildTotal),
                    color: AppColors.cyan,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _SummaryMetric(
                    label: 'Est. Load',
                    value: '${controller.estimatedWattage}W',
                    color: AppColors.magenta,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CompatibilityBadge extends StatelessWidget {
  const _CompatibilityBadge({required this.isCompatible});

  final bool isCompatible;

  @override
  Widget build(BuildContext context) {
    final color = isCompatible ? AppColors.cyan : AppColors.danger;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.62)),
        boxShadow: [
          BoxShadow(color: color.withValues(alpha: 0.16), blurRadius: 14),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isCompatible ? Icons.check_circle : Icons.warning,
              size: 16,
              color: color,
            ),
            const SizedBox(width: 6),
            Text(
              isCompatible ? 'CLEAR' : 'CONFLICT',
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

class _SummaryMetric extends StatelessWidget {
  const _SummaryMetric({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.bgBase.withValues(alpha: 0.54),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.28)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label.toUpperCase(),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textMuted,
                fontSize: 11,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: color,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PartSelector extends StatelessWidget {
  const _PartSelector({
    required this.type,
    required this.parts,
    required this.selected,
    required this.onChanged,
  });

  final PcPartType type;
  final List<PcPartModel> parts;
  final PcPartModel? selected;
  final ValueChanged<PcPartModel> onChanged;

  @override
  Widget build(BuildContext context) {
    final color = _colorForType(type);

    return _GradientBorder(
      borderRadius: 8,
      colors: [
        color.withValues(alpha: selected == null ? 0.34 : 0.72),
        AppColors.violet.withValues(alpha: 0.28),
      ],
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.bgSurface,
          borderRadius: BorderRadius.circular(7),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _PartIcon(type: type, color: color),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        type.label.toUpperCase(),
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppColors.textMain,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        selected?.name ?? 'AWAITING COMPONENT',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: selected == null ? AppColors.textMuted : color,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  selected == null ? 'REQUIRED' : _formatPrice(selected!.price),
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: selected == null ? AppColors.textMuted : color,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            for (final part in parts)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _PartOption(
                  part: part,
                  color: color,
                  isSelected: selected?.id == part.id,
                  onTap: () => onChanged(part),
                ),
              ),
            if (selected != null) ...[
              const SizedBox(height: 2),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _SpecChip(label: selected!.brand, color: color),
                  if (selected!.socket != null)
                    _SpecChip(label: selected!.socket!, color: color),
                  if (selected!.ramType != null)
                    _SpecChip(label: selected!.ramType!, color: color),
                  if (selected!.tdp != null)
                    _SpecChip(label: '${selected!.tdp}W TDP', color: color),
                  if (selected!.wattage != null)
                    _SpecChip(label: '${selected!.wattage}W', color: color),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _PartOption extends StatelessWidget {
  const _PartOption({
    required this.part,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  final PcPartModel part;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected
          ? color.withValues(alpha: 0.11)
          : AppColors.bgBase.withValues(alpha: 0.46),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected
                  ? color.withValues(alpha: 0.58)
                  : AppColors.bgSurfaceLight,
            ),
          ),
          child: Row(
            children: [
              Icon(
                isSelected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_off,
                color: isSelected ? color : AppColors.textMuted,
                size: 19,
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      part.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: AppColors.textMain,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      part.brand.toUpperCase(),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textMuted,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                _formatPrice(part.price),
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: isSelected ? color : AppColors.textMuted,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PartIcon extends StatelessWidget {
  const _PartIcon({required this.type, required this.color});

  final PcPartType type;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.28)),
      ),
      child: Icon(_iconForType(type), color: color, size: 22),
    );
  }
}

class _SpecChip extends StatelessWidget {
  const _SpecChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.24)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
        child: Text(
          label.toUpperCase(),
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: color, fontSize: 11),
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
        border: Border.all(color: color.withValues(alpha: 0.46)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Text(
          label.toUpperCase(),
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

Color _colorForType(PcPartType type) {
  switch (type) {
    case PcPartType.cpu:
    case PcPartType.storage:
      return AppColors.cyan;
    case PcPartType.motherboard:
    case PcPartType.psu:
      return AppColors.magenta;
    case PcPartType.ram:
    case PcPartType.gpu:
    case PcPartType.pcCase:
      return AppColors.violet;
  }
}

IconData _iconForType(PcPartType type) {
  switch (type) {
    case PcPartType.cpu:
      return Icons.developer_board;
    case PcPartType.motherboard:
      return Icons.dashboard_customize;
    case PcPartType.ram:
      return Icons.memory;
    case PcPartType.gpu:
      return Icons.videogame_asset;
    case PcPartType.storage:
      return Icons.storage;
    case PcPartType.psu:
      return Icons.power;
    case PcPartType.pcCase:
      return Icons.inventory_2;
  }
}

String _formatPrice(double price) {
  return '\$${price.toStringAsFixed(0)}';
}
