extension MapExtension on Map<dynamic, dynamic> {
  //Map<String, dynamic> get asStringMap => cast<String, dynamic>();

  Map<String, dynamic> get asStringMap => map((key, value) => MapEntry<String, dynamic>(key.toString(), value));
}

// eof
