import "package:core_dart/core_dart.dart";

enum ClientReportType {
  totalUsers,
  newUsers,
  totalCards,
  activeCards,
  newCards,
  reservationDates,
}

extension ClientReportTypeParam on ClientReportType {
  static final _paramCount = {
    ClientReportType.totalUsers: 0,
    ClientReportType.newUsers: 2,
    ClientReportType.totalCards: 0,
    ClientReportType.activeCards: 2,
    ClientReportType.newCards: 2,
    ClientReportType.reservationDates: 3,
  };
  int get paramCount => _paramCount[this]!;

  static final _paramNames = <ClientReportType, List<String>>{
    ClientReportType.totalUsers: [],
    ClientReportType.newUsers: ["from", "days"],
    ClientReportType.totalCards: [],
    ClientReportType.activeCards: ["from", "days"],
    ClientReportType.newCards: ["from", "days"],
    ClientReportType.reservationDates: ["from", "days", "status"],
  };
  List<String> get paramNames => _paramNames[this]!;

  static final _paramTypes = <ClientReportType, List<String>>{
    ClientReportType.totalUsers: [],
    ClientReportType.newUsers: ["IntDate", "int"],
    ClientReportType.totalCards: [],
    ClientReportType.activeCards: ["IntDate", "int"],
    ClientReportType.newCards: ["IntDate", "int"],
    ClientReportType.reservationDates: ["IntDate", "int", "int"],
  };
  List<String> get paramTypes => _paramTypes[this]!;

  static final _paramMandatories = <ClientReportType, List<bool>>{
    ClientReportType.totalUsers: [],
    ClientReportType.newUsers: [true, true],
    ClientReportType.totalCards: [],
    ClientReportType.activeCards: [true, true],
    ClientReportType.newCards: [true, true],
    ClientReportType.reservationDates: [true, true, true],
  };
  List<bool> get paramMandatories => _paramMandatories[this]!;

  String get paramsDefinition {
    final params = paramNames.map((param) {
      final index = paramNames.indexOf(param);
      return "$param:${paramTypes[index] + (paramMandatories[index] ? "!" : "")}";
    });
    return params.join(", ");
  }

  String redisKey({JsonObject params = const {}}) {
    final key = <String>[name];
    for (var i = 0; i < paramCount; i++) {
      final paramName = paramNames[i];
      final paramValue = getParam(params, paramName);
      key.add(paramValue.toString());
    }
    return key.join(":");
  }

  bool isValidParams(JsonObject params) {
    // check if all mandatory params are present
    if (paramMandatories.any((m) => m)) {
      if (paramNames.any((n) => !params.containsKey(n))) return false;
    }
    final runtimeParamTypes =
        paramTypes.map((t) => t.replaceAll("IntDate", "int").replaceAll("IntMonth", "int")).toList();
    // check if all params are of the correct type
    if (paramTypes.any((t) => t.isNotEmpty)) {
      if (paramNames.any((n) => !runtimeParamTypes[paramNames.indexOf(n)].contains(params[n].runtimeType.toString())))
        return false;
    }
    return true;
  }

  bool isNotValidParams(JsonObject params) {
    return !isValidParams(params);
  }

  T getParam<T>(JsonObject params, String key) {
    if (!params.containsKey(key)) throw ArgumentError("missing $key");
    final paramMandatory = paramMandatories[paramNames.indexOf(key)];
    if (paramMandatory && params[key] == null) {
      throw ArgumentError("$key is mandatory");
    } else if (params[key] == null) {
      return null as T;
    }
    final paramType = paramTypes[paramNames.indexOf(key)];
    if (paramType == "IntDate") {
      final intVal = tryParseInt(params[key]);
      final intDate = IntDate.parseInt(intVal);
      if (intDate == null) throw ArgumentError("$key is not a valid IntDate");
      return intDate as T;
    }
    return params[key] as T;
  }
}

// eof
