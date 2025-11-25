import "package:core_flutter/core_dart.dart";

extension ClientCopy on Client {
  Client copyWith({
    String? name,
    String? description,
    Color? color,
    Map<String, dynamic>? meta,
    Map<String, dynamic>? settings,
  }) {
    return Client(
      clientId: clientId,
      logo: logo,
      logoBh: logoBh,
      blocked: blocked,
      countries: countries,
      categories: categories,
      name: name ?? this.name,
      description: description ?? this.description,
      color: color ?? this.color,
      settings: settings ?? this.settings,
      meta: meta ?? this.meta,
    );
  }
}

// eof
