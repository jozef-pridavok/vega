import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:core_flutter/states/provider.dart";
import "package:flutter/material.dart" hide Card;
import "package:flutter/services.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../states/providers.dart";
import "../../states/qr_tags.dart";
import "../../strings.dart";
import "../../widgets/data_grid.dart";
import "../../widgets/state_error.dart";
import "../dialog.dart";
import "../screen_app.dart";

class UnusedTagsWidget extends ConsumerStatefulWidget {
  final String programId;
  UnusedTagsWidget({super.key, required this.programId});

  @override
  createState() => _UnusedTagsWidgetState();
}

class _UnusedTagsWidgetState extends ConsumerState<UnusedTagsWidget> {
  String get programId => widget.programId;

  final _pointsFromController = TextEditingController();
  final _pointsToController = TextEditingController();

  final Map<String, bool> checked = {};

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      _pointsFromController.text = "0";
      _pointsToController.text = "500";
      ref.read(unusedQrTagsLogic.notifier).load(programId);
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

  void _listenToLogic(BuildContext context) {
    ref.listen(unusedQrTagsLogic, (previous, next) {
      bool failed = next is QrTagsDeleteFailed;
      bool operationCompleted = failed || next is QrTagsDeleteSucceed;
      if (operationCompleted) {
        closeWaitDialog(context, ref);
        ref.read(unusedQrTagsLogic.notifier).refresh(programId);
      }
      if (failed) return toastCoreError(next.error);
    });
  }

  @override
  Widget build(BuildContext context) {
    _listenToLogic(context);
    final state = ref.watch(unusedQrTagsLogic);
    if (state is QrTagsSucceed || state is QrTagsRefreshing) return _buildBody(context, ref);
    if (state is QrTagsFailed)
      return StateErrorWidget(unusedQrTagsLogic,
          onReload: () => ref.read(unusedQrTagsLogic.notifier).refresh(programId));
    return const CenteredWaitIndicator();
  }

  Widget _buildBody(BuildContext context, WidgetRef ref) {
    final isMobile = ref.watch(layoutLogic).isMobile;
    return isMobile ? _mobileLayout() : _defaultLayout();
  }

