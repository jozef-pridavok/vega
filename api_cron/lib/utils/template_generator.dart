import "package:api_cron/implementations/configuration_yaml.dart";
import "package:core_dart/core_api_server2.dart";
import "package:core_dart/core_dart.dart";
import "package:core_dart/core_expression.dart";

class TemplateGenerator {
  static TemplateGenerator? _instance;

  final ApiServer2 _api;

  TemplateGenerator._(ApiServer2 api) : _api = api;

  factory TemplateGenerator(ApiServer2 api) {
    return _instance ??= TemplateGenerator._(api);
  }

  String _getTemplateFile(String template) {
    return joinPath([_api.config.localPath, "static", "templates", "$template.html"]);
  }

  String _removeDebug(String html) {
    // remove text from "<!-- /debug -->" to "<!-- debug/ -->"
    final start = "<!-- /debug -->";
    final end = "<!-- debug/ -->";
    final startIndex = html.indexOf(start);
    final endIndex = html.indexOf(end);
    if (startIndex != -1 && endIndex != -1) {
      html = html.substring(0, startIndex) + html.substring(endIndex + end.length);
    }
    return html;
  }

  /*
  Future<String> _generate(String template, Map<String, dynamic> context) async {
    const evaluator = ExpressionEvaluator();

    final templateProcessor = TemplateProcessor((expr) {
      final expression = Expression.parse(expr);
      String? result;
      try {
        result = evaluator.eval(expression, context) as String;
      } catch (ex) {
        _api.log.error(ex.toString());
        result = ex.toString();
      }
      return result;
    });

    final html = await templateProcessor.processFile(_getTemplateFile(template));
    return _removeDebug(html);
  }
  */
  Future<String> _generate(String template, Map<String, dynamic> context) async {
    const evaluator = ExpressionEvaluator();

    final templateProcessor = TemplateProcessor((expr) {
      // Overíme či ide o ifHasValue
      if (expr.startsWith("ifHasValue(")) {
        // Vyberieme meno premennej z ifHasValue("locationName")
        final varName = expr.substring(10, expr.length - 2); // získame "locationName"
        // Vrátime 'true' ak premenná existuje a má hodnotu
        return context.containsKey(varName) && context[varName] != null ? "true" : "false";
      }

      // Štandardné spracovanie výrazu
      final expression = Expression.parse(expr);
      String? result;
      try {
        result = evaluator.eval(expression, context) as String;
      } catch (ex) {
        _api.log.error(ex.toString());
        result = ex.toString();
      }
      return result;
    });

    final html = await templateProcessor.processFile(_getTemplateFile(template));
    return _removeDebug(html);
  }

  Future<String> notifyReservations({
    required String token,
    required String userEmail,
    required String userLanguage,
    required String clientName,
    required String clientLogo,
    String? location,
  }) async {
    const template = "notify_reservations";

    // translate to slovak, english, spanish

    final context = {
      "mobileApiHost": (_api.config as CronApiConfig).mobileApiHost,
      "translate": (String key) => _api.tr(userLanguage, key, namedArgs: {
            "service": "todo service",
            "term": "todo term",
            "location": location ?? "",
            "price": "todo price",
          }),
      "token": token,
      "clientName": clientName,
      "clientLogo": clientLogo,
      "hasValue": (String variable) => switch (variable) {
            "location" => (location?.isNotEmpty ?? false).toString(),
            _ => false.toString(),
          },
    };

    return _generate(template, context);
  }
}

// eof
