String snakeToCamel(String key) {
  List<String> parts = key.split("_");
  for (int i = 1; i < parts.length; i++) {
    parts[i] = parts[i][0].toUpperCase() + parts[i].substring(1);
  }
  return parts.join("");
}

Map<String, dynamic> mapToCamelCase(Map<String, dynamic> snakeCaseMap) {
  Map<String, dynamic> converted = {};

  snakeCaseMap.forEach((key, value) {
    String newKey = snakeToCamel(key);
    converted[newKey] = value;
  });

  return converted;
}
