import "package:core_flutter/core_dart.dart";

import "../data_models/dashboard.dart";

abstract class DashboardRepository {
  Future<Dashboard> read();
  Future<ClientReportSetData> clientReport(ClientReportSet set);
}

// eof
