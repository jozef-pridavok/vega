import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:core_flutter/states/provider.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/src/consumer.dart";

import "../../states/location_editor.dart";
import "../../states/providers.dart";
import "../../strings.dart";
import "../../widgets/notifications.dart";
import "../screen_app.dart";
import "widget_contact.dart";
import "widget_opening_hours.dart";
import "widget_opening_hours_exceptions.dart";

class LocationEditScreen extends VegaScreen {
  const LocationEditScreen({super.key});

  @override
  createState() => LocationEditState();
}

class LocationEditState extends VegaScreenState<LocationEditScreen> {
  final notificationsTag = "96eb434c-cf0f-487c-9e99-b7ffcf89f964";

  // Contact
  LocationType? pickedType;
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final address1Controller = TextEditingController();
  final address2Controller = TextEditingController();
  final zipController = TextEditingController();
  final cityController = TextEditingController();
  final countryController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final webController = TextEditingController();
  // Opening hours
  final mondayController = TextEditingController();
  final tuesdayController = TextEditingController();
  final wednesdayController = TextEditingController();
  final thursdayController = TextEditingController();
  final fridayController = TextEditingController();
  final saturdayController = TextEditingController();
  final sundayController = TextEditingController();

  double? latitude;
  double? longitude;

  final formKeys = {
    0: GlobalKey<FormState>(),
    1: GlobalKey<FormState>(),
  };
  int indexedStackIndex = 0;

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      final state = cast<LocationEditorEditing>(ref.read(locationEditorLogic));
      if (state == null) return;
      final location = state.location;
      nameController.text = location.name;
      descriptionController.text = location.description ?? "";
      address1Controller.text = location.addressLine1 ?? "";
      address2Controller.text = location.addressLine2 ?? "";
      zipController.text = location.zip ?? "";
      cityController.text = location.city ?? "";
      countryController.text = location.country?.localizedName ?? "";
      phoneController.text = location.phone ?? "";
      emailController.text = location.email ?? "";
      webController.text = location.website ?? "";
      mondayController.text = location.openingHours?.openingHours[Day.monday] ?? "";
      tuesdayController.text = location.openingHours?.openingHours[Day.tuesday] ?? "";
      wednesdayController.text = location.openingHours?.openingHours[Day.wednesday] ?? "";
      thursdayController.text = location.openingHours?.openingHours[Day.thursday] ?? "";
      fridayController.text = location.openingHours?.openingHours[Day.friday] ?? "";
      saturdayController.text = location.openingHours?.openingHours[Day.saturday] ?? "";
      sundayController.text = location.openingHours?.openingHours[Day.sunday] ?? "";
    });
  }

  @override
  void dispose() {
    super.dispose();
    nameController.dispose();
    descriptionController.dispose();
    address1Controller.dispose();
    address2Controller.dispose();
    zipController.dispose();
    cityController.dispose();
    countryController.dispose();
    phoneController.dispose();
    emailController.dispose();
    webController.dispose();
    mondayController.dispose();
    tuesdayController.dispose();
    wednesdayController.dispose();
    thursdayController.dispose();
    fridayController.dispose();
    saturdayController.dispose();
    sundayController.dispose();
  }

  void _listenToLogics(BuildContext context) {
    ref.listen<LocationEditorState>(locationEditorLogic, (previous, next) {
      if (next is LocationEditorFailed) {
        toastCoreError(next.error);
        delayedStateRefresh(() => ref.read(locationEditorLogic.notifier).reedit());
      } else if (next is LocationEditorSaved) {
        dismissUnsaved(notificationsTag);
        delayedStateRefresh(() => ref.read(locationEditorLogic.notifier).reedit());
        final key = ref.read(locationsLogic.notifier).reset();
        ref.read(refreshLogic.notifier).mark(key);
      }
    });
  }

  @override
  String? getTitle() => LangKeys.screenLocationDetailsTitle.tr();

  @override
  bool onBack(WidgetRef ref) {
    dismissUnsaved(notificationsTag);
    return true;
  }

  @override
  List<Widget>? buildAppBarActions() {
    final isMobile = ref.watch(layoutLogic).isMobile;
    return [
      Padding(
        padding: const EdgeInsets.all(moleculeScreenPadding / 2),
        child: NotificationsWidget(),
      ),
      if (!isMobile) ...[
        const MoleculeItemHorizontalSpace(),
        Padding(
          padding: const EdgeInsets.all(moleculeScreenPadding / 2),
          child: _buildSaveButton(),
        ),
      ],
    ];
  }

  @override
  Widget buildBody(BuildContext context) {
    _listenToLogics(context);
    final isMobile = ref.watch(layoutLogic).isMobile;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildChips(),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: moleculeScreenPadding),
            child: IndexedStack(
              index: indexedStackIndex,
              children: [
                isMobile ? buildContactMobileLayout(ref) : buildContactDefaultLayout(ref),
                buildOpeningHoursWidget(ref),
                buildOpeningHoursExceptionsWidget(ref),
              ],
            ),
          ),
        ),
        if (isMobile) ...[
          Padding(
            padding: const EdgeInsets.all(moleculeScreenPadding),
            child: _buildSaveButton(),
          ),
          MoleculeItemSpace(),
        ],
      ],
    );
  }

  void refresh() {
    setState(() {});
  }

  Widget _buildChips() {
    final chipLabels = [
      LangKeys.labelContact.tr(),
      LangKeys.labelOpeningHours.tr(),
      LangKeys.labelOpeningHoursExceptions.tr(),
    ];
    return Padding(
      padding: const EdgeInsets.only(bottom: moleculeScreenPadding, top: moleculeScreenPadding / 2),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: vegaScrollPhysic,
        child: Row(
          children: [
            SizedBox(width: moleculeScreenPadding),
            for (int i = 0; i < chipLabels.length; i++) ...{
              Padding(
                padding: const EdgeInsets.only(right: moleculeScreenPadding),
                child: MoleculeChip(
                    label: chipLabels[i],
                    backgroundColor: indexedStackIndex == i ? ref.scheme.primary : ref.scheme.secondary,
                    onTap: () {
                      indexedStackIndex = i;
                      refresh();
                    }),
              ),
            }
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return MoleculeActionButton(
      title: LangKeys.buttonSave.tr(),
      successTitle: LangKeys.operationSuccessful.tr(),
      failTitle: LangKeys.operationFailed.tr(),
      buttonState: ref.watch(locationEditorLogic).buttonState,
      onPressed: () {
        var validated = true;
        formKeys.forEach((key, formKey) {
          if (!(formKey.currentState?.validate() ?? false)) {
            toastError(LangKeys.toastInvalidFormData.tr());
            indexedStackIndex = key;
            validated = false;
          }
        });
        if (!validated) {
          return refresh();
        }
        ref.read(locationEditorLogic.notifier).set(
              name: nameController.text,
              description: descriptionController.text,
              addressLine1: address1Controller.text,
              addressLine2: address2Controller.text,
              zip: zipController.text,
              city: cityController.text,
              country: CountryCode.fromCodeOrNull(countryController.text),
              phone: phoneController.text,
              email: emailController.text,
              website: webController.text,
              type: pickedType,
              latitude: latitude,
              longitude: longitude,
              openingHours: OpeningHours(
                openingHours: {
                  Day.monday: mondayController.text,
                  Day.tuesday: tuesdayController.text,
                  Day.wednesday: wednesdayController.text,
                  Day.thursday: thursdayController.text,
                  Day.friday: fridayController.text,
                  Day.saturday: saturdayController.text,
                  Day.sunday: sundayController.text,
                },
              ),
            );
        ref.read(locationEditorLogic.notifier).save();
      },
    );
  }
}

// eof
