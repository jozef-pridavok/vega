import "package:core_flutter/states/provider.dart";
import "package:core_flutter/themes/theme.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

extension WidgetRefTheme on WidgetRef {
  //MoleculeTheme get scheme => watch(ThemeNotifierBase.provider).scheme;
  MoleculeTheme get scheme => watch(themeLogic).scheme;
}

// eof
