import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class LocationService {
  /// Returns the device position, or null if location services are off or
  /// permission was denied. Callers keep the previously stored location in
  /// that case.
  static Future<Position?> getCurrentPosition() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return null;

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return null;
    }

    return Geolocator.getCurrentPosition(
      locationSettings:
          const LocationSettings(accuracy: LocationAccuracy.medium),
    );
  }

  /// Reverse-geocodes coordinates into a human-friendly "City, Country" label,
  /// or null if no place name is available (e.g. offline). Falls back through
  /// locality → district → state when the city is unknown.
  static Future<String?> describeCoordinates(double lat, double lng) async {
    try {
      final placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isEmpty) return null;
      final p = placemarks.first;

      String? notEmpty(String? s) =>
          (s != null && s.trim().isNotEmpty) ? s.trim() : null;

      final place = notEmpty(p.locality) ??
          notEmpty(p.subAdministrativeArea) ??
          notEmpty(p.administrativeArea);
      final country = notEmpty(p.country);

      if (place != null && country != null) return '$place, $country';
      return place ?? country;
    } catch (_) {
      return null;
    }
  }
}
