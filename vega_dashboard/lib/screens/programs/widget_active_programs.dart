import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:core_flutter/states/provider.dart";
import "package:flutter/material.dart" hide Card;
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../states/program_patch.dart";
import "../../states/programs.dart";
import "../../states/providers.dart";
import "../../strings.dart";
import "../../widgets/data_grid.dart";
import "../../widgets/state_error.dart";
import "../dialog.dart";
import "../screen_app.dart";
import "popup_menu_items.dart";

class ActiveProgramsWidget extends ConsumerStatefulWidget {
  const ActiveProgramsWidget({super.key});

  @override
  createState() => _WidgetState();
}

class _WidgetState extends ConsumerState<ActiveProgramsWidget> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(activeProgramsLogic.notifier).load());
  }

  void _listenToLogics(BuildContext context) {
    ref.listen<ProgramPatchState>(programPatchLogic, (previous, next) {
      bool closeDialog = next is ProgramPatchFailed;
      if ([ProgramPatchPhase.blocked, ProgramPatchPhase.unblocked].contains(next.phase)) {
        closeDialog = ref.read(activeProgramsLogic.notifier).updated(next.program);
      }
      if ([ProgramPatchPhase.finished].contains(next.phase)) {
        ref.read(activeProgramsLogic.notifier).removed(next.program);
        ref.read(finishedProgramsLogic.notifier).added(next.program);
        closeDialog = true;
      }
      if (closeDialog) closeWaitDialog(context, ref);
      if (next is ProgramPatchFailed) toastCoreError(next.error);
    });
    ref.listen(refreshLogic, (previous, next) {
      final key = ref.read(activeProgramsLogic.notifier).hasRefreshKey(next);
      if (key == null) return;
      ref.read(refreshLogic.notifier).clear(key);
      ref.read(activeProgramsLogic.notifier).load();
    });
  }

  @override
  Widget build(BuildContext context) {
    _listenToLogics(context);
    final state = ref.watch(activeProgramsLogic);
    if (state is ProgramsSucceed)
      return const _GridWidget();
    else if (state is ProgramsFailed)
      return StateErrorWidget(
        activeProgramsLogic,
        getIcon: (error) => error == errorNoData ? AtomIcons.heart : null,
        onReload: () => ref.read(activeProgramsLogic.notifier).refresh(),
      );
    else
      return const CenteredWaitIndicator();
  }
}

class _GridWidget extends ConsumerWidget {
  const _GridWidget();

  static const _columnName = "name";
  static const _columnDescription = "description";
  static const _columnCardName = "cardName";
  static const _columnValidFrom = "validFrom";
  static const _columnValidTo = "validTo";

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isMobile = ref.watch(layoutLogic).isMobile;
    final succeed = ref.watch(activeProgramsLogic) as ProgramsSucceed;
    final programs = succeed.programs;
    return PullToRefresh(
      onRefresh: () => ref.read(activeProgramsLogic.notifier).refresh(),
      child: DataGrid<Program>(
        rows: programs,
        columns: [
          DataGridColumn(name: _columnName, label: LangKeys.columnName.tr()),
          DataGridColumn(name: _columnDescription, label: LangKeys.columnDescription.tr()),
          if (!isMobile) DataGridColumn(name: _columnCardName, label: LangKeys.columnCard.tr()),
          DataGridColumn(name: _columnValidTo, label: LangKeys.columnValidTo.tr()),
        ],
        onBuildCell: (column, program) => _buildCell(context, ref, column, program),
        onRowTapUp: (column, data, details) => _popupOperations(context, ref, data, details),
        onReorder: (oldIndex, newIndex) {
          if (oldIndex < newIndex) newIndex -= 1;
          ref.read(activeProgramsLogic.notifier).reorder(oldIndex, newIndex);
        },
      ),
    );
  }

  Widget _buildCell(BuildContext context, WidgetRef ref, String column, Program program) {
    final locale = context.locale.languageCode;
    final isBlocked = program.blocked;
    final columnMap = <String, ThemedText>{
      _columnName: program.name.text.maxLine(2).overflowEllipsis.color(ref.scheme.content),
      _columnDescription: program.description.text.maxLine(2).overflowEllipsis.color(ref.scheme.content),
      _columnCardName: program.cardName.text.maxLine(2).overflowEllipsis.color(ref.scheme.content),
      _columnValidFrom: formatIntDate(locale, program.validFrom).text.color(ref.scheme.content),
      _columnValidTo: formatIntDate(locale, program.validTo, fallback: LangKeys.cellAlwaysValid.tr())
          .text
          .color(ref.scheme.content),
    };
    final cell = columnMap[column] ?? "?".text.color(ref.scheme.content);
    return isBlocked ? cell.lineThrough : cell;
  }

  void _popupOperations(BuildContext context, WidgetRef ref, Program program, TapUpDetails details) =>
      showVegaPopupMenu(
        context: context,
        ref: ref,
        details: details,
        title: program.name,
        items: [
          ProgramMenuItems.edit(context, ref, program),
          ProgramMenuItems.showCards(context, ref, program),
          if (program.type == ProgramType.reach || program.type == ProgramType.collect) ...{
            ProgramMenuItems.showQrTags(context, ref, program)
          },
          if (program.type == ProgramType.reach) ProgramMenuItems.showRewards(context, ref, program),
          ProgramMenuItems.block(context, ref, program),
          ProgramMenuItems.finish(context, ref, program),
        ],
      );
}

// eof