  // TODO: Mobile layout
  Widget _mobileLayout() => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _buildPointsFrom()),
                    const MoleculeItemHorizontalSpace(),
                    Expanded(child: _buildPointsTo()),
                  ],
                ),
              ),
              SizedBox(width: 200),
              _buildSelectAllButton(),
              const MoleculeItemHorizontalSpace(),
              _buildUnselectAllButton(),
              const MoleculeItemHorizontalSpace(),
              _buildDeleteSelectedButton(),
            ],
          ),
          MoleculeItemSpace(),
          Expanded(
            child: _GridWidget(
              programId: programId,
              pointsFrom: int.tryParse(_pointsFromController.text) ?? 0,
              pointsTo: int.tryParse(_pointsToController.text) ?? 500,
              refresh: refresh,
              checked: checked,
            ),
          ),
        ],
      );

  Widget _defaultLayout() => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _buildPointsFrom()),
                    const MoleculeItemHorizontalSpace(),
                    Expanded(child: _buildPointsTo()),
                  ],
                ),
              ),
              SizedBox(width: 200),
              _buildSelectAllButton(),
              const MoleculeItemHorizontalSpace(),
              _buildUnselectAllButton(),
              const MoleculeItemHorizontalSpace(),
              _buildDeleteSelectedButton(),
            ],
          ),
          MoleculeItemSpace(),
          Expanded(
            child: _GridWidget(
              programId: programId,
              pointsFrom: int.tryParse(_pointsFromController.text) ?? 0,
              pointsTo: int.tryParse(_pointsToController.text) ?? 500,
              refresh: refresh,
              checked: checked,
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

  Widget _buildSelectAllButton() => MoleculeSecondaryButton(
        titleText: LangKeys.buttonSelectAll.tr(),
        onTap: () {
          checked.forEach((key, _) => checked[key] = true);
          refresh();
        },
      );

  Widget _buildUnselectAllButton() => MoleculeSecondaryButton(
        titleText: LangKeys.buttonUnselectAll.tr(),
        onTap: () {
          checked.forEach((key, _) => checked[key] = false);
          refresh();
        },
      );

  Widget _buildDeleteSelectedButton() => MoleculeSecondaryButton(
        titleText: LangKeys.buttonDeleteSelected.tr(),
        onTap: () async {
          final qrTagsToDelete = checked.entries
              .where((keyValuePair) => keyValuePair.value == true)
              .map((keyValuePair) => keyValuePair.key)
              .toList();
          if (qrTagsToDelete.isEmpty) return toastError(LangKeys.toastNothingSelectedToDelete.tr());
          await _askToArchiveQrTags(
            context,
            ref,
            qrTagsToDelete,
          );
        },
      );

  Future<void> _askToArchiveQrTags(BuildContext context, WidgetRef ref, List<String> qrTagIds) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: LangKeys.deleteSelectedQrTagsTitle.tr().text,
        content: LangKeys.deleteSelectedQrTagsContent.tr().text,
        actions: [
          TextButton(
            onPressed: () => context.pop(false),
            child: LangKeys.buttonCancel.text,
          ),
          TextButton(
            onPressed: () => context.pop(true),
            child: LangKeys.buttonDelete.text.color(ref.scheme.negative),
          ),
        ],
      ),
    );
    if (result == true) {
      showWaitDialog(context, ref, LangKeys.toastArchiving.tr());
      ref.read(unusedQrTagsLogic.notifier).deleteMany(qrTagIds);
    }
  }
}

class _GridWidget extends ConsumerWidget {
  final String programId;
  final int pointsFrom;
  final int pointsTo;
  final void Function() refresh;
  final Map<String, bool> checked;

  _GridWidget({
    super.key,
    required this.programId,
    required this.pointsFrom,
    required this.pointsTo,
    required this.refresh,
    required this.checked,
  });

  static const _columnCheck = "checkbox";
  static const _columnCode = "code";
  static const _columnPoints = "points";

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final succeed = ref.watch(unusedQrTagsLogic) as QrTagsSucceed;
    final qrTags = succeed.qrTags.where((tag) {
      checked[tag.qrTagId] = checked[tag.qrTagId] ?? true;
      return tag.points >= pointsFrom && tag.points <= pointsTo;
    }).toList();
    return PullToRefresh(
      onRefresh: () => ref.read(unusedQrTagsLogic.notifier).refresh(programId),
      child: DataGrid<QrTag>(
        rows: qrTags,
        columns: [
          DataGridColumn(name: _columnCheck, label: "", width: 0),
          DataGridColumn(name: _columnCode, label: LangKeys.columnCode.tr()),
          DataGridColumn(name: _columnPoints, label: LangKeys.columnPoints.tr()),
        ],
        onBuildCell: (column, program) => _buildCell(context, ref, column, program),
      ),
    );
  }

  Widget _buildCell(BuildContext context, WidgetRef ref, String column, QrTag qrTag) {
    if (column == _columnCheck)
      return Checkbox(
        checkColor: ref.scheme.content,
        activeColor: ref.scheme.primary,
        value: checked[qrTag.qrTagId],
        onChanged: (bool? value) {
          checked[qrTag.qrTagId] = !checked[qrTag.qrTagId]!;
          refresh();
        },
      );
    final columnMap = <String, ThemedText>{
      _columnCode: qrTag.qrTagId.toString().text.color(ref.scheme.content),
      _columnPoints: qrTag.points.toString().text.color(ref.scheme.content),
    };
    final cell = columnMap[column] ?? "?".text.color(ref.scheme.content);
    return cell;
  }
}

// eof
