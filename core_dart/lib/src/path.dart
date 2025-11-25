import "package:path/path.dart" as path;

String normalizeUrl(String url) {
  // remove last /
  if (url.endsWith("/")) {
    url = url.substring(0, url.length - 1);
  }
  return url;
}

String joinPath(Iterable<String> parts) => path.joinAll(parts);

String joinUrl(Iterable<String> parts) {
  final baseUri = Uri.parse(parts.first);
  final pathSegments = Uri(pathSegments: parts.skip(1));
  return baseUri.replace(path: pathSegments.path).toString();
}

// eof
