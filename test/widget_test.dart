import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:localgo/app.dart';

void main() {
  testWidgets('App boots through splash and renders the Home tab',
      (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: CityBeeApp()));

    // Splash shows the brand + tagline first.
    expect(find.text("Discover What's Around You"), findsOneWidget);

    // Advance past the splash hold (~700 ms) so navigation to Home runs.
    await tester.pump(const Duration(milliseconds: 900));
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
