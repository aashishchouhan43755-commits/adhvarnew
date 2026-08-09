import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/models/building_model.dart';
import '../../../building/presentation/providers/building_provider.dart';

class BuildingsPage extends ConsumerStatefulWidget {
  const BuildingsPage({super.key});

  @override
  ConsumerState<BuildingsPage> createState() => _BuildingsPageState();
}

class _BuildingsPageState extends ConsumerState<BuildingsPage> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      ref.read(buildingProvider.notifier).loadBuildings();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(buildingProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FC),
      appBar: AppBar(
        title: const Text("Buildings"),
        centerTitle: true,
        backgroundColor: const Color(0xFF1d4ed8),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),

        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Error: $error"),
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

        data: (buildings) {
          if (buildings.isEmpty) {
            return const Center(child: Text("No buildings found."));
          }

          return RefreshIndicator(
            onRefresh: () async {
              await ref.read(buildingProvider.notifier).loadBuildings();
            },
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: buildings.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final BuildingModel building = buildings[index];

                return Card(
                  elevation: 2,
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
                        Icons.business_rounded,
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
                      building.description.isNotEmpty
                          ? building.description
                          : "Code: ${building.code} · ${building.totalFloors} floors",
                    ),
                    trailing: const Icon(Icons.chevron_right_rounded, color: Colors.grey),
                    onTap: () {
                      context.push(
                        '/floor-selection?buildingId=${building.id}&building=${Uri.encodeComponent(building.name)}',
                      );
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
