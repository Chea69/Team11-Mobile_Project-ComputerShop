import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/mock_data.dart';
import '../models/models.dart';
import '../models/view_state.dart';
import '../state/nexus_controller.dart';
import '../theme/nexus_fonts.dart';
import '../theme/nexus_palette.dart';
import '../widgets/network_image.dart';
import '../widgets/product_card.dart';
import '../widgets/ui_kit.dart';

Iterable<MapEntry<String, String>> productSpecPairs(ProductSpecs s) sync* {
  if (s.cpu != null) yield MapEntry('CPU', s.cpu!);
  if (s.gpu != null) yield MapEntry('GPU', s.gpu!);
  if (s.ram != null) yield MapEntry('RAM', s.ram!);
  if (s.storage != null) yield MapEntry('STORAGE', s.storage!);
  if (s.display != null) yield MapEntry('DISPLAY', s.display!);
}

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _couponController = TextEditingController();
  String _deliveryWindow = 'Today 16:00-18:00';
  String _paymentLabel = 'Visa 4421';

  @override
  void dispose() {
    _couponController.dispose();
    super.dispose();
  }

  void _applyCoupon(NexusController store) {
    final ok = store.applyCoupon(_couponController.text);
    showNexusToast(context, ok ? 'COUPON APPLIED' : 'COUPON NOT FOUND');
    if (ok) _couponController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<NexusController>();
    final muted = Theme.of(context).dividerColor.withValues(alpha: .75);
    final subtotal = store.cartSubtotal;
    final discount = store.cartDiscount;
    final shipping = store.cartShipping;
    final tax = store.cartTax;
    final total = store.cartTotal;

    if (store.cart.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _StickyBar(
            icon: Icons.chevron_left,
            title: 'CHECKOUT',
            onLeading: () => store.navigate(ViewState.cart),
          ),
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.receipt_long_outlined, size: 48, color: muted),
                    const SizedBox(height: 16),
                    Text(
                      'NOTHING TO CHECK OUT',
                      style: GoogleFonts.jetBrainsMono(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    GradientRgbButton(
                      onPressed: () => store.navigate(ViewState.home),
                      child: const Text('SHOP FEATURED GEAR'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _StickyBar(
          icon: Icons.chevron_left,
          title: 'CHECKOUT',
          onLeading: () => store.navigate(ViewState.cart),
        ),
        Expanded(
          child: ListView(
            physics: const ClampingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            padding: const EdgeInsets.all(22),
            children: [
              Text(
                'ORDER ITEMS',
                style: GoogleFonts.jetBrainsMono(
                  color: muted,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 12),
              ...store.cart.map((e) {
                final options = e.configOptions;
                final optionText = options == null
                    ? ''
                    : [
                        if (options.ram != null) options.ram!,
                        if (options.storage != null) options.storage!,
                      ].join(' / ');
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: muted.withValues(alpha: .45)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              store.featuredById(e.productId)?.name ??
                                  'CUSTOM ITEM',
                              style: Theme.of(context).textTheme.titleSmall
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              optionText.isEmpty
                                  ? 'Qty ${e.qty}'
                                  : 'Qty ${e.qty} - $optionText',
                              style: GoogleFonts.jetBrainsMono(
                                fontSize: 10,
                                color: muted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '\$ ${(e.price * e.qty).toStringAsFixed(2)}',
                        style: GoogleFonts.jetBrainsMono(
                          color: NexusPalette.cyan,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 8),
              Text(
                'COUPON',
                style: GoogleFonts.jetBrainsMono(
                  color: muted,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _couponController,
                      textCapitalization: TextCapitalization.characters,
                      decoration: InputDecoration(
                        hintText: store.activeCouponCode ?? 'NEXUS10',
                        prefixIcon: const Icon(Icons.local_offer_outlined),
                      ),
                      onSubmitted: (_) => _applyCoupon(store),
                    ),
                  ),
                  const SizedBox(width: 10),
                  OutlinedButton(
                    onPressed: () => _applyCoupon(store),
                    child: Text(
                      'APPLY',
                      style: GoogleFonts.jetBrainsMono(fontSize: 11),
                    ),
                  ),
                ],
              ),
              if (store.activeCouponCode != null)
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: store.removeCoupon,
                    icon: const Icon(Icons.close_rounded, size: 16),
                    label: Text(
                      'REMOVE ${store.activeCouponCode}',
                      style: GoogleFonts.jetBrainsMono(fontSize: 10),
                    ),
                  ),
                ),
              const SizedBox(height: 18),
              Text(
                'DELIVERY',
                style: GoogleFonts.jetBrainsMono(
                  color: muted,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 10),
              _CheckoutChoiceGroup(
                values: const [
                  'Today 16:00-18:00',
                  'Tomorrow 10:00-12:00',
                  'Store pickup',
                ],
                selected: _deliveryWindow,
                onSelected: (value) => setState(() => _deliveryWindow = value),
              ),
              const SizedBox(height: 18),
              Text(
                'PAYMENT',
                style: GoogleFonts.jetBrainsMono(
                  color: muted,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 10),
              _CheckoutChoiceGroup(
                values: const ['Visa 4421', 'Nexus Pay', 'Pay in store'],
                selected: _paymentLabel,
                onSelected: (value) => setState(() => _paymentLabel = value),
              ),
              const Divider(height: 32),
              Text(
                'ORDER SUMMARY',
                style: GoogleFonts.jetBrainsMono(
                  color: muted,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 12),
              _CheckoutPriceLine(label: 'Subtotal', amount: subtotal),
              if (discount > 0)
                _CheckoutPriceLine(
                  label: 'Discount',
                  amount: -discount,
                  color: Colors.lightGreenAccent,
                ),
              _CheckoutPriceLine(
                label: shipping == 0 ? 'Shipping' : 'Courier',
                amount: shipping,
                color: shipping == 0 ? Colors.lightGreenAccent : null,
              ),
              _CheckoutPriceLine(label: 'Estimated tax', amount: tax),
              const Divider(height: 26),
              _CheckoutPriceLine(
                label: 'Total',
                amount: total,
                color: NexusPalette.cyan,
                emphasized: true,
              ),
              const SizedBox(height: 24),
              GradientRgbButton(
                onPressed: () => store.placeMockOrder(
                  deliveryWindow: _deliveryWindow,
                  paymentLabel: _paymentLabel,
                ),
                child: const Text('PAY SECURELY'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class CheckoutConfirmationScreen extends StatelessWidget {
  const CheckoutConfirmationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<NexusController>();
    final confirmation = store.lastCheckoutConfirmation;
    final muted = Theme.of(context).dividerColor.withValues(alpha: .75);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _StickyBar(
          icon: Icons.close_rounded,
          title: 'ORDER CONFIRMED',
          onLeading: () => store.navigate(ViewState.home),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(22, 24, 22, 112),
            children: [
              BorderGradientPanel(
                radius: 22,
                child: Padding(
                  padding: const EdgeInsets.all(22),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.verified_rounded,
                            color: NexusPalette.cyan,
                            size: 34,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              confirmation?.orderId ?? 'NX-DEMO',
                              style: GoogleFonts.jetBrainsMono(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Your mock order is queued for fulfillment.',
                        style: Theme.of(
                          context,
                        ).textTheme.bodyMedium?.copyWith(color: muted),
                      ),
                      const SizedBox(height: 20),
                      _CheckoutPriceLine(
                        label: 'Items',
                        amount: (confirmation?.itemCount ?? 0).toDouble(),
                        asMoney: false,
                      ),
                      _CheckoutPriceLine(
                        label: 'Delivery',
                        textValue: confirmation?.deliveryWindow ?? 'Pending',
                      ),
                      _CheckoutPriceLine(
                        label: 'Payment',
                        textValue: confirmation?.paymentLabel ?? 'Mock pay',
                      ),
                      const Divider(height: 26),
                      _CheckoutPriceLine(
                        label: 'Paid total',
                        amount: confirmation?.total ?? 0,
                        color: NexusPalette.cyan,
                        emphasized: true,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),
              OutlinedButton.icon(
                onPressed: () => store.navigate(
                  ViewState.orders,
                  params: {'origin': 'checkout'},
                ),
                icon: const Icon(Icons.receipt_long_outlined),
                label: Text(
                  'VIEW ORDER HISTORY',
                  style: GoogleFonts.jetBrainsMono(fontSize: 11),
                ),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () => store.navigate(ViewState.home),
                child: Text(
                  'BACK TO HOME',
                  style: GoogleFonts.jetBrainsMono(fontSize: 11),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CheckoutChoiceGroup extends StatelessWidget {
  const _CheckoutChoiceGroup({
    required this.values,
    required this.selected,
    required this.onSelected,
  });

  final List<String> values;
  final String selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: values.map((value) {
        final active = value == selected;
        return ChoiceChip(
          selected: active,
          label: Text(value, style: GoogleFonts.jetBrainsMono(fontSize: 10)),
          selectedColor: NexusPalette.cyan.withValues(alpha: .18),
          side: BorderSide(
            color: active
                ? NexusPalette.cyan
                : Theme.of(context).dividerColor.withValues(alpha: .55),
          ),
          onSelected: (_) => onSelected(value),
        );
      }).toList(),
    );
  }
}

class _CheckoutPriceLine extends StatelessWidget {
  const _CheckoutPriceLine({
    required this.label,
    this.amount,
    this.textValue,
    this.color,
    this.emphasized = false,
    this.asMoney = true,
  });

  final String label;
  final double? amount;
  final String? textValue;
  final Color? color;
  final bool emphasized;
  final bool asMoney;

  @override
  Widget build(BuildContext context) {
    final muted = Theme.of(context).dividerColor.withValues(alpha: .75);
    final value =
        textValue ??
        (asMoney
            ? '${(amount ?? 0) < 0 ? '-' : ''}\$ ${(amount ?? 0).abs().toStringAsFixed(2)}'
            : '${(amount ?? 0).round()}');

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: muted,
                fontWeight: emphasized ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
          Text(
            value,
            textAlign: TextAlign.right,
            style: GoogleFonts.jetBrainsMono(
              fontWeight: emphasized ? FontWeight.bold : FontWeight.w500,
              fontSize: emphasized ? 18 : 13,
              color: color ?? Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

class CategoryBrowseScreen extends StatelessWidget {
  const CategoryBrowseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<NexusController>();
    final label = '${controller.viewParams?['category'] ?? 'Shop'}'
        .toUpperCase();

    Iterable<Product> source = featuredProducts;
    final raw = '${controller.viewParams?['category'] ?? ''}'.toLowerCase();
    if (raw.isNotEmpty && raw != 'all deals') {
      source = featuredProducts.where(
        (p) =>
            p.category.toLowerCase() == raw ||
            p.name.toLowerCase().contains(raw),
      );
    }

    final list = source.toList();

    return Column(
      children: [
        _StickyBar(
          icon: Icons.chevron_left,
          title: label,
          onLeading: () => controller.navigate(ViewState.home),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: list.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.inventory_2_outlined,
                          size: 48,
                          color: Theme.of(
                            context,
                          ).dividerColor.withValues(alpha: .6),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'NO LISTINGS IN THIS AISLE',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.jetBrainsMono(letterSpacing: 1.6),
                        ),
                        const SizedBox(height: 24),
                        GradientRgbButton(
                          onPressed: () => controller.navigate(ViewState.home),
                          child: const Text('BACK TO HOME'),
                        ),
                      ],
                    ),
                  )
                : GridView.count(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: .52,
                    children: list
                        .map(
                          (product) => ProductCardTile(
                            product: product,
                            isFavorite: controller.favorites.contains(
                              product.id,
                            ),
                            onToggleFavorite: () =>
                                controller.toggleFavorite(product.id),
                            onTap: () => controller.navigate(
                              ViewState.product,
                              params: {'id': product.id},
                            ),
                          ),
                        )
                        .toList(),
                  ),
          ),
        ),
      ],
    );
  }
}

class ProductDetailRoute extends StatefulWidget {
  const ProductDetailRoute({super.key});

  @override
  State<ProductDetailRoute> createState() => _ProductDetailRouteState();
}

class _ProductDetailRouteState extends State<ProductDetailRoute> {
  String ram = '32GB';
  String disk = '1TB';

  @override
  Widget build(BuildContext context) {
    final store = context.watch<NexusController>();
    final pid = '${store.viewParams?['id'] ?? featuredProducts.first.id}';
    final product = store.featuredById(pid) ?? featuredProducts.first;
    final favors = store.favorites.contains(product.id);

    final base = product.price;
    final mod = (ram == '64GB' ? 200.0 : 0) + (disk == '2TB' ? 150.0 : 0);
    final finalPrice = base + mod;

    final muted = Theme.of(context).dividerColor.withValues(alpha: .75);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
          child: Row(
            children: [
              IconButton(
                onPressed: () => store.navigate(ViewState.home),
                icon: const Icon(Icons.chevron_left),
              ),
              const Spacer(),
              IconButton(
                onPressed: () => showNexusToast(context, 'LINK COPIED'),
                icon: const Icon(Icons.share_rounded),
              ),
              IconButton(
                onPressed: () => store.toggleFavorite(product.id),
                icon: Icon(
                  Icons.favorite,
                  color: favors ? NexusPalette.magenta : muted,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final maxHeroHeight = constraints.maxHeight.isFinite
                  ? constraints.maxHeight * .42
                  : 280.0;
              final minHeroHeight = maxHeroHeight < 180.0 ? 140.0 : 180.0;
              final heroHeight = (constraints.maxWidth * .58)
                  .clamp(minHeroHeight, maxHeroHeight)
                  .toDouble();

              return ListView(
                physics: const ClampingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                padding: const EdgeInsets.only(bottom: 116),
                children: [
                  SizedBox(
                    height: heroHeight,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        ColoredBox(
                          color: Colors.black,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 8,
                            ),
                            child: NexusNetworkImage(
                              imageUrl: product.image,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.center,
                              colors: [
                                Theme.of(context).scaffoldBackgroundColor
                                    .withValues(alpha: .82),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 14,
                          left: 0,
                          right: 0,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircleAvatar(
                                radius: 4,
                                backgroundColor: NexusPalette.cyan,
                              ),
                              const SizedBox(width: 10),
                              CircleAvatar(
                                radius: 4,
                                backgroundColor: muted.withValues(alpha: .55),
                              ),
                              const SizedBox(width: 10),
                              CircleAvatar(
                                radius: 4,
                                backgroundColor: muted.withValues(alpha: .55),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 18,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.category.toUpperCase(),
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 11,
                            color: muted,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          product.name,
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          '\$ ${finalPrice.toStringAsFixed(2)}',
                          style: GoogleFonts.jetBrainsMono(
                            fontWeight: FontWeight.bold,
                            fontSize: 26,
                            color: NexusPalette.cyan,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'IN STOCK • FREE STORE PICKUP',
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 9,
                            letterSpacing: 1.4,
                            color: muted,
                          ),
                        ),
                        if (product.benchmarks != null) ...[
                          const SizedBox(height: 22),
                          NexusBenchmarkStrip(
                            gaming: product.benchmarks!.gaming,
                            productivity: product.benchmarks!.productivity,
                          ),
                        ],
                        const SizedBox(height: 26),
                        _SegmentControl(
                          label: 'MEMORY (RAM)',
                          options: const ['32GB', '64GB'],
                          value: ram,
                          activeColor: NexusPalette.cyan,
                          onChanged: (v) => setState(() => ram = v),
                        ),
                        const SizedBox(height: 18),
                        _SegmentControl(
                          label: 'STORAGE',
                          options: const ['1TB', '2TB'],
                          value: disk,
                          activeColor: NexusPalette.magenta,
                          onChanged: (v) => setState(() => disk = v),
                        ),
                        const SizedBox(height: 28),
                        Text(
                          'SYSTEM SPECS',
                          style: GoogleFonts.jetBrainsMono(letterSpacing: 2),
                        ),
                        const Divider(height: 24),
                        ...productSpecPairs(product.specs).map(
                          (pair) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    pair.key,
                                    style: GoogleFonts.jetBrainsMono(
                                      fontSize: 10,
                                      color: muted,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 3,
                                  child: Text(
                                    pair.value,
                                    textAlign: TextAlign.right,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodyLarge,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        SafeArea(
          top: false,
          minimum: const EdgeInsets.fromLTRB(14, 6, 14, 112),
          child: Row(
            children: [
              Expanded(
                flex: 5,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 14,
                    ),
                  ),
                  onPressed: () =>
                      showNexusToast(context, 'RESERVE REQUEST SENT'),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.calendar_month, size: 17),
                        const SizedBox(width: 7),
                        Text(
                          'RESERVE',
                          style: GoogleFonts.jetBrainsMono(fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 7,
                child: GradientRgbButton(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 14,
                  ),
                  onPressed: () {
                    store.addToCart(
                      NewCartPayload(
                        productId: product.id,
                        qty: 1,
                        price: finalPrice,
                        configOptions: CartConfigOptions(
                          ram: ram,
                          storage: disk,
                        ),
                      ),
                    );
                    showNexusToast(context, 'ADDED TO CART');
                  },
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.shopping_cart_outlined, size: 18),
                        SizedBox(width: 7),
                        Text('ADD TO CART'),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SegmentControl extends StatelessWidget {
  const _SegmentControl({
    required this.label,
    required this.options,
    required this.value,
    required this.activeColor,
    required this.onChanged,
  });

  final String label;
  final List<String> options;
  final String value;
  final Color activeColor;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final muted = Theme.of(context).dividerColor.withValues(alpha: .7);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.jetBrainsMono(fontSize: 11)),
        const SizedBox(height: 12),
        Row(
          children: options.map((opt) {
            final active = opt == value;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  left: opt == options.first ? 0 : 6,
                  right: opt == options.last ? 0 : 6,
                ),
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: active ? activeColor : muted,
                    side: BorderSide(
                      color: active ? activeColor : muted.withValues(alpha: .6),
                    ),
                    backgroundColor: active
                        ? activeColor.withValues(alpha: 0.1)
                        : null,
                  ),
                  onPressed: () => onChanged(opt),
                  child: Text(opt, style: GoogleFonts.jetBrainsMono()),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _StickyBar extends StatelessWidget {
  const _StickyBar({
    required this.icon,
    required this.title,
    required this.onLeading,
  });

  final IconData icon;
  final String title;
  final VoidCallback onLeading;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(4, 8, 8, 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor.withValues(alpha: .55),
          ),
        ),
      ),
      child: Row(
        children: [
          IconButton(onPressed: onLeading, icon: Icon(icon)),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.jetBrainsMono(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }
}
