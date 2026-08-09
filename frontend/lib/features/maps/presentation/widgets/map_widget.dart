import 'package:flutter/material.dart';

class MapWidget extends StatelessWidget {
  final String currentLocation;
  final String destination;

  const MapWidget({
    super.key,
    required this.currentLocation,
    required this.destination,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 350,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.15),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Stack(
        children: [
          const Center(child: Icon(Icons.map, size: 120, color: Colors.grey)),

          Positioned(
            left: 50,
            top: 70,
            child: Column(
              children: const [
                Icon(Icons.my_location, color: Colors.blue, size: 30),
                SizedBox(height: 5),
                Text("Current", style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),

          Positioned(
            right: 50,
            bottom: 70,
            child: Column(
              children: const [
                Icon(Icons.location_on, color: Colors.red, size: 35),
                SizedBox(height: 5),
                Text(
                  "Destination",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),

          Positioned(
            left: 80,
            top: 85,
            child: Container(
              width: 180,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),

          Positioned(
            left: 20,
            bottom: 20,
            child: Chip(
              avatar: const Icon(Icons.my_location, color: Colors.blue),
              label: Text(currentLocation),
            ),
          ),

          Positioned(
            right: 20,
            top: 20,
            child: Chip(
              avatar: const Icon(Icons.flag, color: Colors.red),
              label: Text(destination),
            ),
          ),
        ],
      ),
    );
  }
}
