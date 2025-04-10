import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_fonts/google_fonts.dart';
import 'location_details_screen.dart';

class SavedLocationsScreen extends StatefulWidget {
  const SavedLocationsScreen({super.key});

  @override
  State<SavedLocationsScreen> createState() => _SavedLocationsScreenState();
}

class _SavedLocationsScreenState extends State<SavedLocationsScreen> {
  List<Map<String, dynamic>> locations = [];

  @override
  void initState() {
    super.initState();
    fetchLocations();
  }

  Future<void> fetchLocations() async {
    final dbRef = FirebaseDatabase.instance.ref('parking_locations');
    final snapshot = await dbRef.get();

    if (snapshot.exists) {
      List<Map<String, dynamic>> tempList = [];
      for (var child in snapshot.children) {
        final data = child.value as Map<dynamic, dynamic>;
        tempList.add({
          'key': child.key,
          'latitude': data['latitude'],
          'longitude': data['longitude'],
          'timestamp': data['timestamp'],
          'address': data['address'],
        });
      }
      setState(() {
        locations = tempList.reversed.toList();
      });
    }
  }

  Future<void> clearAllLocations() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All?'),
        content: const Text('Are you sure you want to delete all saved parking spots?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete All')),
        ],
      ),
    );

    if (confirm == true) {
      await FirebaseDatabase.instance.ref('parking_locations').remove();
      setState(() => locations.clear());
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All parking spots deleted.')),
      );
    }
  }

  Future<void> deleteLocation(String key, int index) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Entry?'),
        content: const Text('Delete this saved parking spot?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
        ],
      ),
    );

    if (confirm == true) {
      await FirebaseDatabase.instance.ref('parking_locations/$key').remove();
      setState(() => locations.removeAt(index));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Parking spot deleted.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Parking Spots'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_forever),
            tooltip: 'Clear All',
            onPressed: clearAllLocations,
          ),
        ],
      ),
      body: locations.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: locations.length,
              itemBuilder: (context, index) {
                final item = locations[index];
                final key = item['key'];
                return Card(
                  elevation: 3,
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    title: Text(
                      item['address'] ?? 'No address available',
                      style: GoogleFonts.ubuntu(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 6),
                        Text(
                          'Saved at: ${item['timestamp']}',
                          style: GoogleFonts.ubuntu(fontSize: 12, color: Colors.grey[700]),
                        ),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () => deleteLocation(key, index),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => LocationDetailScreen(
                            latitude: item['latitude'],
                            longitude: item['longitude'],
                            address: item['address'],
                            timestamp: item['timestamp'],
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
