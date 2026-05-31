import 'package:flutter_test/flutter_test.dart';

import 'package:buspass/main.dart';

void main() {
  testWidgets('Home screen shows main actions', (WidgetTester tester) async {
    await tester.pumpWidget(const SmartBusPassApp());

    expect(find.text('Android Smart Bus Pass App'), findsOneWidget);
    expect(find.text('Create / Renew Bus Pass'), findsOneWidget);
    expect(find.text('View My Bus Pass'), findsOneWidget);
    expect(find.text('Scan / Validate Pass'), findsOneWidget);
  });
}
