import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:io' show Platform;
import 'notification_helper.dart';
import 'saved_locations_screen.dart';
import 'location_service.dart';
import 'map_widget.dart';

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

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => MainAppState();
}

class MainAppState extends State<MainApp> {
  Position? location;
  String address = "Address not available";
  String coordinates = "Location not available";

  @override
  void initState() {
    super.initState();
    _getLocationAndAddress();
  }

  Future<void> _getLocationAndAddress() async {
    try {
      final result = await LocationService.getLocationAndAddress();
      if (result == null) {
        setState(() {
          coordinates = "Location not available or permission denied.";
          address = "Address not available";
        });
        return;
      }

      final pos = result['position'] as Position;
      final addr = result['address'] as String;

      setState(() {
        location = pos;
        address = addr;
        coordinates = "Latitude: ${pos.latitude}, Longitude: ${pos.longitude}";
      });
    } catch (e) {
      setState(() {
        coordinates = "Error: $e";
      });
    }
  }

  Future<void> saveParkingLocation() async {
    try {
      await LocationService.saveParkingLocation();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Parking location saved successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving location: $e')),
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(address, textAlign: TextAlign.center),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      coordinates,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  IconButton(
                    onPressed: _getLocationAndAddress,
                    icon: const Icon(Icons.refresh),
                    tooltip: 'Reload Location',
                  ),
                ],
              ),
              const SizedBox(height: 20),
              if (location != null)
                MapWidget(
                  latitude: location!.latitude,
                  longitude: location!.longitude,
                ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: saveParkingLocation,
                child: const Text('Save Parking Spot'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SavedLocationsScreen(),
                    ),
                  );
                },
                child: const Text('View Saved Spots'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
