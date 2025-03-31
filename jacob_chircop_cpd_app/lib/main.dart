import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:geolocator/geolocator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    MaterialApp(
      home: MainApp(),
    ),
  );
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() {
    return MainAppState();
  }
}

class MainAppState extends State<MainApp> {
  String locationMessage = "Location not available";

  // Function to determine the location
  Future<void> getLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        locationMessage = "Location services are disabled.";
      });
      return;
    }

    // Request permission
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          locationMessage = "Location permissions are denied.";
        });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        locationMessage =
            "Location permissions are permanently denied. Please enable them in settings.";
        return;
      });
    }

    // Get current location
    Position position = await Geolocator.getCurrentPosition();
    setState(() {
      locationMessage =
          "Latitude: ${position.latitude}, Longitude: ${position.longitude}";
    });
  }

  // Function to save the current parking location to Firebase Realtime Database
  Future<void> saveParkingLocation() async {
    try {
      // Get the current location
      Position position = await Geolocator.getCurrentPosition();

      // Reference to the "parking_locations" node in Realtime Database
      DatabaseReference parkingLocationsRef =
          FirebaseDatabase.instance.ref('parking_locations');

      // Save the parking location data using push().set() to create a unique record
      await parkingLocationsRef.push().set({
        'latitude': position.latitude,
        'longitude': position.longitude,
        'timestamp': DateTime.now().toIso8601String(),

      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Parking location saved successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving parking location: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Car Finder App'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(locationMessage, textAlign: TextAlign.center),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: getLocation,
              child: const Text('Get Location'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: saveParkingLocation,
              child: const Text('Save Parking Spot'),
            ),
          ],
        ),
      ),
    );
  }
}
