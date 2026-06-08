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

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key, required this.controller});

  final NexusController controller;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(
      const Duration(milliseconds: 1400),
      widget.controller.completeSplash,
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: NexusPalette.frameOuter,
      child: Stack(
        fit: StackFit.expand,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(0, -0.18),
                radius: 0.62,
                colors: [
                  NexusPalette.cyan.withValues(alpha: .13),
                  NexusPalette.frameOuter,
                ],
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                children: [
                  const Spacer(flex: 4),
                  TweenAnimationBuilder<double>(
                    duration: const Duration(milliseconds: 900),
                    curve: Curves.easeOutBack,
                    tween: Tween(begin: .72, end: 1),
                    builder: (context, scale, child) =>
                        Transform.scale(scale: scale, child: child),
                    child: Container(
                      width: 128,
                      height: 128,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: NexusPalette.darkSurface,
                        border: Border.all(
                          color: NexusPalette.cyan.withValues(alpha: .35),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: NexusPalette.cyan.withValues(alpha: .22),
                            blurRadius: 34,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.memory_rounded,
                        color: NexusPalette.cyan,
                        size: 52,
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  const GradientTitle(
                    'NEXUS',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'POWERING YOUR NEXT BUILD',
                    style: GoogleFonts.jetBrainsMono(
                      color: const Color(0xFF94A3B8),
                      fontSize: 11,
                      letterSpacing: 2.2,
                    ),
                  ),
                  const Spacer(flex: 5),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: const SizedBox(
                      width: 112,
                      child: LinearProgressIndicator(
                        minHeight: 3,
                        color: NexusPalette.cyan,
                        backgroundColor: NexusPalette.darkSurfaceLight,
                      ),
                    ),
                  ),
                  const SizedBox(height: 34),
                ],
              ),
            ),
          ),
        ],
      ),
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
  final PageController _pageController = PageController();

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
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _next() async {
    if (step == steps.length - 1) {
      await widget.controller.finishOnboarding();
      return;
    }

    await _pageController.nextPage(
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final slide = steps[step];
    return AuthBackground(
      child: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(top: 4, right: 12),
                child: TextButton(
                  onPressed: () =>
                      unawaited(widget.controller.skipOnboarding()),
                  child: Text(
                    'SKIP',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: steps.length,
                onPageChanged: (index) => setState(() => step = index),
                itemBuilder: (context, index) {
                  final item = steps[index];
                  return LayoutBuilder(
                    builder: (context, constraints) => SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 136,
                              height: 136,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: item.color.withValues(alpha: .34),
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    blurRadius: 28,
                                    color: item.color.withValues(alpha: .2),
                                  ),
                                ],
                                color: NexusPalette.darkSurface.withValues(
                                  alpha: .88,
                                ),
                              ),
                              child: Icon(
                                item.icon,
                                size: 48,
                                color: item.color,
                              ),
                            ),
                            const SizedBox(height: 28),
                            GradientTitle(
                              item.title,
                              style: Theme.of(
                                context,
                              ).textTheme.titleLarge!.copyWith(fontSize: 22),
                            ),
                            const SizedBox(height: 14),
                            ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 330),
                              child: Text(
                                item.body,
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      height: 1.45,
                                      color: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.color
                                          ?.withValues(alpha: .82),
                                    ),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(steps.length, (i) {
                final active = step == i;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 260),
                  width: active ? 24 : 8,
                  height: 7,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: active ? slide.color : NexusPalette.darkSurfaceLight,
                    boxShadow: active
                        ? [
                            BoxShadow(
                              blurRadius: 12,
                              color: slide.color.withValues(alpha: .36),
                            ),
                          ]
                        : null,
                  ),
                );
              }),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 30, 24, 28),
              child: GradientRgbButton(
                onPressed: _next,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(step == steps.length - 1 ? 'GET STARTED' : 'NEXT'),
                    const SizedBox(width: 6),
                    const Icon(Icons.chevron_right),
                  ],
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
                await store.signIn(
                  email: _email.text,
                  password: _password.text,
                );
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
                    onPressed: () async {
                      await store.signIn(
                        email: 'google.demo@nexus.local',
                        password: 'sso',
                      );
                      if (!context.mounted) return;
                      showNexusToast(context, 'GOOGLE SSO - DEMO BUILD');
                      store.navigate(ViewState.home);
                    },
                    child: Text(
                      'GOOGLE',
                      style: GoogleFonts.jetBrainsMono(fontSize: 11),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () async {
                      await store.signIn(
                        email: 'apple.demo@nexus.local',
                        password: 'sso',
                      );
                      if (!context.mounted) return;
                      showNexusToast(context, 'APPLE SSO - DEMO BUILD');
                      store.navigate(ViewState.home);
                    },
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
                await store.register(
                  name: _name.text,
                  email: _email.text,
                  password: _password.text,
                );
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
// Auth