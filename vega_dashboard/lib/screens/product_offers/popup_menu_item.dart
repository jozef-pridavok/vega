import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../states/providers.dart";
import "../../strings.dart";
import "screen_product_option_edit.dart";

class ProductOptionMenuItems {
  static PopupMenuItem edit(BuildContext context, WidgetRef ref, ProductItemOption option) {
    return PopupMenuItem(
      child: MoleculeItemBasic(
        title: LangKeys.operationEdit.tr(),
        icon: AtomIcons.eye,
        onAction: () {
          context.pop();
          ref.read(productItemOptionEditorLogic.notifier).edit(option);
          context.push(EditProductOptionScreen());
        },
      ),
    );
  }
}

// eof
