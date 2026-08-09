import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../auth/presentation/providers/auth_provider.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    String username = "User";
    String email = "";

    authState.whenOrNull(
      data: (user) {
        if (user != null) {
          username = user.name;
          email = user.email;
        }
      },
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text("Adhvar"),
        actions: [
          IconButton(
            tooltip: "Logout",
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await ref.read(authProvider.notifier).logout();

              if (context.mounted) {
                context.go("/login");
              }
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(username),
              accountEmail: Text(email),
              currentAccountPicture: const CircleAvatar(
                child: Icon(Icons.person, size: 35),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text("Home"),
              onTap: () => context.pop(),
            ),
            ListTile(
              leading: const Icon(Icons.route),
              title: const Text("Indoor Navigation"),
              onTap: () {
                context.pop();
                context.push("/building-list");
              },
            ),
            ListTile(
              leading: const Icon(Icons.business),
              title: const Text("Buildings"),
              onTap: () {
                context.pop();
                context.push("/building-list");
              },
            ),
            ListTile(
              leading: const Icon(Icons.meeting_room),
              title: const Text("Rooms"),
              onTap: () {
                context.pop();
                context.push("/search");
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text("Settings"),
              onTap: () => context.pop(),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            Text(
              "Welcome, $username 👋",
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            Text(email, style: const TextStyle(color: Colors.grey)),

            const SizedBox(height: 30),

            TextField(
              readOnly: true,
              onTap: () => context.push("/search"),
              decoration: InputDecoration(
                hintText: "Search room or building...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 30),

            const Text(
              "Quick Actions",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 16),

            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.15,
              children: [
                _DashboardCard(
                  title: "Find Route",
                  icon: Icons.route,
                  color: Colors.blue,
                  onTap: () => context.push("/search"),
                ),
                _DashboardCard(
                  title: "Buildings",
                  icon: Icons.business,
                  color: Colors.green,
                  onTap: () => context.push("/building-list"),
                ),
                _DashboardCard(
                  title: "Rooms",
                  icon: Icons.meeting_room,
                  color: Colors.orange,
                  onTap: () => context.push("/search"),
                ),
                _DashboardCard(
                  title: "Profile",
                  icon: Icons.person,
                  color: Colors.purple,
                  onTap: () => context.push("/profile"),
                ),
              ],
            ),

            const SizedBox(height: 30),

            Card(
              elevation: 2,
              child: ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text("Adhvar Indoor Navigation"),
                subtitle: const Text(
                  "Navigate seamlessly inside buildings using smart routing.",
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _DashboardCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 32,
              backgroundColor: color.withValues(alpha: 0.15),
              child: Icon(icon, color: color, size: 34),
            ),
            const SizedBox(height: 14),
            Text(
              title,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
