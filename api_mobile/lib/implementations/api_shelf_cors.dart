import "package:shelf/shelf.dart";

const accessControlAllowOrigin = "Access-Control-Allow-Origin";
const accessControlExposeHeaders = "Access-Control-Expose-Headers";
const accessControlAllowCredentials = "Access-Control-Allow-Credentials";
const accessControlAllowHeaders = "Access-Control-Allow-Headers";
const accessControlAllowMethods = "Access-Control-Allow-Methods";
const accessControlMaxAge = "Access-Control-Max-Age";
const _vary = "Vary";

const _origin = "origin";

const _defaultHeadersList = [
  "accept",
  "accept-encoding",
  "authorization",
  "content-type",
  "dnt",
  "origin",
  "user-agent",
];

const _defaultMethodsList = ["DELETE", "GET", "OPTIONS", "PATCH", "POST", "PUT"];

Map<String, String> _defaultHeaders = {
  accessControlExposeHeaders: "",
  accessControlAllowCredentials: "true",
  accessControlAllowHeaders: _defaultHeadersList.join(","),
  accessControlAllowMethods: _defaultMethodsList.join(","),
  accessControlMaxAge: "86400",
};

final _defaultHeadersAll = _defaultHeaders.map((key, value) => MapEntry(key, [value]));

typedef OriginChecker = bool Function(String origin);

bool originAllowAll(String origin) => true;

OriginChecker originOneOf(List<String> origins) => (origin) => origins.contains(origin);

Middleware corsHeaders({Map<String, String>? corsHeaders, OriginChecker originChecker = originAllowAll}) {
  final headersAll = corsHeaders?.map((key, value) => MapEntry(key, [value]));
  return (Handler handler) {
    return (Request request) async {
      final origin = request.headers[_origin];
      if (origin == null || !originChecker(origin)) return handler(request);

      final headers = <String, List<String>>{
        ..._defaultHeadersAll,
        ...?headersAll,
      };

      final userProvidedAccessControlAllowOrigin = corsHeaders?[accessControlAllowOrigin];

      if (userProvidedAccessControlAllowOrigin != null) {
        headers[accessControlAllowOrigin] = [userProvidedAccessControlAllowOrigin];
        headers[_vary] = ["Origin"];
      } else {
        headers[accessControlAllowOrigin] = [origin];
      }

      if (request.method == "OPTIONS") return Response.ok(null, headers: headers);

      final response = await handler(request);
      return response.change(headers: {...headers, ...response.headersAll});
    };
  };
}

// eof
