import "package:core_dart/src/extensions/string.dart";
import "package:test/test.dart";

void main() {
  group("StringExtensions", () {
    test("Shorten string with default parameters", () {
      final input = "abcdefghij";
      final expected = "abc**hij";
      expect(input.shorten(), expected);
    });

    test("Shorten string with custom mask", () {
      final input = "abcdefghij";
      final expected = "abc----hij";
      expect(input.shorten(keepStart: 3, keepEnd: 3, mask: "-", maxLength: 10), expected);
    });

    test("Shorten string with maxLength longer than remaining characters", () {
      final input = "abcdefghij";
      final expected = "abc";
      expect(input.shorten(maxLength: 3), expected);
    });

    test("Shorten string with maxLength shorter than remaining characters", () {
      final input = "abcdefghij";
      final expected = "abc**hij";
      expect(input.shorten(keepStart: 3, keepEnd: 3, maxLength: 8), expected);
    });

    test("Shorten string with maxLength equal to remaining characters", () {
      final input = "abcdefghij";
      final expected = "abch";
      expect(input.shorten(keepStart: 3, keepEnd: 3, maxLength: 4), expected);
    });

    test("Shorten string with length shorter than keepStart + keepEnd", () {
      final input = "abcd";
      final expected = "abcd";
      expect(input.shorten(), expected);
    });
  });
}

// eof
