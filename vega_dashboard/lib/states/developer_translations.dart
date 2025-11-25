import "package:collection/collection.dart";
import "package:core_flutter/core_app.dart";
import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:core_flutter/core_redis.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../environment_developer.dart" as developer;

class TranslationConfiguration {
  late final String redisHost;
  late final int redisPort;
  late final int redisDatabase;

  TranslationConfiguration(Map<String, dynamic> variables) {
    redisHost = (variables[developer.translationRedisHost] as String?) ?? "";
    redisPort = (variables[developer.translationRedisPort] as int?) ?? -1;
    redisDatabase = (variables[developer.translationRedisDatabase] as int?) ?? -1;
  }

  bool get isValid {
    return redisHost.isNotEmpty && redisPort > 0 && redisDatabase >= 0;
  }
}

extension HasTranslationConfiguration on F {
  TranslationConfiguration get translationConfig => TranslationConfiguration(variables);
}

enum TranslationModule { cards, dashboard, api }

extension RemoveDiacritics on String {
  bool containsIgnoringDiacritics(String other) =>
      removeDiacritics().toLowerCase().contains(other.removeDiacritics().toLowerCase());
  bool containsIgnoringCase(String other) => toLowerCase().contains(other.toLowerCase());
}

extension TranslationModuleToSelectItem on TranslationModule {
  SelectItem toSelectItem() => SelectItem(label: displayName, value: index.toString());
}

extension TranslationModuleFromSelectItem on SelectItem {
  TranslationModule toTranslationModule() => TranslationModule.values[int.parse(this.value)];
}

extension TranslationModulesToSelectedItems on List<TranslationModule> {
  List<SelectItem> toSelectItems() => map((e) => e.toSelectItem()).toList();
}

extension TranslationScopeToSelectItem on TranslationScope {
  SelectItem toSelectItem() => SelectItem(label: displayName, value: index.toString());
}

extension TranslationScopeFromSelectItem on SelectItem {
  TranslationScope toTranslationScope() => TranslationScope.values[int.parse(this.value)];
}

extension TranslationScopesToSelectedItems on List<TranslationScope> {
  List<SelectItem> toSelectItems() => map((e) => e.toSelectItem()).toList();
}

extension _TranslationModuleExtension on TranslationModule {
  static const _keys = {
    TranslationModule.cards: "vega_app",
    TranslationModule.dashboard: "vega_dashboard",
    TranslationModule.api: "api_mobile",
  };
  String get key => _keys[this]!;

  static const _displayName = {
    TranslationModule.cards: "Vega Cards",
    TranslationModule.dashboard: "Vega Dashboard",
    TranslationModule.api: "Mobile API",
  };
  String get displayName => _displayName[this]!;
}

extension LocaleToSelectItem on Locale {
  SelectItem toSelectItem() => SelectItem(label: "core_language_$languageCode".tr(), value: languageCode);
}

extension LocalesToSelectedItems on List<Locale> {
  List<SelectItem> toSelectItems() => map((e) => e.toSelectItem()).toList();
}

extension LocaleFromSelectItem on SelectItem {
  String toLocale() => this.value;
}

enum TranslationScope { current, pending }

extension _TranslationScopeExtension on TranslationScope {
  static const _keys = {
    TranslationScope.current: "current",
    TranslationScope.pending: "pending",
  };
  String get key => _keys[this]!;

  static const _displayName = {
    TranslationScope.current: "Current (Live)",
    TranslationScope.pending: "Pending",
  };
  String get displayName => _displayName[this]!;
}

class TranslationFilter {
  final TranslationModule module;
  final TranslationScope scope;
  final String language;
  final String term;

  bool get hasTerm => term.isNotEmpty;

  String get keyPrefix => "${module.key}:${scope.key}:$language";

  TranslationFilter({
    required this.module,
    required this.language,
    this.term = "",
    this.scope = TranslationScope.current,
  });

  TranslationFilter copyWith({TranslationModule? module, TranslationScope? scope, String? language, String? term}) =>
      TranslationFilter(
        module: module ?? this.module,
        scope: scope ?? this.scope,
        language: language ?? this.language,
        term: term ?? this.term,
      );
}

class Translation {
  final String key;
  final String value;
  bool isChanged;
  bool markedForDeletion;
  final String displayKey;

  Translation({
    required this.key,
    required this.value,
    this.isChanged = false,
    this.markedForDeletion = false,
    required this.displayKey,
  });

  @override
  toString() => "$key = $value";
}

@immutable
abstract class TranslationState {
  final TranslationFilter filter;
  TranslationState({required this.filter});
}

class TranslationInitial extends TranslationState {
  TranslationInitial(TranslationFilter filter) : super(filter: filter);
}

class TranslationLoading extends TranslationState {
  TranslationLoading({required super.filter});
}

