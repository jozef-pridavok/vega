import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:core_flutter/states/provider.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../extensions/select_item.dart";
import "../../data_models/product_item.dart";
import "../../states/providers.dart";
import "../../strings.dart";
import "../../widgets/molecule_picker.dart";
import "../dialog.dart";
import "screen_product_item_edit.dart";
import "screen_product_items.dart";
import "screen_product_offer_edit.dart";
import "widget_edit_section.dart";

class ProductItemMenuItems {
  static PopupMenuItem edit(BuildContext context, WidgetRef ref, ProductItem productItem) {
    return PopupMenuItem(
      child: MoleculeItemBasic(
        title: LangKeys.operationEdit.tr(),
        icon: AtomIcons.edit,
        onAction: () {
          ref.read(productItemEditorLogic.notifier).edit(productItem);
          context.popPush(EditProductItemScreen());
        },
      ),
    );
  }

  static PopupMenuItem block(BuildContext context, WidgetRef ref, ProductItem productItem) {
    final isBlocked = productItem.blocked;
    return PopupMenuItem(
      child: MoleculeItemBasic(
        title: isBlocked ? LangKeys.operationUnblock.tr() : LangKeys.operationBlock.tr(),
        icon: isBlocked ? AtomIcons.shield : AtomIcons.shieldOff,
        onAction: () {
          context.pop();
          if (isBlocked) {
            showWaitDialog(context, ref, LangKeys.toastUnblocking.tr());
            ref.read(productItemPatchLogic.notifier).unblock(productItem);
          } else {
            showWaitDialog(context, ref, LangKeys.toastBlocking.tr());
            ref.read(productItemPatchLogic.notifier).block(productItem);
          }
        },
      ),
    );
  }

  static PopupMenuItem changeSection(
      BuildContext context, WidgetRef ref, ProductItem productItem, List<ProductSection> sections) {
    return PopupMenuItem(
      child: MoleculeItemBasic(
        title: LangKeys.operationDifferentSection.tr(args: [productItem.name]),
        icon: AtomIcons.xCircle,
        onAction: () {
          context.pop();
          final isMobile = ref.read(layoutLogic).isMobile;
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
                        builder: (context, scrollController) =>
                            _buildSectionPicker(context, ref, productItem, sections),
                      ),
                    );
                  },
                )
              : showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: LangKeys.pickCardLabel.tr().text,
                    content: _buildSectionPicker(context, ref, productItem, sections),
                  ),
                );
        },
      ),
    );
  }

  static Widget _buildSectionPicker(
      BuildContext context, WidgetRef ref, ProductItem productItem, List<ProductSection> sections) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        MoleculeSingleSelect(
          hint: LangKeys.hintPickSection.tr(),
          items: sections.where((section) => section.sectionId != productItem.sectionId).toList().toSelectItems(),
          onChanged: (selected) {
            context.pop();
            final section = sections.firstWhere((s) => s.sectionId == selected.value);
            showWaitDialog(context, ref, LangKeys.toastChangingItemSection.tr());
            final updatedItem = productItem.copyWith(sectionId: section.sectionId);
            ref.read(productItemPatchLogic.notifier).changeSection(updatedItem);
          },
        ),
      ],
    );
  }

  static PopupMenuItem archive(BuildContext context, WidgetRef ref, ProductItem productItem) {
    return PopupMenuItem(
      child: MoleculeItemBasic(
        title: LangKeys.operationArchive.tr(),
        icon: AtomIcons.delete,
        onAction: () {
          context.pop();
          Future.delayed(fastRefreshDuration, () => _askToArchive(context, ref, productItem));
        },
      ),
    );
  }

  static Future<void> _askToArchive(BuildContext context, WidgetRef ref, ProductItem productItem) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: LangKeys.dialogArchiveTitle.tr().text,
        content: LangKeys.dialogArchiveContent.tr().text,
        actions: [
          TextButton(
            onPressed: () => context.pop(false),
            child: LangKeys.buttonCancel.text,
          ),
          TextButton(
            onPressed: () => context.pop(true),
            child: LangKeys.buttonDelete.text.color(ref.scheme.negative),
          ),
        ],
      ),
    );
    if (result == true) {
      showWaitDialog(context, ref, LangKeys.toastArchiving.tr());
      ref.read(productItemPatchLogic.notifier).archive(productItem);
    }
  }
}

