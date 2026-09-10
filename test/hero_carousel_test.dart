import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:localgo/core/widgets/collapsing_detail_header.dart';

void main() {
  const twoImages = [
    'https://res.cloudinary.com/egzlojgo/image/upload/v1789065269/citybee/unsorted/rpvqh47yzgmx5b5zakhv.webp',
    'https://res.cloudinary.com/egzlojgo/image/upload/v1789065272/citybee/unsorted/hpqzfey0w4b7tonv6kn7.webp',
  ];

  Widget buildHero(
          {required List<String> images, ValueChanged<int>? onPageChanged}) =>
      MaterialApp(
        home: Scaffold(
          body: CustomScrollView(
            slivers: [
              CollapsingDetailHeader(
                title: 'Testing Hotel',
                image: images.first,
                imageList: images,
                onPageChanged: onPageChanged,
                onShareTap: () {},
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 800)),
            ],
          ),
        ),
      );

  testWidgets('multi-image hero: carousel swipes both ways (not stuck)',
      (tester) async {
    var currentPage = 0;
    await tester.pumpWidget(buildHero(
      images: twoImages,
      onPageChanged: (i) => currentPage = i,
    ));
    await tester.pumpAndSettle();

    final pageView = find.byType(PageView);
    expect(pageView, findsOneWidget);

    // Fling left (velocity drives the page change even mid-image-load).
    await tester.fling(pageView, const Offset(-500, 0), 2000,
        warnIfMissed: false);
    await tester.pumpAndSettle();
    expect(currentPage, 1, reason: 'fling left should reach page 2');

    await tester.fling(
        pageView, const Offset(500, 0), 2000, warnIfMissed: false);
    await tester.pumpAndSettle();
    expect(currentPage, 0, reason: 'fling right should return to page 1');
  });

  testWidgets('single image: no PageView, plain hero renders',
      (tester) async {
    await tester.pumpWidget(buildHero(images: [twoImages.first]));
    await tester.pumpAndSettle();
    expect(find.byType(PageView), findsNothing);
  });
}
