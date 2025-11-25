import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:flutter/material.dart" hide Card;
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../repositories/qr_tag.dart";

@immutable
abstract class QrTagsEditorState {}

class QrTagsEditorInitial extends QrTagsEditorState {}

class QrTagsEditorCreating extends QrTagsEditorState {}

class QrTagsEditorCreateSucceed extends QrTagsEditorCreating {}

class QrTagsEditorCreateFailed extends QrTagsEditorCreating implements FailedState {
  @override
  final CoreError error;
  @override
  QrTagsEditorCreateFailed(this.error);
}

class QrTagsEditorNotifier extends StateNotifier<QrTagsEditorState> with LoggerMixin {
  final QrTagRepository qrTagRepository;

  QrTagsEditorNotifier({
    required this.qrTagRepository,
  }) : super(QrTagsEditorInitial());

  Future<void> reset() async {
    state = QrTagsEditorInitial();
  }

  Future<void> createMany(List<String> qrTagIds, String programId, int points) async {
    final currentState = cast<QrTagsEditorInitial>(state);
    if (currentState == null) return debug(() => errorUnexpectedState.toString());
    try {
      state = QrTagsEditorCreating();
      final ok = await qrTagRepository.createMany(qrTagIds, programId, points);
      if (ok) {
        state = QrTagsEditorCreateSucceed();
      } else {
        state = QrTagsEditorCreateFailed(errorFailedToSaveData);
      }
    } on CoreError catch (err) {
      warning(err.toString());
      state = QrTagsEditorCreateFailed(err);
    } on Exception catch (ex) {
      state = QrTagsEditorCreateFailed(errorFailedToSaveDataEx(ex: ex));
    } catch (e) {
      warning(e.toString());
      state = QrTagsEditorCreateFailed(errorFailedToSaveData);
    }
  }
}

// eof
