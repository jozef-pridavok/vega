import "package:convert/convert.dart";

/// Simple cipher for encrypting and decrypting strings.
class SimpleCipher {
  final String _key;

  /// Creates a new instance of [SimpleCipher].
  SimpleCipher(this._key);

  /// Encrypts the given [input] string.
  String encrypt(String input) {
    final key = _key.codeUnits;
    final output = <int>[];

    for (var i = 0; i < input.length; i++) {
      final charCode = input.codeUnitAt(i) ^ key[i % key.length];
      output.add(charCode);
    }

    return hex.encode(output);
  }

  /// Decrypts the given [data] string.
  String decrypt(String data) {
    final input = hex.decode(data);
    final key = _key.codeUnits;
    final output = [];

    for (var i = 0; i < input.length; i++) {
      final charCode = input[i] ^ key[i % key.length];
      output.add(String.fromCharCode(charCode));
    }

    return output.join("");
  }
}

// eof
