import 'package:computer_shop_app/app.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows home screen', (WidgetTester tester) async {
    await tester.pumpWidget(const ComputerShopApp());
    await tester.pumpAndSettle();

    expect(find.text('Computer Shop'), findsOneWidget);
    expect(find.text('Build Your Dream Rig'), findsOneWidget);
    expect(find.text('Builder'), findsOneWidget);
  });
}
