import 'package:url_launcher/url_launcher.dart';

/// External-app actions (calls, WhatsApp, maps, websites) with user-friendly
/// failure handling. Raw exceptions are never surfaced to the user.
abstract final class AppLauncher {
  static Future<void> _open(Uri uri, {LaunchMode mode = LaunchMode.externalApplication}) async {
    try {
      await launchUrl(uri, mode: mode);
    } catch (_) {
      // Silently ignore — callers show a snackbar when the launch reports
      // failure via the boolean wrappers below.
    }
  }

  static Future<bool> call(String phone) async {
    // Strip spaces/brackets so tel: URIs stay valid on every device.
    final normalized = phone.replaceAll(RegExp(r'[\s()\-\u2013\u2014]'), '');
    final uri = Uri(scheme: 'tel', path: normalized);
    final ok = await canLaunchUrl(uri);
    if (ok) await _open(uri);
    return ok;
  }

  /// Normalizes a phone number to the wa.me format:
  /// `+91 98765 43210` → `919876543210`.
  static String normalizeWhatsAppNumber(String raw) {
    var digits = raw.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.startsWith('00')) digits = digits.substring(2);
    // Bare 10-digit local numbers default to the India country code.
    if (digits.length == 10) digits = '91$digits';
    return digits;
  }

  /// Opens WhatsApp at [number] with an optional prefilled [message].
  ///
  /// Falls back to web WhatsApp in the browser when the app isn't
  /// installed; returns false only when neither can open.
  static Future<bool> whatsapp(String number, {String message = ''}) async {
    final normalized = normalizeWhatsAppNumber(number);
    if (normalized.isEmpty) return false;

    final appUri = Uri.parse(
      'https://wa.me/$normalized'
      '${message.isEmpty ? '' : '?text=${Uri.encodeComponent(message)}'}',
    );

    // wa.me links resolve to the WhatsApp app when installed.
    if (await canLaunchUrl(appUri)) {
      await _open(appUri);
      return true;
    }

    // Fallback: the same URL opens web WhatsApp in the browser.
    try {
      await launchUrl(appUri, mode: LaunchMode.platformDefault);
      return true;
    } catch (_) {
      return false;
    }
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

  /// Opens the mail client pre-filled for support conversations.
  static Future<bool> email(String address, {String subject = ''}) async {
    final uri = Uri(
      scheme: 'mailto',
      path: address,
      query: subject.isEmpty ? null : 'subject=${Uri.encodeComponent(subject)}',
    );
    final ok = await canLaunchUrl(uri);
    if (ok) await _open(uri);
    return ok;
  }
}
