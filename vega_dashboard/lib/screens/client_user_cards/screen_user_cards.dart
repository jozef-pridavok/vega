import "package:collection/collection.dart";
import "package:core_flutter/core_app.dart";
import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:core_flutter/states/provider.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../extensions/select_item.dart";
import "../../states/client_cards.dart";
import "../../states/client_user_cards.dart";
import "../../states/programs.dart";
import "../../states/providers.dart";
import "../../strings.dart";
import "../../utils/debouncer.dart";
import "../../widgets/button_refresh.dart";
import "../../widgets/molecule_picker.dart";
import "../../widgets/qr_identity.dart";
import "../screen_app.dart";
import "widget_user_cards.dart";

class ClientUserCardsScreen extends VegaScreen {
  final Program? selectedProgram;

  const ClientUserCardsScreen({super.showDrawer, super.key, this.selectedProgram});

  @override
  createState() => _ClientUsersScreenState();
}

class _ClientUsersScreenState extends VegaScreenState<ClientUserCardsScreen> with SingleTickerProviderStateMixin {
  final _debouncer = Debouncer(milliseconds: 500);

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (widget.selectedProgram != null) {
        ref.read(clientUserCardsLogic.notifier).loadProgram(widget.selectedProgram!.programId);
      } else {
        ref.read(clientUserCardsLogic.notifier).loadPeriod(7);
      }
    });
    Future(() {
      ref.read(activeClientCardsLogic.notifier).load();
      ref.read(activeProgramsLogic.notifier).load();
    });
  }

  @override
  void dispose() {
    super.dispose();
    _debouncer.dispose();
  }

  @override
  String? getTitle() => LangKeys.screenClientUserCards.tr();

  @override
  List<Widget>? buildAppBarActions() {
    final userCards = ref.watch(clientUserCardsLogic);
    final isRefreshing = userCards is ClientUserCardsRefreshing;
    return [
      VegaRefreshButton(
        onPressed: () => ref.read(clientUserCardsLogic.notifier).refresh(),
        isRotating: isRefreshing,
      ),
      VegaMenuButton(
        items: [
          PopupMenuItem(
            child: MoleculeItemBasic(
              title: LangKeys.buttonAddCardByClientIdentity.tr(),
              onAction: () {
                context.pop();
                final clientId = (ref.read(deviceRepository).get(DeviceKey.client) as Client).clientId;
                final qrCode = F().qrBuilder.generateClientIdentity(clientId);
                showIdentityForNewCard(context, ref, qrCode);
              },
            ),
          ),
        ],
      ),
      const SizedBox(width: moleculeScreenPadding),
    ];
  }

  @override
  Widget buildBody(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(moleculeScreenPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Filters(debouncer: _debouncer, selectedProgram: widget.selectedProgram),
          const MoleculeItemSpace(),
          Expanded(child: const UserCardsWidget()),
        ],
      ),
    );
  }
}

class _Filters extends ConsumerWidget {
  final Program? selectedProgram;
  final Debouncer debouncer;

  const _Filters({required this.debouncer, this.selectedProgram});

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
              const _PeriodFilter(),
              const MoleculeItemSpace(),
              _TextFilter(debouncer: debouncer),
              const MoleculeItemSpace(),
              const _CardFilter(),
              const MoleculeItemSpace(),
              _ProgramFilter(selectedProgram: selectedProgram),
              const MoleculeItemSpace(),
            ],
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(child: const _PeriodFilter()),
              const MoleculeItemHorizontalSpace(),
              Flexible(child: _TextFilter(debouncer: debouncer)),
              const MoleculeItemHorizontalSpace(),
              Flexible(child: const _CardFilter()),
              const MoleculeItemHorizontalSpace(),
              Flexible(child: _ProgramFilter(selectedProgram: selectedProgram)),
            ],
          );
  }
}

class _PeriodFilter extends ConsumerWidget {
  const _PeriodFilter();

  static final periods = [
    SelectItem(value: "7", label: LangKeys.clientUserCardsPeriodLastSevenDays.tr()),
    SelectItem(value: "30", label: LangKeys.clientUserCardsPeriodLastMonth.tr()),
    SelectItem(value: "365", label: LangKeys.clientUserCardsPeriodLastYear.tr()),
    SelectItem(value: "-1", label: LangKeys.clientUserCardsPeriodInactive.tr()),
  ];
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(clientUserCardsLogic);
    return MoleculeSingleSelect(
      title: LangKeys.clientUserCardsPeriodTitle.tr(),
      hint: LangKeys.clientUserCardsPeriodHint.tr(),
      items: periods,
      selectedItem: periods.firstWhereOrNull((element) => element.value == state.period.toString()),
      onChanged: (val) => ref.read(clientUserCardsLogic.notifier).load(period: int.tryParse(val.value)),
    );
  }
}

class _TextFilter extends ConsumerWidget {
  final Debouncer debouncer;

  const _TextFilter({required this.debouncer});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(clientUserCardsLogic);
    return MoleculeInput(
      title: LangKeys.clientUserCardsFilterTitle.tr(),
      hint: LangKeys.clientUserCardsFilterHint.tr(),
      initialValue: state.filter,
      onChanged: (val) => debouncer.run(() => ref.read(clientUserCardsLogic.notifier).load(filter: val)),
    );
  }
}

class _CardFilter extends ConsumerWidget {
  const _CardFilter();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cards = cast<ClientCardsSucceed>(ref.watch(activeClientCardsLogic))?.cards ?? [];
    final userCards = ref.watch(clientUserCardsLogic);
    final card = cards.firstWhereOrNull((card) => card.cardId == userCards.cardId);
    return MoleculeSingleSelect(
      title: LangKeys.labelCard.tr(),
      hint: LangKeys.hintAllCards.tr(),
      items: cards.toSelectItems(),
      selectedItem: card?.toSelectItem(),
      onChangedOrClear: (val) => ref.read(clientUserCardsLogic.notifier).loadCard(val?.value),
    );
  }
}

class _ProgramFilter extends ConsumerWidget {
  final Program? selectedProgram;

  const _ProgramFilter({this.selectedProgram});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final programs = cast<ProgramsSucceed>(ref.watch(activeProgramsLogic))?.programs ?? [];
    final userCards = ref.watch(clientUserCardsLogic);
    final program = programs.firstWhereOrNull((program) => program.programId == userCards.programId);
    return MoleculeSingleSelect(
      title: LangKeys.labelReservationProgram.tr(),
      hint: LangKeys.hintAllPrograms.tr(),
      items: programs.toSelectItems(),
      selectedItem: selectedProgram?.toSelectItem() ?? program?.toSelectItem(),
      onChangedOrClear: (val) => ref.read(clientUserCardsLogic.notifier).loadProgram(val?.value),
    );
  }
}

// eof
