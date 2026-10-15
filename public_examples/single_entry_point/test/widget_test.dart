import 'package:flutter_test/flutter_test.dart';

import 'package:single_entry_point/main.dart';

void main() {
  testWidgets('Tabs switch between host and IA SDK screens', (WidgetTester tester) async {
    await tester.pumpWidget(const ExampleApp());

    expect(find.text('This is the host app home screen.'), findsOneWidget);

    await tester.tap(find.text('IA SDK'));
    await tester.pumpAndSettle();

    expect(find.text('Launch IA SDK'), findsOneWidget);
  });
}
