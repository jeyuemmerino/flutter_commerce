import 'package:flutter_test/flutter_test.dart';

import 'package:frontend/main.dart';

void main() {
  testWidgets('Marketplace app boots', (WidgetTester tester) async {
    await tester.pumpWidget(const CommerceApp());

    expect(find.text('Marketplace Demo'), findsWidgets);
  });
}
