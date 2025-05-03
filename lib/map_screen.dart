// ignore_for_file: library_private_types_in_public_api, deprecated_member_use, use_build_context_synchronously, unnecessary_to_list_in_spreads

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _mapController;
  LatLng _currentPosition =
      const LatLng(37.7749, -122.4194); // Default location
  final String _googleApiKey =
      "AlzaSy9TI0P1SxaKZGGiN_laxxkcerMf6AV8h9e"; // Replace with your API key
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  BitmapDescriptor? _customMarkerIcon;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCustomMarker();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _getCurrentLocation();
    });
  }

  Future<void> _loadCustomMarker() async {
    _customMarkerIcon = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(size: Size(48, 48)),
      'assets/images/electric_icon.png',
    );
  }

  Future<void> _getCurrentLocation() async {
    final hasPermission = await _handleLocationPermission();
    if (!hasPermission) return;

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _currentPosition = LatLng(position.latitude, position.longitude);
    });

    _moveCamera(_currentPosition);
    _fetchEVChargingStations(_currentPosition);
  }

  Future<bool> _handleLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location permissions are denied')),
        );
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'Location permissions are permanently denied, we cannot request permissions.')),
      );
      return false;
    }
    return true;
  }

  Future<void> _fetchEVChargingStations(LatLng location) async {
    final placesUrl =
        "https://maps.gomaps.pro/maps/api/place/nearbysearch/json?location=${location.latitude},${location.longitude}&radius=50000&key=$_googleApiKey&keyword=charging";

    try {
      final response = await http.get(Uri.parse(placesUrl));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['results'].isNotEmpty) {
          Set<Marker> markers = data['results'].map<Marker>((station) {
            LatLng stationPosition = LatLng(
              station['geometry']['location']['lat'],
              station['geometry']['location']['lng'],
            );

            // Mock charging type and price data
            List<String> chargingTypes = [
              "Type 1",
              "Type 2",
              "CHAdeMO",
              "CCS",
              "Tesla"
            ];
            String price = "₹21.71/min";

            return Marker(
              markerId: MarkerId(station['place_id']),
              position: stationPosition,
              icon: _customMarkerIcon ?? BitmapDescriptor.defaultMarker,
              infoWindow: InfoWindow(
                title: station['name'],
                snippet: "Tap for details",
              ),
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  builder: (context) => _buildStationDetailsBottomSheet(
                    station,
                    chargingTypes,
                    price,
                    stationPosition,
                  ),
                );
              },
            );
          }).toSet();

          setState(() {
            _markers = markers;
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text("No EV charging stations found nearby.")),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  "Failed to fetch EV charging stations. Error: ${response.reasonPhrase}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching charging stations: $e")),
      );
    }
  }

  void _moveCamera(LatLng position) {
    _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: position, zoom: 14),
      ),
    );
  }

  Widget _buildStationDetailsBottomSheet(Map<String, dynamic> station,
      List<String> chargingTypes, String price, LatLng stationPosition) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            station['name'],
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text("Address: ${station['vicinity']}"),
          Text("Rating: ${station['rating'] ?? 'Not available'}"),
          Text(
              "User Reviews: ${station['user_ratings_total'] ?? 'No ratings'}"),
          Text(
              "Open Now: ${station['opening_hours']?['open_now'] == true ? 'Yes' : 'No'}"),
          const SizedBox(height: 10),
          const Text(
            "Charging Types:",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          ...chargingTypes.map((type) => Text("- $type")).toList(),
          const SizedBox(height: 10),
          Text(
            "Price: $price",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {
              _drawRoute(_currentPosition, stationPosition);
              Navigator.pop(context);
            },
            child: const Text("Get Directions"),
          ),
        ],
      ),
    );
  }

  Future<void> _drawRoute(LatLng source, LatLng destination) async {
    final directionsUrl =
        "https://maps.gomaps.pro/maps/api/directions/json?origin=${source.latitude},${source.longitude}&destination=${destination.latitude},${destination.longitude}&mode=driving&key=$_googleApiKey";

    try {
      final response = await http.get(Uri.parse(directionsUrl));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['status'] != 'OK') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("No route found: ${data['status']}")),
          );
          return;
        }

        final polylinePoints = data['routes'][0]['overview_polyline']['points'];
        List<LatLng> routePoints = _decodePolyline(polylinePoints);

        setState(() {
          _polylines = {
            Polyline(
              polylineId: const PolylineId('route'),
              points: routePoints,
              color: Colors.blue,
              width: 5,
            ),
          };
        });

        LatLngBounds bounds = _calculateBounds(source, destination);
        _mapController?.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50));
      } else {
        throw Exception("Failed to fetch directions.");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching directions: $e")),
      );
    }
  }

  List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> points = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;

      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20);

      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;

      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20);

      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      points.add(LatLng(lat / 1E5, lng / 1E5));
    }

    return points;
  }

  LatLngBounds _calculateBounds(LatLng source, LatLng destination) {
    return LatLngBounds(
      southwest: LatLng(
        source.latitude < destination.latitude
            ? source.latitude
            : destination.latitude,
        source.longitude < destination.longitude
            ? source.longitude
            : destination.longitude,
      ),
      northeast: LatLng(
        source.latitude > destination.latitude
            ? source.latitude
            : destination.latitude,
        source.longitude > destination.longitude
            ? source.longitude
            : destination.longitude,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Stations Map"),
        backgroundColor: Colors.green,
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _currentPosition,
              zoom: 14,
            ),
            onMapCreated: (controller) => _mapController = controller,
            markers: _markers,
            polylines: _polylines,
            myLocationEnabled: true,
          ),
          Positioned(
            top: 10,
            left: 10,
            right: 70, // Leaves space for the FAB button
            child: Card(
              elevation: 4,
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: "Search Location",
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(8),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: () {
                      _searchLocation(_searchController.text);
                    },
                  ),
                ),
                onSubmitted: (value) {
                  _searchLocation(value);
                },
              ),
            ),
          ),
          Positioned(
            top: 10,
            right: 10,
            child: FloatingActionButton(
              onPressed: _getCurrentLocation,
              backgroundColor: Colors.green,
              child: const Icon(Icons.my_location),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _searchLocation(String query) async {
    if (query.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Search query is empty.")),
      );
      return;
    }

    final geocodeUrl =
        "https://maps.gomaps.pro/maps/api/geocode/json?address=$query&key=$_googleApiKey";

    try {
      final response = await http.get(Uri.parse(geocodeUrl));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['results'].isNotEmpty) {
          double lat = data['results'][0]['geometry']['location']['lat'];
          double lng = data['results'][0]['geometry']['location']['lng'];
          LatLng searchedPosition = LatLng(lat, lng);

          _moveCamera(searchedPosition);
          _fetchEVChargingStations(searchedPosition);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("No results found for '$query'.")),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  "Failed to search location. Error: ${response.reasonPhrase}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error searching location: $e")),
      );
    }
  }
}
