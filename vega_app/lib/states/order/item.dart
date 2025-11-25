import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../repositories/order/item.dart";

@immutable
abstract class ItemState {}

class ItemInitial extends ItemState {}

class ItemLoading extends ItemState {}

class ItemSucceed extends ItemState {
  final List<ProductItemModification> modifications;
  final List<ProductItemOption> options;

  ItemSucceed({required this.modifications, required this.options});

  List<ProductItemModification> getModifications(String itemId) =>
      modifications.where((e) => e.itemId == itemId).where((e) => getOptions(e.modificationId).isNotEmpty).toList();

  List<ProductItemOption> getOptions(String modificationId) =>
      options.where((e) => e.modificationId == modificationId).toList();
}

class ItemRefreshing extends ItemSucceed {
  ItemRefreshing({required super.modifications, required super.options});
}

class ItemFailed extends ItemState implements FailedState {
  @override
  final CoreError error;
  ItemFailed(this.error);
}

class ItemNotifier extends StateNotifier<ItemState> with LoggerMixin {
  final String itemId;
  final ItemRepository itemRepository;

  ItemNotifier(this.itemId, {required this.itemRepository}) : super(ItemInitial());

  Future<void> _load({bool reload = false}) async {
    if (!reload && cast<ItemSucceed>(state) != null) return debug(() => errorAlreadyLoaded.toString());

    try {
      if (state is! ItemRefreshing) state = ItemLoading();

      final results = await Future.wait(<Future>[
        itemRepository.readModifications(itemId),
        itemRepository.readOptions(itemId),
      ]);

      final modifications = results[0] as List<ProductItemModification>;
      final options = results[1] as List<ProductItemOption>;

      state = ItemSucceed(modifications: modifications, options: options);
    } on CoreError catch (e) {
      error(e.toString());
      state = ItemFailed(e);
    } catch (e) {
      error(e.toString());
      state = ItemFailed(errorUnexpectedException(e));
    }
  }

  Future<void> load() => _load();

  Future<void> reload() => _load(reload: true);

  Future<void> refresh() async {
    if (state is! ItemSucceed) return;
    final modifications = cast<ItemSucceed>(state)!.modifications;
    final options = cast<ItemSucceed>(state)!.options;
    state = ItemRefreshing(modifications: modifications, options: options);
    await _load(reload: true);
  }
}

// eof
