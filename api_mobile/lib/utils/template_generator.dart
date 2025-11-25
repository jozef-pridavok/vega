import "package:core_dart/core_api_server2.dart";
import "package:core_dart/core_dart.dart";
import "package:core_dart/core_expression.dart";

import "../implementations/configuration_yaml.dart";

class TemplateGenerator {
  static TemplateGenerator? _instance;

  final ApiServer2 _api;

  TemplateGenerator._(ApiServer2 api) : _api = api;

  factory TemplateGenerator(ApiServer2 api) {
    return _instance ??= TemplateGenerator._(api);
  }

  String _getTemplateFile(String template) {
    return joinPath([_api.config.localPath, "static", "templates", template, "index.html"]);
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

  Future<String> _generate(String template, Map<String, dynamic> context) async {
    const evaluator = ExpressionEvaluator();

    final templateProcessor = TemplateProcessor((expr) {
      final expression = Expression.parse(expr);
      String? result;
      try {
        result = evaluator.eval(expression, context) as String;
      } catch (ex, st) {
        _api.log.error(ex.toString());
        _api.log.error(st.toString());
        result = ex.toString();
      }
      return result;
    });

    final html = await templateProcessor.processFile(_getTemplateFile(template));
    return _removeDebug(html);
  }

  Future<String> email(String? subject, String body, String? clientName, String? clientLogo) async {
    const template = "email";

    final context = {
      "mobileApiHost": (_api.config as MobileApiConfig).mobileApiHost,
      "subject": subject,
      "body": body,
      "clientName": clientName,
      "clientLogo": clientLogo,
    };

    return _generate(template, context);
  }

  Future<String> linkExpired(String userLanguage) async {
    const template = "link_expired";

    final context = {
      "mobileApiHost": (_api.config as MobileApiConfig).mobileApiHost,
      "translate": (String key) => _api.tr(userLanguage, key),
    };

    return _generate(template, context);
  }

  Future<String> confirmEmail(String userLanguage, String token) async {
    const template = "confirm_email";

    final context = {
      "mobileApiHost": (_api.config as MobileApiConfig).mobileApiHost,
      "translate": (String key) => _api.tr(userLanguage, key),
      "token": token,
    };

    return _generate(template, context);
  }

  Future<String> emailConfirmed(String userLanguage) async {
    const template = "email_confirmed";

    final context = {
      "mobileApiHost": (_api.config as MobileApiConfig).mobileApiHost,
      "translate": (String key) => _api.tr(userLanguage, key),
    };

    return _generate(template, context);
  }

  Future<String> changePasswordRequest(String userLanguage, String token) async {
    const template = "change_password_request";

    final context = {
      "mobileApiHost": (_api.config as MobileApiConfig).mobileApiHost,
      "translate": (String key) => _api.tr(userLanguage, key),
      "token": token,
    };

    return _generate(template, context);
  }

  Future<String> changePassword(String userLanguage, String token) async {
    const template = "change_password";

    final context = {
      "mobileApiHost": (_api.config as MobileApiConfig).mobileApiHost,
      "translate": (String key) => _api.tr(userLanguage, key),
      "token": token,
    };

    return _generate(template, context);
  }

  Future<String> passwordChanged(String userLanguage) async {
    const template = "password_changed";

    final context = {
      "mobileApiHost": (_api.config as MobileApiConfig).mobileApiHost,
      "translate": (String key) => _api.tr(userLanguage, key),
    };

    return _generate(template, context);
  }

  Future<String> operationFailed(String userLanguage) async {
    const template = "operation_failed";

    final context = {
      "mobileApiHost": (_api.config as MobileApiConfig).mobileApiHost,
      "translate": (String key) => _api.tr(userLanguage, key),
    };

    return _generate(template, context);
  }
}

// eof
