import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

/// Why resolving the current location failed — the UI maps this to a localized
/// message (see `LocaleKeys.location*`).
enum LocationError { serviceDisabled, permissionDenied, permissionDeniedForever, unknown }

/// A resolved current location: coordinates plus the address parts pulled from
/// reverse geocoding. Fields are best-effort — any may be empty depending on
/// what the geocoder returns for the area.
class ResolvedPlace {
  const ResolvedPlace({
    required this.lat,
    required this.lng,
    this.city = '',
    this.area = '',
    this.line1 = '',
    this.postCode = '',
  });

  final double lat;
  final double lng;
  final String city;
  final String area;
  final String line1;
  final String postCode;

  /// Short one-line label for the "Deliver to" header.
  String get label {
    final parts = [area, city].where((p) => p.trim().isNotEmpty);
    return parts.isEmpty ? line1 : parts.join(', ');
  }
}

/// Outcome of [LocationService.resolveCurrentPlace].
sealed class LocationResult {
  const LocationResult();
}

class LocationSuccess extends LocationResult {
  const LocationSuccess(this.place);
  final ResolvedPlace place;
}

class LocationFailure extends LocationResult {
  const LocationFailure(this.error);
  final LocationError error;
}

/// Wraps geolocator (permissions + GPS fix) and geocoding (reverse geocode)
/// behind one call. Registered as a singleton so the whole app shares it.
class LocationService {
  const LocationService();

  /// Ensures location services + permission, gets a fix, then reverse-geocodes
  /// it. Never throws — returns a [LocationFailure] with a reason instead.
  Future<LocationResult> resolveCurrentPlace() async {
    final permission = await _ensurePermission();
    if (permission != null) return LocationFailure(permission);

    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );
      final place = await _reverseGeocode(position.latitude, position.longitude);
      return LocationSuccess(place);
    } catch (_) {
      return const LocationFailure(LocationError.unknown);
    }
  }

  /// Checks the service is on and permission is granted, requesting it if
  /// needed. Returns null on success, or the blocking [LocationError].
  Future<LocationError?> _ensurePermission() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      return LocationError.serviceDisabled;
    }
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever) {
      return LocationError.permissionDeniedForever;
    }
    if (permission == LocationPermission.denied) {
      return LocationError.permissionDenied;
    }
    return null;
  }

  /// Reverse-geocode an arbitrary point (e.g. a spot the user tapped on the
  /// map). Never throws — returns coordinates only if geocoding fails.
  Future<ResolvedPlace> reverseGeocode(double lat, double lng) =>
      _reverseGeocode(lat, lng);

  Future<ResolvedPlace> _reverseGeocode(double lat, double lng) async {
    try {
      final marks = await placemarkFromCoordinates(lat, lng);
      if (marks.isEmpty) return ResolvedPlace(lat: lat, lng: lng);
      final p = marks.first;
      return ResolvedPlace(
        lat: lat,
        lng: lng,
        city: p.locality ?? p.administrativeArea ?? '',
        area: p.subLocality ?? p.subAdministrativeArea ?? '',
        line1: [p.street, p.name]
            .where((s) => s != null && s.trim().isNotEmpty)
            .toSet()
            .join(', '),
        postCode: p.postalCode ?? '',
      );
    } catch (_) {
      // Geocoding can fail offline; still return the coordinates.
      return ResolvedPlace(lat: lat, lng: lng);
    }
  }
}
