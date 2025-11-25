import "package:core_dart/core_dart.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../core_screens.dart";

class LayoutState {
  final double screenWidth;
  final double screenHeight;

  final bool isPortrait;
  final bool isMobile;
  final bool isTablet;
  final bool isDesktop;

  LayoutState({
    required this.screenWidth,
    required this.screenHeight,
    required this.isPortrait,
    required this.isMobile,
    required this.isTablet,
    required this.isDesktop,
  });

  factory LayoutState.fromContext(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context);
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;
    final isPortrait = screenWidth > screenHeight;
    //final minWidth = min(screenWidth, screenHeight);
    //final isMobile = minWidth < atomTabletBreakpoint;
    //final isTablet = minWidth >= atomTabletBreakpoint && minWidth < atomDesktopBreakpoint;
    //final isDesktop = minWidth >= atomDesktopBreakpoint;
    final screenType = ScreenFactor.getScreenType(context);
    return LayoutState(
      screenWidth: screenWidth,
      screenHeight: screenHeight,
      isPortrait: isPortrait,
      isMobile: screenType == ScreenType.mobile, //isMobile,
      isTablet: screenType == ScreenType.tablet, //isTablet,
      isDesktop: screenType == ScreenType.desktop, //isDesktop,
    );
  }

  static LayoutState initial() => LayoutState(
        screenWidth: 0,
        screenHeight: 0,
        isPortrait: false,
        isMobile: false,
        isTablet: false,
        isDesktop: false,
      );
}

/*
class LayoutNotifier extends StateNotifier<LayoutState> {
  LayoutNotifier() : super(LayoutState.empty());

  Future<void> update(BuildContext context) async {
    final layout = LayoutState.fromContext(context);
    state = layout;
  }
}
*/

class LayoutNotifier extends StateNotifier<LayoutState> /*LayoutNotifierBase*/ with LoggerMixin {
  LayoutNotifier() : super(LayoutState.initial());

  Future<void> update(BuildContext context) async {
    final layout = LayoutState.fromContext(context);
    state = layout;
  }
}
// eof
