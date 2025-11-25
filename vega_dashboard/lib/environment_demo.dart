import "package:core_flutter/core_app.dart";
import "package:core_flutter/core_dart.dart";

import "environment_developer.dart";

final environment = Environment(
  flavor: Flavor.demo,
  apiUrl: "https://vega-demo-mapi.vega.com",
  apiKey: "10030bd5-9eec-41c5-b72d-f5cbd845c8e2",
  qrCodeKey: "26361f04-090a-42dd-aecb-1c4eaac53d46",
  receiptPassword: "03e7f1ef-4527-49b1-8410-df1cbc58b1f3",
  vapidKey: "**********",
  variables: developerVariables,
);

// eof
