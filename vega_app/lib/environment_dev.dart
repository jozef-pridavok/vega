import "package:core_flutter/core_app.dart";
import "package:core_flutter/core_dart.dart";

final environment = Environment(
  flavor: Flavor.dev,
  apiUrl: const String.fromEnvironment(
    "API",
    defaultValue: "https://vega-dev-mapi.vega.com",
  ),
  apiKey: "3a26f931-85c2-47ea-81cb-04276280423d",
  qrCodeKey: "00f2ebbc-16ec-4e83-b1d3-2ec73c1b6fb0",
  receiptPassword: "3773e71b-7bb2-465a-92a1-c2880e13b855",
  vapidKey: "**********",
);

// eof
