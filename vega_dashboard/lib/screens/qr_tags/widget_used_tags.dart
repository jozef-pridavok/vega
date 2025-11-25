import "package:collection/collection.dart";
import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:core_flutter/states/provider.dart";
import "package:flutter/material.dart" hide Card;
import "package:flutter/services.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:intl/intl.dart";

import "../../states/providers.dart";
import "../../states/qr_tags.dart";
import "../../strings.dart";
import "../../widgets/data_grid.dart";
import "../../widgets/molecule_picker.dart";
import "../../widgets/state_error.dart";
import "../dialog.dart";
import "popup_menu_items.dart";

class UsedTagsWidget extends ConsumerStatefulWidget {
  final String programId;
  UsedTagsWidget({super.key, required this.programId});

  @override
  createState() => _UsedTagsWidgetState();
}

class _UsedTagsWidgetState extends ConsumerState<UsedTagsWidget> {
  String get programId => widget.programId;

  final _pointsFromController = TextEditingController();
  final _pointsToController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      _pointsFromController.text = "0";
      _pointsToController.text = "500";
      ref.read(usedQrTagsLogic.notifier).load(programId);
    });
  }

  @override
  void dispose() {
    super.dispose();
    _pointsFromController.dispose();
    _pointsToController.dispose();
  }

  void refresh() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(usedQrTagsLogic);
    if (state is QrTagsSucceed || state is QrTagsRefreshing) return _buildBody(context, ref, state);
    if (state is QrTagsFailed)
      return StateErrorWidget(usedQrTagsLogic, onReload: () => ref.read(usedQrTagsLogic.notifier).refresh(programId));
    return const CenteredWaitIndicator();
  }

  Widget _buildBody(BuildContext context, WidgetRef ref, QrTagsState state) {
    final isMobile = ref.watch(layoutLogic).isMobile;
    return isMobile ? _mobileLayout(state) : _defaultLayout(state);
  }

  Widget _mobileLayout(QrTagsState state) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _PeriodFilter(state: state, programId: programId)),
                    const MoleculeItemHorizontalSpace(),
                    Expanded(child: _buildPointsFrom()),
                    const MoleculeItemHorizontalSpace(),
                    Expanded(child: _buildPointsTo()),
                  ],
                ),
              ),
            ],
          ),
          MoleculeItemSpace(),
          Expanded(
            child: _GridWidget(
              programId: programId,
              pointsFrom: int.tryParse(_pointsFromController.text) ?? 0,
              pointsTo: int.tryParse(_pointsToController.text) ?? 500,
            ),
          ),
        ],
      );

  Widget _defaultLayout(QrTagsState state) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _PeriodFilter(state: state, programId: programId)),
                    const MoleculeItemHorizontalSpace(),
                    Expanded(child: _buildPointsFrom()),
                    const MoleculeItemHorizontalSpace(),
                    Expanded(child: _buildPointsTo()),
                  ],
                ),
              ),
            ],
          ),
          MoleculeItemSpace(),
          Expanded(
            child: _GridWidget(
              programId: programId,
              pointsFrom: int.tryParse(_pointsFromController.text) ?? 0,
              pointsTo: int.tryParse(_pointsToController.text) ?? 500,
            ),
          ),
        ],
      );

  Widget _buildPointsFrom() => MoleculeInput(
        title: LangKeys.labelPointsFrom.tr(),
        controller: _pointsFromController,
        maxLines: 1,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        onChanged: (value) => refresh(),
      );

  Widget _buildPointsTo() => MoleculeInput(
        title: LangKeys.labelPointsTo.tr(),
        controller: _pointsToController,
        maxLines: 1,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        onChanged: (value) => refresh(),
      );
}

class _PeriodFilter extends ConsumerWidget {
  final QrTagsState state;
  final String programId;
  const _PeriodFilter({required this.state, required this.programId});

  static final periods = [
    SelectItem(value: "7", label: LangKeys.clientUserCardsPeriodLastSevenDays.tr()),
    SelectItem(value: "30", label: LangKeys.clientUserCardsPeriodLastMonth.tr()),
  ];
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MoleculeSingleSelect(
      title: LangKeys.clientUserCardsPeriodTitle.tr(),
      hint: LangKeys.clientUserCardsPeriodHint.tr(),
      items: periods,
      selectedItem: periods.firstWhereOrNull((element) => element.value == state.period.toString()),
      onChanged: (selectedPeriod) =>
          ref.read(usedQrTagsLogic.notifier).refresh(programId, period: int.tryParse(selectedPeriod.value)),
    );
  }
}

class _GridWidget extends ConsumerWidget {
  final String programId;
  final int pointsFrom;
  final int pointsTo;

  _GridWidget({
    required this.programId,
    required this.pointsFrom,
    required this.pointsTo,
  });

  static const _columnCode = "code";
  static const _columnPoints = "points";
  static const _columnUsedBy = "usedBy";
  static const _columnUsedAt = "usedAt";

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final succeed = ref.watch(usedQrTagsLogic) as QrTagsSucceed;
    final qrTags = succeed.qrTags.where((tag) {
      return tag.points >= pointsFrom && tag.points <= pointsTo;
    }).toList();
    return PullToRefresh(
      onRefresh: () => ref.read(usedQrTagsLogic.notifier).refresh(programId),
      child: DataGrid<QrTag>(
        rows: qrTags,
        columns: [
          DataGridColumn(name: _columnCode, label: LangKeys.columnCode.tr()),
          DataGridColumn(name: _columnUsedBy, label: LangKeys.columnUsedBy.tr()),
          DataGridColumn(name: _columnPoints, label: LangKeys.columnPoints.tr()),
          DataGridColumn(name: _columnUsedAt, label: LangKeys.columnUsedAt.tr()),
        ],
        onBuildCell: (column, qrTag) => _buildCell(context, ref, column, qrTag),
        onRowTapUp: (column, qrTag, details) => _popupOperations(context, ref, qrTag, details),
      ),
    );
  }

  Widget _buildCell(BuildContext context, WidgetRef ref, String column, QrTag qrTag) {
    final Locale currentLocale = Localizations.localeOf(context);
    final DateFormat formatter = DateFormat.yMMMMEEEEd(currentLocale.toString());
    final columnMap = <String, ThemedText>{
      _columnCode: qrTag.qrTagId.text.color(ref.scheme.content),
      _columnPoints: qrTag.points.toString().text.color(ref.scheme.content),
      _columnUsedBy: (qrTag.usedByUserNick ?? "-").text.color(ref.scheme.content),
      _columnUsedAt: (qrTag.usedAt != null ? formatter.format(qrTag.usedAt!) : "").text.color(ref.scheme.content),
    };
    final cell = columnMap[column] ?? "?".text.color(ref.scheme.content);
    return cell;
  }

  void _popupOperations(BuildContext context, WidgetRef ref, QrTag qrTag, TapUpDetails details) => showVegaPopupMenu(
        context: context,
        ref: ref,
        details: details,
        title: LangKeys.qrTagPopupMenuTitle.tr(args: [qrTag.usedByUserNick ?? ""]),
        items: [
          if (qrTag.usedByUserId != null) ...{
            QrTagsMenuItems.sendMessage(context, ref, qrTag),
            QrTagsMenuItems.openUserData(context, ref, qrTag),
          }
        ],
      );
}

// eof
