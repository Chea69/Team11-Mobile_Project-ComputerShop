import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/mock_data.dart';
import '../models/models.dart';
import '../models/view_state.dart';
import '../state/nexus_controller.dart';
import '../theme/nexus_fonts.dart';
import '../theme/nexus_palette.dart';
import '../widgets/network_image.dart';

class CartSheet extends StatelessWidget {
  const CartSheet({super.key});

  Product? _resolveProduct(String id) {
    try {
      return allCatalogProducts.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  static String cents(double value) => value.toStringAsFixed(2);

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<NexusController>();
    final muted = NexusPalette.textMuted(context);

    Widget header(String txt) => Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.92),
        border: Border(bottom: BorderSide(color: muted.withValues(alpha: .55))),
      ),
      child: Text(
        txt,
        style: GoogleFonts.jetBrainsMono(fontWeight: FontWeight.bold),
      ),
    );

    if (controller.cart.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          header('CART (0)'),
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(36),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.shopping_cart_outlined, size: 48, color: muted),
                    const SizedBox(height: 16),
                    Text(
                      'YOUR CART IS EMPTY',
                      style: GoogleFonts.jetBrainsMono(fontSize: 13),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Add some gear to get started.',
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: muted),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    }

    final subtotal = controller.cartSubtotal;
    final discount = controller.cartDiscount;
    final shipping = controller.cartShipping;
    final tax = controller.cartTax;
    final total = controller.cartTotal;

    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            header('CART (${controller.cartCount})'),
            Expanded(
              child: ListView.builder(
                physics: const ClampingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 240),
                itemCount: controller.cart.length + 1,
                itemBuilder: (context, i) {
                  if (i == controller.cart.length) {
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(2, 10, 2, 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _TotalsRow(
                            label: 'Subtotal',
                            amount: subtotal,
                            muted: muted,
                          ),
                          if (discount > 0) ...[
                            const SizedBox(height: 8),
                            _TotalsRow(
                              label:
                                  'Coupon ${controller.activeCouponCode ?? ''}',
                              amount: -discount,
                              muted: muted,
                              emphasized: Colors.lightGreenAccent,
                            ),
                          ],
                          const SizedBox(height: 8),
                          _TotalsRow(
                            label: shipping == 0 ? 'Shipping' : 'Courier',
                            amount: shipping,
                            muted: muted,
                            emphasized: shipping == 0
                                ? Colors.lightGreenAccent
                                : null,
                          ),
                          const SizedBox(height: 8),
                          _TotalsRow(
                            label: 'Estimated Tax',
                            amount: tax,
                            muted: muted,
                          ),
                          const Divider(height: 24),
                          _TotalsRow(
                            label: 'Total',
                            amount: total,
                            muted: muted,
                            emphasized: NexusPalette.cyan,
                            emphasizeStyle: FontWeight.bold,
                          ),
                        ],
                      ),
                    );
                  }
                  final item = controller.cart[i];
                  final prod = _resolveProduct(item.productId);
                  return _CartLine(
                    item: item,
                    prod: prod,
                    onIncrease: () =>
                        controller.updateCartQty(item.id, item.qty + 1),
                    onDecrease: () =>
                        controller.updateCartQty(item.id, item.qty - 1),
                    onDelete: () => controller.removeFromCart(item.id),
                  );
                },
              ),
            ),
          ],
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 112),
            child: GradientPrimaryButton(
              label: 'PROCEED TO CHECKOUT',
              onTap: () => controller.navigate(ViewState.checkout),
            ),
          ),
        ),
      ],
    );
  }
}

class GradientPrimaryButton extends StatelessWidget {
  const GradientPrimaryButton({
    super.key,
    required this.label,
    required this.onTap,
  });

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Ink(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                NexusPalette.cyan,
                NexusPalette.magenta,
                NexusPalette.violet,
              ],
            ),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.jetBrainsMono(fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }
}

class _TotalsRow extends StatelessWidget {
  const _TotalsRow({
    required this.label,
    required this.amount,
    required this.muted,
    this.emphasized,
    this.emphasizeStyle,
  });

  final String label;
  final double amount;
  final Color muted;
  final Color? emphasized;
  final FontWeight? emphasizeStyle;

  @override
  Widget build(BuildContext context) {
    final labelStyle = Theme.of(
      context,
    ).textTheme.bodyMedium!.copyWith(color: muted.withValues(alpha: .9));

    final amountStyle = GoogleFonts.jetBrainsMono(
      fontWeight: emphasizeStyle ?? FontWeight.w500,
      color: emphasized ?? muted,
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: labelStyle),
        Text('\$ ${CartSheet.cents(amount)}', style: amountStyle),
      ],
    );
  }
}

class _CartLine extends StatelessWidget {
  const _CartLine({
    required this.item,
    required this.prod,
    required this.onIncrease,
    required this.onDecrease,
    required this.onDelete,
  });

  final CartItem item;
  final Product? prod;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final surface = Theme.of(context).colorScheme.surface;
    final border = Theme.of(context).dividerColor.withValues(alpha: .55);

    final opts = item.configOptions;
    final subtitle = opts == null
        ? ''
        : '${opts.ram ?? ''}${opts.ram != null && opts.storage != null ? ' • ' : ''}${opts.storage ?? ''}';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: border),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: 78,
              height: 78,
              child: prod == null
                  ? ColoredBox(
                      color: Colors.black.withValues(alpha: .18),
                      child: Icon(Icons.memory, color: border),
                    )
                  : NexusNetworkImage(imageUrl: prod!.image, fit: BoxFit.cover),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  prod?.name ??
                      (item.productId == 'custom-build'
                          ? 'CUSTOM BUILD'
                          : 'CUSTOM ITEM'),
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall!.copyWith(fontWeight: FontWeight.bold),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (subtitle.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 10,
                      color: border,
                    ),
                  ),
                ],
                const SizedBox(height: 10),
                Row(
                  children: [
                    Text(
                      '\$ ${CartSheet.cents(item.price * item.qty)}',
                      style: GoogleFonts.jetBrainsMono(
                        color: NexusPalette.cyan,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (item.qty > 1) ...[
                      const SizedBox(width: 8),
                      Text(
                        '@ \$${CartSheet.cents(item.price)}',
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 10,
                          color: border,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          Column(
            children: [
              Container(
                height: 38,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: border),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      onPressed: onDecrease,
                      icon: const Icon(Icons.remove, size: 18),
                    ),
                    SizedBox(
                      width: 24,
                      child: Text(
                        '${item.qty}',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.jetBrainsMono(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      onPressed: onIncrease,
                      icon: const Icon(Icons.add, size: 18),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
