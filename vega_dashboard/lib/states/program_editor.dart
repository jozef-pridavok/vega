import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:flutter/foundation.dart";
import "package:flutter/material.dart" hide Card;
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:vega_dashboard/data_models/data_model.dart";

import "../repositories/program.dart";

@immutable
abstract class ProgramEditorState {}

extension ProgramEditorStateToActionButtonState on ProgramEditorState {
  static const stateMap = {
    ProgramEditorSaving: MoleculeActionButtonState.loading,
    ProgramEditorSaved: MoleculeActionButtonState.success,
    ProgramEditorFailed: MoleculeActionButtonState.fail,
  };

  MoleculeActionButtonState get buttonState => stateMap[runtimeType] ?? MoleculeActionButtonState.idle;
}

class ProgramEditorInitial extends ProgramEditorState {}

class ProgramEditorEditing extends ProgramEditorState {
  final Program program;
  final bool isNew;
  ProgramEditorEditing({required this.program, this.isNew = false});
}

class ProgramEditorSaving extends ProgramEditorEditing {
  ProgramEditorSaving({required super.program, required super.isNew});
}

class ProgramEditorSaved extends ProgramEditorSaving {
  ProgramEditorSaved(Program program) : super(program: program, isNew: false);
}

class ProgramEditorFailed extends ProgramEditorSaving implements FailedState {
  @override
  final CoreError error;
  @override
  ProgramEditorFailed(this.error, {required super.program, required super.isNew});
}

class ProgramEditorNotifier extends StateNotifier<ProgramEditorState> with StateMixin {
  final ProgramRepository programRepository;
  final DeviceRepository deviceRepository;

  ProgramEditorNotifier({
    required this.programRepository,
    required this.deviceRepository,
  }) : super(ProgramEditorInitial());

  void reset() => state = ProgramEditorInitial();

  void create() {
    final client = deviceRepository.get(DeviceKey.client) as Client;
    final program = DataModel.createProgram(client);
    state = ProgramEditorEditing(program: program, isNew: true);
  }

  void edit(Program program) {
    state = ProgramEditorEditing(program: program, isNew: false);
  }

  void set({
    String? name,
    ProgramType? type,
    List<Country>? countries,
    String? cardId,
    IntDate? validFrom,
    IntDate? validTo,
    String? description,
    Plural? plural,
    ProgramActions? actions,
    double? qrCodeScanningRatio,
    double? reservationsRatio,
    double? ordersRatio,
    int? digits,
  }) {
    final editing = expect<ProgramEditorEditing>(state);
    if (editing == null) return;
    final program = editing.program.copyWith(
      name: name ?? editing.program.name,
      type: type ?? editing.program.type,
      countries: countries ?? editing.program.countries,
      cardId: cardId ?? editing.program.cardId,
      validFrom: validFrom ?? editing.program.validFrom,
      validTo: validTo ?? editing.program.validTo,
      description: description ?? editing.program.description,
      digits: digits ?? editing.program.digits,
      //plural: plural ?? editing.program.plural,
      //actions: actions ?? editing.program.actions,
      //qrCodeScanningRatio: qrCodeScanningRatio ?? editing.program.qrCodeScanningRatio,
    );
    program.setPlural(plural: plural);
    program.setActions(actions: actions);
    program.setQrCodeScanning(ratio: qrCodeScanningRatio);
    program.setReservations(ratio: reservationsRatio);
    program.setOrders(ratio: ordersRatio);
    state = ProgramEditorEditing(program: program, isNew: editing.isNew);
  }

  Future<void> save(List<int>? image) async {
    final editing = expect<ProgramEditorEditing>(state);
    if (editing == null) return;
    final program = editing.program;
    state = ProgramEditorSaving(program: program, isNew: editing.isNew);
    try {
      final ok = editing.isNew
          ? await programRepository.create(program, image: image)
          : await programRepository.update(program, image: image);
      state = ok
          ? ProgramEditorSaved(program)
          : ProgramEditorFailed(errorFailedToSaveData, program: program, isNew: editing.isNew);
    } on CoreError catch (err) {
      verbose(() => err.toString());
      state = ProgramEditorFailed(err, program: program, isNew: editing.isNew);
    } on Exception catch (ex) {
      verbose(() => ex.toString());
      state = ProgramEditorFailed(errorFailedToSaveDataEx(ex: ex), program: program, isNew: editing.isNew);
    } catch (e) {
      verbose(() => e.toString());
      state = ProgramEditorFailed(errorFailedToSaveData, program: program, isNew: editing.isNew);
    }
  }

  void reedit() {
    final saving = expect<ProgramEditorSaving>(state);
    if (saving == null) return;
    state = ProgramEditorEditing(program: saving.program, isNew: saving.isNew);
  }
}

// eof
