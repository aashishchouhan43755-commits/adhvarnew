import 'package:flutter/material.dart';

class NavigationPage extends StatefulWidget {
  const NavigationPage({super.key});

  @override
  State<NavigationPage> createState() => _NavigationPageState();
}

class _NavigationPageState extends State<NavigationPage> {
  bool navigationStarted = false;

  final List<String> directions = [
    "Start from the Main Entrance",
    "Walk straight for 20 meters",
    "Turn left at the Reception",
    "Continue for 15 meters",
    "Take the stairs to First Floor",
    "Turn right",
    "Destination is on your left",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF4F7FC),

      appBar: AppBar(
        title: const Text("Navigation"),
        centerTitle: true,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: const ListTile(
                leading: Icon(Icons.my_location, color: Colors.blue),
                title: Text("Current Location"),
                subtitle: Text("Building Entrance"),
              ),
            ),

            const SizedBox(height: 10),

            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: const ListTile(
                leading: Icon(Icons.flag, color: Colors.red),
                title: Text("Destination"),
                subtitle: Text("Selected Room"),
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                icon: Icon(navigationStarted ? Icons.stop : Icons.navigation),
                label: Text(
                  navigationStarted ? "STOP NAVIGATION" : "START NAVIGATION",
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: navigationStarted ? Colors.red : Colors.blue,
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  setState(() {
                    navigationStarted = !navigationStarted;
                  });
                },
              ),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: ListView.builder(
                itemCount: directions.length,
                itemBuilder: (context, index) {
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.blue.shade100,
                        child: Text("${index + 1}"),
                      ),
                      title: Text(directions[index]),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
