import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/models/room_search_result_model.dart';
import '../providers/search_provider.dart';

class SearchController {
  SearchController(this.ref);

  final Ref ref;

  Future<void> search(String query) async {
    await ref.read(searchProvider.notifier).search(query);
  }

  void clear() {
    ref.read(searchProvider.notifier).clear();
  }

  AsyncValue<List<RoomSearchResultModel>> get results {
    return ref.watch(searchProvider);
  }
}

final searchControllerProvider = Provider<SearchController>(
  (ref) => SearchController(ref),
);
