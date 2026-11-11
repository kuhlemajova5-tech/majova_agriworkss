import 'package:geolocator/geolocator.dart';

class LocationService {
  /// Checks permissions and returns the phone's current GPS position.
  static Future<Position> getCurrentLocation() async {
    // Check whether Location/GPS is enabled on the phone.
    final bool serviceEnabled =
    await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      throw Exception(
        'Location services are disabled. Please turn on GPS and try again.',
      );
    }

    // Check the current permission.
    LocationPermission permission =
    await Geolocator.checkPermission();

    // Ask the user for permission if it has not been granted.
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.denied) {
        throw Exception(
          'Location permission was denied.',
        );
      }
    }

    // The user has permanently denied the permission.
    if (permission == LocationPermission.deniedForever) {
      throw Exception(
        'Location permission is permanently denied. '
            'Please enable it from your phone settings.',
      );
    }

    // Get the real position from the device.
    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
      ),
    );
  }

  /// Opens the application's settings page.
  static Future<bool> openAppSettings() {
    return Geolocator.openAppSettings();
  }

  /// Opens the phone's Location/GPS settings.
  static Future<bool> openLocationSettings() {
    return Geolocator.openLocationSettings();
  }
}