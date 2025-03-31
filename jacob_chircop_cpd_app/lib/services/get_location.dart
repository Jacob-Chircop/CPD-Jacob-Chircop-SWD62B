import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';



class LocationUpdatesPage extends StatefulWidget {
  const LocationUpdatesPage({super.key});

  @override
  LocationUpdatesPageState createState() => LocationUpdatesPageState();
}

class LocationUpdatesPageState extends State<LocationUpdatesPage> {
  String locationMessage = "Listening for location updates...";
  Stream<Position>? positionStream;

  @override
  void initState() {
    super.initState();
    listenToLocationUpdates();
  }

  // Function to listen to location updates
  void listenToLocationUpdates() async {
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

    // Start listening to location updates
    positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // Update every 10 meters
      ),
    );

    positionStream!.listen((Position position) {
      setState(() {
        locationMessage =
            "Latitude: ${position.latitude}, Longitude: ${position.longitude}";
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Location Updates Example'),
      ),
      body: Center(
        child: Text(
          locationMessage,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}