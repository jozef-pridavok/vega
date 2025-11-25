import "../core_dart.dart";
import "../extensions/string.dart";

extension DayTranslation on Day {
  // TODO: localize core_day_monday "Pondelok", "Monday", "Lunes"
  // TODO: localize core_day_tuesday "Utorok", "Tuesday", "Martes"
  // TODO: localize core_day_wednesday "Streda", "Wednesday", "Miércoles"
  // TODO: localize core_day_thursday "Štvrtok", "Thursday", "Jueves"
  // TODO: localize core_day_friday "Piatok", "Friday", "Viernes"
  // TODO: localize core_day_saturday "Sobota", "Saturday", "Sábado"
  // TODO: localize core_day_sunday "Nedeľa", "Sunday", "Domingo"

  String get localizedName => "core_day_$name".tr();
}

extension RelativeDayTranslation on RelativeDay {
  // TODO: localize core_relative_day_yesterday "Včera", "Yesterday", "Ayer"
  // TODO: localize core_relative_day_today "Dnes", "Today", "Hoy"
  // TODO: localize core_relative_day_tomorrow "Zajtra", "Tomorrow", "Mañana"

  String get localizedName => "core_relative_day_$name".tr();
}

// eof
