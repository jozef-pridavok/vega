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

class PreparedProgramsWidget extends ConsumerStatefulWidget {
  const PreparedProgramsWidget({super.key});

  @override
  createState() => _WidgetState();
}

class _WidgetState extends ConsumerState<PreparedProgramsWidget> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(preparedProgramsLogic.notifier).load());
  }

  void _listenToLogics(BuildContext context) {
    ref.listen<ProgramPatchState>(programPatchLogic, (previous, next) {
      bool closeDialog = next is ProgramPatchFailed;
      if ([ProgramPatchPhase.started].contains(next.phase)) {
        ref.read(activeProgramsLogic.notifier).added(next.program);
        ref.read(preparedProgramsLogic.notifier).removed(next.program);
        closeDialog = true;
      }
      if (next.phase == ProgramPatchPhase.archived) {
        ref.read(preparedProgramsLogic.notifier).removed(next.program);
        ref.read(archivedProgramsLogic.notifier).added(next.program);
        closeDialog = true;
      }
      if (closeDialog) closeWaitDialog(context, ref);
      if (next is ProgramPatchFailed) toastCoreError(next.error);
    });
    ref.listen(refreshLogic, (previous, next) {
      final key = ref.read(preparedProgramsLogic.notifier).hasRefreshKey(next);
      if (key == null) return;
      ref.read(refreshLogic.notifier).clear(key);
      ref.read(preparedProgramsLogic.notifier).load();
    });
  }

  @override
  Widget build(BuildContext context) {
    _listenToLogics(context);
    final state = ref.watch(preparedProgramsLogic);
    if (state is ProgramsSucceed)
      return const _GridWidget();
    else if (state is ProgramsFailed)
      return StateErrorWidget(
        preparedProgramsLogic,
        getIcon: (error) => error == errorNoData ? AtomIcons.heart : null,
        onReload: () => ref.read(preparedProgramsLogic.notifier).refresh(),
      );
    else
      return const CenteredWaitIndicator();
  }
}

class _GridWidget extends ConsumerWidget {
  const _GridWidget();

  static const _columnName = "name";
  //static const _columnDescription = "description";
  static const _columnValidFrom = "validFrom";
  static const _columnValidTo = "validTo";
  //static bool _reorderInProgress = false;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final succeed = ref.watch(preparedProgramsLogic) as ProgramsSucceed;
    final programs = succeed.programs;
    return PullToRefresh(
      onRefresh: () => ref.read(preparedProgramsLogic.notifier).refresh(),
      child: DataGrid<Program>(
        rows: programs,
        columns: [
          DataGridColumn(name: _columnName, label: LangKeys.columnName.tr()),
          //DataGridColumn(name: _columnDescription, label: LangKeys.columnDescription.tr()),
          DataGridColumn(name: _columnValidFrom, label: LangKeys.columnValidFrom.tr()),
          DataGridColumn(name: _columnValidTo, label: LangKeys.columnValidTo.tr()),
        ],
        onBuildCell: (column, program) => _buildCell(context, ref, column, program),
        onRowTapUp: (column, data, details) => _popupOperations(context, ref, data, details),
        onReorder: (oldIndex, newIndex) {
          if (oldIndex < newIndex) newIndex -= 1;
          ref.read(preparedProgramsLogic.notifier).reorder(oldIndex, newIndex);
        },
      ),
    );
  }

  Widget _buildCell(BuildContext context, WidgetRef ref, String column, Program program) {
    final locale = context.locale.languageCode;
    final isBlocked = program.blocked;
    final columnMap = <String, ThemedText>{
      _columnName: program.name.text.maxLine(2).overflowEllipsis.color(ref.scheme.content),
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
          if (program.type == ProgramType.reach) ...{
            ProgramMenuItems.showRewards(context, ref, program),
          },
          if (program.type == ProgramType.reach || program.type == ProgramType.collect) ...{
            ProgramMenuItems.showQrTags(context, ref, program),
          },
          ProgramMenuItems.start(context, ref, program),
          ProgramMenuItems.archive(context, ref, program),
        ],
      );
}

// eof
