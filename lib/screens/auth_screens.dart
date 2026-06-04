import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/view_state.dart';
import '../state/nexus_controller.dart';
import '../theme/nexus_fonts.dart';
import '../theme/nexus_palette.dart';
import '../widgets/ui_kit.dart';

class AuthBackground extends StatelessWidget {
  const AuthBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFF0B0E15)
        : Theme.of(context).colorScheme.surface;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: const Alignment(.1, -.7),
          radius: 1.2,
          colors: [
            Theme.of(context).brightness == Brightness.dark
                ? NexusPalette.cyan.withValues(alpha: .12)
                : NexusPalette.cyan.withValues(alpha: .08),
            base,
          ],
        ),
      ),
      child: child,
    );
  }
}

class OnboardingCarousel extends StatefulWidget {
  const OnboardingCarousel({super.key, required this.controller});

  final NexusController controller;

  @override
  State<OnboardingCarousel> createState() => _OnboardingCarouselState();
}

class _SlideSpec {
  _SlideSpec({
    required this.title,
    required this.body,
    required this.icon,
    required this.color,
  });

  final String title;
  final String body;
  final IconData icon;
  final Color color;
}

class _OnboardingCarouselState extends State<OnboardingCarousel> {
  final steps = [
    _SlideSpec(
      title: 'BUILD WITHOUT LIMITS',
      body: 'Configure your dream PC with our real-time compatibility checker.',
      color: NexusPalette.cyan,
      icon: Icons.memory_rounded,
    ),
    _SlideSpec(
      title: 'SHOP THE LATEST',
      body: 'RTX 4090s, mechanical decks, and pro audio gear in stock.',
      color: NexusPalette.magenta,
      icon: Icons.tv_rounded,
    ),
    _SlideSpec(
      title: 'WE FIX. WE UPGRADE.',
      body: 'Book repairs and track them in real time from your phone.',
      color: NexusPalette.violet,
      icon: Icons.build_rounded,
    ),
  ];

  int step = 0;

