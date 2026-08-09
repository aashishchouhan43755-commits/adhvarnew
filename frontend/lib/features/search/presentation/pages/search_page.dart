import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/models/room_search_result_model.dart';
import '../providers/search_provider.dart';

class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key});

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  final TextEditingController searchController = TextEditingController();
  Timer? _debounce;

  static const _debounceDuration = Duration(milliseconds: 350);

  void _onQueryChanged(String value) {
    setState(() {}); // refresh the clear button visibility

    _debounce?.cancel();
    _debounce = Timer(_debounceDuration, () {
      ref.read(searchProvider.notifier).search(value);
    });
  }

  void _clear() {
    searchController.clear();
    _debounce?.cancel();
    ref.read(searchProvider.notifier).clear();
    setState(() {});
  }

  void _openOnMap(RoomSearchResultModel room) {
    context.push(
      Uri(
        path: "/indoor-map",
        queryParameters: {
          "buildingId": "${room.buildingId}",
          "building": room.buildingName,
          "floorId": "${room.floorId}",
          "floor": room.floorName,
          ...room.toQueryParams(),
        },
      ).toString(),
    );
  }

  IconData _iconForType(String roomType) {
    switch (roomType) {
      case "meeting":
        return Icons.groups_outlined;
      case "lab":
        return Icons.science_outlined;
      case "office":
        return Icons.badge_outlined;
      case "cafeteria":
        return Icons.local_cafe_outlined;
      case "reception":
        return Icons.support_agent_outlined;
      case "library":
        return Icons.menu_book_outlined;
      case "utility":
        return Icons.build_outlined;
      case "lounge":
        return Icons.weekend_outlined;
      case "classroom":
        return Icons.school_outlined;
      default:
        return Icons.place_outlined;
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final resultsState = ref.watch(searchProvider);

    return Scaffold(
      backgroundColor: const Color(0xffF4F7FC),

      appBar: AppBar(
        title: const Text("Search"),
        centerTitle: true,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          children: [
            TextField(
              controller: searchController,
              onChanged: _onQueryChanged,
              onSubmitted: (value) {
                _debounce?.cancel();
                ref.read(searchProvider.notifier).search(value);
              },
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: "Search Room, Lab, Office...",
                prefixIcon: const Icon(Icons.search),
                suffixIcon: searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: _clear,
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: resultsState.when(
                data: (results) {
                  if (searchController.text.trim().isEmpty) {
                    return const _SearchHint();
                  }

                  if (results.isEmpty) {
                    return const _EmptyResults();
                  }

                  return ListView.builder(
                    itemCount: results.length,
                    itemBuilder: (context, index) {
                      final room = results[index];

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: CircleAvatar(
                            child: Icon(_iconForType(room.roomType)),
                          ),
                          title: Text(room.roomName),
                          subtitle: Text(
                            "${room.roomNumber} · ${room.floorName} · ${room.buildingName}",
                          ),
                          trailing: const Icon(
                            Icons.arrow_forward_ios,
                            size: 18,
                          ),
                          onTap: () => _openOnMap(room),
                        ),
                      );
                    },
                  );
                },
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (error, _) => Center(
                  child: Text(
                    "Couldn't search right now. Please try again.",
                    style: TextStyle(color: Colors.grey.shade600),
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

class _SearchHint extends StatelessWidget {
  const _SearchHint();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        "Search for a room, lab, or office\nacross the Adhvar Innovation Center",
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.grey.shade600),
      ),
    );
  }
}

class _EmptyResults extends StatelessWidget {
  const _EmptyResults();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        "No matching rooms found",
        style: TextStyle(color: Colors.grey.shade600),
      ),
    );
  }
}
