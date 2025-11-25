String? formatAddress(
  String? addressLine1,
  String? addressLine2,
  String? city, {
  String? zip,
  bool singleLine = false,
}) {
  final address = <String>[];
  if (addressLine1?.isNotEmpty ?? false) {
    address.add(addressLine1!);
  }
  if (addressLine2?.isNotEmpty ?? false) {
    if (address.isNotEmpty) address.add(", ");
    address.add(addressLine2!);
  }
  if (city?.isNotEmpty ?? false) {
    if (address.isNotEmpty) address.add(singleLine ? ", " : "\n");
    if (zip?.isNotEmpty ?? false) {
      address.add("$zip $city");
    } else {
      address.add(city!);
    }
  }
  return address.isNotEmpty ? address.join() : null;
}

// eof
