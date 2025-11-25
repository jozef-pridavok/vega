import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:vega_app/strings.dart";

import "../../states/client/client.dart";
import "../../states/providers.dart";
import "../../widgets/status_error.dart";
import "../screen_app.dart";
import "screen_location.dart";

class LocationsScreen extends AppScreen {
  final String clientId;
  const LocationsScreen(this.clientId, {super.key}) : super(useSafeArea: false);

  @override
  createState() => _LocationsState();
}

class _LocationsState extends AppScreenState<LocationsScreen> {
  String get _clientId => widget.clientId;

  @override
  PreferredSizeWidget? buildAppBar(BuildContext context) {
    return VegaAppBar(
      hideButton: true,
      titleWidget: MoleculeInput(
        prefixIcon: GestureDetector(
          onTap: () => context.pop(),
          child: const Padding(padding: EdgeInsets.all(6.0), child: VegaIcon(name: "arrow_left")),
        ),
        hint: LangKeys.screenLocationsSearchHint.tr(),
        onChanged: (value) {},
      ),
    );
  }

  @override
  Widget buildBody(BuildContext context) {
    final clientState = ref.watch(clientLogic(_clientId));
    final stateWidgetMap = <Type, Widget>{
      ClientFailed: Padding(
        padding: const EdgeInsets.all(moleculeScreenPadding),
        child: StatusErrorWidget(
          clientLogic(_clientId),
          onReload: () => ref.read(clientLogic(_clientId).notifier).reload(),
        ),
      ),
      ClientSucceed: _LocationsWidget(_clientId),
      ClientLoading: const CenteredWaitIndicator(),
      ClientRefreshing: _LocationsWidget(_clientId),
    };
    return stateWidgetMap[clientState.runtimeType] ?? const AlignedWaitIndicator();
    //return Padding(
    //  padding: const EdgeInsets.symmetric(horizontal: moleculeScreenPadding),
    //  child: stateWidgetMap[clientState.runtimeType] ?? const AlignedWaitIndicator(),
    //);
  }
}

class _LocationsWidget extends ConsumerWidget {
  final String clientId;

  const _LocationsWidget(this.clientId);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clientState = ref.watch(clientLogic(clientId)) as ClientSucceed;
    final locations = clientState.locations;
    return MapWidget<Location>(
      objects: locations,
      getGeoPoint: (location) => location.geoPoint,
      onMarkerTap: (location) => context.push(LocationScreen(clientId, (location as Location).locationId)),
    );
  }
}

// eof
