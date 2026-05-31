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
      appBar: AppBar(title: const Text('PC Builder')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _BuildSummary(controller: controller),
            const SizedBox(height: 16),
            Text(
              'Component Selector',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 10),
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

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isCompatible
              ? AppColors.accent.withValues(alpha: 0.45)
              : AppColors.danger.withValues(alpha: 0.45),
        ),
        gradient: const LinearGradient(
          colors: [
            Color.fromRGBO(16, 24, 39, 1),
            Color.fromRGBO(35, 25, 64, 1),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Custom PC Build',
                  style: Theme.of(context).textTheme.displaySmall,
                ),
              ),
              _CompatibilityBadge(isCompatible: isCompatible),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            controller.compatibilityMessage,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          if (issues.length > 1) ...[
            const SizedBox(height: 8),
            for (final issue in issues.skip(1))
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  issue,
                  style: Theme.of(context).textTheme.bodyMedium,
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
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _SummaryMetric(
                  label: 'Est. Load',
                  value: '${controller.estimatedWattage}W',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CompatibilityBadge extends StatelessWidget {
  const _CompatibilityBadge({required this.isCompatible});

  final bool isCompatible;

  @override
  Widget build(BuildContext context) {
    final color = isCompatible ? AppColors.accent : AppColors.danger;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.6)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
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
              isCompatible ? 'Compatible' : 'Conflict',
              style: Theme.of(
                context,
              ).textTheme.labelLarge?.copyWith(color: color),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryMetric extends StatelessWidget {
  const _SummaryMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.darkBackground.withValues(alpha: 0.42),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.darkSurfaceHigh),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 4),
            Text(value, style: Theme.of(context).textTheme.titleLarge),
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
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.darkSurfaceHigh),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _PartIcon(type: type),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  type.label,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              Text(
                selected == null ? 'Required' : _formatPrice(selected!.price),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<PcPartModel>(
            initialValue: selected,
            isExpanded: true,
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.darkBackground,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
            ),
            hint: Text('Select ${type.label}'),
            selectedItemBuilder: (context) {
              return parts.map((part) {
                return Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    part.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }).toList();
            },
            items: parts.map((part) {
              return DropdownMenuItem<PcPartModel>(
                value: part,
                child: Text(
                  '${part.name} - ${_formatPrice(part.price)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              );
            }).toList(),
            onChanged: (part) {
              if (part != null) {
                onChanged(part);
              }
            },
          ),
          if (selected != null) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _SpecChip(label: selected!.brand),
                if (selected!.socket != null)
                  _SpecChip(label: selected!.socket!),
                if (selected!.ramType != null)
                  _SpecChip(label: selected!.ramType!),
                if (selected!.tdp != null)
                  _SpecChip(label: '${selected!.tdp}W TDP'),
                if (selected!.wattage != null)
                  _SpecChip(label: '${selected!.wattage}W'),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _PartIcon extends StatelessWidget {
  const _PartIcon({required this.type});

  final PcPartType type;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(_iconForType(type), color: AppColors.primary, size: 22),
    );
  }
}

class _SpecChip extends StatelessWidget {
  const _SpecChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.darkSurfaceHigh,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
        child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
      ),
    );
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
