import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'map_widget.dart';
import 'main.dart';


class LocationDetailScreen extends StatefulWidget {
  final double latitude;
  final double longitude;
  final String address;
  final String timestamp;

  const LocationDetailScreen({
    super.key,
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.timestamp,
  });

  @override
  State<LocationDetailScreen> createState() => _LocationDetailScreenState();
}

class _LocationDetailScreenState extends State<LocationDetailScreen> {
  TimeOfDay selectedTime = TimeOfDay.now();

  Future<void> pickTimeAndSetReminder() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );

    if (picked != null) {
      setState(() {
        selectedTime = picked;
      });

      final now = DateTime.now();
      DateTime scheduledTime = DateTime(
        now.year,
        now.month,
        now.day,
        picked.hour,
        picked.minute,
      );

      if (scheduledTime.isBefore(now)) {
        scheduledTime = scheduledTime.add(const Duration(days: 1));
      }

      final delay = scheduledTime.difference(now);

      Future.delayed(delay, () {
        flutterLocalNotificationsPlugin.show(
          0,
          'Parking Spot Reminder',
          'Don’t forget your parking spot!',
          NotificationDetails(
            android: AndroidNotificationDetails(
              'parking_channel',
              'Parking Reminder',
              channelDescription: 'Reminder for your parking spot',
              importance: Importance.max,
              priority: Priority.high,
            ),
          ),
        );
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Reminder set for ${picked.format(context)}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat.yMMMd().add_jm().format(DateTime.parse(widget.timestamp));

    return Scaffold(
      appBar: AppBar(title: const Text('Parking Spot Details')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Address:", style: Theme.of(context).textTheme.titleMedium),
            Text(widget.address, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 16),
            Text("Coordinates:", style: Theme.of(context).textTheme.titleMedium),
            Text("Lat: ${widget.latitude}, Lng: ${widget.longitude}", style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 16),
            Text("Saved At:", style: Theme.of(context).textTheme.titleMedium),
            Text(formattedDate, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 16),
            MapWidget(latitude: widget.latitude, longitude: widget.longitude),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: pickTimeAndSetReminder,
              child: const Text("Set Reminder Time"),
            )
          ],
        ),
      ),
    );
  }
}
