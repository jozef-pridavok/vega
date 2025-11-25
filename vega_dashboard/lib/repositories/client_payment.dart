import "package:core_flutter/core_dart.dart";

enum ClientPaymentRepositoryFilter {
  unpaid,
  lastThreeMonths,
  lastYear,
  previousYear,
}

enum SellerPaymentRepositoryClientFilter {
  onlyReadyForRequest,
  onlyWaitingForClient,
}

extension ClientPaymentRepositoryFilterDates on ClientPaymentRepositoryFilter {
  IntDate get dateFrom {
    final now = DateTime.now();
    switch (this) {
      case ClientPaymentRepositoryFilter.lastThreeMonths:
        return IntDate.fromDate(now.subtract(const Duration(days: 90)));
      case ClientPaymentRepositoryFilter.lastYear:
        return IntDate.fromDate(now.subtract(const Duration(days: 365)));
      case ClientPaymentRepositoryFilter.previousYear:
        return IntDate.fromDate(now.subtract(const Duration(days: 730)));
      case ClientPaymentRepositoryFilter.unpaid:
        throw Exception("Date from is not defined for unpaid filter");
    }
  }

  IntDate get dateTo {
    final now = DateTime.now();
    switch (this) {
      case ClientPaymentRepositoryFilter.lastThreeMonths:
        return IntDate.fromDate(now);
      case ClientPaymentRepositoryFilter.lastYear:
        return IntDate.fromDate(now.subtract(const Duration(days: 90)));
      case ClientPaymentRepositoryFilter.previousYear:
        return IntDate.fromDate(now.subtract(const Duration(days: 365)));
      case ClientPaymentRepositoryFilter.unpaid:
        throw Exception("Date to is not defined for unpaid filter");
    }
  }
}

abstract class ClientPaymentRepository {
  Future<(List<ClientPaymentProvider>, List<ClientPayment>)> read({
    bool onlyUnpaid = false,
    IntDate? dateFrom,
    IntDate? dateTo,
  });
  Future<String> startStripePayment(ClientPaymentProvider provider, List<ClientPayment> payments, Price price);
  Future<bool> startDemoCreditPayment(ClientPaymentProvider provider, List<ClientPayment> payments, Price price);
  Future<int> confirm(ClientPaymentProvider provider, List<ClientPayment> payments, JsonObject? payload);
  Future<int> cancel(ClientPaymentProvider provider, List<ClientPayment> payments, JsonObject? payload);

  Future<List<ClientPayment>> forSeller(SellerPaymentRepositoryClientFilter filter);
}

// eof
