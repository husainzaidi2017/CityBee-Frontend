import 'package:geolocator/geolocator.dart';

import '../errors/app_exception.dart';
import '../../domain/models/city.dart';

/// Wraps Geolocator behind an app-level service so permission handling and
/// errors stay out of widgets and can be faked in tests.
class LocationService {
  const LocationService();

  /// Returns the device position, or null when permission is denied.
  ///
  /// Throws [LocationPermissionException] when permission is permanently
  /// denied so the UI can route users to settings / manual city selection.
  Future<Position?> getCurrentPosition() async {
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    switch (permission) {
      case LocationPermission.denied:
      case LocationPermission.deniedForever:
      case LocationPermission.unableToDetermine:
        return null;
      case LocationPermission.whileInUse:
      case LocationPermission.always:
        break;
    }
    try {
      return await Geolocator.getCurrentPosition();
    } catch (_) {
      throw const NetworkException();
    }
  }

  /// Picks the closest known city to [position] (reverse geocoding is not
  /// needed at mock-data scale; PostGIS handles this server-side later).
  City? nearestCity(Position position, List<City> cities) {
    City? best;
    var bestDistance = double.infinity;
    for (final city in cities) {
      final distance = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        city.latitude,
        city.longitude,
      );
      if (distance < bestDistance) {
        bestDistance = distance;
        best = city;
      }
    }
    // Beyond 120 km, none of the known cities is a sensible default.
    return best != null && bestDistance < 120000 ? best : null;
  }
}