class TranslationLoadingFailed extends TranslationState implements FailedState {
  @override
  final CoreError error;
  TranslationLoadingFailed({required this.error, required super.filter});
}

abstract class TranslationChanges {
  final List<Translation> changes;

  TranslationChanges({required this.changes});
}

class TranslationSaving extends TranslationState implements TranslationChanges {
  @override
  final List<Translation> changes;
  TranslationSaving({required super.filter, required this.changes});
}

class TranslationSaved extends TranslationState implements TranslationChanges {
  @override
  final List<Translation> changes;
  TranslationSaved({required super.filter, required this.changes});
}

class TranslationSavingFailed extends TranslationState implements FailedState, TranslationChanges {
  @override
  final List<Translation> changes;
  @override
  final CoreError error;
  TranslationSavingFailed({required this.error, required super.filter, required this.changes});
}

class TranslationEditing extends TranslationState implements TranslationChanges {
  final List<Translation> remote;
  @override
  final List<Translation> changes;

  late final List<Translation> filtered;
  late final List<Translation> rows;

  String getValue(String displayKey) {
    final key = "${filter.module.key}:${TranslationScope.pending.key}:${filter.language}:$displayKey";
    return changes.firstWhereOrNull((e) => e.key == key)?.value ?? getInitialValue(displayKey);
  }

  String getInitialValue(String displayKey) {
    final key = "${filter.module.key}:${filter.scope.key}:${filter.language}:$displayKey";
    return remote.firstWhereOrNull((e) => e.key == key)?.value ?? "?";
  }

  TranslationEditing({required this.remote, required super.filter, required this.changes}) {
    filtered = filter.hasTerm
        ? remote.where((e) => e.key.contains(filter.term) || e.value.contains(filter.term)).toList()
        : [];

    if (filtered.isEmpty && filter.hasTerm) {
      rows = [];
      return;
    }

    final result = (filtered.isEmpty && !filter.hasTerm ? remote : filtered);

    if (!filter.hasTerm) {
      result.sort((a, b) => a.value.compareTo(b.value));
      rows = result;
      _updateRows(rows);
      return;
    }

    final valuesFirst = result.where((element) => element.value.containsIgnoringDiacritics(filter.term)).toList();
    valuesFirst.sort((a, b) => a.value.compareTo(b.value));
    final valuesFirstKeys = valuesFirst.map((e) => e.key).toList();
    result.removeWhere((element) => valuesFirstKeys.contains(element.key));

    result.sort((a, b) => a.key.compareTo(b.key.toString()));

    rows = valuesFirst + result;
    _updateRows(rows);
  }

  void _updateRows(List<Translation> rows) {
    for (final row in rows) {
      if (filter.scope == TranslationScope.current) {
        final pendingKey = "${filter.module.key}:${TranslationScope.pending.key}:${filter.language}:${row.displayKey}";
        row.isChanged = changes.any((e) => e.key == row.key || e.key == pendingKey);
      } else {
        row.isChanged = changes.any((e) => !e.markedForDeletion && e.key == row.key);
        row.markedForDeletion = changes.any((e) => e.markedForDeletion && e.key == row.key);
      }
    }
  }
}

class TranslationNotifier extends StateNotifier<TranslationState> with StateMixin {
  String _keepValue = "";

  TranslationNotifier() : super(TranslationInitial(TranslationFilter(module: TranslationModule.cards, language: "en")));

  Future<(RedisConnection, int)> _connect() async {
    try {
      final config = F().translationConfig;
      final server = RedisServer(config.redisHost, port: config.redisPort, timeout: Duration(seconds: 5));
      return (await server.connect(), config.redisDatabase);
    } on Exception catch (ex) {
      error(ex.toString());
      throw errorUnexpectedException(ex);
    }
  }

  Future<void> load({
    TranslationModule? module,
    String? language,
    TranslationScope? scope = TranslationScope.current,
  }) async {
    final filter = state.filter.copyWith(module: module, language: language, scope: scope);
    final changes = cast<TranslationChanges>(state)?.changes ?? [];
    state = TranslationLoading(filter: filter);

    RedisConnection? connection;
    try {
      int database;
      (connection, database) = await _connect();
      final command = RedisCommand(RedisClient(connection));
      await command.execute(["SELECT", database]);
      final keys =
          ((await command.execute(["KEYS", "${filter.keyPrefix}:*"])).toDart() as List<dynamic>?)?.cast<String>() ?? [];

      keys.removeWhere((key) => key.startsWith("${filter.keyPrefix}:core_"));
      keys.remove("translation_version");

      final all = await Future.wait(keys.map((key) async {
        final value = (await command.execute(["GET", key])).toDart().toString().trim();
        final displayKey = key.substring("${filter.keyPrefix}:".length);
        return Translation(key: key, value: value, displayKey: displayKey);
      }));

      state = TranslationEditing(remote: all, filter: filter, changes: changes);
    } on CoreError catch (err) {
      error(err.toString());
      state = TranslationLoadingFailed(error: err, filter: filter);
    } on Exception catch (ex) {
      error(ex.toString());
      state = TranslationLoadingFailed(error: errorUnexpectedException(ex), filter: filter);
    } finally {
      connection?.close();
    }
  }

