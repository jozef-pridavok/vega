import "package:core_dart/core_dart.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

class PushNotificationNotifier extends StateNotifier<List<PushNotification>> {
  final List<String> _handled = [];

  PushNotificationNotifier() : super([]);

  bool push(PushNotification message) {
    if (_handled.contains(message.uuid)) return false;
    if (message.uuid != null) _handled.add(message.uuid!);
    state = [...state, message];
    return true;
  }

  PushNotification? peek() => state.isEmpty ? null : state.first;

  PushNotification? pop() {
    if (state.isEmpty) return null;
    final message = state.first;
    state = [...state.skip(1)];
    return message;
  }
}

// eof
