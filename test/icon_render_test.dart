import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:localgo/core/widgets/app_icons.dart';

/// Diagnostic: renders every icon and counts painted pixels on a 96x96
/// canvas (max 9216). Blank = broken glyph; full canvas = knockout square
/// not stripped; healthy glyphs land in between.
void main() {
  final all = <String, String>{
    'at': AppUiIcons.at, 'lock': AppUiIcons.lock_outline,
    'eye': AppUiIcons.eye_outline, 'map': AppUiIcons.map_outline,
    'back': AppUiIcons.back, 'heart': AppUiIcons.heart,
    'account': AppUiIcons.account_outline, 'store': AppUiIcons.storefront,
    'filter': AppUiIcons.tune, 'navigation': AppUiIcons.navigation,
    'plus': AppUiIcons.plus, 'bed': AppUiIcons.bed_outline,
    'tag': AppUiIcons.tag, 'location': AppUiIcons.map_marker,
    'settings': AppUiIcons.cog_outline, 'share': AppUiIcons.share,
    'close': AppUiIcons.close, 'search': AppUiIcons.magnify,
    'compass': AppUiIcons.compass_outline, 'message': AppUiIcons.message_outline,
    'phone': AppUiIcons.phone, 'mail': AppUiIcons.email_outline,
    'verified': AppUiIcons.check_decagram, 'check_circle': AppUiIcons.check_circle,
    'chevron_right': AppUiIcons.chevron_right, 'chevron_down': AppUiIcons.chevron_down,
    'clock': AppUiIcons.clock_outline, 'calendar': AppUiIcons.calendar_outline,
    'camera': AppUiIcons.camera_outline, 'edit': AppUiIcons.pencil,
    'info': AppUiIcons.information_outline, 'help': AppUiIcons.help_circle_outline,
    'logout': AppUiIcons.logout, 'gavel': AppUiIcons.gavel,
    'hospital': AppUiIcons.medical_bag, 'food': AppUiIcons.food,
    'flash': AppUiIcons.flash, 'snowflake': AppUiIcons.snowflake,
    'bug': AppUiIcons.bug_outline, 'wallet': AppUiIcons.wallet_outline,
    'gift': AppUiIcons.gift_outline, 'shield': AppUiIcons.shield_outline,
    'star': AppUiIcons.star, 'starOutline': AppUiIcons.star_outline,
    'download': AppUiIcons.open_in_new, 'bookmark': AppUiIcons.bookmark_outline,
    'city': AppUiIcons.city, 'document': AppUiIcons.file_document_outline,
    'earth': AppUiIcons.earth, 'party': AppUiIcons.party_popper,
    'silverware': AppUiIcons.silverware_fork_knife, 'handshake': AppUiIcons.handshake_outline,
  };

  for (final e in all.entries) {
    testWidgets('count ${e.key}', (tester) async {
      tester.view.physicalSize = const Size(200, 200);
      tester.view.devicePixelRatio = 1.0;
      final key = GlobalKey();
      await tester.pumpWidget(
        MaterialApp(
          home: Center(
            child: RepaintBoundary(
              key: key,
              child: Iconify(e.value, size: 96, color: Colors.black),
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 200));
      await tester.pump(const Duration(milliseconds: 200));

      final boundary =
          key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      var bytes = <int>[];
      await tester.runAsync(() async {
        final image = await boundary.toImage(pixelRatio: 1.0);
        final data = await image.toByteData();
        bytes = data!.buffer.asUint8List().toList();
      });
      int painted = 0;
      for (int i = 3; i < bytes.length; i += 4) {
        if (bytes[i] > 16) painted++;
      }
      // ignore: avoid_print
      print('PAINT ${e.key}: $painted px');
      expect(
        painted,
        allOf(greaterThan(50), lessThan(9000)),
        reason: '${e.key} painted $painted px (blank=0, full box=9216)',
      );
    });
  }
}
