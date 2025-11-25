import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:flutter/material.dart" hide Card;
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../repositories/qr_tag.dart";

@immutable
abstract class QrTagsState {
  final int? period;
  QrTagsState({required this.period});
}

class QrTagsInitial extends QrTagsState {
  QrTagsInitial({required super.period});
}

class QrTagsLoading extends QrTagsState {
  QrTagsLoading({required super.period});
}

class QrTagsSucceed extends QrTagsState {
  final List<QrTag> qrTags;
  QrTagsSucceed({required this.qrTags, required super.period});
}

class QrTagsDeleteSucceed extends QrTagsSucceed {
  QrTagsDeleteSucceed({required super.qrTags, required super.period});
}

class QrTagsRefreshing extends QrTagsSucceed {
  QrTagsRefreshing({required super.qrTags, required super.period});
}

class QrTagsFailed extends QrTagsState implements FailedState {
  @override
  final CoreError error;
  @override
  QrTagsFailed(this.error, {required super.period});
}

class QrTagsDeleteFailed extends QrTagsFailed {
  QrTagsDeleteFailed(super.error, {required super.period});
}

class QrTagsNotifier extends StateNotifier<QrTagsState> with LoggerMixin {
  final QrTagRepositoryFilter filter;
  final QrTagRepository qrTagRepository;

  QrTagsNotifier(
    this.filter, {
    required this.qrTagRepository,
  }) : super(QrTagsInitial(period: 30));

  Future<void> load(String programId, {bool reload = false, int? period}) async {
    if (!reload && cast<QrTagsSucceed>(state) != null) return debug(() => errorAlreadyLoaded.toString());
    period ??= state.period;

    try {
      if (state is! QrTagsRefreshing) state = QrTagsLoading(period: period);
      final qrTags = await qrTagRepository.readAll(programId, filter: filter, period: period);
      state = QrTagsSucceed(qrTags: qrTags, period: period);
    } on CoreError catch (err) {
      warning(err.toString());
      state = QrTagsFailed(err, period: period);
    } on Exception catch (ex) {
      state = QrTagsFailed(errorFailedToLoadDataEx(ex: ex), period: period);
    } catch (e) {
      warning(e.toString());
      state = QrTagsFailed(errorFailedToLoadData, period: period);
    }
  }

  Future<void> refresh(String programId, {int? period}) async {
    final succeed = cast<QrTagsSucceed>(state);
    if (succeed == null) return load(programId, reload: true);
    state = QrTagsRefreshing(qrTags: succeed.qrTags, period: state.period);
    await load(programId, reload: true, period: period ?? state.period);
  }

  Future<void> deleteMany(List<String> qrTagIds) async {
    final currentState = cast<QrTagsSucceed>(state);
    if (currentState == null) return debug(() => errorUnexpectedState.toString());
    try {
      final affected = await qrTagRepository.archiveMany(qrTagIds);
      if (affected > 0) {
        state = QrTagsDeleteSucceed(qrTags: currentState.qrTags, period: currentState.period);
      } else {
        state = QrTagsDeleteFailed(errorFailedToDeleteData, period: currentState.period);
      }
    } on CoreError catch (err) {
      warning(err.toString());
      state = QrTagsDeleteFailed(err, period: currentState.period);
    } on Exception catch (ex) {
      state = QrTagsDeleteFailed(errorFailedToLoadDataEx(ex: ex), period: currentState.period);
    } catch (e) {
      warning(e.toString());
      state = QrTagsDeleteFailed(errorFailedToLoadData, period: currentState.period);
    }
  }
}

// eof
