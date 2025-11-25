import "dart:io";

typedef TemplateEvaluator = String Function(String);

class TemplateProcessor {
  final TemplateEvaluator evaluator;

  TemplateProcessor(this.evaluator);

  // RegExp na nájdenie výrazov medzi {{ a }}
  final _simpleExprRegex = RegExp(r"\{\{(.*?)\}\}");
  final _ifRegex = RegExp(r"\{\{if\s+([^}]+)\}\}(.*?)\{\{/if\}\}", dotAll: true);

  // Získa všetky výrazy zo šablóny
  List<String> getExpressions(String template) {
    return _simpleExprRegex.allMatches(template).map((match) => match.group(1)!.trim()).toList();
  }

  //String process(String template) {
  //  return template.replaceAllMapped(_simpleExprRegex, (match) {
  //    String expr = match.group(1)!.trim();
  //    return evaluator(expr);
  //  });
  //}

  String process(String template) {
    // Najprv spracujeme if bloky
    var result = template.replaceAllMapped(_ifRegex, (match) {
      String condition = match.group(1)!; // boolean expression
      String content = match.group(2)!; // obsah medzi tagmi

      // Vyhodnotíme boolean expression
      bool shouldInclude = evaluator(condition) == "true";

      // Ak je podmienka splnená, spracujeme vnútorný obsah
      return shouldInclude ? process(content) : "";
    });

    // Potom spracujeme jednoduché výrazy
    return result.replaceAllMapped(_simpleExprRegex, (match) {
      String expr = match.group(1)!.trim();
      return evaluator(expr);
    });
  }

  Future<String> processFile(String filePath) async {
    final file = File(filePath);
    final template = await file.readAsString();
    return process(template);
  }
}

// eof