  @override
  Widget build(BuildContext context) {
    final slide = steps[step];
    return AuthBackground(
      child: SafeArea(
        child: Stack(
          children: [
            Positioned(
              top: 0,
              right: 12,
              child: TextButton(
                onPressed: () => unawaited(widget.controller.skipOnboarding()),
                child: Text(
                  'SKIP',
                  style: GoogleFonts.jetBrainsMono(fontSize: 11),
                ),
              ),
            ),
            Positioned.fill(
              child: LayoutBuilder(
                builder: (context, constraints) => SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(24, 52, 24, 36),
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 260),
                          child: Column(
                            key: ValueKey(step),
                            children: [
                              Container(
                                width: 132,
                                height: 132,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: slide.color.withValues(alpha: .4),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      blurRadius: 24,
                                      color: slide.color.withValues(alpha: .25),
                                    ),
                                  ],
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.surface.withValues(alpha: 0.7),
                                ),
                                child: Icon(
                                  slide.icon,
                                  size: 48,
                                  color: slide.color,
                                ),
                              ),
                              const SizedBox(height: 24),
                              GradientTitle(
                                slide.title,
                                style: Theme.of(
                                  context,
                                ).textTheme.titleLarge!.copyWith(fontSize: 22),
                              ),
                              const SizedBox(height: 14),
                              Text(
                                slide.body,
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      height: 1.35,
                                      color: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.color
                                          ?.withValues(alpha: .75),
                                    ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 40),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(3, (i) {
                            final active = step == i;
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 260),
                              width: active ? 24 : 8,
                              height: 8,
                              margin: const EdgeInsets.symmetric(horizontal: 6),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: active
                                    ? slide.color
                                    : Theme.of(context).dividerColor,
                                boxShadow: active
                                    ? [
                                        BoxShadow(
                                          blurRadius: 14,
                                          color: slide.color.withValues(
                                            alpha: .36,
                                          ),
                                        ),
                                      ]
                                    : null,
                              ),
                            );
                          }),
                        ),
                        const SizedBox(height: 36),
                        GradientRgbButton(
                          onPressed: () async {
                            if (step == 2) {
                              await widget.controller.finishOnboarding();
                            } else {
                              setState(() => step += 1);
                            }
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(step == 2 ? 'GET STARTED' : 'NEXT'),
                              const SizedBox(width: 6),
                              const Icon(Icons.chevron_right),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool obscure = true;
  bool loading = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final store = context.read<NexusController>();
    final muted = Theme.of(context).dividerColor.withValues(alpha: .6);
    return AuthBackground(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.fromLTRB(24, 96, 24, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _brandMark(context),
            const SizedBox(height: 12),
            const Align(
              alignment: Alignment.center,
              child: GradientTitle('NEXUS', style: TextStyle(fontSize: 26)),
            ),
            const SizedBox(height: 8),
            Text(
              'WELCOME BACK',
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: muted),
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(hintText: 'Email Address'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _password,
              obscureText: obscure,
              decoration: InputDecoration(
                hintText: 'Password',
                suffixIcon: IconButton(
                  onPressed: () => setState(() => obscure = !obscure),
                  icon: Icon(obscure ? Icons.visibility : Icons.visibility_off),
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => store.navigate(ViewState.forgotPassword),
                child: Text(
                  'FORGOT PASSWORD?',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 10,
                    color: NexusPalette.cyan,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            GradientRgbButton(
              onPressed: () async {
                setState(() => loading = true);
                await Future<void>.delayed(const Duration(milliseconds: 1200));
                if (!context.mounted) return;
                setState(() => loading = false);
                showNexusToast(context, 'SIGNED IN');
                store.navigate(ViewState.home);
              },
              child: loading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('SIGN IN'),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(child: Divider(color: muted)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text(
                    'OR CONTINUE WITH',
                    style: GoogleFonts.jetBrainsMono(fontSize: 9, color: muted),
                  ),
                ),
                Expanded(child: Divider(color: muted)),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () =>
                        showNexusToast(context, 'GOOGLE SSO — DEMO BUILD'),
                    child: Text(
                      'GOOGLE',
                      style: GoogleFonts.jetBrainsMono(fontSize: 11),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () =>
                        showNexusToast(context, 'APPLE SSO — DEMO BUILD'),
                    child: Text(
                      'APPLE',
                      style: GoogleFonts.jetBrainsMono(fontSize: 11),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('NEW HERE? ', style: TextStyle(color: muted)),
                TextButton(
                  onPressed: () => store.navigate(ViewState.signup),
                  child: Text(
                    'CREATE ACCOUNT',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 11,
                      color: NexusPalette.cyan,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _brandMark(BuildContext context) {
    return Center(
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: const LinearGradient(
            colors: [
              NexusPalette.cyan,
              NexusPalette.magenta,
              NexusPalette.violet,
            ],
          ),
          boxShadow: [
            BoxShadow(
              blurRadius: 18,
              color: NexusPalette.cyan.withValues(alpha: .25),
            ),
          ],
        ),
        padding: const EdgeInsets.all(1),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(11),
            color: Theme.of(context).scaffoldBackgroundColor,
          ),
          child: const Icon(Icons.memory, color: NexusPalette.cyan),
        ),
      ),
    );
  }
}

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool obscure = true;
  bool loading = false;

  int get strength {
    final p = _password.text;
    if (p.isEmpty) return 0;
    if (p.length < 6) return 1;
    if (p.length < 10) return 2;
    return 3;
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final store = context.read<NexusController>();
    final muted = Theme.of(context).dividerColor.withValues(alpha: .6);
    return AuthBackground(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.fromLTRB(24, 56, 24, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                onPressed: () => store.navigate(ViewState.login),
                icon: const Icon(Icons.chevron_left),
              ),
            ),
            const SizedBox(height: 8),
            const GradientTitle(
              'CREATE ACCOUNT',
              style: TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 6),
            Text('JOIN THE NEXUS', style: TextStyle(color: muted)),
            const SizedBox(height: 24),
            TextField(
              controller: _name,
              decoration: const InputDecoration(hintText: 'Full Name'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(hintText: 'Email Address'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _password,
              obscureText: obscure,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Password',
                suffixIcon: IconButton(
                  onPressed: () => setState(() => obscure = !obscure),
                  icon: Icon(obscure ? Icons.visibility : Icons.visibility_off),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: List.generate(
                3,
                (i) => Expanded(
                  child: Container(
                    height: 4,
                    margin: EdgeInsets.only(right: i == 2 ? 0 : 6),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      color: strength > i
                          ? (strength >= 3 && i == 2
                                ? NexusPalette.magenta
                                : NexusPalette.cyan)
                          : Theme.of(context).dividerColor,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 18),
            GradientRgbButton(
              onPressed: () async {
                setState(() => loading = true);
                await Future<void>.delayed(const Duration(milliseconds: 1500));
                if (!context.mounted) return;
                setState(() => loading = false);
                showNexusToast(context, 'WELCOME TO NEXUS');
                store.navigate(ViewState.home);
              },
              child: loading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('SIGN UP'),
            ),
          ],
        ),
      ),
    );
  }
}

class ForgotScreen extends StatelessWidget {
  const ForgotScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.read<NexusController>();
    return AuthBackground(
      child: SafeArea(
        child: LayoutBuilder(
          builder: (context, c) => SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.fromLTRB(24, 56, 24, 28),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: c.maxHeight),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    alignment: Alignment.centerLeft,
                    onPressed: () => store.navigate(ViewState.login),
                    icon: const Icon(Icons.chevron_left),
                  ),
                  const SizedBox(height: 12),
                  const GradientTitle(
                    'RESET ACCESS',
                    style: TextStyle(fontSize: 22),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'We will email magic instructions (mock)',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(
                        context,
                      ).dividerColor.withValues(alpha: .7),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const TextField(
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(hintText: 'Email Address'),
                  ),
                  const SizedBox(height: 20),
                  GradientRgbButton(
                    onPressed: () {
                      showNexusToast(context, 'RESET LINK — CHECK INBOX');
                      store.navigate(ViewState.login);
                    },
                    child: const Text('SUBMIT'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
