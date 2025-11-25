import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:core_flutter/states/provider.dart";
import "package:flutter/material.dart" hide Card;
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../states/programs.dart";
import "../../states/providers.dart";
import "../../strings.dart";
import "../../widgets/data_grid.dart";
import "../../widgets/state_error.dart";

class ArchivedProgramsWidget extends ConsumerStatefulWidget {
  const ArchivedProgramsWidget({super.key});

  @override
  createState() => _WidgetState();
}

class _WidgetState extends ConsumerState<ArchivedProgramsWidget> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(archivedProgramsLogic.notifier).load());
  }

  void _listenToLogics(BuildContext context) {
    ref.listen(refreshLogic, (previous, next) {
      final key = ref.read(archivedProgramsLogic.notifier).hasRefreshKey(next);
      if (key == null) return;
      ref.read(refreshLogic.notifier).clear(key);
      ref.read(archivedProgramsLogic.notifier).load();
    });
  }

  @override
  Widget build(BuildContext context) {
    _listenToLogics(context);
    final state = ref.watch(archivedProgramsLogic);
    if (state is ProgramsSucceed)
      return const _GridWidget();
    else if (state is ProgramsFailed)
      return StateErrorWidget(
        archivedProgramsLogic,
        getIcon: (error) => error == errorNoData ? AtomIcons.heart : null,
        onReload: () => ref.read(archivedProgramsLogic.notifier).refresh(),
      );
    else
      return const CenteredWaitIndicator();
  }
}

class _GridWidget extends ConsumerWidget {
  const _GridWidget();

  static const _columnName = "name";
  static const _columnDescription = "description";
  static const _columnValidTo = "validTo";

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final succeed = ref.watch(archivedProgramsLogic) as ProgramsSucceed;
    final programs = succeed.programs;
    return PullToRefresh(
      onRefresh: () => ref.read(archivedProgramsLogic.notifier).refresh(),
      child: DataGrid<Program>(
        rows: programs,
        columns: [
          DataGridColumn(name: _columnName, label: LangKeys.columnName.tr()),
          DataGridColumn(name: _columnDescription, label: LangKeys.columnDescription.tr()),
          DataGridColumn(name: _columnValidTo, label: LangKeys.columnValidTo.tr()),
        ],
        onBuildCell: (column, program) => _buildCell(context, ref, column, program),
      ),
    );
  }

  Widget _buildCell(BuildContext context, WidgetRef ref, String column, Program program) {
    final locale = context.locale.languageCode;
    final isBlocked = program.blocked;
    final columnMap = <String, ThemedText>{
      _columnName: program.name.text.maxLine(2).overflowEllipsis.color(ref.scheme.content),
      _columnDescription: program.description.text.maxLine(2).overflowEllipsis.color(ref.scheme.content),
      _columnValidTo: formatIntDate(locale, program.validTo, fallback: LangKeys.cellAlwaysValid.tr())
          .text
          .color(ref.scheme.content),
    };
    final cell = columnMap[column] ?? "?".text.color(ref.scheme.content);
    return isBlocked ? cell.lineThrough : cell;
  }
}

// eof
