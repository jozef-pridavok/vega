import "package:core_flutter/core_app.dart";
import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:vega_app/states/providers.dart";
import "package:vega_app/strings.dart";

import "../../states/client/client.dart";
import "../../widgets/status_error.dart";
import "../screen_app.dart";
import "screen_locations.dart";

class ClientInfoScreen extends AppScreen {
  final String clientId;
  final String clientName;
  const ClientInfoScreen(this.clientId, this.clientName, {super.key});

  @override
  createState() => _ClientInfoState();
}

class _ClientInfoState extends AppScreenState<ClientInfoScreen> {
  String get _clientId => widget.clientId;
  String get _clientName => widget.clientName;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(clientLogic(_clientId).notifier).load());
  }

  @override
  PreferredSizeWidget? buildAppBar(BuildContext context) => VegaAppBar(title: _clientName);

  @override
  Widget buildBody(BuildContext context) {
    final clientState = ref.watch(clientLogic(_clientId));
    final stateWidgetMap = <Type, Widget>{
      ClientFailed: StatusErrorWidget(
        clientLogic(_clientId),
        onReload: () => ref.read(clientLogic(_clientId).notifier).reload(),
      ),
      ClientSucceed: _ClientWidget(_clientId),
      ClientLoading: const CenteredWaitIndicator(),
      ClientRefreshing: _ClientWidget(_clientId),
    };
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: moleculeScreenPadding),
      child: stateWidgetMap[clientState.runtimeType] ?? const AlignedWaitIndicator(),
    );
  }
}

class _ClientWidget extends ConsumerWidget {
  final String clientId;

  const _ClientWidget(this.clientId);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clientState = ref.watch(clientLogic(clientId)) as ClientSucceed;
    final locale = Localizations.localeOf(context);
    final user = ref.read(deviceRepository).get(DeviceKey.user) as User;
    //final userUpdate = cast<UserUpdateSucceed>(ref.watch(userUpdateLogic));
    //final languageCode = userUpdate?.language?.languageCode ?? user.language ?? locale.languageCode;
    final languageCode = user.language ?? locale.languageCode;
    final description = clientState.client.getDescription(languageCode);
    final hasWeb = clientState.client.web.isNotEmpty;
    final web = clientState.client.web;
    final hasPhone = clientState.client.phone.isNotEmpty;
    final phone = clientState.client.phone;
    final hasEmail = clientState.client.email.isNotEmpty;
    final email = clientState.client.email;
    final hasLocations = clientState.locations.isNotEmpty;
    return PullToRefresh(
      onRefresh: () => ref.read(clientLogic(clientId).notifier).reload(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: moleculeScreenPadding),
        child: ListView(
          //physics: vegaScrollPhysic,
          children: [
            description.text.alignLeft.color(ref.scheme.content),
            const MoleculeItemSpace(),
            if (hasWeb) ...[
              MoleculeItemBasic(
                title: LangKeys.screenClientInfoMoreDetail.tr(),
                actionIcon: AtomIcons.chevronRight,
                onAction: () => Environment.openWebBrowser(web),
              ),
              const MoleculeItemSpace(),
            ],
            const MoleculeItemSeparator(),
            const MoleculeItemSpace(),
            MoleculeItemTitle(header: LangKeys.screenClientInfoContacts.tr()),
            const MoleculeItemSpace(),
            if (hasPhone)
              MoleculeItemBasic(
                title: LangKeys.screenClientInfoPhone.tr(),
                label: phone,
                actionIcon: AtomIcons.phone,
                onAction: () => Environment.makePhoneCall(phone),
              ),
            if (hasEmail)
              MoleculeItemBasic(
                title: LangKeys.screenClientInfoEmail.tr(),
                label: email,
                actionIcon: AtomIcons.email,
                onAction: () => Environment.openEmail(email),
              ),
            if (hasLocations)
              MoleculeItemBasic(
                title: LangKeys.screenClientInfoLocations.tr(),
                label: LangKeys.labelShowMap.tr(),
                actionIcon: AtomIcons.location,
                onAction: () => context.push(LocationsScreen(clientId)),
              ),
          ],
        ),
      ),
    );
  }
}

// eof
