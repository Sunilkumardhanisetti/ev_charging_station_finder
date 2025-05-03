// ignore_for_file: library_private_types_in_public_api, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../database_helper.dart'; // Import DatabaseHelper

class ChargingStationListScreen extends StatefulWidget {
  const ChargingStationListScreen({super.key});

  @override
  _ChargingStationListScreenState createState() =>
      _ChargingStationListScreenState();
}

class _ChargingStationListScreenState extends State<ChargingStationListScreen> {
  List<Map<String, dynamic>> chargingStations = [];
  bool isLoading = true;
  final String apiKey =
      "AlzaSy9TI0P1SxaKZGGiN_laxxkcerMf6AV8h9e"; // Replace with actual API key

  @override
  void initState() {
    super.initState();
    _loadChargingStations();
  }

  Future<void> _loadChargingStations() async {
    setState(() => isLoading = true);

    // Check if internet is available
    bool isOnline = await _checkInternetConnection();

    if (isOnline) {
      // If online, fetch from API and update SQLite
      await _fetchAndSaveChargingStations();
    } else {
      // If offline, load from SQLite
      await _loadFromDatabase();
    }

    setState(() => isLoading = false);
  }

  Future<bool> _checkInternetConnection() async {
    try {
      final response = await http.get(Uri.parse("https://www.google.com"));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<void> _fetchAndSaveChargingStations() async {
    try {
      Position position = await _getCurrentLocation();
      String url =
          "https://maps.gomaps.pro/maps/api/place/nearbysearch/json?location=${position.latitude},${position.longitude}&radius=50000&key=$apiKey&keyword=charging";

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        List<Map<String, dynamic>> stations = [];

        for (var result in data['results']) {
          stations.add({
            "name": result["name"],
            "location": result["vicinity"],
            "status": (result["business_status"] == "OPERATIONAL")
                ? "Available"
                : "In Use",
          });
        }

        // Save to SQLite
        await DatabaseHelper.instance.clearStations(); // Clear old data
        for (var station in stations) {
          await DatabaseHelper.instance.insertStation(station);
        }

        setState(() => chargingStations = stations);
      }
    } catch (e) {
      debugPrint("Error fetching data: $e");
    }
  }

  Future<void> _loadFromDatabase() async {
    final stations = await DatabaseHelper.instance.getStations();
    setState(() => chargingStations = stations);
  }

  Future<Position> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception("Location services are disabled.");
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        throw Exception("Location permissions are denied.");
      }
    }

    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80.0),
        child: AppBar(
          elevation: 0,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.green, Colors.lightGreen],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          title: const Text(
            "Nearby Charging Stations",
            style: TextStyle(
                fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          centerTitle: true,
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : chargingStations.isEmpty
              ? const Center(
                  child: Text(
                    "No charging stations available",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  itemCount: chargingStations.length,
                  itemBuilder: (context, index) {
                    final station = chargingStations[index];
                    return Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(12),
                        leading: Icon(Icons.ev_station,
                            size: 32,
                            color: station["status"] == "Available"
                                ? Colors.green
                                : Colors.red),
                        title: Text(
                          station["name"],
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          station["location"],
                          style: const TextStyle(fontSize: 15),
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 6, horizontal: 10),
                          decoration: BoxDecoration(
                            color: station["status"] == "Available"
                                ? Colors.green
                                : Colors.red,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            station["status"],
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _loadChargingStations,
        backgroundColor: Colors.green,
        child: const Icon(Icons.refresh, size: 28, color: Colors.white),
      ),
    );
  }
}
