// ignore_for_file: avoid_print, deprecated_member_use

import 'dart:convert';
import 'package:workmanager/workmanager.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'database_helper.dart';

const String apiKey =
    "AlzaSy9TI0P1SxaKZGGiN_laxxkcerMf6AV8h9e"; // Replace with your actual API key
const String taskName = "update_ev_stations";

void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    if (task == taskName) {
      await _fetchAndStoreEVStations();
    }
    return Future.value(true);
  });
}

Future<void> _fetchAndStoreEVStations() async {
  try {
    Position? position = await _getCurrentLocation();
    if (position == null) return;

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
      DatabaseHelper dbHelper = DatabaseHelper.instance;
      await dbHelper.clearStations(); // Clear old data
      for (var station in stations) {
        await dbHelper.insertStation(station);
      }
    } else {
      print(
          "Error: Failed to fetch EV stations. Status Code: ${response.statusCode}");
    }
  } catch (e) {
    print("Error in background task: $e");
  }
}

Future<Position?> _getCurrentLocation() async {
  try {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print("Location services are disabled.");
      return null;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        print("Location permissions are denied.");
        return null;
      }
    }

    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  } catch (e) {
    print("Error getting location: $e");
    return null;
  }
}
