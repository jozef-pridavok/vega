import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../repositories/user/user_address.dart";

@immutable
abstract class UserAddressesState {}

class UserAddressesInitial extends UserAddressesState {}

class UserAddressesLoading extends UserAddressesState {}

class UserAddressesSucceed extends UserAddressesState {
  final List<UserAddress> addresses;

  UserAddressesSucceed(this.addresses);
}

class UserAddressesRefreshing extends UserAddressesState {
  final List<UserAddress> addresses;
  UserAddressesRefreshing(this.addresses);
}

class UserAddressesFailed extends UserAddressesState implements FailedState {
  @override
  final CoreError error;

  UserAddressesFailed(this.error);
}

class UserAddressesNotifier extends StateNotifier<UserAddressesState> with StateMixin {
  final UserAddressRepository remoteAddresses;

  UserAddressesNotifier({required this.remoteAddresses}) : super(UserAddressesInitial());

  Future<void> _load({bool reload = false}) async {
    if (!reload && cast<UserAddressesSucceed>(state) != null) return debug(() => errorAlreadyLoaded.toString());

    try {
      if (state is! UserAddressesRefreshing) state = UserAddressesLoading();
      //await Future.delayed(const Duration(seconds: 5));
      final addresses = await remoteAddresses.readAll();
      state = UserAddressesSucceed(addresses ?? []);
    } on CoreError catch (err) {
      warning(err.toString());
      state = UserAddressesFailed(err);
    } on Exception catch (ex) {
      state = UserAddressesFailed(errorFailedToLoadDataEx(ex: ex));
    } catch (e) {
      warning(e.toString());
      state = UserAddressesFailed(errorFailedToLoadData);
    }
  }

  Future<void> load() async => _load();

  Future<void> refresh() async {
    final succeed = cast<UserAddressesSucceed>(state);
    if (succeed != null) state = UserAddressesRefreshing(succeed.addresses);
    await _load(reload: true);
  }
}

// eof
