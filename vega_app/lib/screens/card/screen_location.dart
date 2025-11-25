import "package:core_flutter/core_app.dart";
import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:vega_app/strings.dart";

import "../../states/client/client.dart";
import "../../states/providers.dart";
import "../../widgets/status_error.dart";
import "../screen_app.dart";

class LocationScreen extends AppScreen {
  final String clientId;
  final String locationId;
  const LocationScreen(this.clientId, this.locationId, {super.key}) : super(useSafeArea: false);

  @override
  createState() => _LocationState();
}

class _LocationState extends AppScreenState<LocationScreen> {
  String get _clientId => widget.clientId;
  String get _locationId => widget.locationId;

  @override
  PreferredSizeWidget? buildAppBar(BuildContext context) => VegaAppBar(
        title: LangKeys.screenLocation.tr(),
      );

  @override
  Widget buildBody(BuildContext context) {
    final clientState = ref.watch(clientLogic(_clientId));
    final stateWidgetMap = <Type, Widget>{
      ClientFailed: StatusErrorWidget(
        clientLogic(_clientId),
        onReload: () => ref.read(clientLogic(_clientId).notifier).reload(),
      ),
      ClientSucceed: _LocationWidget(_clientId, _locationId),
      ClientLoading: const CenteredWaitIndicator(),
      ClientRefreshing: _LocationWidget(_clientId, _locationId),
    };
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: moleculeScreenPadding),
      child: stateWidgetMap[clientState.runtimeType] ?? const AlignedWaitIndicator(),
    );
  }
}

class _LocationWidget extends ConsumerWidget {
  final String clientId;
  final String locationId;

  const _LocationWidget(this.clientId, this.locationId);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clientState = ref.watch(clientLogic(clientId)) as ClientSucceed;
    final client = clientState.client;
    final locations = clientState.locations;
    final location = locations.firstWhere((element) => element.locationId == locationId);
    final hasPhone = location.phone?.isNotEmpty ?? false;
    final phone = location.phone;
    final hasEmail = location.email?.isNotEmpty ?? false;
    final email = location.email;
    final hasOpeningHours = location.openingHours?.isNotEmpty ?? true;
    return PullToRefresh(
      onRefresh: () => ref.read(clientLogic(clientId).notifier).reload(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: moleculeScreenPadding),
        child: ListView(
          //physics: vegaScrollPhysic,
          children: [
            MoleculeItemBasic(
              icon: AtomIcons.location,
              title: client.name,
              label: location.buildAddress(),
            ),
            const MoleculeItemSpace(),
            if (hasOpeningHours) ...[
              _OpeningHours(location.openingHours!),
              const MoleculeItemSpace(),
            ],
            if (hasPhone)
              MoleculeItemBasic(
                title: LangKeys.screenClientInfoPhone.tr(),
                label: phone,
                actionIcon: AtomIcons.phone,
                onAction: () => Environment.makePhoneCall(phone!),
              ),
            if (hasEmail)
              MoleculeItemBasic(
                title: LangKeys.screenClientInfoEmail.tr(),
                label: email,
                actionIcon: AtomIcons.email,
                onAction: () => Environment.openEmail(email!),
              ),
          ],
        ),
      ),
    );
  }
}

class _OpeningHours extends StatelessWidget {
  final OpeningHours openingHours;
  const _OpeningHours(this.openingHours);

  @override
  Widget build(BuildContext context) {
    openingHours.sort();
    // TODO: zapracovať openingHoursException, t.j. vyradiť tie ktoré sú "closed"
    // a pridať podľa dátumu tie ktoré sú pre aktuálny týždeň v zozname
    return MoleculeCardLoyaltyBig(
      title: LangKeys.sectionOpeningHours.tr(),
      child: Column(
        children: [
          const MoleculeItemSeparator(),
          ...openingHours.openingHours.entries.map(
            (e) => Column(
              children: [
                const MoleculeItemSpace(),
                MoleculeTableRow(label: e.key.localizedName, value: e.value),
              ],
            ),
          )

          //SizedBox(height: 200, child: Container(color: Colors.amber)),
        ],
      ),
    );
  }
}

// eof
