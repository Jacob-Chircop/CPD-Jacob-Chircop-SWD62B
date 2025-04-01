import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

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
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context, false),
          ),
          TextButton(
            child: const Text('Delete All'),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final dbRef = FirebaseDatabase.instance.ref('parking_locations');
      await dbRef.remove();
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
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context, false),
          ),
          TextButton(
            child: const Text('Delete'),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final dbRef = FirebaseDatabase.instance.ref('parking_locations/$key');
      await dbRef.remove();
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
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    title: Text('Lat: ${item['latitude']}, Lng: ${item['longitude']}'),
                    subtitle: Text('Saved at: ${item['timestamp']}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      tooltip: 'Delete this spot',
                      onPressed: () => deleteLocation(key, index),
                    ),
                  ),
                );
              },
            ),
    );
  }
}

