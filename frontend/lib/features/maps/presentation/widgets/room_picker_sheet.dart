import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/models/room_search_result_model.dart';
import '../../../search/presentation/providers/search_provider.dart';

/// Shows a search sheet and resolves with the room the user picked, or
/// null if they dismissed it. Reuses [searchProvider] from the search
/// feature rather than duplicating room-lookup logic.
Future<RoomSearchResultModel?> showRoomPickerSheet(
  BuildContext context, {
  required String title,
}) {
  return showModalBottomSheet<RoomSearchResultModel>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => _RoomPickerSheet(title: title),
  );
}

class _RoomPickerSheet extends ConsumerStatefulWidget {
  final String title;

  const _RoomPickerSheet({required this.title});

  @override
  ConsumerState<_RoomPickerSheet> createState() => _RoomPickerSheetState();
}

class _RoomPickerSheetState extends ConsumerState<_RoomPickerSheet> {
  final TextEditingController controller = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    ref.read(searchProvider.notifier).clear();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    ref.read(searchProvider.notifier).clear();
    controller.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      ref.read(searchProvider.notifier).search(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    final resultsState = ref.watch(searchProvider);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                Text(
                  widget.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: controller,
                  autofocus: true,
                  onChanged: _onChanged,
                  decoration: InputDecoration(
                    hintText: "Search Room, Lab, Office...",
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: resultsState.when(
                    data: (results) {
                      if (results.isEmpty) {
                        return Center(
                          child: Text(
                            controller.text.trim().isEmpty
                                ? "Start typing to search rooms"
                                : "No matching rooms found",
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                        );
                      }

                      return ListView.builder(
                        controller: scrollController,
                        itemCount: results.length,
                        itemBuilder: (context, index) {
                          final room = results[index];
                          return ListTile(
                            leading: const Icon(Icons.place_outlined),
                            title: Text(room.roomName),
                            subtitle: Text(
                              "${room.roomNumber} · ${room.floorName} · ${room.buildingName}",
                            ),
                            onTap: () => Navigator.of(context).pop(room),
                          );
                        },
                      );
                    },
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (err, _) => Center(
                      child: Text(
                        "Couldn't search right now.",
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
