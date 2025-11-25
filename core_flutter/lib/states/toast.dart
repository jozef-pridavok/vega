import "package:collection/collection.dart";
import "package:core_dart/core_dart.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

enum ToastType { info, warning, error, errorCore }

class Toast {
  late String _guid;
  final String message;
  final ToastType type;
  final String? tag;
  final CoreError? error;

  String get guid => _guid;

  Toast(this.message, {this.type = ToastType.info, this.tag, this.error}) {
    _guid = uuid();
  }
}

class ToastNotifier extends StateNotifier<List<Toast>> {
  ToastNotifier() : super([]);

  void errorCore(CoreError error, {String? message}) {
    state = [...state, Toast(message ?? "", type: ToastType.errorCore, error: error)];
  }

  void error(String message) {
    state = [...state, Toast(message, type: ToastType.error)];
  }

  void warning(String message, {String? tag}) {
    if (tag == null) {
      state = [...state, Toast(message, type: ToastType.warning)];
      return;
    }
    final existing = state.firstWhereOrNull((n) => n.tag == tag);
    if (existing != null) return;
    state = [...state, Toast(message, type: ToastType.warning, tag: tag)];
  }

  void info(String message) {
    state = [...state, Toast(message)];
  }

  Toast? peek() {
    if (state.isEmpty) return null;
    return state.first;
  }

  Toast? pop() {
    if (state.isEmpty) return null;
    final toast = state.first;
    state = [...state.skip(1)];
    return toast;
  }

  void read(String guid) {
    state = [
      for (final notification in state)
        if (notification.guid != guid) notification,
    ];
  }

  void dismissTag(String tag) {
    state = [
      for (final notification in state)
        if (notification.tag != tag) notification,
    ];
  }
}

// eof
