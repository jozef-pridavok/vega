import "package:core_flutter/core_dart.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "layout.dart";
import "push_notifications.dart";
import "refresh.dart";
import "theme.dart";
import "toast.dart";

final toastLogic = StateNotifierProvider<ToastNotifier, List<Toast>>(
  (ref) => ToastNotifier(),
);

final pushNotificationLogic = StateNotifierProvider<PushNotificationNotifier, List<PushNotification>>(
  (ref) => PushNotificationNotifier(),
);

final layoutLogic = StateNotifierProvider<LayoutNotifier, LayoutState>(
  (ref) => LayoutNotifier(),
);

final themeLogic = StateNotifierProvider<ThemeNotifier, ThemeState>(
  (ref) => ThemeNotifier(),
);

final refreshLogic = StateNotifierProvider<RefreshNotifier, List<String>>(
  (ref) => RefreshNotifier(),
);

// eof
