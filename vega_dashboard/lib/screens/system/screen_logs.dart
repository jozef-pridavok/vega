import "package:core_flutter/core_dart.dart" hide Color;
import "package:core_flutter/core_flutter.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../extensions/log.dart";
import "../../states/logs.dart";
import "../../states/providers.dart";
import "../../strings.dart";
import "../../widgets/button_refresh.dart";
import "../../widgets/data_grid.dart";
import "../../widgets/state_error.dart";
import "../screen_app.dart";

class LogsScreen extends VegaScreen {
  const LogsScreen({super.key});

  @override
  createState() => _LogsScreenState();
}

class _LogsScreenState extends VegaScreenState<LogsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;
      ref.read(logsLogic.notifier).load();
    });
  }

  @override
  String? getTitle() => LangKeys.screenLogsTitle.tr();

  @override
  List<Widget>? buildAppBarActions() {
    final state = ref.watch(logsLogic);
    final refreshing = state.runtimeType == LogsRefreshing;
    return [
      VegaRefreshButton(
        onPressed: () => ref.read(logsLogic.notifier).refresh(),
        isRotating: refreshing,
      ),
      const MoleculeItemHorizontalSpace(),
    ];
  }

  @override
  Widget buildBody(BuildContext context) {
    final logs = ref.watch(logsLogic);
    if (logs is LogsSucceed)
      return const _GridWidget();
    else if (logs is LogsFailed)
      return StateErrorWidget(
        logsLogic,
        getIcon: (error) => error == errorNoData ? AtomIcons.list : null,
        onReload: () => ref.read(logsLogic.notifier).refresh(),
      );
    else
      return const CenteredWaitIndicator();
  }
}

class _GridWidget extends ConsumerWidget {
  const _GridWidget();

  static const _columnDate = "date";
  static const _columnMessage = "message";
  static const _columnInfo = "info";

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final succeed = ref.watch(logsLogic) as LogsSucceed;
    final logs = succeed.logs;
    return PullToRefresh(
      onRefresh: () => ref.read(activeProgramsLogic.notifier).refresh(),
      child: DataGrid<Log>(
        rows: logs,
        columns: [
          DataGridColumn(name: _columnDate, label: LangKeys.columnDate.tr(), width: 200),
          DataGridColumn(name: _columnMessage, label: LangKeys.columnDescription.tr()),
          DataGridColumn(name: _columnInfo, label: LangKeys.columnDescription.tr()),
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

  Widget _buildCell(BuildContext context, WidgetRef ref, String column, Log log) {
    final locale = context.locale.languageCode;
    final columnMap = <String, ThemedText>{
      _columnDate: formatDateTime(locale, log.date).text.color(log.level.getForeground(ref.scheme)),
      _columnMessage: log.message.text.maxLine(2).overflowEllipsis.color(ref.scheme.content),
      _columnInfo: log.info.join("\n").text.maxLine(2).overflowEllipsis.color(ref.scheme.content),
    };
    final cell = columnMap[column] ?? "?".text.color(ref.scheme.content);
    return cell;
    //return isBlocked ? cell.lineThrough : cell;
  }

  void _popupOperations(BuildContext context, WidgetRef ref, Log log, TapUpDetails details) {
    final locale = context.locale.languageCode;
    modalBottomSheet(
      context,
      Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const MoleculeItemSpace(),
          MoleculeItemTitle(header: formatDate(locale, log.date) ?? "?"),
          const MoleculeItemSpace(),
          MoleculeInput(initialValue: log.message, readOnly: true, maxLines: 5),
          if (log.stackTrace != null) ...[
            const MoleculeItemSpace(),
            MoleculeInput(initialValue: log.stackTrace.toString(), readOnly: true, maxLines: 5),
          ],
          const MoleculeItemSpace(),
          for (final info in log.info) ...[
            MoleculeInput(initialValue: info, readOnly: true, maxLines: 5),
            const MoleculeItemSpace(),
          ]
        ],
      ),
    );
  }
}


// eof
