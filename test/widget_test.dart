import 'package:computer_shop_app/app_shell.dart';
import 'package:computer_shop_app/state/nexus_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('shows Nexus home shell', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => NexusController(prefs),
        child: const NexusFlutterApp(),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('NEXUS'), findsWidgets);
    expect(find.text('HOME'), findsWidgets);
  });
}
