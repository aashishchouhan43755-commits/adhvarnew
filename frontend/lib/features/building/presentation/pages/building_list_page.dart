import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/models/building_model.dart';
import '../providers/building_provider.dart';

class BuildingListPage extends ConsumerStatefulWidget {
  const BuildingListPage({super.key});

  @override
  ConsumerState<BuildingListPage> createState() => _BuildingListPageState();
}

class _BuildingListPageState extends ConsumerState<BuildingListPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(buildingProvider.notifier).loadBuildings();
    });
  }

  @override
  Widget build(BuildContext context) {
    final buildingsState = ref.watch(buildingProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FC),
      appBar: AppBar(
        title: const Text("Buildings"),
        centerTitle: true,
        backgroundColor: const Color(0xFF1d4ed8),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: buildingsState.when(
          data: (buildings) {
            if (buildings.isEmpty) {
              return const Center(child: Text("No buildings found."));
            }

            return RefreshIndicator(
              onRefresh: () async {
                await ref.read(buildingProvider.notifier).loadBuildings();
              },
              child: ListView.builder(
                itemCount: buildings.length,
                itemBuilder: (context, index) {
                  final building = buildings[index];

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
                          Icons.apartment_rounded,
                          color: Color(0xFF1d4ed8),
                        ),
                      ),
                      title: Text(
                        building.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Text(
                        building.totalFloors > 0
                            ? "${building.totalFloors} floors · Tap to view"
                            : "Tap to view floors",
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                      trailing: const Icon(
                        Icons.chevron_right_rounded,
                        color: Colors.grey,
                      ),
                      onTap: () => _openFloors(context, building),
                    ),
                  );
                },
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Couldn't load buildings."),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () {
                    ref.read(buildingProvider.notifier).loadBuildings();
                  },
                  child: const Text("Retry"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _openFloors(BuildContext context, BuildingModel building) {
    context.push(
      '/floor-selection?buildingId=${building.id}&building=${Uri.encodeComponent(building.name)}',
    );
  }
}
