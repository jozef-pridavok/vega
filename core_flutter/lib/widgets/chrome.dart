import "dart:io";

import "package:core_flutter/extensions/color.dart";
import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";

class Chrome extends StatelessWidget {
  final Widget child;
  final Color backgroundColor;

  const Chrome({
    Key? key,
    required this.backgroundColor,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = backgroundColor.isDark();

    var statusBarBrightness = isDark ? Brightness.dark : Brightness.light;
    if (!kIsWeb && Platform.isAndroid) {
      statusBarBrightness = isDark ? Brightness.light : Brightness.dark;
    }
    final navigationBarBrightness = isDark ? Brightness.light : Brightness.dark;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarBrightness: statusBarBrightness,
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: statusBarBrightness,
        systemNavigationBarColor: backgroundColor,
        systemNavigationBarIconBrightness: navigationBarBrightness,
      ),
      child: child,
    );
  }
}

// eof
