import "package:collection/collection.dart";
import "package:core_flutter/core_dart.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

enum NotificationType { info, warning, error }

class Notification {
  late String _guid;
  final String message;
  final NotificationType type;
  final String? tag;

  String get guid => _guid;

  Notification(this.message, {this.type = NotificationType.info, this.tag}) {
    _guid = uuid();
  }
}

class NotificationsNotifier extends StateNotifier<List<Notification>> {
  NotificationsNotifier() : super([]);

  void error(String message) {
    state = [...state, Notification(message, type: NotificationType.error)];
  }

  void warning(String message, {String? tag}) {
    if (tag == null) {
      state = [...state, Notification(message, type: NotificationType.warning)];
      return;
    }
    final existing = state.firstWhereOrNull((n) => n.tag == tag);
    if (existing != null) return;
    state = [...state, Notification(message, type: NotificationType.warning, tag: tag)];
  }

  void info(String message) {
    state = [...state, Notification(message)];
  }

  void read(String guid) {
    state = [
      for (final notification in state)
        if (notification.guid != guid) notification,
    ];
  }

  void dismiss(String tag) {
    state = [
      for (final notification in state)
        if (notification.tag != tag) notification,
    ];
  }
}

// eof
