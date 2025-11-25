import "dart:convert";
import "dart:ui";

import "package:core_flutter/localization/localized_widget.dart";
import "package:flutter/services.dart";

abstract class AssetLoader {
  const AssetLoader();
  Future<Map<String, dynamic>?> load(String path, Locale locale);
}

class RootBundleAssetLoader extends AssetLoader {
  const RootBundleAssetLoader();

  String getLocalePath(String basePath, Locale locale) {
    return '$basePath/${locale.toStringWithSeparator(separator: "-")}.json';
  }

  @override
  Future<Map<String, dynamic>?> load(String path, Locale locale) async {
    var localePath = getLocalePath(path, locale);
    LocalizedWidget.logger.debug(() => "Load asset from $path");
    return json.decode(await rootBundle.loadString(localePath));
  }
}

// eof
