import 'package:computer_shop_app/app_shell.dart';
import 'package:computer_shop_app/state/nexus_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  Future<void> pumpApp(WidgetTester tester) async {
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => NexusController(prefs),
        child: const NexusFlutterApp(),
      ),
    );
  }

  testWidgets('shows onboarding on first launch', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await pumpApp(tester);

    expect(find.text('POWERING YOUR NEXT BUILD'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 1700));

    expect(find.text('BUILD WITHOUT LIMITS'), findsOneWidget);
    expect(find.text('NEXT'), findsOneWidget);
  });

  testWidgets('returning users still see onboarding in the static demo', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      NexusController.kHasSeenOnboarding: true,
    });
    await pumpApp(tester);

    await tester.pump(const Duration(milliseconds: 1700));

    expect(find.text('BUILD WITHOUT LIMITS'), findsOneWidget);
    expect(find.text('NEXT'), findsOneWidget);
  });

  testWidgets('saved session does not bypass static onboarding', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      NexusController.kHasSeenOnboarding: true,
      NexusController.kSessionName: 'Demo User',
      NexusController.kSessionEmail: 'demo@nexus.local',
    });
    await pumpApp(tester);

    await tester.pump(const Duration(milliseconds: 1700));

    expect(find.text('BUILD WITHOUT LIMITS'), findsOneWidget);
    expect(find.text('NEXT'), findsOneWidget);
  });

  testWidgets('completing onboarding persists first-launch state', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    await pumpApp(tester);
    await tester.pump(const Duration(milliseconds: 1700));

    await tester.tap(find.text('NEXT'));
    await tester.pumpAndSettle();
    expect(find.text('SHOP THE LATEST'), findsOneWidget);

    await tester.tap(find.text('NEXT'));
    await tester.pumpAndSettle();
    expect(find.text('WE FIX. WE UPGRADE.'), findsOneWidget);

    await tester.tap(find.text('GET STARTED'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool(NexusController.kHasSeenOnboarding), isTrue);
    expect(find.text('WELCOME BACK'), findsOneWidget);
  });
}
