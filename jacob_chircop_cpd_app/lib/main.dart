import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:io' show Platform;
import 'package:geolocator/geolocator.dart';
import 'notification_helper.dart';
import 'saved_locations_screen.dart';
import 'location_service.dart';
import 'map_widget.dart';
import 'package:google_fonts/google_fonts.dart';

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
      appBar: AppBar(title: const Text('Car Finder App')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Location Info
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        address,
                        style: GoogleFonts.ubuntu(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              coordinates,
                              style: GoogleFonts.ubuntu(
                                fontSize: 13,
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: _getLocationAndAddress,
                            icon: const Icon(Icons.refresh),
                            tooltip: 'Reload Location',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              if (location != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: MapWidget(
                    latitude: location!.latitude,
                    longitude: location!.longitude,
                  ),
                ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: saveParkingLocation,
                icon: const Icon(Icons.save),
                label: const Text('Save Parking Spot'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SavedLocationsScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.folder_open),
                label: const Text('View Saved Spots'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
