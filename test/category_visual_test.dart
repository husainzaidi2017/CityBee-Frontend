import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:localgo/features/home/presentation/widgets/category_visual.dart';

void main() {
  test('Live API category slugs have distinct illustrations', () {
    const ids = [
      'fashion',
      'shops',
      'restaurants',
      'doctors',
      'hotel',
      'heritages',
      'salons',
      'malls',
      'cinemas',
      'gyms',
      'bars',
      'cafes',
    ];
    final assets = ids.map((id) => CategoryVisual.of(id).icon).toSet();
    expect(assets.length, ids.length);
    // Legacy slug forms resolve to the same assets as their live versions.
    expect(CategoryVisual.of('barber').icon, CategoryVisual.of('salons').icon);
    expect(CategoryVisual.of('gym').icon, CategoryVisual.of('gyms').icon);
    expect(CategoryVisual.of('hotels').icon, CategoryVisual.of('hotel').icon);
    expect(CategoryVisual.of('dining').icon, CategoryVisual.of('restaurants').icon);
  });

  testWidgets('All category SVG assets load and render', (tester) async {
    const ids = [
      'fashion',
      'shops',
      'restaurants',
      'doctors',
      'hotel',
      'heritages',
      'salons',
      'malls',
      'cinemas',
      'gyms',
      'bars',
      'cafes',
      'unknown',
    ];
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Wrap(
            children: [
              for (final id in ids) CategoryIcon(visual: CategoryVisual.of(id)),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
