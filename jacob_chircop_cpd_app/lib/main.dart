import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:io' show Platform;

// Initialize notification plugin
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
  const initSettings = InitializationSettings(android: androidInit);
  await flutterLocalNotificationsPlugin.initialize(initSettings);

  if (Platform.isAndroid) {
    await NotificationHelper.requestPermission();
  }

  runApp(const MaterialApp(home: MainApp()));
}

class NotificationHelper {
  static Future<void> requestPermission() async {
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidImplementation != null) {
      await androidImplementation.requestNotificationsPermission();
    }
  }
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

  Future<void> getLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    LocationPermission permission = await Geolocator.checkPermission();

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
      });
      return;
    }

    // Get current location
    Position position = await Geolocator.getCurrentPosition();
    setState(() {
      locationMessage =
          "Latitude: ${position.latitude}, Longitude: ${position.longitude}";
    });
  }

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
        SnackBar(content: Text('Error saving location: $e')),
      );
    }
  }

  Future<void> showDelayedReminder(int minutes) async {
    final androidDetails = AndroidNotificationDetails(
      'parking_channel',
      'Parking Reminder',
      channelDescription: 'Reminder to check your parking meter',
      importance: Importance.max,
      priority: Priority.high,
    );

    await Future.delayed(Duration(minutes: minutes));

    await flutterLocalNotificationsPlugin.show(
      0,
      'Parking Meter Reminder',
      'Your parking might be expiring now!',
      NotificationDetails(android: androidDetails),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Car Finder App'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
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
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => showDelayedReminder(1),
                child: const Text('Set Reminder (1 min)'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
