import "package:core_flutter/core_dart.dart";

enum SellerPaymentRepositoryFilter {
  lastThreeMonths,
  lastYear,
  onlyUnpaid,
}

extension SellerPaymentRepositoryFilterDates on SellerPaymentRepositoryFilter {
  IntDate get from {
    final now = DateTime.now();
    switch (this) {
      case SellerPaymentRepositoryFilter.lastThreeMonths:
        return IntDate.fromDate(now.subtract(const Duration(days: 90)));
      case SellerPaymentRepositoryFilter.lastYear:
        return IntDate.fromDate(now.subtract(const Duration(days: 365)));
      default:
        throw Exception("Date from is not defined for unpaid filter");
    }
  }

  IntDate get to {
    final now = DateTime.now();
    switch (this) {
      case SellerPaymentRepositoryFilter.lastThreeMonths:
        return IntDate.fromDate(now);
      case SellerPaymentRepositoryFilter.lastYear:
        return IntDate.fromDate(now.subtract(const Duration(days: 90)));
      default:
        throw Exception("Date from is not defined for unpaid filter");
    }
  }
}

abstract class SellerPaymentRepository {
  Future<List<SellerPayment>> read(SellerPaymentRepositoryFilter filter);
  Future<SellerPayment> request(List<ClientPayment> payments, String invoiceNumber, IntDate? dueDate);
}

// eof
