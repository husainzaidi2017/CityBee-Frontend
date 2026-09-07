import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../utils/app_launcher.dart';

/// Stylized map preview rendered with CustomPaint for the mock-data phase.
///
/// Architecture note: this is the single map surface used by detail and
/// listing screens. When the Google Maps key is configured, replace the
/// painter here with a `GoogleMap` widget — no screen changes required.
class MapPreview extends StatelessWidget {
  const MapPreview({
    super.key,
    required this.latitude,
    required this.longitude,
    this.height = 170,
    this.pinLabel,
    this.showOpenMap = true,
  });

  final double latitude;
  final double longitude;
  final double height;
  final String? pinLabel;

  /// Renders the "Open Map ↗" pill overlay.
  final bool showOpenMap;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: SizedBox(
        height: height,
        child: Stack(
          fit: StackFit.expand,
          children: [
            CustomPaint(
              painter: _StylizedMapPainter(seed: latitude + longitude),
            ),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.location_on, color: AppColors.brandRed, size: 34),
                  if (pinLabel != null)
                    Container(
                      margin: const EdgeInsets.only(top: 2),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(999),
                        boxShadow: const [
                          BoxShadow(color: Color(0x22000000), blurRadius: 8),
                        ],
                      ),
                      child: Text(
                        pinLabel!,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            if (showOpenMap)
              Positioned(
                right: 10,
                bottom: 10,
                child: GestureDetector(
                  onTap: () => AppLauncher.directions(latitude, longitude, label: pinLabel),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(999),
                      boxShadow: const [
                        BoxShadow(color: Color(0x2E000000), blurRadius: 10, offset: Offset(0, 3)),
                      ],
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.map_outlined, size: 14, color: AppColors.primary),
                        SizedBox(width: 5),
                        Text(
                          'Open Map',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                          ),
                        ),
                        SizedBox(width: 3),
                        Icon(Icons.open_in_new, size: 11, color: AppColors.primary),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Paints a light map-like canvas: park blocks, minor streets, two main
/// roads and a diagonal highway. Deterministic per [seed].
class _StylizedMapPainter extends CustomPainter {
  _StylizedMapPainter({required this.seed});

  final double seed;

  @override
  void paint(Canvas canvas, Size size) {
    final bg = Paint()..color = AppColors.mapCanvas;
    canvas.drawRect(Offset.zero & size, bg);

    final rng = math.Random(seed.round());

    // Park / water blocks.
    final blockPaint = Paint()
      ..color = const Color(0xFFDDEBDD).withValues(alpha: 0.9);
    final waterPaint = Paint()..color = const Color(0xFFD6E6EE);
    for (var i = 0; i < 5; i++) {
      final rect = Rect.fromLTWH(
        rng.nextDouble() * size.width,
        rng.nextDouble() * size.height,
        30 + rng.nextDouble() * 70,
        24 + rng.nextDouble() * 50,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(8)),
        i.isEven ? blockPaint : waterPaint,
      );
    }

    // Minor streets grid.
    final minor = Paint()
      ..color = AppColors.mapRoadMinor
      ..strokeWidth = 3;
    for (var x = 20.0; x < size.width; x += 44) {
      canvas.drawLine(Offset(x, 0), Offset(x + 8, size.height), minor);
    }
    for (var y = 18.0; y < size.height; y += 38) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y - 6), minor);
    }

    // Main roads (white, wider).
    final main = Paint()
      ..color = AppColors.mapRoad
      ..strokeWidth = 7
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(-10, size.height * 0.62), Offset(size.width + 10, size.height * 0.5), main);
    canvas.drawLine(Offset(size.width * 0.3, -10), Offset(size.width * 0.44, size.height + 10), main);

    // Highway.
    final highway = Paint()
      ..color = const Color(0xFFFCE9C8)
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(-10, size.height * 0.16), Offset(size.width + 10, size.height * 0.34), highway);
  }

  @override
  bool shouldRepaint(covariant _StylizedMapPainter oldDelegate) => oldDelegate.seed != seed;
}
