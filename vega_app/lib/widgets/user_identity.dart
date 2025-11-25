import "package:core_flutter/core_app.dart";
import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:core_flutter/states/provider.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../strings.dart";

class QrCodeWidget extends ConsumerWidget {
  final String value;
  const QrCodeWidget({required this.value, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final brightness = ref.scheme.mode;
    return Container(
      color: Colors.white,
      padding: EdgeInsets.all(brightness == ThemeMode.light ? 0 : moleculeScreenPadding),
      child: CodeWidget(type: CodeType.qr, code: value),
    );
  }
}

Future<void> showUserIdentity(BuildContext context, WidgetRef ref) async {
  final user = ref.watch(deviceRepository).get(DeviceKey.user) as User;
  final userId = user.userId;
  final qrCode = F().qrBuilder.generateUserIdentity(userId);
  return modalBottomSheet(
    context,
    Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const MoleculeItemSpace(),
        MoleculeItemTitle(header: LangKeys.dialogYourQrIdentityTitle.tr()),
        const MoleculeItemSpace(),
        Consumer(builder: (context, ref, _) {
          return GestureDetector(
            onTap: () {
              Clipboard.setData(ClipboardData(text: qrCode));
              ref.read(toastLogic.notifier).info(LangKeys.toastCopiedToClipboard.tr());
            },
            child: Center(
              child: FractionallySizedBox(
                widthFactor: 0.8,
                child: AspectRatio(
                  aspectRatio: 1,
                  child: QrCodeWidget(value: qrCode),
                ),
              ),
            ),
          );
        }),
        const MoleculeItemSpace(),
      ],
    ),
  );
}
  
// eof