class ProductSectionMenuItems {
  static PopupMenuItem edit(BuildContext context, WidgetRef ref, ProductSection section) {
    return PopupMenuItem(
      child: MoleculeItemBasic(
        title: LangKeys.operationRename.tr(),
        icon: AtomIcons.edit,
        onAction: () {
          context.pop();
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: LangKeys.labelEditSection.tr().text,
              content: EditSectionWidget(offerId: section.offerId!, sectionToEdit: section),
            ),
          );
        },
      ),
    );
  }

  static PopupMenuItem block(BuildContext context, WidgetRef ref, ProductSection productSection) {
    final isBlocked = productSection.blocked;
    return PopupMenuItem(
      child: MoleculeItemBasic(
        title: isBlocked ? LangKeys.operationUnblock.tr() : LangKeys.operationBlock.tr(),
        icon: isBlocked ? AtomIcons.shield : AtomIcons.shieldOff,
        onAction: () {
          context.pop();
          if (isBlocked) {
            showWaitDialog(context, ref, LangKeys.toastUnblocking.tr());
            ref.read(productSectionPatchLogic.notifier).unblock(productSection);
          } else {
            showWaitDialog(context, ref, LangKeys.toastBlocking.tr());
            ref.read(productSectionPatchLogic.notifier).block(productSection);
          }
        },
      ),
    );
  }

  static PopupMenuItem archive(BuildContext context, WidgetRef ref, ProductSection productSection) {
    return PopupMenuItem(
      child: MoleculeItemBasic(
        title: LangKeys.operationArchive.tr(),
        icon: AtomIcons.delete,
        onAction: () {
          context.pop();
          Future.delayed(fastRefreshDuration, () => _askToArchive(context, ref, productSection));
        },
      ),
    );
  }

  static Future<void> _askToArchive(BuildContext context, WidgetRef ref, ProductSection productSection) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: LangKeys.dialogArchiveTitle.tr().text,
        content: LangKeys.dialogArchiveContent.tr().text,
        actions: [
          TextButton(
            onPressed: () => context.pop(false),
            child: LangKeys.buttonCancel.text,
          ),
          TextButton(
            onPressed: () => context.pop(true),
            child: LangKeys.buttonDelete.text.color(ref.scheme.negative),
          ),
        ],
      ),
    );
    if (result == true) {
      showWaitDialog(context, ref, LangKeys.toastArchiving.tr());
      ref.read(productSectionPatchLogic.notifier).archive(productSection);
    }
  }
}

class ProductOfferMenuItems {
  static PopupMenuItem edit(BuildContext context, WidgetRef ref, ProductOffer productOffer) {
    return PopupMenuItem(
      child: MoleculeItemBasic(
        title: LangKeys.operationEdit.tr(),
        icon: AtomIcons.edit,
        onAction: () {
          ref.read(productOfferEditorLogic.notifier).edit(productOffer);
          context.popPush(EditProductOffer());
        },
      ),
    );
  }

  static PopupMenuItem editProducts(BuildContext context, WidgetRef ref, ProductOffer productOffer) {
    return PopupMenuItem(
      child: MoleculeItemBasic(
        title: LangKeys.operationEditProducts.tr(),
        icon: AtomIcons.card,
        onAction: () {
          context.popPush(ProductItemsScreen(productOffer: productOffer));
        },
      ),
    );
  }

  static PopupMenuItem block(BuildContext context, WidgetRef ref, ProductOffer productOffer) {
    final isBlocked = productOffer.blocked;
    return PopupMenuItem(
      child: MoleculeItemBasic(
        title: isBlocked ? LangKeys.operationUnblock.tr() : LangKeys.operationBlock.tr(),
        icon: isBlocked ? AtomIcons.shield : AtomIcons.shieldOff,
        onAction: () {
          context.pop();
          if (isBlocked) {
            showWaitDialog(context, ref, LangKeys.toastUnblocking.tr());
            ref.read(productOfferPatchLogic.notifier).unblock(productOffer);
          } else {
            showWaitDialog(context, ref, LangKeys.toastBlocking.tr());
            ref.read(productOfferPatchLogic.notifier).block(productOffer);
          }
        },
      ),
    );
  }

  static PopupMenuItem archive(BuildContext context, WidgetRef ref, ProductOffer productOffer) {
    return PopupMenuItem(
      child: MoleculeItemBasic(
        title: LangKeys.operationArchive.tr(),
        icon: AtomIcons.delete,
        onAction: () {
          context.pop();
          Future.delayed(fastRefreshDuration, () => _askToArchive(context, ref, productOffer));
        },
      ),
    );
  }

  static Future<void> _askToArchive(BuildContext context, WidgetRef ref, ProductOffer productOffer) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: LangKeys.dialogArchiveTitle.tr().text,
        content: LangKeys.dialogArchiveContent.tr().text,
        actions: [
          TextButton(
            onPressed: () => context.pop(false),
            child: LangKeys.buttonCancel.text,
          ),
          TextButton(
            onPressed: () => context.pop(true),
            child: LangKeys.buttonDelete.text.color(ref.scheme.negative),
          ),
        ],
      ),
    );
    if (result == true) {
      showWaitDialog(context, ref, LangKeys.toastArchiving.tr());
      ref.read(productOfferPatchLogic.notifier).archive(productOffer);
    }
  }
}
