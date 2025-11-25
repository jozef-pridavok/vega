import "dart:math" as math;

import "package:core_dart/core_dart.dart";

extension StringExtensions on String {
  String ensureHead(String head) => startsWith(head) ? this : head + this;

  String ensureTail(String tail) => endsWith(tail) ? this : this + tail;

  bool startsWithIgnoringCase(String head) => toLowerCase().startsWith(head.toLowerCase(), 0);

  String formattedVegaNumber() {
    if (length <= 4) return this;
    String normalized = "";
    int mod = length % 3;
    int from = mod != 0 ? 2 : 0;
    for (int i = from; i < length; i++) {
      normalized += this[i];
      final off = i - from + 1;
      if ((off % 3) == 0) normalized += " ";
    }
    return ("${substring(0, from)} $normalized").trim();
  }

  String replaceWithMap(JsonObject payload) {
    final pattern = RegExp(r"{{(.*?)}}");
    return replaceAllMapped(pattern, (match) {
      final key = match.group(1)?.trim();
      return payload[key] != null ? payload[key].toString() : match.group(0)!;
    });
  }

  String shorten({int keepStart = 3, int keepEnd = 3, String mask = "*", int maxLength = 8}) {
    if (length <= keepStart + keepEnd) return this;

    final first = substring(0, keepStart);
    final last = substring(length - keepEnd);

    // (length - keepStart - keepEnd)
    final middle = mask * (math.min(length, maxLength) - keepStart - keepEnd);

    final result = first + middle + last;
    if (result.length <= maxLength) return result;
    return result.substring(0, maxLength);
  }
}

// eof
