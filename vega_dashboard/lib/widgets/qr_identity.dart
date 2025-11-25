import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:core_flutter/states/provider.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../strings.dart";

void showIdentityForNewCard(BuildContext context, WidgetRef ref, String qrCode) {
  final title = LangKeys.titleAddUserCard.tr();
  final description = LangKeys.labelAddUserCard.tr();
  var column = Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      const MoleculeItemSpace(),
      MoleculeItemTitle(header: title),
      const MoleculeItemSpace(),
      description.text,
      const MoleculeItemSpace(),
      _buildClientIdentity(context, ref, qrCode),
    ],
  );
  final isMobile = ref.watch(layoutLogic).isMobile;
  isMobile
      ? showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          shape: moleculeBottomSheetBorder,
          builder: (context) {
            return StatefulBuilder(
              builder: (context, setState) => DraggableScrollableSheet(
                expand: false,
                initialChildSize: 0.66,
                minChildSize: 0.66,
                maxChildSize: 0.90,
                builder: (context, scrollController) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: column,
                  );
                },
              ),
            );
          },
        )
      : showDialog(
          context: context,
          builder: (context) => AlertDialog(content: column),
        );
}

Widget _buildClientIdentity(BuildContext context, WidgetRef ref, String qrCode) {
  final brightness = ref.scheme.mode;
  return Padding(
    padding: const EdgeInsets.all(moleculeScreenPadding),
    child: Container(
      color: Colors.white,
      padding: EdgeInsets.all(brightness == ThemeMode.light ? 0 : moleculeScreenPadding),
      child: CodeWidget(type: CodeType.qr, code: qrCode),
    ),
  );
}
  // eof
  
