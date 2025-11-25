import "package:api_mobile/implementations/configuration_yaml.dart";
import "package:core_dart/core_api_server.dart";
import "package:core_dart/core_api_server2.dart";

import "package:core_dart/core_dart.dart";

//import "package:path/path.dart" as path;

String? storageUrl(
  ApiServer api,
  String? url,
  StorageObject type, {
  DateTime? timeStamp,
}) {
  if (url == null) return null;
  final root = "${api.config.storageUrl}${type.folderName}/";
  if (timeStamp != null) {
    final ts = timeStamp.millisecondsSinceEpoch;
    url = "$url?$ts";
  }
  if (!url.startsWithIgnoringCase("https")) url = root + url;
  if (api.config.isDev && api.config.storageDev2Local.isNotEmpty) {
    if (url.startsWithIgnoringCase("https://vega-dev-static.vega.com/"))
      url = url.replaceFirst(
        "https://vega-dev-static.vega.com/",
        api.config.storageDev2Local,
      );
  }
  return url;
}

String storagePath(StorageConfig config, String file, StorageObject type) {
  final root = "${config.storagePath}${type.folderName}/";
  return joinPath([root, file]);
}

String stripStorageUrl(ApiServer api, String url, StorageObject type) {
  final root = api.config.isDev && api.config.storageDev2Local.isNotEmpty
      ? "${api.config.storageDev2Local}${type.folderName}/"
      : "${api.config.storageUrl}${type.folderName}/";
  if (url.startsWithIgnoringCase(root)) url = url.substring(root.length);
  // remove everything after ?
  final index = url.indexOf("?");
  if (index > 0) url = url.substring(0, index);
  return url;
}

bool urlIsRelativeStorage(String url) {
  for (final type in StorageObject.values) {
    if (url.startsWith("${type.folderName}/")) return true;
  }
  return false;
}

extension ApiServer2Storage on ApiServer2 {
  String? storageUrl(String? url, StorageObject type, {DateTime? timeStamp}) {
    if (url == null) return null;
    final root = "${(config as MobileApiConfig).storageUrl}${type.folderName}/";
    if (timeStamp != null) {
      final ts = timeStamp.millisecondsSinceEpoch;
      url = "$url?$ts";
    }
    if (!url.startsWithIgnoringCase("https")) url = root + url;
    if (config.isDev &&
        (config as MobileApiConfig).storageDev2Local.isNotEmpty) {
      if (url.startsWithIgnoringCase("https://vega-dev-static.vega.com/"))
        url = url.replaceFirst(
          "https://vega-dev-static.vega.com/",
          (config as MobileApiConfig).storageDev2Local,
        );
    }
    return url;
  }

  String storagePath(String file, StorageObject type) {
    final root =
        "${(config as MobileApiConfig).storagePath}${type.folderName}/";
    return joinPath([root, file]);
  }

  String stripStorageUrl(String url, StorageObject type) {
    final root =
        config.isDev && (config as MobileApiConfig).storageDev2Local.isNotEmpty
        ? "${(config as MobileApiConfig).storageDev2Local}${type.folderName}/"
        : "${(config as MobileApiConfig).storageUrl}${type.folderName}/";
    if (url.startsWithIgnoringCase(root)) url = url.substring(root.length);
    // remove everything after ?
    final index = url.indexOf("?");
    if (index > 0) url = url.substring(0, index);
    return url;
  }
}

// eof
