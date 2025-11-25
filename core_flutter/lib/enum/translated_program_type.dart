import "package:core_dart/core_dart.dart";

import "../extensions/string.dart";

extension ProgramTypeTranslation on ProgramType {
  // TODO: localize core_program_type_reach "Dosiahni", "Reach", "Alcanza"
  // TODO: localize core_program_type_collect "Zbieraj", "Collect", "Colecciona"
  // TODO: localize core_program_type_credit "Kredit", "Credit", "Crédito"

  String get localizedName => "core_program_type_$name".tr();
}

// eof
