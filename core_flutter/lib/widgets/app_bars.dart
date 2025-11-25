import "package:core_flutter/core_flutter.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../core_dart.dart";

class VegaPrimaryAppBar extends ConsumerWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? searchTextField;
  const VegaPrimaryAppBar(
    this.title, {
    this.actions,
    this.searchTextField,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SliverAppBar(
      backgroundColor: ref.scheme.paper,
      surfaceTintColor: Colors.transparent,
      expandedHeight: searchTextField != null ? kToolbarHeight : 90,
      elevation: 0,
      pinned: true,
      automaticallyImplyLeading: false,
      flexibleSpace: LayoutBuilder(
        builder: (context, constraints) {
          if (searchTextField != null) return searchTextField!;
          return Padding(
            padding: const EdgeInsets.only(top: kToolbarHeight / 4),
            child: Transform.translate(
              offset: Offset(
                moleculeScreenPadding,
                constraints.maxHeight - 58, // $screenAppBarHeight
              ),
              child: title.h3.color(ref.scheme.content),
            ),
          );
        },
      ),
      //),
      //),
      actions: searchTextField != null ? [] : actions,
    );
  }
}

class VegaAppBar extends ConsumerWidget implements PreferredSizeWidget {
  final String? title;
  final Widget? titleWidget;

  /// Return false to prevent pop
  final dynamic Function()? onBack;
  final List<Widget>? actions;
  final bool cancel;
  final bool hideButton;
  final bool centerTitle;

  const VegaAppBar({
    this.title,
    this.titleWidget,
    this.onBack,
    this.actions,
    this.cancel = false,
    this.hideButton = false,
    this.centerTitle = true,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppBar(
      surfaceTintColor: Colors.transparent,
      title: titleWidget ?? Text(title ?? ""),
      titleTextStyle: AtomStyles.textBold.copyWith(color: ref.scheme.content),
      centerTitle: centerTitle,
      titleSpacing: moleculeScreenPadding,
      elevation: 0,
      automaticallyImplyLeading: hideButton ? false : true,
      leadingWidth: hideButton ? 0 : null,
      leading: hideButton
          ? null
          : VegaBackButton(
              cancel: cancel,
              onPressed: () {
                if (onBack == null) return context.pop();
                final result = onBack!();
                if (cast<bool>(result) ?? true) context.pop(result);
              },
            ),
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class VegaDrawerBar extends ConsumerWidget implements PreferredSizeWidget {
  final String? title;
  final Widget? titleWidget;
  final Function()? onDrawer;
  final List<Widget>? actions;

  const VegaDrawerBar({
    this.title,
    this.titleWidget,
    this.onDrawer,
    this.actions,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppBar(
      surfaceTintColor: Colors.transparent,
      title: titleWidget ?? Text(title ?? ""),
      titleTextStyle: AtomStyles.textBold.copyWith(color: ref.scheme.content),
      centerTitle: false,
      titleSpacing: 0,
      elevation: 0,
      leading: VegaDrawerButton(onPressed: () => onDrawer?.call()),
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class VegaSliverAppBar extends ConsumerWidget {
  final String title;
  final List<Widget>? actions;
  const VegaSliverAppBar(
    this.title, {
    this.actions,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SliverAppBar(
      surfaceTintColor: Colors.transparent,
      backgroundColor: ref.scheme.paper,
      titleTextStyle: AtomStyles.textBold.copyWith(color: ref.scheme.content),
      centerTitle: true,
      titleSpacing: 0,
      elevation: 0,
      pinned: false,
      title: Text(title),
      leading: const VegaBackButton(),
      actions: actions,
    );
  }
}

// eof
