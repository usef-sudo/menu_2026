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

  Future<UserLocation> fetch() async {
    final permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      await Geolocator.requestPermission();
    }

    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return const UserLocation(latitude: 31.8353, longitude: 35.6180);
    }

    final position = await Geolocator.getCurrentPosition();
    return UserLocation(
      latitude: position.latitude,
      longitude: position.longitude,
    );
  }
}

final locationControllerProvider =
    AutoDisposeAsyncNotifierProvider<LocationController, UserLocation>(
      LocationController.new,
    );
