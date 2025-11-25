import "package:core_dart/core_dart.dart";

enum ProgramActionKeys {
  addition,
  subtraction,
}

class ProgramActions {
  final String addition;
  final String subtraction;

  ProgramActions({required this.addition, required this.subtraction});

  static const camel = {
    ProgramActionKeys.addition: "addition",
    ProgramActionKeys.subtraction: "subtraction",
  };

  static const snake = {
    ProgramActionKeys.addition: "addition",
    ProgramActionKeys.subtraction: "subtraction",
  };

  static ProgramActions fromMap(Map<String, dynamic> map, Convention convention) {
    final mapper = convention == Convention.camel ? ProgramActions.camel : ProgramActions.snake;
    return ProgramActions(
      addition: map[mapper[ProgramActionKeys.addition]!] as String,
      subtraction: map[mapper[ProgramActionKeys.subtraction]!] as String,
    );
  }

  Map<String, dynamic> toMap(Convention convention) {
    final mapper = convention == Convention.camel ? ProgramActions.camel : ProgramActions.snake;
    return {
      mapper[ProgramActionKeys.addition]!: addition,
      mapper[ProgramActionKeys.subtraction]!: subtraction,
    };
  }
}

// eof
