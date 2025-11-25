import "package:core_flutter/core_flutter.dart";
import "package:core_flutter/states/provider.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../states/providers.dart";

class WaitDialog extends ConsumerWidget {
  const WaitDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AlertDialog(
      backgroundColor: ref.scheme.paperCard,
      content: Padding(
        padding: const EdgeInsets.all(moleculeScreenPadding),
        child: Consumer(
          builder: (BuildContext context, WidgetRef ref, Widget? child) {
            final text = ref.watch(waitDialogProvider);
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const WaitIndicator(),
                const SizedBox(height: 16),
                text.text.color(ref.scheme.content),
              ],
            );
          },
        ),
      ),
    );
  }
}

class WaitDialogNotifier extends StateNotifier<String> {
  WaitDialogNotifier() : super("");
  void show(String info) => state = info;
  void close() => state = "";

  void updateInfo(String info) => state = info;
  String get info => state;
}

void showWaitDialog(BuildContext context, WidgetRef ref, String info) {
  final alertDialogState = ref.read(waitDialogProvider.notifier);
  if (alertDialogState.info.isEmpty) {
    alertDialogState.show(info);
    showDialog(context: context, barrierDismissible: true, builder: (context) => WaitDialog());
  }
}

void updateWaitDialog(BuildContext context, WidgetRef ref, String info) {
  final alertDialogState = ref.read(waitDialogProvider.notifier);
  if (alertDialogState.info.isNotEmpty) alertDialogState.updateInfo(info);
}

void closeWaitDialog(BuildContext context, WidgetRef ref) {
  final alertDialogState = ref.read(waitDialogProvider.notifier);
  if (alertDialogState.info.isNotEmpty) {
    alertDialogState.close();
    context.pop();
  }
}

void showVegaPopupMenu<T>({
  required BuildContext context,
  required WidgetRef ref,
  required TapUpDetails details,
  required String title,
  required List<PopupMenuItem<T>> items,
}) {
  final offset = details.globalPosition;
  final isMobile = ref.read(layoutLogic).isMobile;
  if (isMobile)
    modalBottomSheet(
      context,
      Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
              const MoleculeItemSpace(),
              MoleculeItemTitle(header: title),
              const SizedBox(height: 8),
            ] +
            items,
      ),
    );
  else
    showMenu<T>(
      position: RelativeRect.fromLTRB(
        offset.dx,
        offset.dy,
        MediaQuery.of(context).size.width - offset.dx,
        MediaQuery.of(context).size.height - offset.dy,
      ),
      context: context,
      constraints: const BoxConstraints(minWidth: 200, maxWidth: 600),
      items: [
            PopupMenuItem<T>(
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  Padding(padding: const EdgeInsets.all(8.0), child: MoleculeItemTitle(header: title)),
                  //const MoleculeItemSpace(),
                ],
              ),
              enabled: false,
              mouseCursor: SystemMouseCursors.basic,
            )
          ] +
          items,
    );
}

// eof
