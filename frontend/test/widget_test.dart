import 'package:flutter_test/flutter_test.dart';

import 'package:frontend/main.dart';

void main() {
  testWidgets('Marketplace app boots', (WidgetTester tester) async {
    await tester.pumpWidget(const MarketplaceApp());

    expect(find.text('Local Marketplace Demo'), findsWidgets);
  });
}
