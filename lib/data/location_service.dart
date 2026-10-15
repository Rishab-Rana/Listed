import 'package:geolocator/geolocator.dart';

class LocationService {
  // Shared by every instance, for this running app process only.
  // Cache null too: a denied permission must not trigger repeated prompts.
  static Future<Position?>? _sessionLocation;

  Future<Position?> getCurrentLocation() {
    return _sessionLocation ??= _requestLocation();
  }

  Future<Position?> _requestLocation() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) return null;

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return null;
      }

      return await Geolocator.getCurrentPosition().timeout(
        const Duration(seconds: 20),
      );
    } catch (_) {
      // Location is optional. Disabled GPS, timeouts and permission changes
      // should not prevent Home from opening.
      return null;
    }
  }
}
