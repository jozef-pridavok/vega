import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

class AddressWidget extends ConsumerWidget {
  final String icon;
  final String name;
  final String? addressLine1;
  final String? addressLine2;
  final String? city;
  final String? zip;

  final String? action;
  final Function()? onAction;

  const AddressWidget({
    super.key,
    this.icon = AtomIcons.map,
    required this.name,
    this.addressLine1,
    this.addressLine2,
    this.zip,
    this.city,
    this.action,
    this.onAction,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: moleculeShadowDecoration(ref.scheme.paperCard),
      padding: const EdgeInsets.all(moleculeScreenPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          MoleculeItemTitle(icon: icon, header: name, action: action, onAction: onAction),
          const SizedBox(height: 16),
          const MoleculeItemSeparator(),
          const SizedBox(height: 16),
          formatAddress(addressLine1, addressLine2, city, zip: zip, singleLine: true).label.color(ref.scheme.content),
        ],
      ),
    );
  }
}

// eof
