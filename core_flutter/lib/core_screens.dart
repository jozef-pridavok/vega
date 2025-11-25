library core_flutter;

import "package:flutter/material.dart";

export "screens/code_camera_scanner.dart";
export "screens/error.dart";
export "screens/screen.dart";
export "screens/webview.dart";

enum ScreenType { mobile, tablet, desktop }

class ScreenFactor {
  /// Screen width in pixels for desktop layout (900)
  static const double desktop = 900;

  /// Screen width in pixels for tablet layout (600)
  static const double tablet = 600;

  /// Screen width in pixels for mobile layout (300)
  //static const double _mobile = 300;

  static ScreenType getScreenType(BuildContext context) {
    double deviceWidth = MediaQuery.of(context).size.shortestSide;
    if (deviceWidth > ScreenFactor.desktop) return ScreenType.desktop;
    if (deviceWidth >= ScreenFactor.tablet) return ScreenType.tablet;
    return ScreenType.mobile;
  }
}


/*
const double atomTabletBreakpoint = 450;
const double atomDesktopBreakpoint = 900;

const double atomDesktopDrawerWidth = 350;
*/

// eof
