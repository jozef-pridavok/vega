import "package:flutter_riverpod/flutter_riverpod.dart";

class RefreshNotifier extends StateNotifier<List<String>> {
  RefreshNotifier() : super([]);

  void mark(String key) {
    state = [...state, key];
  }

  void clear(String key) {
    state = state.where((k) => k != key).toList();
  }
}

// eof
