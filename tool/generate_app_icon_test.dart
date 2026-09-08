// Rasterizes the official CityBee mark (assets/brand/citybee_mark.svg) into
// every Android launcher-icon density. Run with:
//
//   flutter test tool/generate_app_icon_test.dart
//
// Produces:
//   mipmap-*/ic_launcher.png          legacy square icons (white background)
//   mipmap-*/ic_launcher_round.png    legacy round icons
//   mipmap-*/ic_launcher_foreground.png  adaptive-icon foreground layers
//
// The adaptive-icon background is declared in values/ic_launcher_background.xml.

import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('generate CityBee launcher icons from the official mark', () async {
    final svg = File('assets/brand/citybee_mark.svg').readAsStringSync();
    final pictureInfo = await vg.loadPicture(SvgStringLoader(svg), null);
    final picture = pictureInfo.picture;

    // SVG viewBox: 110 x 120.
    const vbW = 110.0, vbH = 120.0;

    Future<void> render({
      required int size,
      required String path,
      required double contentFraction,
      ui.Color background = const ui.Color(0x00000000),
    }) async {
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);

      if (background.a > 0) {
        canvas.drawRect(
          Offset.zero & Size(size.toDouble(), size.toDouble()),
          Paint()..color = background,
        );
      }

      // Fit the viewBox (contain) into `contentFraction` of the canvas.
      final scale = size * contentFraction / vbH;
      final dx = (size - vbW * scale) / 2;
      final dy = (size - vbH * scale) / 2;
      canvas.translate(dx, dy);
      canvas.scale(scale, scale);
      canvas.drawPicture(picture);

      final rendered = recorder.endRecording();
      final image = await rendered.toImage(size, size);
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      File(path).parent.createSync(recursive: true);
      File(path).writeAsBytesSync(bytes!.buffer.asUint8List());
    }

    const densities = <String, int>{
      'mdpi': 48,
      'hdpi': 72,
      'xhdpi': 96,
      'xxhdpi': 144,
      'xxxhdpi': 192,
    };
    // Legacy launcher sizes (px) per density.
    const legacySizes = densities;
    // Adaptive foreground sizes (108dp canvas).
    const foregroundSizes = <String, int>{
      'mdpi': 108,
      'hdpi': 162,
      'xhdpi': 216,
      'xxhdpi': 324,
      'xxxhdpi': 432,
    };

    const resRoot = 'android/app/src/main/res';

    for (final entry in legacySizes.entries) {
      final dir = '$resRoot/mipmap-${entry.key}';
      // Legacy icons: white background, mark at 82%.
      await render(
        size: entry.value,
        path: '$dir/ic_launcher.png',
        contentFraction: 0.82,
        background: const ui.Color(0xFFFFFFFF),
      );
      await render(
        size: entry.value,
        path: '$dir/ic_launcher_round.png',
        contentFraction: 0.82,
        background: const ui.Color(0xFFFFFFFF),
      );
    }

    for (final entry in foregroundSizes.entries) {
      // Adaptive foreground: transparent, mark at 60% (safe zone ≈ 61%).
      await render(
        size: entry.value,
        path: '$resRoot/mipmap-${entry.key}/ic_launcher_foreground.png',
        contentFraction: 0.60,
      );
    }

    picture.dispose();
  }, timeout: const Timeout(Duration(minutes: 2)));
}
