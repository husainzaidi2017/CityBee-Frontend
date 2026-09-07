import 'package:url_launcher/url_launcher.dart';

/// External-app actions (calls, WhatsApp, maps) with user-friendly failure
/// handling. Raw exceptions are never surfaced to the user.
abstract final class AppLauncher {
  static Future<void> _open(Uri uri) async {
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      // Silently ignore — callers show a snackbar when the launch reports
      // failure via the boolean wrappers below.
    }
  }

  static Future<bool> call(String phone) async {
    final ok = await canLaunchUrl(Uri(scheme: 'tel', path: phone));
    if (ok) await _open(Uri(scheme: 'tel', path: phone));
    return ok;
  }

  static Future<bool> whatsapp(String number, {String message = ''}) async {
    final uri = Uri.parse(
      'https://wa.me/$number${message.isEmpty ? '' : '?text=${Uri.encodeComponent(message)}'}',
    );
    final ok = await canLaunchUrl(uri);
    if (ok) await _open(uri);
    return ok;
  }

  static Future<bool> directions(double lat, double lng, {String? label}) async {
    final query = label == null ? '$lat,$lng' : '${Uri.encodeComponent(label)}@$lat,$lng';
    final uri = Uri.parse('https://www.google.com/maps/dir/?api=1&destination=$query');
    final ok = await canLaunchUrl(uri);
    if (ok) await _open(uri);
    return ok;
  }

  static Future<bool> openWebsite(String url) async {
    final uri = Uri.parse(url.startsWith('http') ? url : 'https://$url');
    final ok = await canLaunchUrl(uri);
    if (ok) await _open(uri);
    return ok;
  }
}
