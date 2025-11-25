import "package:flutter/material.dart";

import "../themes/theme.dart";

/*
class BottomSheetHeader extends ConsumerWidget {
  final bool showHandle;
  final String? title;
  final String? description;

  const BottomSheetHeader({
    Key? key,
    this.title,
    this.description,
    this.showHandle = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        if (showHandle)
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              height: 4,
              width: 70,
              decoration: BoxDecoration(
                color: ref.scheme.content50,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        if ((title?.length ?? 0) > 0) ...[
          const MoleculusItemSpace(),
          GestureDetector(
            onTap: () {
              Clipboard.setData(ClipboardData(text: title));
              context.instantInfo("toast_copied_to_clipboard".tr());
            },
            child: MoleculusItemTitle(header: title!),
          ),
          const MoleculusItemSpace(),
        ],
        if ((description?.length ?? 0) > 0) ...[
          description!.text.alignLeft.maxLine(5).color(ref.scheme.content),
          const MoleculusItemSpace(),
        ],
      ],
    );
  }
}
*/

Future<T?> modalBottomSheet<T>(BuildContext context, Widget child) => showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: moleculeBottomSheetBorder,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: child,
        ),
      ),
    );


    // eof
    