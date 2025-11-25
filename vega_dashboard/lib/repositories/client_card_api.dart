import "dart:io";

import "package:core_flutter/core_dart.dart";

import "client_card.dart";

extension _ClientCardRepositoryFilterCode on ClientCardRepositoryFilter {
  static final _codeMap = {
    ClientCardRepositoryFilter.active: 1,
    ClientCardRepositoryFilter.archived: 2,
  };
  int get code => _codeMap[this]!;
}

class ApiClientCardRepository with LoggerMixin implements ClientCardRepository {
  @override
  Future<List<Card>> readAll({ClientCardRepositoryFilter filter = ClientCardRepositoryFilter.active}) async {
    final res = await ApiClient().get("/v1/dashboard/card/?filter=${filter.code}");
    final json = await res.handleStatusCodeWithJson();
    return (json?["cards"] as JsonArray?)?.map((e) => Card.fromMap(e, Convention.camel)).toList() ?? [];
  }

  @override
  Future<bool> create(Card card, {List<int>? image}) async {
    final path = "/v1/dashboard/card/${card.cardId}";
    final api = ApiClient();
    final res = image != null
        ? await api.postMultipart(path, [image, card.toMap(Convention.camel)])
        : await api.post(path, data: card.toMap(Convention.camel));
    final json = await res.handleStatusCodeWithJson(HttpStatus.created);
    return (json?["affected"] as int?) == 1;
  }

  @override
  Future<bool> update(Card card, {List<int>? image}) async {
    final path = "/v1/dashboard/card/${card.cardId}";
    final api = ApiClient();
    final res = image != null
        ? await api.putMultipart(path, [image, card.toMap(Convention.camel)])
        : await api.put(path, data: card.toMap(Convention.camel));
    final json = await res.handleStatusCodeWithJson(HttpStatus.accepted);
    return (json?["affected"] as int?) == 1;
  }

  @override
  Future<bool> reorder(List<Card> cards) async {
    final ApiResponse res = await ApiClient().put(
      "/v1/dashboard/card/reorder",
      data: {"reorder": cards.map((e) => e.cardId).toList()},
    );
    final json = await res.handleStatusCodeWithJson(HttpStatus.accepted);
    return (json?["affected"] as int?) == cards.length;
  }

  Future<bool> _patch(Card card, Map<String, dynamic> data) async {
    final res = await ApiClient().patch("/v1/dashboard/card/${card.cardId}", data: data);
    final json = await res.handleStatusCodeWithJson(HttpStatus.accepted);
    return (json?["affected"] as int?) == 1;
  }

  @override
  Future<bool> unblock(Card card) => _patch(card, {"blocked": false});

  @override
  Future<bool> block(Card card) => _patch(card, {"blocked": true});

  @override
  Future<bool> archive(Card card) => _patch(card, {"archived": true});
}

// eof
