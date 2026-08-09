import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../maps/presentation/providers/maps_provider.dart';

class FloorSelectionPage extends ConsumerWidget {
  final int buildingId;
  final String buildingName;

  const FloorSelectionPage({
    super.key,
    required this.buildingId,
    required this.buildingName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final floorsAsync = ref.watch(floorsByBuildingProvider(buildingId));

    return Scaffold(
      backgroundColor: const Color(0xffF4F7FC),
      appBar: AppBar(
        title: Text(buildingName),
        centerTitle: true,
        backgroundColor: const Color(0xFF1d4ed8),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Select Floor",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: floorsAsync.when(
                data: (floors) {
                  if (floors.isEmpty) {
                    return const Center(
                      child: Text("No floors found for this building."),
                    );
                  }

                  return ListView.builder(
                    itemCount: floors.length,
                    itemBuilder: (context, index) {
                      final floor = floors[index];

                      return Card(
                        elevation: 2,
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          leading: CircleAvatar(
                            radius: 24,
                            backgroundColor: const Color(0xFF1d4ed8).withValues(alpha: 0.1),
                            child: const Icon(
                              Icons.layers_rounded,
                              color: Color(0xFF1d4ed8),
                            ),
                          ),
                          title: Text(
                            floor.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          subtitle: Text("Floor Level ${floor.floorNumber}"),
                          trailing: const Icon(
                            Icons.chevron_right_rounded,
                            color: Colors.grey,
                          ),
                          onTap: () {
                            context.push(
                              '/indoor-map?buildingId=$buildingId&building=${Uri.encodeComponent(buildingName)}&floorId=${floor.id}&floor=${Uri.encodeComponent(floor.name)}',
                            );
                          },
                        ),
                      );
                    },
                  );
                },
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (err, stack) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Couldn't load floors."),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () {
                          ref.invalidate(floorsByBuildingProvider(buildingId));
                        },
                        child: const Text("Retry"),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
