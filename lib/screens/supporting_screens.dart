import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../data/mock_data.dart';
import '../models/models.dart';
import '../models/view_state.dart';
import '../state/nexus_controller.dart';
import '../theme/nexus_fonts.dart';
import '../theme/nexus_palette.dart';
import '../widgets/network_image.dart';
import '../widgets/ui_kit.dart';

class _NexusStickyHeader extends StatelessWidget {
  const _NexusStickyHeader({required this.title, required this.onBack});

  final String title;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final d = Theme.of(context).dividerColor.withValues(alpha: .55);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(4, 8, 8, 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: d)),
      ),
      child: Row(
        children: [
          IconButton(onPressed: onBack, icon: const Icon(Icons.chevron_left)),
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

Widget _capsLabel(BuildContext ctx, Color muted, String t) => Padding(
  padding: const EdgeInsets.only(bottom: 6),
  child: Text(
    t,
    style: GoogleFonts.jetBrainsMono(
      fontSize: 10,
      letterSpacing: 3,
      color: muted.withValues(alpha: .85),
    ),
  ),
);

Color _statusTint(OrderStatus s) => switch (s) {
  OrderStatus.delivered => Colors.lightGreenAccent,
  OrderStatus.shipped => NexusPalette.cyan,
  OrderStatus.processing => Colors.amberAccent,
  OrderStatus.cancelled => Colors.redAccent,
};

Product _productForId(String? id) {
  if (id != null && id.isNotEmpty) {
    for (final p in allCatalogProducts) {
      if (p.id == id) return p;
    }
  }
  return featuredProducts.first;
}

class _SearchResultItem {
  const _SearchResultItem({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.image,
    required this.price,
    required this.isPart,
  });

  final String id;
  final String name;
  final String subtitle;
  final String image;
  final double price;
  final bool isPart;
}

class NexusSearchScreen extends StatefulWidget {
  const NexusSearchScreen({super.key});

  @override
  State<NexusSearchScreen> createState() => _NexusSearchScreenState();
}

class _NexusSearchScreenState extends State<NexusSearchScreen> {
  final _txt = TextEditingController();
  String _q = '';
  bool _loading = false;
  List<_SearchResultItem> _results = [];
  Timer? _debounce;

  static const _recentSearches = [
    'RTX 4090',
    'mechanical keyboard',
    'gaming laptop',
  ];

  static const _trending = ['Laptops', 'Desktops', 'Components', 'Monitors'];

  @override
  void initState() {
    super.initState();
    _txt.addListener(_onQueryChanged);
  }

  void _onQueryChanged() {
    setState(() => _q = _txt.text);
    _debounce?.cancel();
    final ql = _q.trim();
    if (ql.length <= 2) {
      setState(() {
        _loading = false;
        _results = [];
      });
      return;
    }
    setState(() => _loading = true);
    _debounce = Timer(const Duration(milliseconds: 400), () {
      if (!mounted) return;
      final lower = ql.toLowerCase();
      final productMatches = allCatalogProducts
          .where(
            (p) =>
                p.name.toLowerCase().contains(lower) ||
                p.category.toLowerCase().contains(lower),
          )
          .map(
            (p) => _SearchResultItem(
              id: p.id,
              name: p.name,
              subtitle:
                  '${p.category.toUpperCase()} • \$${p.price.toStringAsFixed(2)}',
              image: p.image,
              price: p.price,
              isPart: false,
            ),
          );
      final partMatches = allBuilderParts
          .where(
            (p) =>
                p.name.toLowerCase().contains(lower) ||
                p.brand.toLowerCase().contains(lower),
          )
          .map(
            (p) => _SearchResultItem(
              id: p.id,
              name: p.name,
              subtitle:
                  '${p.partType.toUpperCase()} • \$${p.price.toStringAsFixed(2)}',
              image: p.image,
              price: p.price,
              isPart: true,
            ),
          );
      setState(() {
        _results = [...productMatches, ...partMatches].take(8).toList();
        _loading = false;
      });
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _txt.removeListener(_onQueryChanged);
    _txt.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = context.read<NexusController>();
    final muted = NexusPalette.textMuted(context);
    final surface = Theme.of(context).colorScheme.surface;
    final ql = _q.trim();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          decoration: BoxDecoration(
            color: surface.withValues(alpha: 0.82),
            border: Border(
              bottom: BorderSide(
                color: Theme.of(context).dividerColor.withValues(alpha: .45),
              ),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  autofocus: true,
                  controller: _txt,
                  style: Theme.of(context).textTheme.bodyMedium,
                  decoration: InputDecoration(
                    hintText: 'Search products, parts...',
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 14,
                    ),
                    prefixIcon: Icon(
                      Icons.search_rounded,
                      size: 18,
                      color: muted,
                    ),
                    suffixIcon: ql.isEmpty
                        ? null
                        : IconButton(
                            icon: Icon(
                              Icons.close_rounded,
                              size: 18,
                              color: muted,
                            ),
                            onPressed: () {
                              _txt.clear();
                              setState(() {
                                _q = '';
                                _results = [];
                                _loading = false;
                              });
                            },
                          ),
                    filled: true,
                    fillColor: Theme.of(
                      context,
                    ).colorScheme.secondary.withValues(alpha: .55),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Theme.of(
                          context,
                        ).dividerColor.withValues(alpha: .55),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: NexusPalette.cyan),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              TextButton(
                onPressed: () => ctrl.navigate(ViewState.home),
                child: Text(
                  'CANCEL',
                  style: GoogleFonts.jetBrainsMono(fontSize: 11, color: muted),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 112),
            children: [
              if (ql.length > 2) ...[
                if (_loading)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: Center(
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: NexusPalette.cyan,
                        ),
                      ),
                    ),
                  )
                else if (_results.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: Text(
                      'NO RESULTS FOUND',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 13,
                        color: muted,
                      ),
                    ),
                  )
                else
                  ..._results.map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Material(
                        color: surface.withValues(alpha: .95),
                        borderRadius: BorderRadius.circular(14),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(14),
                          onTap: () {
                            if (item.isPart) {
                              ctrl.navigate(ViewState.builder);
                            } else {
                              ctrl.navigate(
                                ViewState.product,
                                params: {'id': item.id},
                              );
                            }
                          },
                          child: Ink(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: Theme.of(
                                  context,
                                ).dividerColor.withValues(alpha: .45),
                              ),
                            ),
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: .5),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  padding: const EdgeInsets.all(4),
                                  child: NexusNetworkImage(
                                    imageUrl: item.image,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.name,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleSmall
                                            ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        item.subtitle,
                                        style: GoogleFonts.jetBrainsMono(
                                          fontSize: 10,
                                          color: muted,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  Icons.arrow_forward_rounded,
                                  size: 18,
                                  color: muted,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ] else ...[
                Text(
                  'RECENT SEARCHES',
                  style: GoogleFonts.jetBrainsMono(fontSize: 11, color: muted),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _recentSearches.map((s) {
                    return ActionChip(
                      label: Text(
                        s,
                        style: GoogleFonts.jetBrainsMono(fontSize: 11),
                      ),
                      backgroundColor: surface.withValues(alpha: .95),
                      side: BorderSide(
                        color: Theme.of(
                          context,
                        ).dividerColor.withValues(alpha: .45),
                      ),
                      onPressed: () {
                        _txt.text = s;
                        _txt.selection = TextSelection.collapsed(
                          offset: s.length,
                        );
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 28),
                Text(
                  'TRENDING CATEGORIES',
                  style: GoogleFonts.jetBrainsMono(fontSize: 11, color: muted),
                ),
                const SizedBox(height: 12),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 2.4,
                  children: _trending.map((t) {
                    return Material(
                      color: surface.withValues(alpha: .95),
                      borderRadius: BorderRadius.circular(14),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: () => ctrl.navigate(
                          ViewState.category,
                          params: {'category': t},
                        ),
                        child: Ink(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: Theme.of(
                                context,
                              ).dividerColor.withValues(alpha: .45),
                            ),
                          ),
                          padding: const EdgeInsets.all(16),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              t,
                              style: GoogleFonts.jetBrainsMono(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class NotificationsFeedScreen extends StatelessWidget {
  const NotificationsFeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<NexusController>();
    final muted = Theme.of(context).dividerColor.withValues(alpha: .65);

    return Column(
      children: [
        _NexusStickyHeader(
          title: 'NOTIFICATIONS',
          onBack: () => ctrl.navigate(ViewState.home),
        ),
        Expanded(
          child: ctrl.notifications.isEmpty
              ? Center(
                  child: Text(
                    'ALL CAUGHT UP',
                    style: GoogleFonts.jetBrainsMono(color: muted),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(22, 16, 22, 112),
                  separatorBuilder: (_, _) => const Divider(height: 22),
                  itemCount: ctrl.notifications.length,
                  itemBuilder: (_, i) {
                    final n = ctrl.notifications[i];
                    return InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () => ctrl.markNotificationRead(n.id),
                      child: Ink(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: muted.withValues(alpha: .42),
                          ),
                          color: n.read
                              ? Colors.transparent
                              : NexusPalette.cyan.withValues(alpha: .06),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                if (!n.read)
                                  GlowDot(color: NexusPalette.magenta),
                                if (!n.read) const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    n.title,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall!
                                        .copyWith(fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Text(
                                  n.date.length >= 10
                                      ? n.date.substring(0, 10)
                                      : n.date,
                                  style: GoogleFonts.jetBrainsMono(fontSize: 9),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              n.message,
                              style: Theme.of(
                                context,
                              ).textTheme.bodyMedium?.copyWith(color: muted),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class AccountOverviewScreen extends StatelessWidget {
  const AccountOverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<NexusController>();
    final user =
        ctrl.currentUser ??
        const NexusUser(name: 'Guest Insider', email: 'Sign in to sync');
    final muted = Theme.of(context).dividerColor.withValues(alpha: .65);

    Widget row(
      String title,
      IconData ic,
      VoidCallback onTap, [
      Color tint = NexusPalette.cyan,
    ]) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: muted.withValues(alpha: .45)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 18),
            child: Row(
              children: [
                Icon(ic, color: tint),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    title,
                    style: GoogleFonts.jetBrainsMono(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Icon(Icons.chevron_right, color: muted.withValues(alpha: .7)),
              ],
            ),
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(22, 14, 22, 112),
      children: [
        BorderGradientPanel(
          radius: 20,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: muted.withValues(alpha: .35),
                  child: ShaderMask(
                    blendMode: BlendMode.srcIn,
                    shaderCallback: (b) =>
                        NexusPalette.textGradientHorizontal.createShader(b),
                    child: Text(
                      user.initials,
                      style: GoogleFonts.jetBrainsMono(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.name.toUpperCase(),
                        style: GoogleFonts.jetBrainsMono(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        ctrl.isSignedIn
                            ? '${user.email} - Platinum rewards tier'
                            : user.email,
                        style: Theme.of(
                          context,
                        ).textTheme.bodySmall?.copyWith(color: muted),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 26),
        _capsLabel(context, muted, 'ACCOUNT MENU'),
        row(
          'ORDERS',
          Icons.receipt_long_rounded,
          () => ctrl.navigate(ViewState.orders),
        ),
        row(
          'LOYALTY & REWARDS',
          Icons.emoji_events_rounded,
          () => ctrl.navigate(ViewState.loyalty),
          Colors.amberAccent.shade400,
        ),
        row(
          'ADDRESSES',
          Icons.place_rounded,
          () => ctrl.navigate(ViewState.addresses),
        ),
        row(
          'PAYMENT METHODS',
          Icons.wallet_rounded,
          () => ctrl.navigate(ViewState.paymentMethods),
          NexusPalette.magenta,
        ),
        row(
          'WRITE A REVIEW',
          Icons.rate_review_rounded,
          () => ctrl.navigate(
            ViewState.writeReview,
            params: {'id': featuredProducts.first.id},
          ),
        ),
        row(
          'HELP CENTER',
          Icons.help_outline_rounded,
          () => ctrl.navigate(ViewState.help),
        ),
        row(
          'SETTINGS',
          Icons.tune_rounded,
          () => ctrl.navigate(ViewState.settings),
          Colors.white70,
        ),
        const SizedBox(height: 18),
        OutlinedButton(
          onPressed: () async {
            if (!ctrl.isSignedIn) {
              ctrl.navigate(ViewState.login);
              return;
            }
            await ctrl.signOut();
            if (!context.mounted) return;
            showNexusToast(context, 'SIGNED OUT');
          },
          child: Text(
            ctrl.isSignedIn ? 'SIGN OUT' : 'SIGN IN',
            style: GoogleFonts.jetBrainsMono(fontSize: 11),
          ),
        ),
      ],
    );
  }
}

class OrdersListScreen extends StatelessWidget {
  const OrdersListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = context.read<NexusController>();
    final rows = listMockOrdersByDate();
    final muted = Theme.of(context).dividerColor.withValues(alpha: .65);

    return Column(
      children: [
        _NexusStickyHeader(
          title: 'YOUR ORDERS',
          onBack: () {
            final fromCheckout = ctrl.viewParams?['origin'] == 'checkout';
            ctrl.navigate(fromCheckout ? ViewState.home : ViewState.account);
          },
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(22, 14, 22, 112),
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemCount: rows.length,
            itemBuilder: (_, i) {
              final r = rows[i];
              final tint = _statusTint(r.status);
              return InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => ctrl.navigate(
                  ViewState.orderDetail,
                  params: {'orderId': r.id},
                ),
                child: Ink(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: muted.withValues(alpha: .5)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              r.id,
                              style: GoogleFonts.jetBrainsMono(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${r.date} · ${r.itemCount} ITEMS',
                              style: GoogleFonts.jetBrainsMono(
                                fontSize: 10,
                                letterSpacing: 2,
                                color: muted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '\$ ${r.total.toStringAsFixed(2)}',
                            style: GoogleFonts.jetBrainsMono(
                              fontWeight: FontWeight.bold,
                              color: NexusPalette.cyan,
                            ),
                          ),
                          const SizedBox(height: 6),
                          DecoratedBox(
                            decoration: BoxDecoration(
                              color: tint.withValues(alpha: .12),
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(
                                color: tint.withValues(alpha: .45),
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              child: Text(
                                r.status.name.toUpperCase(),
                                style: GoogleFonts.jetBrainsMono(
                                  fontSize: 9,
                                  letterSpacing: 2,
                                  color: tint,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 2),
                      Icon(Icons.chevron_right, color: muted),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class OrderReceiptScreen extends StatelessWidget {
  const OrderReceiptScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<NexusController>();
    final id = '${ctrl.viewParams?['orderId'] ?? ''}';
    final detail = mockOrderDetailById(id) ?? mockOrderCatalog.values.first;
    final muted = Theme.of(context).dividerColor.withValues(alpha: .65);
    final s = detail.summary;
    final hints = detail.trackingHints;

    return Column(
      children: [
        _NexusStickyHeader(
          title: 'ORDER RECEIPT',
          onBack: () => ctrl.navigate(ViewState.orders),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(22, 16, 22, 112),
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    s.id,
                    style: GoogleFonts.jetBrainsMono(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: _statusTint(s.status).withValues(alpha: .14),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      child: Text(
                        s.status.name.toUpperCase(),
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 10,
                          letterSpacing: 2,
                          color: _statusTint(s.status),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '${s.date} · ${detail.carrier ?? ''}',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 11,
                  letterSpacing: 1.2,
                  color: muted,
                ),
              ),
              if (detail.etaNote != null) ...[
                const SizedBox(height: 6),
                Text(detail.etaNote!, style: TextStyle(color: muted)),
              ],
              const SizedBox(height: 24),
              Text(
                'ITEMS',
                style: GoogleFonts.jetBrainsMono(
                  letterSpacing: 2,
                  fontSize: 11,
                ),
              ),
              const Divider(height: 24),
              ...detail.lines.map(
                (l) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 3, child: Text(l.title)),
                      Text(
                        '${l.qty}×',
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 11,
                          color: muted,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '\$ ${(l.unitPrice * l.qty).toStringAsFixed(2)}',
                        style: GoogleFonts.jetBrainsMono(
                          fontWeight: FontWeight.bold,
                          color: NexusPalette.cyan,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Divider(height: 28),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'PAID TOTAL',
                    style: GoogleFonts.jetBrainsMono(fontSize: 12),
                  ),
                  Text(
                    '\$ ${s.total.toStringAsFixed(2)}',
                    style: GoogleFonts.jetBrainsMono(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: NexusPalette.cyan,
                    ),
                  ),
                ],
              ),
              if (hints.isNotEmpty) ...[
                const SizedBox(height: 26),
                Text(
                  'TRACKING PULSE',
                  style: GoogleFonts.jetBrainsMono(
                    letterSpacing: 2,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 12),
                for (var i = 0; i < hints.length; i++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GlowDot(
                          radius: i == hints.length - 1 ? 5 : 3,
                          color: NexusPalette.magenta.withValues(
                            alpha: i == hints.length - 1 ? 1 : .5,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            '${i + 1}. ${hints[i]}',
                            style: TextStyle(color: muted, height: 1.35),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class AppSettingsScreen extends StatelessWidget {
  const AppSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<NexusController>();

    return Column(
      children: [
        _NexusStickyHeader(
          title: 'SETTINGS',
          onBack: () => ctrl.navigate(ViewState.account),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(6, 4, 6, 112),
            children: [
              SwitchListTile(
                title: Text(
                  'DARK INTERFACE',
                  style: GoogleFonts.jetBrainsMono(fontSize: 13),
                ),
                value: ctrl.isDarkTheme,
                onChanged: (_) => ctrl.toggleTheme(),
              ),
              SwitchListTile(
                title: Text(
                  'FLASH DEAL ALERTS',
                  style: GoogleFonts.jetBrainsMono(fontSize: 13),
                ),
                value: true,
                onChanged: (_) {},
              ),
              SwitchListTile(
                title: Text(
                  'SECURE DEVICE CHECKOUT',
                  style: GoogleFonts.jetBrainsMono(fontSize: 13),
                ),
                value: false,
                onChanged: (_) {},
              ),
              ListTile(
                title: Text(
                  'EMAIL DIGEST SETTINGS',
                  style: GoogleFonts.jetBrainsMono(fontSize: 11),
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => showNexusToast(context, 'PREFERENCES UPDATED'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class SavedAddressesScreen extends StatelessWidget {
  const SavedAddressesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = context.read<NexusController>();
    final muted = Theme.of(context).dividerColor.withValues(alpha: .65);

    final list = [
      (
        tag: 'DEFAULT SHIPPING',
        ln1: 'Unit 904 · Solaris Heights Tower',
        ln2: 'Neo District · NC 94108',
      ),
      (
        tag: 'SERVICE DESK DROP',
        ln1: 'Nexus Apex · Repair counter #04',
        ln2: 'Orion Mall · Level 02',
      ),
    ];

    return Column(
      children: [
        _NexusStickyHeader(
          title: 'ADDRESSES',
          onBack: () => ctrl.navigate(ViewState.account),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(22, 22, 22, 112),
            separatorBuilder: (_, _) => const SizedBox(height: 16),
            itemCount: list.length,
            itemBuilder: (_, i) {
              final item = list[i];
              return Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: muted.withValues(alpha: .5)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.tag,
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 10,
                        letterSpacing: 2,
                        color: NexusPalette.cyan,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      item.ln1,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      item.ln2,
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: muted),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () =>
                            showNexusToast(context, 'ADDRESS EDITOR OPENED'),
                        child: Text(
                          'EDIT',
                          style: GoogleFonts.jetBrainsMono(fontSize: 10),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class PaymentWalletScreen extends StatelessWidget {
  const PaymentWalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = context.read<NexusController>();
    final muted = Theme.of(context).dividerColor.withValues(alpha: .65);

    Widget cardRow(String primary, String sub, IconData ic) => Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: muted.withValues(alpha: .5)),
      ),
      child: ListTile(
        leading: Icon(ic),
        title: Text(
          primary,
          style: GoogleFonts.jetBrainsMono(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(sub),
        trailing: Icon(Icons.more_horiz, color: muted),
      ),
    );

    return Column(
      children: [
        _NexusStickyHeader(
          title: 'PAYMENTS',
          onBack: () => ctrl.navigate(ViewState.account),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(22, 20, 22, 112),
            children: [
              cardRow(
                'VISA ·••4421',
                'Primary fingerprint checkout',
                Icons.credit_card_rounded,
              ),
              cardRow(
                'Nexus Pay balance',
                '\$340.21 available',
                Icons.account_balance_wallet_outlined,
              ),
              OutlinedButton(
                onPressed: () =>
                    showNexusToast(context, 'PAYMENT SETUP STARTED'),
                child: Text(
                  '+ PAYMENT METHOD',
                  style: GoogleFonts.jetBrainsMono(fontSize: 10),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class WriteReviewSheet extends StatefulWidget {
  const WriteReviewSheet({super.key});

  @override
  State<WriteReviewSheet> createState() => _WriteReviewSheetState();
}

class _WriteReviewSheetState extends State<WriteReviewSheet> {
  int stars = 4;
  final _notes = TextEditingController();

  @override
  void dispose() {
    _notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<NexusController>();
    final product = _productForId(ctrl.viewParams?['id'] as String?);
    final muted = Theme.of(context).dividerColor.withValues(alpha: .65);

    return Column(
      children: [
        _NexusStickyHeader(
          title: 'WRITE REVIEW',
          onBack: () => ctrl.navigate(ViewState.account),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(22, 18, 22, 120),
            children: [
              Text(
                product.name,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 18),
              _capsLabel(context, muted, 'RATING'),
              Row(
                children: List.generate(
                  5,
                  (i) => GestureDetector(
                    onTap: () => setState(() => stars = i + 1),
                    child: Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: Icon(
                        i < stars
                            ? Icons.star_rounded
                            : Icons.star_border_rounded,
                        color: i < stars
                            ? NexusPalette.magenta
                            : Colors.white24,
                        size: 30,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _notes,
                maxLines: 5,
                decoration: const InputDecoration(
                  hintText: 'Thermals · noise · performance?',
                ),
              ),
              const SizedBox(height: 24),
              GradientRgbButton(
                onPressed: () {
                  showNexusToast(context, 'REVIEW SUBMITTED — THANKS');
                  ctrl.navigate(ViewState.account);
                },
                child: const Text('SUBMIT REVIEW'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class BranchLocatorScreen extends StatelessWidget {
  const BranchLocatorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = context.read<NexusController>();
    final muted = Theme.of(context).dividerColor.withValues(alpha: .65);

    final spots = [
      ('Nexus Central Flagship', '2.4 km · open until 21:00'),
      ('Solaris Pop-up Lounge', '6.9 km · custom demos'),
      ('Orion Repair Bar', '3.8 km · bench consult'),
    ];

    return Column(
      children: [
        _NexusStickyHeader(
          title: 'STORE MAP',
          onBack: () => ctrl.navigate(ViewState.more),
        ),
        Expanded(
          child: Column(
            children: [
              Expanded(
                flex: 3,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 8),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(22),
                      gradient: RadialGradient(
                        center: const Alignment(.1, -.55),
                        radius: 1.15,
                        colors: [
                          NexusPalette.cyan.withValues(alpha: .32),
                          Theme.of(context).colorScheme.surface,
                        ],
                      ),
                      border: Border.all(color: muted.withValues(alpha: .55)),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.location_on_rounded,
                        size: 84,
                        color: muted,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(22, 0, 22, 112),
                  itemCount: spots.length,
                  itemBuilder: (_, i) {
                    final pair = spots[i];
                    final title = pair.$1;
                    final sub = pair.$2;
                    return ListTile(
                      leading: GlowDot(
                        color: NexusPalette.violet.withValues(alpha: .9),
                      ),
                      title: Text(title, style: GoogleFonts.jetBrainsMono()),
                      subtitle: Text(sub, style: TextStyle(color: muted)),
                      trailing: TextButton(
                        onPressed: () =>
                            showNexusToast(context, 'DIRECTIONS UPDATED'),
                        child: Text('GO', style: GoogleFonts.jetBrainsMono()),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class NearbyAvailabilityScreen extends StatelessWidget {
  const NearbyAvailabilityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = context.read<NexusController>();
    final muted = Theme.of(context).dividerColor.withValues(alpha: .65);

    return Column(
      children: [
        _NexusStickyHeader(
          title: 'NEARBY STOCK',
          onBack: () => ctrl.navigate(ViewState.more),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(22, 12, 22, 112),
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: ['ALL', 'GPU', 'LAPTOP', 'PSU'].map((t) {
                  return Chip(
                    label: Text(
                      t,
                      style: GoogleFonts.jetBrainsMono(fontSize: 10),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              ...featuredProducts
                  .take(8)
                  .map(
                    (p) => Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: muted.withValues(alpha: .5)),
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: SizedBox(
                              width: 64,
                              height: 64,
                              child: NexusNetworkImage(
                                imageUrl: p.image,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(p.name),
                                const SizedBox(height: 8),
                                Text(
                                  '${3 + (p.id.hashCode % 8)} IN SHELF HOLD',
                                  style: GoogleFonts.jetBrainsMono(
                                    fontSize: 9,
                                    letterSpacing: 2,
                                    color: NexusPalette.cyan,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          TextButton(
                            onPressed: () => ctrl.navigate(
                              ViewState.product,
                              params: {'id': p.id},
                            ),
                            child: Text(
                              'VIEW',
                              style: GoogleFonts.jetBrainsMono(),
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
  }
}

class PromotionsHubScreen extends StatelessWidget {
  const PromotionsHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _PromotionsExperience();
  }
}

class OldPromotionsHubScreen extends StatelessWidget {
  const OldPromotionsHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = context.read<NexusController>();
    final muted = Theme.of(context).dividerColor.withValues(alpha: .65);

    final promos = [
      ('-18% PSU BUNDLES', 'Stacks with cashback this weekend.'),
      ('\$240 READY RIG CREDIT', 'Zero-interest window through June.'),
      ('REPAIR FAST PASS', '\$79 · concierge bench queue.'),
    ];

    return Column(
      children: [
        _NexusStickyHeader(
          title: 'PROMOS',
          onBack: () => ctrl.navigate(ViewState.more),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(22, 18, 22, 112),
            separatorBuilder: (_, _) => const SizedBox(height: 16),
            itemCount: promos.length,
            itemBuilder: (_, i) {
              final row = promos[i];
              return InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap: () => ctrl.navigate(ViewState.category),
                child: BorderGradientPanel(
                  radius: 17,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          row.$1,
                          style: GoogleFonts.jetBrainsMono(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          row.$2,
                          style: Theme.of(
                            context,
                          ).textTheme.bodyMedium?.copyWith(color: muted),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'REDEEM',
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 10,
                            letterSpacing: 3,
                            color: NexusPalette.cyan,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _PromotionsExperience extends StatelessWidget {
  const _PromotionsExperience();

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<NexusController>();
    final muted = Theme.of(context).dividerColor.withValues(alpha: .65);
    final surface = Theme.of(context).colorScheme.surface;

    final coupons = [
      (
        code: 'NEXUS10',
        title: '10% off carts',
        description: 'Up to \$250 off ready rigs and configured laptops.',
        expires: 'ENDS JUN 30',
      ),
      (
        code: 'UPGRADE75',
        title: '\$75 upgrade credit',
        description: 'Valid on carts over \$799 with parts or labor.',
        expires: 'LIMITED DROP',
      ),
      (
        code: 'FASTPASS',
        title: 'Repair fast pass',
        description: 'Adds priority queue flag during service booking.',
        expires: 'SERVICE PERK',
      ),
    ];

    final bundles = [
      (
        title: 'Streaming Creator Kit',
        detail: 'Blade 16 + dock + capture card',
        price: '\$2,149',
        save: 'SAVE \$310',
        icon: Icons.video_camera_front_outlined,
      ),
      (
        title: 'Thermal Refresh Pack',
        detail: 'Repaste + fans + dust service',
        price: '\$129',
        save: 'BUNDLE -22%',
        icon: Icons.device_thermostat_rounded,
      ),
    ];

    Future<void> copyCoupon(String code) async {
      await Clipboard.setData(ClipboardData(text: code));
      if (!context.mounted) return;
      showNexusToast(context, '$code copied');
    }

    return Column(
      children: [
        _NexusStickyHeader(
          title: 'PROMOS',
          onBack: () => ctrl.navigate(ViewState.more),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(22, 18, 22, 112),
            children: [
              BorderGradientPanel(
                radius: 22,
                child: Padding(
                  padding: const EdgeInsets.all(22),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'FEATURED CAMPAIGN',
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 10,
                          letterSpacing: 2,
                          color: muted,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Weekend Upgrade Drop',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'GPU, PSU, and cooling bundles with same-day bench install.',
                        style: Theme.of(
                          context,
                        ).textTheme.bodyMedium?.copyWith(color: muted),
                      ),
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => copyCoupon('UPGRADE75'),
                              icon: const Icon(Icons.copy_rounded, size: 17),
                              label: Text(
                                'UPGRADE75',
                                style: GoogleFonts.jetBrainsMono(fontSize: 11),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: GradientRgbButton(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 12,
                              ),
                              onPressed: () {
                                ctrl.applyCoupon('UPGRADE75');
                                showNexusToast(context, 'COUPON READY');
                                ctrl.navigate(ViewState.cart);
                              },
                              child: const Text('APPLY'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _capsLabel(context, muted, 'COUPONS'),
              ...coupons.map(
                (coupon) => Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: surface.withValues(alpha: .82),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: muted.withValues(alpha: .45)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 54,
                        height: 54,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          color: NexusPalette.cyan.withValues(alpha: .11),
                          border: Border.all(
                            color: NexusPalette.cyan.withValues(alpha: .45),
                          ),
                        ),
                        child: const Icon(
                          Icons.confirmation_number_outlined,
                          color: NexusPalette.cyan,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              coupon.title,
                              style: GoogleFonts.jetBrainsMono(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              coupon.description,
                              style: Theme.of(
                                context,
                              ).textTheme.bodySmall?.copyWith(color: muted),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${coupon.code} - ${coupon.expires}',
                              style: GoogleFonts.jetBrainsMono(
                                fontSize: 9,
                                letterSpacing: 1.3,
                                color: NexusPalette.magenta,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: 'Copy coupon',
                        onPressed: () => copyCoupon(coupon.code),
                        icon: const Icon(Icons.copy_rounded),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              _capsLabel(context, muted, 'FEATURED DEALS'),
              ...featuredProducts.map(
                (product) => Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: muted.withValues(alpha: .45)),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () => ctrl.navigate(
                      ViewState.product,
                      params: {'id': product.id},
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AspectRatio(
                          aspectRatio: 16 / 7,
                          child: NexusNetworkImage(
                            imageUrl: product.image,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      product.name,
                                      style: GoogleFonts.jetBrainsMono(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      'Promo price from \$${(product.price * .92).toStringAsFixed(2)}',
                                      style: TextStyle(color: muted),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.chevron_right_rounded),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              _capsLabel(context, muted, 'BUNDLES'),
              ...bundles.map(
                (bundle) => Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    gradient: LinearGradient(
                      colors: [
                        NexusPalette.violet.withValues(alpha: .17),
                        surface.withValues(alpha: .9),
                      ],
                    ),
                    border: Border.all(color: muted.withValues(alpha: .45)),
                  ),
                  child: Row(
                    children: [
                      Icon(bundle.icon, color: NexusPalette.cyan, size: 30),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              bundle.title,
                              style: GoogleFonts.jetBrainsMono(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              bundle.detail,
                              style: Theme.of(
                                context,
                              ).textTheme.bodySmall?.copyWith(color: muted),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            bundle.price,
                            style: GoogleFonts.jetBrainsMono(
                              color: NexusPalette.cyan,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            bundle.save,
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 9,
                              color: NexusPalette.magenta,
                            ),
                          ),
                        ],
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
  }
}

class RepairBookingScreen extends StatefulWidget {
  const RepairBookingScreen({super.key});

  @override
  State<RepairBookingScreen> createState() => _RepairBookingExperienceState();
}

class _RepairBookingExperienceState extends State<RepairBookingScreen> {
  final _modelController = TextEditingController(text: 'ROG Strix G16');
  final _serialController = TextEditingController(text: 'NX-G16-4492');
  final _notesController = TextEditingController();
  String device = 'Gaming Laptop';
  String service = 'Repair diagnostic';
  String priority = 'Standard';
  DateTime selectedDate = DateTime(2026, 6, 10);
  String selectedTime = '14:00';

  static const _devices = [
    'Gaming Laptop',
    'Creator Station',
    'Handheld',
    'Custom loop rig',
  ];
  static const _services = [
    'Repair diagnostic',
    'Performance upgrade',
    'Thermal cleaning',
    'Data migration',
  ];
  static const _times = ['10:00', '12:30', '14:00', '16:30'];

  @override
  void dispose() {
    _modelController.dispose();
    _serialController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  double get _estimatedFee {
    final base = switch (service) {
      'Performance upgrade' => 79.0,
      'Thermal cleaning' => 39.0,
      'Data migration' => 59.0,
      _ => 49.0,
    };
    return base + (priority == 'Rush' ? 30 : 0);
  }

  void _submit(NexusController ctrl) {
    if (_modelController.text.trim().isEmpty) {
      showNexusToast(context, 'DEVICE MODEL REQUIRED');
      return;
    }
    final stamp = DateTime.now().millisecondsSinceEpoch.toString();
    ctrl.createBookingTicket(
      BookingTicket(
        ticketId: 'RT-${stamp.substring(stamp.length - 6)}',
        deviceType: device,
        deviceModel: _modelController.text.trim(),
        serialNumber: _serialController.text.trim().isEmpty
            ? 'Not provided'
            : _serialController.text.trim(),
        serviceType: service,
        serviceNotes: _notesController.text.trim().isEmpty
            ? 'Bench team will confirm symptoms at intake.'
            : _notesController.text.trim(),
        slot: selectedDate,
        timeSlot: selectedTime,
        priority: priority,
        estimatedFee: _estimatedFee,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = context.read<NexusController>();
    final muted = Theme.of(context).dividerColor.withValues(alpha: .65);

    return Column(
      children: [
        _NexusStickyHeader(
          title: 'BOOK REPAIR',
          onBack: () => ctrl.navigate(ViewState.more),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(22, 16, 22, 120),
            children: [
              _capsLabel(context, muted, 'DEVICE'),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(),
                initialValue: device,
                items: _devices
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) => setState(() => device = v ?? device),
              ),
              const SizedBox(height: 18),
              _capsLabel(context, muted, 'MODEL'),
              TextField(
                controller: _modelController,
                decoration: const InputDecoration(
                  hintText: 'Device brand and model',
                  prefixIcon: Icon(Icons.devices_other_rounded),
                ),
              ),
              const SizedBox(height: 18),
              _capsLabel(context, muted, 'SERIAL'),
              TextField(
                controller: _serialController,
                decoration: const InputDecoration(
                  hintText: 'Serial number or asset tag',
                  prefixIcon: Icon(Icons.qr_code_2_rounded),
                ),
              ),
              const SizedBox(height: 18),
              _capsLabel(context, muted, 'SERVICE'),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _services.map((option) {
                  final active = service == option;
                  return ChoiceChip(
                    selected: active,
                    label: Text(
                      option,
                      style: GoogleFonts.jetBrainsMono(fontSize: 10),
                    ),
                    selectedColor: NexusPalette.cyan.withValues(alpha: .16),
                    side: BorderSide(
                      color: active
                          ? NexusPalette.cyan
                          : muted.withValues(alpha: .55),
                    ),
                    onSelected: (_) => setState(() => service = option),
                  );
                }).toList(),
              ),
              const SizedBox(height: 18),
              _capsLabel(context, muted, 'SERVICE DETAILS'),
              TextField(
                controller: _notesController,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: 'Symptoms, upgrade target, warranty notes',
                ),
              ),
              const SizedBox(height: 18),
              _capsLabel(context, muted, 'DATE'),
              Row(
                children: List.generate(3, (index) {
                  final day = DateTime(2026, 6, 10 + index);
                  final active =
                      selectedDate.year == day.year &&
                      selectedDate.month == day.month &&
                      selectedDate.day == day.day;
                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(right: index == 2 ? 0 : 8),
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: active ? NexusPalette.cyan : null,
                          side: BorderSide(
                            color: active
                                ? NexusPalette.cyan
                                : muted.withValues(alpha: .55),
                          ),
                        ),
                        onPressed: () => setState(() => selectedDate = day),
                        child: Text(
                          'JUN ${day.day}',
                          style: GoogleFonts.jetBrainsMono(fontSize: 11),
                        ),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 18),
              _capsLabel(context, muted, 'TIME SLOT'),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _times.map((time) {
                  final active = selectedTime == time;
                  return ChoiceChip(
                    selected: active,
                    label: Text(
                      time,
                      style: GoogleFonts.jetBrainsMono(fontSize: 10),
                    ),
                    selectedColor: NexusPalette.magenta.withValues(alpha: .16),
                    side: BorderSide(
                      color: active
                          ? NexusPalette.magenta
                          : muted.withValues(alpha: .55),
                    ),
                    onSelected: (_) => setState(() => selectedTime = time),
                  );
                }).toList(),
              ),
              const SizedBox(height: 18),
              _capsLabel(context, muted, 'PRIORITY'),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  'Rush queue (+\$30)',
                  style: GoogleFonts.jetBrainsMono(fontSize: 12),
                ),
                subtitle: Text(
                  'Moves intake to the next available bench slot.',
                  style: TextStyle(color: muted),
                ),
                value: priority == 'Rush',
                onChanged: (value) =>
                    setState(() => priority = value ? 'Rush' : 'Standard'),
              ),
              const Divider(height: 28),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('ESTIMATED INTAKE', style: TextStyle(color: muted)),
                  Text(
                    '\$ ${_estimatedFee.toStringAsFixed(2)}',
                    style: GoogleFonts.jetBrainsMono(
                      color: NexusPalette.cyan,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              GradientRgbButton(
                onPressed: () => _submit(ctrl),
                child: const Text('LOCK SLOT'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class BookingConfirmationScreen extends StatelessWidget {
  const BookingConfirmationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<NexusController>();
    final ticket = ctrl.lastBookingTicket;
    final muted = Theme.of(context).dividerColor.withValues(alpha: .65);
    final dateText = ticket == null
        ? 'Pending'
        : 'Jun ${ticket.slot.day}, ${ticket.timeSlot} local';

    Widget row(String label, String value) => Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: GoogleFonts.jetBrainsMono(
                fontSize: 10,
                color: muted,
                letterSpacing: 1.4,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );

    return Column(
      children: [
        _NexusStickyHeader(
          title: 'BOOKING TICKET',
          onBack: () => ctrl.navigate(ViewState.more),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(22, 18, 22, 112),
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
                            Icons.build_circle_outlined,
                            color: NexusPalette.cyan,
                            size: 34,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              ticket?.ticketId ?? 'RT-DEMO',
                              style: GoogleFonts.jetBrainsMono(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      row('DEVICE', ticket?.deviceType ?? 'Device'),
                      row('MODEL', ticket?.deviceModel ?? 'Model pending'),
                      row('SERIAL', ticket?.serialNumber ?? 'Not provided'),
                      row('SERVICE', ticket?.serviceType ?? 'Diagnostic'),
                      row('SLOT', dateText),
                      row('PRIORITY', ticket?.priority ?? 'Standard'),
                      row(
                        'ESTIMATE',
                        '\$ ${(ticket?.estimatedFee ?? 0).toStringAsFixed(2)}',
                      ),
                      const Divider(height: 26),
                      Text(
                        ticket?.serviceNotes ??
                            'Bench team will confirm symptoms at intake.',
                        style: Theme.of(
                          context,
                        ).textTheme.bodyMedium?.copyWith(color: muted),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),
              GradientRgbButton(
                onPressed: () => ctrl.navigate(ViewState.repairTracker),
                child: const Text('TRACK SERVICE'),
              ),
              const SizedBox(height: 10),
              OutlinedButton(
                onPressed: () => ctrl.navigate(ViewState.booking),
                child: Text(
                  'BOOK ANOTHER DEVICE',
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

class LegacyRepairBookingScreenState extends State<RepairBookingScreen> {
  String device = 'Gaming Laptop';
  DateTime slot = DateTime(2026, 6, 1, 14);

  @override
  Widget build(BuildContext context) {
    final ctrl = context.read<NexusController>();
    final muted = Theme.of(context).dividerColor.withValues(alpha: .65);

    return Column(
      children: [
        _NexusStickyHeader(
          title: 'BOOK REPAIR',
          onBack: () => ctrl.navigate(ViewState.more),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(22, 16, 22, 120),
            children: [
              _capsLabel(context, muted, 'DEVICE'),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(),
                initialValue: device,
                items:
                    [
                          'Gaming Laptop',
                          'Creator Station',
                          'Handheld',
                          'Custom loop rig',
                        ]
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                onChanged: (v) => setState(() => device = v ?? device),
              ),
              const SizedBox(height: 18),
              _capsLabel(context, muted, 'TECH NOTES'),
              TextField(
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Symptoms · warranty window · BIOS tweaks…',
                ),
              ),
              const SizedBox(height: 18),
              _capsLabel(context, muted, 'DROP-OFF'),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  '${slot.month}/${slot.day} · ${slot.hour}:00 LOCAL',
                  style: GoogleFonts.jetBrainsMono(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  'Tap arrow to iterate day (demo)',
                  style: TextStyle(color: muted),
                ),
                trailing: IconButton(
                  icon: Icon(Icons.calendar_month_outlined, color: muted),
                  onPressed: () =>
                      setState(() => slot = slot.add(const Duration(days: 1))),
                ),
              ),
              const SizedBox(height: 22),
              GradientRgbButton(
                onPressed: () {
                  showNexusToast(context, 'SERVICE REQUEST CONFIRMED');
                  ctrl.navigate(ViewState.repairTracker);
                },
                child: const Text('LOCK SLOT'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class TechChatScreen extends StatefulWidget {
  const TechChatScreen({super.key});

  @override
  State<TechChatScreen> createState() => _TechChatScreenState();
}

class _Msg {
  _Msg({required this.fromUser, required this.text});
  final bool fromUser;
  final String text;
}

class _TechChatScreenState extends State<TechChatScreen> {
  final ctrlText = TextEditingController();
  final msgs = <_Msg>[
    _Msg(
      fromUser: false,
      text: 'Hi Hex · need PSU math for dual-GPU workstation?',
    ),
    _Msg(fromUser: true, text: '7800X3D · 4090 Strix OC · light OC only.'),
    _Msg(
      fromUser: false,
      text: 'Shoot for RM1000x class. Sending bundle link.',
    ),
  ];

  @override
  void dispose() {
    ctrlText.dispose();
    super.dispose();
  }

  void _send(BuildContext ctx) {
    final v = ctrlText.text.trim();
    if (v.isEmpty) return;
    setState(() => msgs.add(_Msg(fromUser: true, text: v)));
    ctrlText.clear();
  }

  @override
  Widget build(BuildContext context) {
    final store = context.read<NexusController>();
    final bottomPad =
        MediaQuery.paddingOf(context).bottom +
        MediaQuery.viewInsetsOf(context).bottom;

    return Column(
      children: [
        _NexusStickyHeader(
          title: 'TECH SUPPORT',
          onBack: () => store.navigate(ViewState.more),
        ),
        Expanded(
          child: ListView.builder(
            reverse: true,
            padding: const EdgeInsets.fromLTRB(22, 12, 22, 8),
            itemCount: msgs.length,
            itemBuilder: (_, i) {
              final m = msgs[msgs.length - 1 - i];
              final align = m.fromUser
                  ? Alignment.centerRight
                  : Alignment.centerLeft;
              final bubble = BorderRadius.circular(14).copyWith(
                bottomRight: m.fromUser
                    ? const Radius.circular(3)
                    : const Radius.circular(14),
                bottomLeft: !m.fromUser
                    ? const Radius.circular(3)
                    : const Radius.circular(14),
              );
              final maxW = MediaQuery.sizeOf(context).width * .78;

              return Align(
                alignment: align,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  constraints: BoxConstraints(maxWidth: maxW),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: bubble,
                    color: m.fromUser
                        ? NexusPalette.cyan.withValues(alpha: .18)
                        : Theme.of(context).colorScheme.surfaceContainerHighest
                              .withValues(alpha: .45),
                  ),
                  child: Text(m.text, style: const TextStyle(height: 1.32)),
                ),
              );
            },
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(16, 6, 16, 112 + bottomPad),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: ctrlText,
                  decoration: InputDecoration(hintText: 'Message Nexus…'),
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _send(context),
                ),
              ),
              IconButton(
                onPressed: () => _send(context),
                icon: const Icon(Icons.send_rounded),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class CommunityReviewsScreen extends StatelessWidget {
  const CommunityReviewsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = context.read<NexusController>();

    Widget card(String handle, double stars, String sku, String body) =>
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Theme.of(context).dividerColor.withValues(alpha: .45),
              ),
            ),
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        handle,
                        style: GoogleFonts.jetBrainsMono(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Text(
                      '★'.padRight(stars.round(), '★').padRight(5, '☆'),
                      style: TextStyle(
                        fontSize: 12,
                        color: NexusPalette.magenta,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(body),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () =>
                      ctrl.navigate(ViewState.product, params: {'id': sku}),
                  child: Text(
                    'SKU',
                    style: GoogleFonts.jetBrainsMono(fontSize: 10),
                  ),
                ),
              ],
            ),
          ),
        );

    return Column(
      children: [
        _NexusStickyHeader(
          title: 'REVIEWS',
          onBack: () => ctrl.navigate(ViewState.more),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(22, 18, 22, 112),
            children: [
              card(
                'NebulaFam',
                5,
                'p1',
                'Creator X9 melts through Blender with fans barely spinning.',
              ),
              card(
                'TRAVEL OPS',
                4,
                'p2',
                'Blade 16 survives red-eye installs; mini-LED is chef kiss.',
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class ShowcaseMediaScreen extends StatelessWidget {
  const ShowcaseMediaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = context.read<NexusController>();

    return Column(
      children: [
        _NexusStickyHeader(
          title: 'SHOWCASE',
          onBack: () => ctrl.navigate(ViewState.more),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(22, 18, 22, 112),
            itemCount: featuredProducts.length + 1,
            itemBuilder: (_, i) {
              if (i == featuredProducts.length) {
                return ListTile(
                  leading: GlowDot(color: NexusPalette.cyan),
                  title: Text(
                    'LIVE PODCAST RIG',
                    style: GoogleFonts.jetBrainsMono(),
                  ),
                  subtitle: Text('Neo Central sunday stream tap-in'),
                  trailing: const Icon(Icons.play_circle_fill_rounded),
                );
              }
              final p = featuredProducts[i];
              return Padding(
                padding: const EdgeInsets.only(bottom: 18),
                child: InkWell(
                  onTap: () =>
                      ctrl.navigate(ViewState.product, params: {'id': p.id}),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        NexusNetworkImage(imageUrl: p.image, fit: BoxFit.cover),
                        DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.black.withValues(alpha: .72),
                                Colors.transparent,
                              ],
                              begin: Alignment.bottomCenter,
                              end: Alignment.center,
                            ),
                          ),
                        ),
                        Positioned(
                          left: 16,
                          bottom: 14,
                          right: 16,
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  '${p.category.toUpperCase()} REEL',
                                  style: GoogleFonts.jetBrainsMono(
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                              const Icon(Icons.play_arrow_rounded, size: 36),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class RepairTimelineScreen extends StatelessWidget {
  const RepairTimelineScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = context.read<NexusController>();
    final muted = Theme.of(context).dividerColor.withValues(alpha: .65);

    final steps = [
      ('Intake QA scan', true),
      ('Bench thermals graphed', true),
      ('Customer bench sign-off', false),
      ('Pickup kiosk ready', false),
    ];

    return Column(
      children: [
        _NexusStickyHeader(
          title: 'REPAIR TRACK',
          onBack: () => ctrl.navigate(ViewState.more),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(22, 20, 22, 112),
            children: [
              BorderGradientPanel(
                radius: 18,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'RT-88412 · GPU HYBRID SWAP',
                        style: GoogleFonts.jetBrainsMono(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Bench lead: Mara · SLA 36h',
                        style: TextStyle(color: muted),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 28),
              for (var i = 0; i < steps.length; i++)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: steps[i].$2
                                ? NexusPalette.cyan
                                : Colors.transparent,
                            border: Border.all(color: muted, width: 1.8),
                          ),
                        ),
                        if (i != steps.length - 1)
                          Container(
                            width: 1,
                            height: 46,
                            color: muted.withValues(alpha: .35),
                          ),
                      ],
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(
                          bottom: i == steps.length - 1 ? 0 : 16,
                        ),
                        child: Text(
                          steps[i].$1,
                          style: TextStyle(
                            fontWeight: steps[i].$2
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: steps[i].$2 ? Colors.white : muted,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              OutlinedButton(
                onPressed: () => ctrl.navigate(ViewState.chat),
                child: Text('OPEN CHAT', style: GoogleFonts.jetBrainsMono()),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class LoyaltyHubScreen extends StatelessWidget {
  const LoyaltyHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = context.read<NexusController>();
    final muted = Theme.of(context).dividerColor.withValues(alpha: .65);

    return Column(
      children: [
        _NexusStickyHeader(
          title: 'REWARDS',
          onBack: () => ctrl.navigate(ViewState.account),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(22, 18, 22, 112),
            children: [
              BorderGradientPanel(
                radius: 20,
                child: Padding(
                  padding: const EdgeInsets.all(22),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '12,482 PTS',
                        style: GoogleFonts.jetBrainsMono(
                          fontWeight: FontWeight.bold,
                          fontSize: 30,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Neon tier · \$50 voucher unlocked @ 13k pts.',
                        style: TextStyle(color: muted),
                      ),
                      const SizedBox(height: 18),
                      LinearProgressIndicator(
                        value: .72,
                        minHeight: 8,
                        backgroundColor: Colors.white.withValues(alpha: .12),
                      ),
                    ],
                  ),
                ),
              ),
              ListTile(
                leading: GlowDot(color: Colors.amberAccent.shade400),
                title: Text(
                  'Redeem perk drops',
                  style: GoogleFonts.jetBrainsMono(),
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => showNexusToast(context, 'REWARDS OPENED'),
              ),
              ListTile(
                leading: GlowDot(color: NexusPalette.magenta),
                title: Text(
                  'Refer a builder buddy',
                  style: GoogleFonts.jetBrainsMono(fontSize: 12),
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => ctrl.navigate(ViewState.more),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class HelpDeskScreen extends StatelessWidget {
  const HelpDeskScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = context.read<NexusController>();
    final faqs = [
      (
        'HOW DO RETURNS WORK?',
        '15-day untouched gear window + restock fee waived for defects.',
      ),
      (
        'BUILD SYNC?',
        'We flash BIOS profiles + chipset drivers prior to courier pickup.',
      ),
      (
        'WARRANTY TIERS?',
        'NexusCare extends accidental + advanced swap lockers.',
      ),
    ];

    return Column(
      children: [
        _NexusStickyHeader(
          title: 'HELP',
          onBack: () => ctrl.navigate(ViewState.account),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(8, 4, 8, 112),
            itemCount: faqs.length,
            itemBuilder: (_, i) {
              final q = faqs[i].$1;
              final a = faqs[i].$2;
              return ExpansionTile(
                title: Text(q, style: GoogleFonts.jetBrainsMono(fontSize: 12)),
                childrenPadding: const EdgeInsets.fromLTRB(26, 0, 26, 12),
                children: [Text(a)],
              );
            },
          ),
        ),
      ],
    );
  }
}
