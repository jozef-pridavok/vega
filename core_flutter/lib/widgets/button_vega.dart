import "package:core_flutter/core_flutter.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

class VegaButton extends ConsumerWidget {
  final String icon;
  final void Function()? onPressed;
  final bool disabled;

  const VegaButton({
    Key? key,
    required this.icon,
    required this.onPressed,
    this.disabled = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      icon: VegaIcon(name: icon, color: disabled ? ref.scheme.content20 : null),
      onPressed: disabled ? null : onPressed,
    );
  }
}

class VegaBackButton extends ConsumerWidget {
  final Color? color;
  final void Function()? onPressed;
  final bool cancel;

  const VegaBackButton({
    Key? key,
    this.color,
    this.onPressed,
    this.cancel = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      icon: VegaIcon(
        name: cancel ? AtomIcons.cancel : AtomIcons.arrowLeft,
        color: color ?? (ref.scheme.mode == ThemeMode.dark ? ref.scheme.content : ref.scheme.primary),
        applyColorFilter: true,
      ),
      onPressed: () {
        if (onPressed != null) {
          onPressed!();
          return;
        }
        Navigator.pop(context);
      },
    );
  }
}

class VegaMenuButton<T> extends ConsumerWidget {
  final List<PopupMenuEntry<T>> items;
  final bool disabled;

  const VegaMenuButton({
    Key? key,
    required this.items,
    this.disabled = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return InkWell(
      onTapUp: disabled ? null : (details) => _popupMenu(context, ref, details),
      child: SizedBox(
        width: 38,
        height: 38,
        child: Center(
          child: VegaIcon(
            name: AtomIcons.moreVertical,
            color: disabled ? ref.scheme.content20 : null,
          ),
        ),
      ),
    );
  }

  void _popupMenu(
    BuildContext context,
    WidgetRef ref,
    TapUpDetails details,
  ) {
    final offset = details.globalPosition;
    showMenu(
      position: RelativeRect.fromLTRB(
        offset.dx,
        offset.dy,
        MediaQuery.of(context).size.width - offset.dx,
        MediaQuery.of(context).size.height - offset.dy,
      ),
      context: context,
      items: items,
    );
  }
}

class VegaDrawerButton extends ConsumerWidget {
  final Color? color;
  final void Function()? onPressed;

  const VegaDrawerButton({
    Key? key,
    this.color,
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      icon: VegaIcon(
        name: "menu",
        color: color ?? (ref.scheme.mode == ThemeMode.dark ? ref.scheme.content : ref.scheme.primary),
        applyColorFilter: true,
      ),
      onPressed: () {
        if (onPressed != null) {
          onPressed!();
          return;
        }
        Navigator.pop(context);
      },
    );
  }
}


// eof
