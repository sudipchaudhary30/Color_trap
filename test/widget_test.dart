import 'package:flutter_test/flutter_test.dart';

import 'package:color_tap/main.dart';

void main() {
  testWidgets('App shows Color Tap home title', (WidgetTester tester) async {
    await tester.pumpWidget(const ColorTapApp());

    expect(find.text('COLOR'), findsOneWidget);
    expect(find.text('TAP'), findsOneWidget);
  });
}
