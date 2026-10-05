import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class LocationResult {
  final double lat;
  final double lng;
  final String address;

  LocationResult({
    required this.lat,
    required this.lng,
    required this.address,
  });
}

class LocationHelper {
  /// Location mil gayi to LocationResult, nahi mili to null
  static Future<LocationResult?> getCurrent() async {
    // GPS on hai ya nahi
    final enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) return null;

    // permission
    LocationPermission perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
    }
    if (perm == LocationPermission.denied ||
        perm == LocationPermission.deniedForever) {
      return null;
    }

    final pos = await Geolocator.getCurrentPosition();

    // lat/long se address (internet chahiye, na ho to default text)
    String address = 'Address nahi mila';
    try {
      final Geocoding geocoding = Geocoding(); // naye version me object banta hai
      final List<Placemark> list =
      await geocoding.placemarkFromCoordinates(pos.latitude, pos.longitude);

      if (list.isNotEmpty) {
        final p = list.first;
        final parts = <String?>[
          p.street,
          p.subLocality,
          p.locality,
          p.administrativeArea,
          p.postalCode,
        ].where((e) => e != null && e.trim().isNotEmpty).toList();

        if (parts.isNotEmpty) address = parts.join(', ');
      }
    } catch (_) {}

    return LocationResult(
      lat: pos.latitude,
      lng: pos.longitude,
      address: address,
    );
  }
}