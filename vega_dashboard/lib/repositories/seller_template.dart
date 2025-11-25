import "package:core_flutter/core_dart.dart";

import "../enums/seller_template.dart";

abstract class SellerTemplateRepository {
  Future<bool> create(Client client, SellerTemplate template);
}
