import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:firebase_database/firebase_database.dart';

class LocationService {
  static Future<Map<String, dynamic>?> getLocationAndAddress() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    LocationPermission permission = await Geolocator.checkPermission();

    if (!serviceEnabled || permission == LocationPermission.deniedForever) {
      return null;
    }

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return null;
      }
    }

    final position = await Geolocator.getCurrentPosition();
    final placemarks = await placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );

    final place = placemarks.first;
    final fullAddress =
        "${place.street}, ${place.locality}, ${place.postalCode}, ${place.country}";

    return {
      'position': position,
      'address': fullAddress,
    };
  }

  static Future<void> saveParkingLocation() async {
    final result = await getLocationAndAddress();
    if (result == null) throw Exception("Location not available");

    final position = result['position'] as Position;
    final address = result['address'] as String;

    final db = FirebaseDatabase.instance.ref('parking_locations');

    await db.push().set({
      'latitude': position.latitude,
      'longitude': position.longitude,
      'address': address,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }
}
