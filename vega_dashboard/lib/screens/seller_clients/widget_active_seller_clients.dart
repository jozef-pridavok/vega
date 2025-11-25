import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:flutter/material.dart" hide Card;
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../states/providers.dart";
import "../../states/seller_client.dart";
import "../../states/seller_client_patch.dart";
import "../../strings.dart";
import "../../widgets/data_grid.dart";
import "../../widgets/state_error.dart";
import "../dialog.dart";
import "../screen_app.dart";
import "popup_menu_items.dart";
import "screen_list.dart";

class ActiveSellerClientsWidget extends ConsumerStatefulWidget {
  final String? nameFilter;

  ActiveSellerClientsWidget({super.key, this.nameFilter});

  @override
  createState() => _WidgetState();
}

class _WidgetState extends ConsumerState<ActiveSellerClientsWidget> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(activeSellerClientsLogic.notifier).load());
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(activeSellerClientsLogic);
    final onReload = ref.read(activeSellerClientsLogic.notifier).refresh;
    if (state is SellerClientsFailed) {
      return StateErrorWidget(
        activeSellerClientsLogic,
        onReload: () => onReload(),
        getIcon: (error) => error == errorNoData ? AtomIcons.users : null,
        getMessage: (error) => error == errorNoData ? LangKeys.messageYouHaveNoClients.tr() : null,
        getButtonText: (error) => error == errorNoData ? LangKeys.buttonAddClient.tr() : null,
        getButtonAction: (error, context, ref) => error == errorNoData ? showAddClient(ref, context) : onReload(),
      );
    } else if (state is SellerClientsSucceed)
      return _GridWidget(nameFilter: widget.nameFilter);
    else
      return const CenteredWaitIndicator();
  }
}

class _GridWidget extends ConsumerWidget {
  final String? nameFilter;

  const _GridWidget({this.nameFilter});

  static const _columnName = "name";
  static const _columnCountries = "countries";
  static const _columnCategories = "categories";
  static const _columnOrder = "#";
  static const _columnDemoCredit = "demoCredit";

  void _listenToPatchState(BuildContext context, WidgetRef ref) {
    ref.listen<SellerClientPatchState>(sellerClientPatchLogic, (previous, next) {
      if (next.isSucceed) {
        closeWaitDialog(context, ref);
        ref.read(sellerClientPatchLogic.notifier).reset();
      } else if (next is SellerClientPatchFailed) {
        closeWaitDialog(context, ref);
        toastError(ref, next.error.toString());
      }
    });
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    _listenToPatchState(context, ref);
    final succeed = ref.watch(activeSellerClientsLogic) as SellerClientsSucceed;
    final clients = nameFilter != null
        ? succeed.clients
            .where((client) => client.name.toLowerCase().contains(nameFilter?.toLowerCase() ?? ""))
            .toList()
        : succeed.clients;
    return PullToRefresh(
      onRefresh: () async => await ref.read(activeSellerClientsLogic.notifier).refresh(),
      child: DataGrid<Client>(
        rows: clients,
        columns: [
          DataGridColumn(name: _columnName, label: LangKeys.columnName.tr(), width: 300),
          DataGridColumn(name: _columnCountries, label: LangKeys.columnCountries.tr(), width: 300),
          DataGridColumn(name: _columnCategories, label: LangKeys.columnCategories.tr(), width: -1),
          // localize to slovak, english, spanish
          DataGridColumn(name: _columnDemoCredit, label: LangKeys.columnDemoCredit.tr(), width: 0),
        ],
        onBuildCell: (column, client) => _buildCell(context, ref, column, client),
        onRowTapUp: (column, client, details) => _popupOperations(context, ref, client, details),
      ),
    );
  }

  Widget _buildCell(BuildContext context, WidgetRef ref, String column, Client client) {
    final isBlocked = client.blocked;

    final maxCategories = 3;
    final categories = client.categories ?? [];
    final headCategories = categories.map((category) => category.localizedName.toString()).take(maxCategories);
    final remainingCategories = categories.length - headCategories.length;

    final maxCountries = 3;
    final countries = client.countries ?? [];
    final headCountries = countries.map((country) => country.localizedName.toString()).take(maxCountries);
    final remainingCountries = countries.length - headCountries.length;

    final currency = client.currency;
    final demoCredit = client.demoCredit;

    final columnMap = <String, ThemedText>{
      _columnOrder: client.name.toString().text.color(ref.scheme.content),
      _columnName: client.name.text.color(ref.scheme.content),
      _columnCountries: (headCountries.join(", ") + (remainingCountries > 0 ? " +$remainingCountries" : "")).text,
      _columnCategories: (headCategories.join(", ") + (remainingCategories > 0 ? " +$remainingCategories" : "")).text,
      _columnDemoCredit: currency.formatSymbol(demoCredit).text,
    };

    final cell = columnMap[column] ?? "?".text.color(ref.scheme.content);
    return isBlocked ? cell.lineThrough : cell;
  }

  void _popupOperations(BuildContext context, WidgetRef ref, Client client, TapUpDetails details) async {
    showVegaPopupMenu(
      context: context,
      ref: ref,
      details: details,
      title: client.name,
      items: [
        SellerClientMenuItems.edit(context, ref, client),
        SellerClientMenuItems.block(context, ref, client),
        SellerClientMenuItems.manageUsers(context, ref, client),
        SellerClientMenuItems.setDemoCredit(context, ref, client),
        SellerClientMenuItems.archive(context, ref, client),
      ],
    );
  }
}
