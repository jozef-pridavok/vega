import "package:collection/collection.dart";
import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:core_flutter/states/provider.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../extensions/select_item.dart";
import "../../states/client_user_card_transactions.dart";
import "../../states/programs.dart";
import "../../states/providers.dart";
import "../../strings.dart";
import "../../widgets/molecule_picker.dart";
import "../../widgets/molecule_picker_date.dart";
import "../screen_app.dart";
import "widget_transactions.dart";

class ClientUserCardTransactionsScreen extends VegaScreen {
  final UserCard userCard;
  const ClientUserCardTransactionsScreen(this.userCard, {super.key});

  @override
  createState() => _ClientUserCardTransactionsState();
}

class _ClientUserCardTransactionsState extends VegaScreenState<ClientUserCardTransactionsScreen> {
  UserCard get _userCard => widget.userCard;
  String? _selectedProgramId;
  DateTime? _selectedDateFrom;
  DateTime? _selectedDateTo;
  int? _programTotalPoints;

  void refresh() {
    setState(() {});
  }

  void setProgramId(String? val) {
    _selectedProgramId = val;
    refresh();
  }

  void setDateFrom(DateTime? val) {
    _selectedDateFrom = val;
    refresh();
  }

  void setDateTo(DateTime? val) {
    _selectedDateTo = val;
    refresh();
  }

  @override
  void initState() {
    super.initState();
    Future(() {
      ref.read(activeProgramsLogic.notifier).load();
      ref.read(clientUserCardTransactionsLogic.notifier).load(userCardId: _userCard.userCardId);
    });
  }

  @override
  String? getTitle() => LangKeys.screenClientUserCardTransactions.tr();

  @override
  Widget buildBody(BuildContext context) {
    final succeed = ref.watch(clientUserCardTransactionsLogic);
    final transactions = succeed.transactions;
    if (succeed is ClientUserCardTransactionsSucceed) {
      if (_selectedProgramId != null) {
        transactions.removeWhere((t) => t.programId != _selectedProgramId);
      }
      if (_selectedDateFrom != null) {
        transactions.removeWhere((t) => t.date.isBefore(_selectedDateFrom!));
      }
      if (_selectedDateTo != null) {
        transactions.removeWhere((t) => t.date.isAfter(_selectedDateTo!));
      }
      _programTotalPoints = transactions.fold<int>(0, (prev, t) => prev + t.points);
    }
    return Padding(
      padding: const EdgeInsets.all(moleculeScreenPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Filters(
            _userCard,
            selectedProgramId: _selectedProgramId,
            selectedDateFrom: _selectedDateFrom,
            selectedDateTo: _selectedDateTo,
            setProgramId: setProgramId,
            setDateFrom: setDateFrom,
            setDateTo: setDateTo,
            programTotalPoints: _programTotalPoints,
          ),
          const MoleculeItemSpace(),
          Expanded(child: ClientUserCardTransactionsWidget(_userCard, transactions: transactions)),
        ],
      ),
    );
  }
}

class _Filters extends ConsumerWidget {
  final UserCard userCard;
  final String? selectedProgramId;
  final DateTime? selectedDateFrom;
  final DateTime? selectedDateTo;
  final int? programTotalPoints;
  final Function(String?) setProgramId;
  final Function(DateTime?) setDateFrom;
  final Function(DateTime?) setDateTo;

  _Filters(
    this.userCard, {
    required this.selectedProgramId,
    required this.selectedDateFrom,
    required this.selectedDateTo,
    required this.setProgramId,
    required this.setDateFrom,
    required this.setDateTo,
    required this.programTotalPoints,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isMobile = ref.watch(layoutLogic).isMobile;
    return isMobile
        ? ExpansionTile(
            title: LangKeys.sectionFilter.tr().label,
            tilePadding: EdgeInsets.zero,
            textColor: ref.scheme.content,
            iconColor: ref.scheme.primary,
            collapsedIconColor: ref.scheme.primary,
            trailing: VegaIcon(name: AtomIcons.chevronDown),
            dense: true,
            visualDensity: VisualDensity.compact,
            children: [
              _ProgramFilter(setProgramId),
              const MoleculeItemSpace(),
              _DateFromFilter(setDateFrom, selectedDateTo),
              const MoleculeItemSpace(),
              _DateToFilter(selectedDateFrom, setDateTo),
              if (selectedProgramId != null) ...{
                const MoleculeItemSpace(),
                _ProgramPointsTotal(programTotalPoints, selectedProgramId),
              },
            ],
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(child: _ProgramFilter(setProgramId)),
              const MoleculeItemHorizontalSpace(),
              Flexible(child: _DateFromFilter(setDateFrom, selectedDateTo)),
              const MoleculeItemHorizontalSpace(),
              Flexible(child: _DateToFilter(selectedDateFrom, setDateTo)),
              if (selectedProgramId != null) ...{
                const MoleculeItemHorizontalSpace(),
                Flexible(child: _ProgramPointsTotal(programTotalPoints, selectedProgramId)),
              },
              const MoleculeItemHorizontalSpace(),
            ],
          );
  }
}

class _ProgramFilter extends ConsumerWidget {
  final Function(String?) setProgramId;
  _ProgramFilter(this.setProgramId);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final programs = cast<ProgramsSucceed>(ref.watch(activeProgramsLogic))?.programs ?? [];
    return MoleculeSingleSelect(
      title: LangKeys.labelReservationProgram.tr(),
      hint: LangKeys.hintAllPrograms.tr(),
      items: programs.toSelectItems(),
      onChangedOrClear: (val) => setProgramId(val?.value),
    );
  }
}

class _DateFromFilter extends ConsumerWidget {
  final Function(DateTime?) setDateFrom;
  final DateTime? selectedDateTo;
  _DateFromFilter(this.setDateFrom, this.selectedDateTo);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MoleculeDatePicker(
      title: LangKeys.labelDateFrom.tr(),
      hint: LangKeys.hintPickDateFrom.tr(),
      onChangedOrNull: (val) {
        if (selectedDateTo != null && val != null && val.isAfter(selectedDateTo!)) {
          toastError(ref, LangKeys.validationValidToAfterFrom.tr());
        } else {
          setDateFrom(val);
        }
      },
    );
  }
}

class _DateToFilter extends ConsumerWidget {
  final DateTime? selectedDateFrom;
  final Function(DateTime?) setDateTo;
  _DateToFilter(this.selectedDateFrom, this.setDateTo);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MoleculeDatePicker(
      title: LangKeys.labelDateTo.tr(),
      hint: LangKeys.hintPickDateTo.tr(),
      onChangedOrNull: (val) {
        if (selectedDateFrom != null && val != null && val.isBefore(selectedDateFrom!)) {
          toastError(ref, LangKeys.validationValidToAfterFrom.tr());
        } else {
          setDateTo(val);
        }
      },
    );
  }
}

class _ProgramPointsTotal extends ConsumerWidget {
  final int? programTotalPoints;
  final String? selectedProgramId;
  const _ProgramPointsTotal(this.programTotalPoints, this.selectedProgramId);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final programs = cast<ProgramsSucceed>(ref.watch(activeProgramsLogic))?.programs ?? [];
    final program = programs.firstWhereOrNull((program) => program.programId == selectedProgramId);
    final points = formatAmount(context.locale.languageCode, program?.plural, programTotalPoints ?? 0,
        digits: program?.digits ?? 0);
    String summary = "${program?.name}: $points";
    return MoleculeChip(
      label: LangKeys.currentBalance.tr(args: [summary]),
      style: AtomStyles.textBold,
    );
  }
}

// eof
