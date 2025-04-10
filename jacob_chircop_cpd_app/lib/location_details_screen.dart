
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_fonts/google_fonts.dart';
import 'main.dart';
import 'map_widget.dart';

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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Address:", style: GoogleFonts.ubuntu(fontWeight: FontWeight.w600, fontSize: 16)),
            Text(widget.address, style: GoogleFonts.ubuntu(fontSize: 15)),
            const SizedBox(height: 16),
            Text("Coordinates:", style: GoogleFonts.ubuntu(fontWeight: FontWeight.w600, fontSize: 16)),
            Text("Lat: ${widget.latitude}, Lng: ${widget.longitude}",
                style: GoogleFonts.ubuntu(fontSize: 14, color: Colors.grey[800])),
            const SizedBox(height: 16),
            Text("Saved At:", style: GoogleFonts.ubuntu(fontWeight: FontWeight.w600, fontSize: 16)),
            Text(formattedDate, style: GoogleFonts.ubuntu(fontSize: 14, color: Colors.grey[800])),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: MapWidget(
                latitude: widget.latitude,
                longitude: widget.longitude,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: pickTimeAndSetReminder,
              icon: const Icon(Icons.alarm),
              label: const Text("Set Reminder Time"),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
              ),
            )
          ],
        ),
      ),
    );
  }
}
