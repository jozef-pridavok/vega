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

class ArchivedSellerClientsWidget extends ConsumerStatefulWidget {
  final String? nameFilter;

  ArchivedSellerClientsWidget({super.key, this.nameFilter});

  @override
  createState() => _WidgetState();
}

class _WidgetState extends ConsumerState<ArchivedSellerClientsWidget> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(archivedSellerClientsLogic.notifier).load());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(archivedSellerClientsLogic);
    final onReload = ref.read(archivedSellerClientsLogic.notifier).refresh;
    if (state is SellerClientsFailed) {
      return StateErrorWidget(
        archivedSellerClientsLogic,
        onReload: () => onReload(),
        getIcon: (error) => error == errorNoData ? AtomIcons.users : null,
        getMessage: (error) => error == errorNoData ? LangKeys.errorNoData.tr() : null,
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
  static const _columnCategories = LangKeys.categories;
  static const _columnOrder = "#";

  void _listenToEditorLogic(BuildContext context, WidgetRef ref) {
    ref.listen(sellerClientPatchLogic, (previous, next) {
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
    _listenToEditorLogic(context, ref);
    final succeed = ref.watch(archivedSellerClientsLogic) as SellerClientsSucceed;
    final clients = nameFilter != null
        ? succeed.clients
            .where((client) => client.name.toLowerCase().contains(nameFilter?.toLowerCase() ?? ""))
            .toList()
        : succeed.clients;
    return PullToRefresh(
      onRefresh: () async => await ref.read(archivedSellerClientsLogic.notifier).refresh(),
      child: DataGrid<Client>(
        rows: clients,
        columns: [
          DataGridColumn(name: _columnName, label: LangKeys.columnName.tr()),
          DataGridColumn(name: _columnCountries, label: LangKeys.columnCountries.tr()),
          DataGridColumn(name: _columnCategories, label: LangKeys.columnCategories.tr()),
        ],
        onBuildCell: (column, client) => _buildCell(context, ref, column, client),
        onRowTapUp: (column, client, details) => (),
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

    final columnMap = <String, ThemedText>{
      _columnOrder: client.name.toString().text.color(ref.scheme.content),
      _columnName: client.name.text.color(ref.scheme.content),
      _columnCountries: (headCountries.join(", ") + (remainingCountries > 0 ? " +$remainingCountries" : "")).text,
      _columnCategories: (headCategories.join(", ") + (remainingCategories > 0 ? " +$remainingCategories" : "")).text,
    };

    final cell = columnMap[column] ?? "?".text.color(ref.scheme.content);
    return isBlocked ? cell.lineThrough : cell;
  }
}
