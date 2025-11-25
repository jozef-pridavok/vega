import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:core_flutter/states/provider.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../strings.dart";

bool isValidFromTo(
  WidgetRef ref,
  IntDate? validFrom,
  IntDate? validTo, {
  bool validFromIsRequired = true,
  bool validFromInFuture = true,
  bool validToIsRequired = false,
  bool validToBeforeFrom = true,
}) {
  if (validFrom == null && validFromIsRequired) {
    ref.read(toastLogic.notifier).error(LangKeys.validationValidFromRequired.tr());
    return false;
  }

  final now = IntDate.now().value;
  if (validFrom != null && validFromInFuture) {
    if (validFrom.value < now) {
      ref.read(toastLogic.notifier).error(LangKeys.validationValidFromFuture.tr());
      return false;
    }
  }

  if (validTo == null && validToIsRequired) {
    ref.read(toastLogic.notifier).error(LangKeys.validationValidToRequired.tr());
    return false;
  }

  if (validToBeforeFrom && validFrom != null && validTo != null) {
    if (validTo.value < validFrom.value) {
      ref.read(toastLogic.notifier).error(LangKeys.validationValidToAfterFrom.tr());
      return false;
    }
  }

  return true;
}

bool isOpeningHours(String? val, {bool required = false}) {
  if (required && (val == null || val.isEmpty)) return false;
  if (!required && (val == null || val.isEmpty)) return true;

  // Allow following formats: "07:00 - 13:00", "07:00 - 13:00, 14:00 - 18:00"
  final regex = RegExp(r"^\s*(\d{2}:\d{2}\s*-\s*\d{2}:\d{2}\s*,\s*)*\d{2}:\d{2}\s*-\s*\d{2}:\d{2}\s*$");
  if (!regex.hasMatch(val ?? "")) return false;

  return true;
}

// eof
