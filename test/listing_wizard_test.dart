import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:localgo/domain/models/app_category.dart';
import 'package:localgo/features/listings/presentation/list_business_screen.dart';
import 'package:localgo/providers/app_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _SignedIn extends AuthController {
  @override
  bool build() => true;
}

void main() {
  testWidgets(
    'details enable Continue immediately, including with keyboard open',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetViewInsets);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authStateProvider.overrideWith(_SignedIn.new),
            categoriesProvider.overrideWith(
              (_) async => [
                const AppCategory(
                  id: 'hotel',
                  name: 'Hotels',
                  listingTitle: 'Hotels',
                ),
              ],
            ),
          ],
          child: const MaterialApp(home: ListBusinessScreen()),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Hotels'));
      await tester.pump();
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();
      final button = find.widgetWithText(FilledButton, 'Continue');
      expect(tester.widget<FilledButton>(button).onPressed, isNull);
      await tester.enterText(find.byType(TextField).at(0), 'Test Hotel');
      await tester.enterText(find.byType(TextField).at(3), '9876543210');
      tester.view.viewInsets = const FakeViewPadding(bottom: 300);
      await tester.pumpAndSettle();
      expect(tester.widget<FilledButton>(button).onPressed, isNotNull);
      expect(tester.getBottomRight(button).dy, lessThanOrEqualTo(544));
      await tester.tap(button);
      await tester.pumpAndSettle();
      expect(find.text('Business Address *'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