  Future<void> search(String term) async {
    final editing = expect<TranslationEditing>(state);
    if (editing == null) return;
    state = TranslationEditing(
      remote: editing.remote,
      filter: editing.filter.copyWith(term: term.trim()),
      changes: editing.changes,
    );
  }

  Future<void> refresh() async {
    final editing = expect<TranslationEditing>(state);
    if (editing == null) return;
    state = TranslationEditing(
      remote: editing.remote,
      filter: editing.filter.copyWith(),
      changes: editing.changes,
    );
  }

  void keepValue(String value) {
    _keepValue = value;
  }

  bool update(Translation translation) {
    final editing = expect<TranslationEditing>(state);
    if (editing == null) return false;
    String oldValue = editing.getInitialValue(translation.key);
    int oldCount = RegExp(r"{[^}]*}").allMatches(oldValue).length;
    int newCount = RegExp(r"{[^}]*}").allMatches(_keepValue).length;
    if (oldCount != newCount) {
      return false;
    }
    final filter = editing.filter;
    final currentScopeKey = "${filter.module.key}:${TranslationScope.current.key}:${filter.language}:";
    translation.isChanged = true;
    String key = translation.key;
    final changes = editing.changes.where((e) => e.key != key).toList();
    if (key.startsWith(currentScopeKey)) {
      final keyWithoutPrefix = key.substring(currentScopeKey.length);
      final pendingKey = "${filter.module.key}:${TranslationScope.pending.key}:${filter.language}:$keyWithoutPrefix";
      key = pendingKey;
    }
    final updatedTranslation = Translation(
      key: key,
      value: _keepValue,
      isChanged: false,
      markedForDeletion: translation.markedForDeletion,
      displayKey: translation.displayKey,
    );
    changes.add(updatedTranslation);
    state = TranslationEditing(
      remote: editing.remote,
      filter: editing.filter,
      changes: changes,
    );
    return true;
  }

  void discardChanges() {
    final editing = expect<TranslationEditing>(state);
    if (editing == null) return;
    state = TranslationEditing(
      remote: editing.remote,
      filter: editing.filter,
      changes: [],
    );
  }

  void delete(Translation translation) {
    final editing = expect<TranslationEditing>(state);
    if (editing == null || editing.filter.scope != TranslationScope.pending) return;
    translation.markedForDeletion = !translation.markedForDeletion;
    final changes = editing.changes;
    final existing = changes.firstWhereOrNull((e) => e.key == translation.key);
    if (existing != null) changes.removeWhere((e) => e.key == translation.key);
    changes.add(Translation(
      key: translation.key,
      value: translation.value,
      markedForDeletion: translation.markedForDeletion,
      displayKey: translation.displayKey,
    ));
    state = TranslationEditing(
      remote: editing.remote,
      filter: editing.filter,
      changes: changes,
    );
  }

  Future<void> submitChanges() async {
    final editing = cast<TranslationEditing>(state);
    final failed = cast<TranslationSavingFailed>(state);
    if (editing == null && failed == null)
      return debug(() => "Invalid state: ${state.runtimeType} expected TranslationEditing or TranslationSavingFailed");

    final filter = state.filter;
    final changes = cast<TranslationChanges>(state)?.changes ?? [];
    if (changes.isEmpty) return debug(() => "Broken logic detected: nothing to save");

    state = TranslationSaving(filter: filter, changes: changes);

    RedisConnection? connection;
    try {
      int database;
      (connection, database) = await _connect();

      final command = RedisCommand(RedisClient(connection));
      await command.execute(["SELECT", database]);

      final pending = changes.where((e) => e.key.startsWith("${filter.module.key}:${TranslationScope.pending.key}"));

      await Future.wait(pending.map((translation) async {
        if (translation.markedForDeletion) {
          await command.execute(["DEL", translation.key]);
        } else {
          await command.execute(["SET", translation.key, translation.value]);
        }
      }));

      await command.execute([
        "DEL",
        ...changes
            .where((e) => e.markedForDeletion)
            .map((e) => "${filter.module.key}:${TranslationScope.pending.key}:${filter.language}:${e.key}")
      ]);

      state = TranslationSaved(filter: filter, changes: []);
    } on CoreError catch (err) {
      error(err.toString());
      state = TranslationSavingFailed(error: err, filter: filter, changes: changes);
    } on Exception catch (ex) {
      error(ex.toString());
      state = TranslationSavingFailed(error: errorUnexpectedException(ex), filter: filter, changes: changes);
    } finally {
      connection?.close();
    }
  }
}

// eof
