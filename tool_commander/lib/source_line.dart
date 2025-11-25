class SourceLine {
  final String file;
  final String line;
  final int lineNumber;

  SourceLine(this.file, this.line, this.lineNumber);

  @override
  String toString() {
    return "SourceLine{line: $line, lineNumber: $lineNumber}";
  }
}

// eof
