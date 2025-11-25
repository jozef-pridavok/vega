import "package:collection/collection.dart";
import "package:core_flutter/core_app.dart";
import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_states.dart";
import "package:flutter/foundation.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../repositories/user/user_cards.dart";
import "../../repositories/user/user_cards_hive.dart";

@immutable
abstract class UserCardsState {}

class UserCardsInitial extends UserCardsState {}

class UserCardsLoading extends UserCardsState {}

class UserCardsSucceed extends UserCardsState {
  final User user;
  final List<UserCard> userCards;
  final Map<Folder, List<UserCard>> userCardsByFolder;

  Folders get folders => user.folders;

  int get selectedFolderIndex {
    var index = folders.list.indexWhere((e) => e.folderId == folders.selectedFolder);
    if (index != -1) return index;

    index = folders.list.indexWhere((e) => e.folderId == Folder.idAll);
    if (index != -1) return index;

    index = folders.list.indexWhere((e) => e.folderId == Folder.idFavorites);
    if (index != -1) return index;

    return 0;
  }

  UserCardsSucceed._({required this.user, required this.userCards, required this.userCardsByFolder});

  static UserCardsSucceed init({required User user, required List<UserCard> userCards}) {
    Folders folders = user.folders;
    Folder? allFolder = folders.list.firstWhereOrNull((e) => e.folderId == Folder.idAll);
    if (allFolder != null) {
      allFolder = allFolder.copyWith(
        userCardIds: allFolder.userCardIds.addNonExisting(userCards.map((e) => e.userCardId).toList()),
      );
      folders = folders.copyWith(list: folders.list.map((e) => e.folderId == Folder.idAll ? allFolder! : e).toList());
      user.folders = folders;
    }
    Map<Folder, List<UserCard>> userCardsByFolder = Map.fromEntries(
      folders.list.map(
        (folder) => MapEntry(
          folder,
          folder.userCardIds
              .map((e) => userCards.firstWhereOrNull((userCard) => userCard.userCardId == e))
              .whereNotNull()
              .toList(),
        ),
      ),
    );
    return UserCardsSucceed._(user: user, userCards: userCards, userCardsByFolder: userCardsByFolder);
  }

  UserCardsSucceed copyWith({User? user, List<UserCard>? userCards}) => UserCardsSucceed.init(
        user: user ?? this.user,
        userCards: userCards ?? this.userCards,
      );
}

class UserCardsFailed extends UserCardsState implements FailedState {
  @override
  final CoreError error;
  @override
  UserCardsFailed(this.error);
}

class UserCardsRefreshing extends UserCardsSucceed {
  UserCardsRefreshing._({required super.user, required super.userCards, required super.userCardsByFolder}) : super._();

  static UserCardsRefreshing init({required User user, required List<UserCard> userCards}) {
    final initialized = UserCardsSucceed.init(user: user, userCards: userCards);
    return UserCardsRefreshing._(user: user, userCards: userCards, userCardsByFolder: initialized.userCardsByFolder);
  }
}

class UserCardsNotifier extends StateNotifier<UserCardsState> with StateMixin {
  final DeviceRepository device;
  final UserCardsRepository remoteUserCards;
  final UserCardsRepository localUserCards;

  UserCardsNotifier({required this.device, required this.remoteUserCards, required this.localUserCards})
      : super(UserCardsInitial());

  Future<void> _load({bool reload = false}) async {
    if (!reload && cast<UserCardsSucceed>(state) != null) return debug(() => errorAlreadyLoaded.toString());

    try {
      if (reload && !await isApiAvailable()) {
        state = UserCardsFailed(errorServiceUnavailable);
        return;
      }

      if (state is! UserCardsRefreshing) state = UserCardsLoading();

      List<UserCard>? userCards = reload ? null : (await localUserCards.readAll() ?? []);

      userCards ??= await _synchronize();

      final user = device.get(DeviceKey.user) as User;
      state = UserCardsSucceed.init(user: user, userCards: userCards);
    } on CoreError catch (e) {
      error(e.toString());
      state = UserCardsFailed(e);
    } catch (e) {
      error(e.toString());
      state = UserCardsFailed(errorUnexpectedException(e));
    }
  }

  Future<void> load() async => _load();

  Future<void> refresh() async {
    final succeed = cast<UserCardsSucceed>(state);
    if (succeed == null) return _load(reload: true);
    state = UserCardsRefreshing.init(user: succeed.user, userCards: succeed.userCards);
    await _load(reload: true);
  }

  Future<void> refreshOnBackground() async {
    final succeed = expect<UserCardsSucceed>(state);
    if (succeed == null) return;
    if (await isApiAvailable()) {
      final userCards = await _synchronize();
      final user = device.get(DeviceKey.user) as User;
      state = UserCardsSucceed.init(user: user, userCards: userCards);
    }
  }

  Future<void> repair() async {
    final succeed = expect<UserCardsFailed>(state);
    if (succeed == null) return;
    if (!await isApiAvailable()) {
      state = UserCardsFailed(errorCannotLoadInOfflineMode);
      return;
    }
    state = UserCardsLoading();
    try {
      HiveUserCardsRepository.clear();
      final userCards = await _synchronize();
      final user = device.get(DeviceKey.user) as User;
      state = UserCardsSucceed.init(user: user, userCards: userCards);
    } on CoreError catch (e) {
      error(e.toString());
      state = UserCardsFailed(e);
    } catch (e) {
      error(e.toString());
      state = UserCardsFailed(errorUnexpectedException(e));
    }
  }

  Future<List<UserCard>> _synchronize() async {
    await sync(
      localUserCards as SyncedLocalRepository<UserCard>,
      remoteUserCards as SyncedRemoteRepository<UserCard>,
      debug: kDebugMode,
    );
    return await localUserCards.readAll() ?? [];
  }

  Future<void> delete(String userCardId) async {
    final succeed = expect<UserCardsSucceed>(state);
    if (succeed == null) return;

    final userCard = succeed.userCards.firstWhereOrNull((e) => e.userCardId == userCardId);
    if (userCard == null) return debug(() => "UserCard not found: $userCardId");

    await localUserCards.delete(userCard);

    var userCards = succeed.userCards;
    state = succeed.copyWith(userCards: userCards);

    if (await isApiAvailable()) {
      //userCards = await _synchronize();
      if (await remoteUserCards.delete(userCard)) {
        await (localUserCards as SyncedLocalRepository).synced(userCard);
        userCards = userCards.where((e) => e.userCardId != userCardId).toList();
        state = succeed.copyWith(userCards: userCards);
      }
    }
  }

  void updateFolders() {
    final succeed = expect<UserCardsSucceed>(state);
    if (succeed == null) return;
    state = succeed.copyWith();
  }

  void updateCard(UserCard userCard) {
    final succeed = expect<UserCardsSucceed>(state);
    if (succeed == null) return;

    final userCardId = userCard.userCardId;
    var src = succeed.userCards.firstWhereOrNull((e) => e.userCardId == userCardId);
    if (src == null) return debug(() => "UserCard not found: $userCardId");

    final dst = src.copyWith(name: userCard.name, number: userCard.number, notes: userCard.notes);

    final userCards = succeed.userCards.map((e) => e.userCardId == userCardId ? dst : e).toList();
    state = succeed.copyWith(userCards: userCards);
  }
}

// eof
