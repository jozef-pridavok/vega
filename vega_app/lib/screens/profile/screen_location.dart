import "package:core_flutter/core_app.dart";
import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:core_flutter/widgets/map_picker.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../states/providers.dart";
import "../../states/user_location.dart";
import "../../strings.dart";
import "../screen_app.dart";

class LocationScreen extends AppScreen {
  const LocationScreen({super.key});

  @override
  createState() => _LocationState();
}

class _LocationState extends AppScreenState<LocationScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(userLocationLogic.notifier).ask());
  }

  /*
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    Future.microtask(() => ref.read(userLocationLogic.notifier).ask());
  }
  */

  @override
  PreferredSizeWidget? buildAppBar(BuildContext context) => VegaAppBar(
        title: LangKeys.screenLocationTitle.tr(),
      );

  @override
  void onGainedVisibility() {
    super.onGainedVisibility();
    Future.microtask(() => ref.read(userLocationLogic.notifier).ask());
  }

  @override
  Widget buildBody(BuildContext context) {
    final userLocation = ref.watch(userLocationLogic);
    final succeed = cast<UserLocationSucceed>(userLocation);

    final user = ref.read(deviceRepository).get(DeviceKey.user) as User;
    final automaticLocationEnabled = !user.metaLocationAutoDisabled;
    final permanentlyDenied = cast<UserLocationFailed>(userLocation)?.error == errorLocationPermanentlyDenied;
    final x = automaticLocationEnabled && permanentlyDenied;

    return Padding(
      padding: const EdgeInsets.all(moleculeScreenPadding),
      child: ListView(
        children: [
          MoleculeItemBasic(
            title: LangKeys.screenLocationAuto.tr(),
            label: LangKeys.screenLocationAutoDescription.tr(),
            actionIcon: (succeed != null && succeed.userAutomaticLocationEnabled) || x ? AtomIcons.check : null,
            onAction: () => ref.read(userLocationLogic.notifier).enableAutomaticLocation(),
          ),
          const MoleculeItemSpace(),
          MoleculeItemBasic(
            title: LangKeys.screenLocationManual.tr(),
            label: LangKeys.screenLocationManualDescription.tr(),
            actionIcon: succeed != null && succeed.userAutomaticLocationDisabled ? AtomIcons.check : null,
            onAction: () => ref.read(userLocationLogic.notifier).disableAutomaticLocation(),
          ),
          const MoleculeItemSpace(),
          const SizedBox(
            height: 400,
            child: _StatusWidget(),
          ),
        ],
      ),
    );
  }
}

class _StatusWidget extends ConsumerWidget {
  const _StatusWidget();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userLocation = ref.watch(userLocationLogic);
    final succeed = cast<UserLocationSucceed>(userLocation);
    final failed = cast<UserLocationFailed>(userLocation);
    if (succeed != null) {
      if (succeed.userAutomaticLocationEnabled)
        return MapWidget(
          objects: [succeed.location],
          getGeoPoint: (object) => object,
        );
      else
        return MapPickerWidget(
          initial: succeed.location,
          onChanged: (point) => ref.read(userLocationLogic.notifier).updateManualLocation(point),
          usePin: false,
        );
    } else if (failed != null) {
      //final permanentlyDenied = failed?.error == errorLocationPermanentlyDenied;
      return MoleculeErrorWidget(
        message: failed.error.message,
        primaryButton: LangKeys.buttonOpenAppSettings.tr(),
        onPrimaryAction: () => Environment.openAppSettings(),
      );
    } else
      return const CenteredWaitIndicator();
  }
}

// eof
