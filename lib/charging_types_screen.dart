import 'package:flutter/material.dart';

class ChargingTypesScreen extends StatelessWidget {
  const ChargingTypesScreen({super.key});

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
            "EV Charging Types",
            style: TextStyle(
                fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          centerTitle: true,
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.green.shade50],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _chargingTypeCard(
              title: "Type 1 (SAE J1772)",
              description:
                  "Used in North America, mainly for AC charging up to 7.2 kW.",
              icon: Icons.electrical_services_rounded,
            ),
            _chargingTypeCard(
              title: "Type 2 (Mennekes)",
              description:
                  "Common in Europe and Asia, supports both AC and DC charging.",
              icon: Icons.charging_station_rounded,
            ),
            _chargingTypeCard(
              title: "CHAdeMO",
              description:
                  "Fast-charging DC standard used by Nissan, Mitsubishi, etc.",
              icon: Icons.flash_on_rounded,
            ),
            _chargingTypeCard(
              title: "CCS (Combined Charging System)",
              description:
                  "Widely adopted standard supporting fast DC charging.",
              icon: Icons.bolt_rounded,
            ),
            _chargingTypeCard(
              title: "Tesla Supercharger",
              description:
                  "Exclusive to Tesla vehicles, ultra-fast DC charging.",
              icon: Icons.electric_car_rounded,
            ),
          ],
        ),
      ),
    );
  }

  Widget _chargingTypeCard(
      {required String title,
      required String description,
      required IconData icon}) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Icon(icon, size: 35, color: Colors.green.shade700),
        title: Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          description,
          style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
        ),
      ),
    );
  }
}
