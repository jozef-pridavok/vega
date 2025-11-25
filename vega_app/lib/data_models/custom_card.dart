import "package:core_flutter/core_dart.dart";

class CustomCard {
  static Card? _customInstance;

  static get() {
    return _customInstance ??= Card(
      cardId: "",
      clientId: null,
      codeType: CodeType.code128,
      name: "",
      meta: {"custom": true},
    );
  }
}

extension CustomCardExtension on Card {
  bool get isCustom => meta?["custom"] == true;
}

// eof
