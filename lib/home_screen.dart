// ignore_for_file: use_build_context_synchronously, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'map_screen.dart';
import 'charging_types_screen.dart';
import 'charging_station_list_screen.dart'; // Import Charging Stations List

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  // Navigation destinations
  static final List<Widget> _screens = [
    const HomeContent(),
    const MapScreen(),
    const ChargingTypesScreen(),
    const ChargingStationListScreen(), // Charging Stations List Screen
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text("EV Charging Finder"),
        backgroundColor: Colors.green,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountName: const Text("User"),
              accountEmail: Text(user?.email ?? ""),
              currentAccountPicture: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.person, size: 40, color: Colors.green),
              ),
              decoration: const BoxDecoration(color: Colors.green),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text("Profile"),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                Navigator.pushNamed(context, '/profile'); // Navigate to Profile
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text("Logout"),
              onTap: () => _logout(context),
            ),
          ],
        ),
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: "Map"),
          BottomNavigationBarItem(
              icon: Icon(Icons.info), label: "Charging Types"),
          BottomNavigationBarItem(
              icon: Icon(Icons.ev_station), label: "Stations"),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.greenAccent,
        onTap: _onItemTapped,
      ),
    );
  }
}

// Home content widget with EV advantages
class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // EV Advantages Section
          const Text(
            "Advantages of Electric Vehicles",
            style: TextStyle(
                fontSize: 22, fontWeight: FontWeight.bold, color: Colors.green),
          ),
          const SizedBox(height: 10),

          // List of EV Advantages
          _advantageItem(Icons.battery_charging_full, "Lower Fuel Costs",
              "EVs use electricity instead of gasoline, which is much cheaper."),
          _advantageItem(Icons.eco, "Eco-Friendly",
              "EVs produce zero emissions, reducing air pollution."),
          _advantageItem(Icons.build, "Low Maintenance",
              "Fewer moving parts lead to lower maintenance costs."),
          _advantageItem(Icons.speed, "Instant Torque",
              "Electric motors provide immediate acceleration."),
          _advantageItem(Icons.home, "Home Charging",
              "Conveniently charge your EV at home overnight."),
          _advantageItem(Icons.local_gas_station, "Energy Independence",
              "Reduces dependence on fossil fuels and foreign oil."),
        ],
      ),
    );
  }

  // Helper method to create an advantage item
  Widget _advantageItem(IconData icon, String title, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(icon, size: 30, color: Colors.green),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 5),
                Text(description, style: const TextStyle(fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
