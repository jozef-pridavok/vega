import "package:core_dart/core_dart.dart";

import "../implementations/configuration_yaml.dart";

String? storageUrl(CronApiConfig config, String? url, StorageObject type, {DateTime? timeStamp}) {
  if (url == null) return null;
  url = joinUrl([config.storageHost, type.name, url]);
  if (timeStamp != null) {
    final ts = timeStamp.millisecondsSinceEpoch;
    url = "$url?$ts";
  }
  return url;
}

// eof
