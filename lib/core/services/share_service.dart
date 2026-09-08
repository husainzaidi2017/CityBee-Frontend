import 'package:share_plus/share_plus.dart';

import '../constants/app_config.dart';
import '../../domain/models/business.dart';
import '../../domain/models/offer.dart';
import '../../domain/models/place.dart';

/// Builds share messages dynamically from the current detail object and
/// hands them to the native Android share sheet (WhatsApp, Gmail, Telegram,
/// Messages, copy-to-clipboard, …).
///
/// Every message ends with the CityBee signature + app link.
abstract final class ShareService {
  static const String _signature =
      'Discover local businesses, doctors, restaurants, offers and more on ${AppConfig.appName}.\n'
      '${AppConfig.appName}: ${AppConfig.appUrl}';

  static Future<void> shareBusiness(Business business) {
    final lines = [
      business.name,
      business.tagline,
      '📍 ${business.address}',
      if (business.phone.isNotEmpty) '📞 ${business.phone}',
    ];
    return _share(lines.join('\n'));
  }

  static Future<void> shareOffer(Offer offer) {
    final lines = [
      offer.title,
      '${offer.badgeText} ${offer.subtitle}',
      '📅 ${offer.validityText}',
      '📍 ${offer.area} · ${offer.distanceText}',
    ];
    return _share(lines.join('\n'));
  }

  static Future<void> sharePlace(Place place) {
    final lines = [
      place.name,
      if (place.address.isNotEmpty) '📍 ${place.address}',
      if (place.timings.isNotEmpty) '🕒 ${place.timings}',
      place.description,
    ];
    return _share(lines.join('\n'));
  }

  static Future<void> shareApp({String note = ''}) {
    return _share([
      if (note.isNotEmpty) note,
      _signature,
    ].join('\n'));
  }

  static Future<void> _share(String body) => Share.share('$body\n\n$_signature');
}
