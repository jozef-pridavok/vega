import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:core_flutter/states/provider.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../states/providers.dart";
import "../../states/seller_client.dart";
import "../../strings.dart";
import "../../widgets/button_refresh.dart";
import "../screen_app.dart";
import "screen_edit.dart";
import "widget_active_seller_clients.dart";
import "widget_archived_seller_clients.dart";

class SellerClientsScreen extends VegaScreen {
  const SellerClientsScreen({super.showDrawer, super.key});

  @override
  createState() => _SellerClientState();
}

class _SellerClientState extends VegaScreenState<SellerClientsScreen> with SingleTickerProviderStateMixin {
  late TabController _controller;
  String? _nameFilter;

  @override
  void initState() {
    super.initState();
    _controller = TabController(initialIndex: 0, length: 2, vsync: this);
    Future(() => ref.read(clientPaymentProvidersLogic.notifier).load());
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  String? getTitle() => LangKeys.screenSellerClientsTitle.tr();

  void _listenToLogics(BuildContext context) {
    ref.listen(sellerClientPatchLogic, (previous, next) {
      if (next.isSucceed) {
        ref.read(activeSellerClientsLogic.notifier).refresh();
        ref.read(archivedSellerClientsLogic.notifier).refresh();
      }
    });
  }

  @override
  List<Widget>? buildAppBarActions() {
    final activeSellerClients = ref.watch(activeSellerClientsLogic);
    final archivedSellerClients = ref.watch(archivedSellerClientsLogic);
    final isRefreshing = [activeSellerClients, archivedSellerClients].any((state) => state is SellerClientsRefreshing);
    return [
      IconButton(
        icon: const VegaIcon(name: AtomIcons.add),
        onPressed: () => showAddClient(ref, context),
      ),
      VegaRefreshButton(
        onPressed: () {
          ref.read(activeSellerClientsLogic.notifier).refresh();
          ref.read(archivedSellerClientsLogic.notifier).refresh();
        },
        isRotating: isRefreshing,
      ),
      const SizedBox(width: moleculeScreenPadding),
    ];
  }

  @override
  Widget buildBody(BuildContext context) {
    _listenToLogics(context);
    return Padding(
      padding: const EdgeInsets.all(moleculeScreenPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Filters(
            onFilterChanged: (filterValue) {
              setState(() {
                _nameFilter = filterValue;
              });
            },
          ),
          const MoleculeItemSpace(),
          MoleculeTabs(controller: _controller, tabs: [
            Tab(text: LangKeys.tabActive.tr()),
            Tab(text: LangKeys.tabArchived.tr()),
          ]),
          Expanded(
            child: TabBarView(
              physics: vegaScrollPhysic,
              controller: _controller,
              children: [
                ActiveSellerClientsWidget(nameFilter: _nameFilter),
                ArchivedSellerClientsWidget(nameFilter: _nameFilter),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

void showAddClient(WidgetRef ref, BuildContext context) {
  final user = ref.read(deviceRepository).get(DeviceKey.user) as User;
  final country = CountryCode.fromCodeOrNull(user.country);
  context.push(
    EditSellerClientScreen(
      client: Client(
        name: "",
        clientId: uuid(),
        countries: country != null ? [country] : [],
        categories: [],
      )
        ..setMetaLicense(activityPeriod: 30, base: 2500, pricing: 50, currency: defaultCurrency)
        ..newUserCardMask = "YY-***-**",
      isNew: true,
    ),
  );
}

class _Filters extends ConsumerWidget {
  final void Function(String)? onFilterChanged;

  _Filters({required this.onFilterChanged});

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
              _TextFilter(onChanged: onFilterChanged),
            ],
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(child: _TextFilter(onChanged: onFilterChanged)),
            ],
          );
  }
}

class _TextFilter extends ConsumerWidget {
  final void Function(String)? onChanged;

  _TextFilter({required this.onChanged});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MoleculeInput(
      title: LangKeys.labelFilterTitle.tr(),
      hint: LangKeys.hintClientNameFilter.tr(),
      onChanged: onChanged,
    );
  }
}

// eof
