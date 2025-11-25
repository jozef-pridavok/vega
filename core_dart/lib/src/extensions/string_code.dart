import "../../core_algorithm.dart";

extension StringCodeExtensions on String {
  String removeEmptyLines() => replaceAll(RegExp(r"(?:[\t ]*(?:\r?\n|\r))+"), "\n");

  // Remove leading tabs but keep the indentation, remove empty lines
  String tidyCode() => Indentation(removeEmptyLines()).unindent().trimRight();

  String toCamelCase() {
    if (isEmpty) return "";

    List<String> words = split(RegExp(r"[^a-zA-Z0-9]"));

    String firstWord = words[0].toLowerCase();
    String camelCase = firstWord;

    for (int i = 1; i < words.length; i++) {
      String word = words[i];
      if (word.isNotEmpty) {
        String capitalizedWord = word[0].toUpperCase() + word.substring(1).toLowerCase();
        camelCase += capitalizedWord;
      }
    }

    return camelCase;
  }
}

// eof
