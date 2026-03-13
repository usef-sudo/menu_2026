import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:geolocator/geolocator.dart";

class UserLocation {
  const UserLocation({required this.latitude, required this.longitude});
  final double latitude;
  final double longitude;
}

class LocationController extends AutoDisposeAsyncNotifier<UserLocation> {
  @override
  Future<UserLocation> build() async {
    return fetch();
  }

  static const UserLocation _fallback =
      UserLocation(latitude: 31.8353, longitude: 35.6180);

  Future<UserLocation> fetch() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever) {
        return _fallback;
      }

      final bool serviceEnabled =
          await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return _fallback;
      }

      final position = await Geolocator.getCurrentPosition();
      return UserLocation(
        latitude: position.latitude,
        longitude: position.longitude,
      );
    } catch (_) {
      return _fallback;
    }
  }
}

final locationControllerProvider =
    AutoDisposeAsyncNotifierProvider<LocationController, UserLocation>(
      LocationController.new,
    );
