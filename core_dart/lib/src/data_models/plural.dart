import "package:core_dart/core_dart.dart";

enum PluralKeys {
  zero,
  one,
  two,
  few,
  many,
  other,
}

class Plural {
  String? zero;
  String? one;
  String? two;
  String? few;
  String? many;
  String other;

  Plural({
    this.zero,
    this.one,
    this.two,
    this.few,
    this.many,
    required this.other,
  });

  Plural copyWith({
    String? zero,
    String? one,
    String? two,
    String? few,
    String? many,
    String? other,
  }) {
    return Plural(
      zero: zero ?? this.zero,
      one: one ?? this.one,
      two: two ?? this.two,
      few: few ?? this.few,
      many: many ?? this.many,
      other: other ?? this.other,
    );
  }

  Plural merge(Plural? other) {
    if (other == null) return this;
    return copyWith(
      zero: other.zero,
      one: other.one,
      two: other.two,
      few: other.few,
      many: other.many,
      other: other.other,
    );
  }

  static const camel = {
    PluralKeys.zero: "zero",
    PluralKeys.one: "one",
    PluralKeys.two: "two",
    PluralKeys.few: "few",
    PluralKeys.many: "many",
    PluralKeys.other: "other",
  };

  static const snake = {
    PluralKeys.zero: "zero",
    PluralKeys.one: "one",
    PluralKeys.two: "two",
    PluralKeys.few: "few",
    PluralKeys.many: "many",
    PluralKeys.other: "other",
  };

  static Plural fromMap(Map<String, dynamic> map, Convention convention) {
    final mapper = convention == Convention.camel ? Plural.camel : Plural.snake;
    return Plural(
      zero: map[mapper[PluralKeys.zero]!] as String?,
      one: map[mapper[PluralKeys.one]!] as String?,
      two: map[mapper[PluralKeys.two]!] as String?,
      few: map[mapper[PluralKeys.few]!] as String?,
      many: map[mapper[PluralKeys.many]!] as String?,
      other: map[mapper[PluralKeys.other]!] as String? ?? "{} points",
    );
  }

  Map<String, dynamic> toMap(Convention convention) {
    final mapper = convention == Convention.camel ? Plural.camel : Plural.snake;
    return {
      if (zero != null) mapper[PluralKeys.zero]!: zero,
      if (one != null) mapper[PluralKeys.one]!: one,
      if (two != null) mapper[PluralKeys.two]!: two,
      if (few != null) mapper[PluralKeys.few]!: few,
      if (many != null) mapper[PluralKeys.many]!: many,
      mapper[PluralKeys.other]!: other,
    };
  }

  @override
  String toString() {
    return "Plural{zero: $zero, one: $one, two: $two, few: $few, many: $many, other: $other}";
  }
}

// eof
