import "package:core_flutter/core_app.dart";
import "package:core_flutter/core_dart.dart";

import "environment_developer.dart";

final environment = Environment(
  flavor: Flavor.qa,
  apiUrl: const String.fromEnvironment(
    "API",
    defaultValue: "https://vega-qa-mapi.vega.com",
  ),
  apiKey: "d82e18de-e830-4ea1-8aa6-3e7a3beca2c6",
  qrCodeKey: "4d43d168-a202-45d2-9dd9-9674d4126ecc",
  receiptPassword: "77928dee-d460-4555-8a09-ac7e5f8c4704",
  vapidKey: "**********",
  variables: developerVariables,
);

// eof
