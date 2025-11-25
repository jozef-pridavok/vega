import "package:core_flutter/core_flutter.dart";
import "package:flutter/material.dart" hide Notification;
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:vega_dashboard/states/notifications.dart";

import "../states/providers.dart";

class NotificationsWidget extends ConsumerWidget {
  Color _background(WidgetRef ref, Notification notification) {
    switch (notification.type) {
      case NotificationType.error:
        return ref.scheme.negative;
      case NotificationType.info:
        return ref.scheme.paper;
      case NotificationType.warning:
        return ref.scheme.accent;
    }
  }

  Color _foreground(WidgetRef ref, Notification notification) {
    switch (notification.type) {
      case NotificationType.error:
        return ref.scheme.light;
      case NotificationType.info:
        return ref.scheme.content;
      case NotificationType.warning:
        return ref.scheme.content;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifications = ref.watch(notificationsLogic);
    if (notifications.isEmpty) return SizedBox();
    final notification = notifications.last;
    final bg = _background(ref, notification);
    final fg = _foreground(ref, notification);
    var message = notification.message;
    //if (kDebugMode) message = "${notification.guid.shorten()} $message";
    return GestureDetector(
      onTap: () {
        final guid = notification.guid;
        ref.read(notificationsLogic.notifier).read(guid);
      },
      child: Container(
        decoration: moleculeOutlineDecoration(fg, bg),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: moleculeScreenPadding / 2, horizontal: moleculeScreenPadding),
          child: Center(child: message.text.color(fg)),
        ),
      ),
    );
  }
}

// eof
