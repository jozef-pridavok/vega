import "package:core_dart/core_enums.dart";

import "../extensions/string.dart";

extension GenderTranslation on Gender {
  // TODO: localize core_gender_male "Muž", "Male", "Masculino"
  // TODO: localize core_gender_female "Žena", "Female", "Femenino"
  // TODO: localize core_gender_not_set "Nenastavené", "Not set", "No establecido"

  static final _displayMap = {
    Gender.man: "core_gender_male".tr(),
    Gender.woman: "core_gender_female".tr(),
  };

  String get display => _displayMap[this] ?? "core_gender_not_set".tr();
}

// eof
