import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localgo/app.dart';

void main() {
  testWidgets('App boots and renders the Home tab', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: LocalGoApp()));

    // Pump past the mock repository delays (200–250 ms each); fixed pumps
    // instead of pumpAndSettle because loading spinners animate forever.
    await tester.pump(const Duration(seconds: 2));

    // Home screen sections are present.
    expect(find.text('Explore Near You'), findsOneWidget);
    expect(find.text('Offers Near You'), findsOneWidget);
    expect(find.text('Popular Near You'), findsOneWidget);

    // Bottom navigation tabs.
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Offers'), findsOneWidget);
    expect(find.text('Services'), findsOneWidget);
    expect(find.text('Explore'), findsOneWidget);
    expect(find.text('More'), findsOneWidget);
  });
}
