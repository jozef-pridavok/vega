import "package:core_flutter/core_dart.dart" hide Color;
import "package:core_flutter/core_flutter.dart";
import "package:flutter/material.dart";

extension LogLevelColors on LogLevel {
  Color getForeground(MoleculeTheme theme) {
    switch (this) {
      case LogLevel.warning:
        return theme.accent;
      case LogLevel.error:
        return theme.negative;
      default:
        return theme.content;
    }
  }
}

// eof
