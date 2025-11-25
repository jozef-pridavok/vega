import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:core_flutter/states/provider.dart";
import "package:flutter/material.dart";
import "package:vega_dashboard/screens/client_settings/widget_tab_integrations.dart";

import "../../states/client_settings.dart";
import "../../states/providers.dart";
import "../../strings.dart";
import "../../widgets/notifications.dart";
import "../../widgets/state_error.dart";
import "../screen_app.dart";
import "widget_tab_basic.dart";
import "widget_tab_contact.dart";
import "widget_tab_delivery.dart";
import "widget_tab_invoicing.dart";

class ClientSettingsScreen extends VegaScreen {
  const ClientSettingsScreen({super.showDrawer, super.key});

  @override
  createState() => ClientSettingsScreenState();
}

class ClientSettingsScreenState extends VegaScreenState<ClientSettingsScreen> with SingleTickerProviderStateMixin {
  // TODO: read from yaml
  static const supportedLanguages = ["sk", "cz", "en", "es"];

  final notificationTag = "6d508354-f0b7-42ff-b967-d9370c9843ce";
  final unsavedWarningText = LangKeys.notificationUnsavedData.tr();

  late TabController _tabController;
  // Basic Settings
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  // Contact settings
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final webController = TextEditingController();
  final languageController = TextEditingController();
  final descriptionLocalizedController = TextEditingController();
  // Invoicing settings
  final invoicingNameController = TextEditingController();
  final invoicingCompanyNumberIdController = TextEditingController();
  final invoicingCompanyVatIdController = TextEditingController();
  final invoicingAddress1Controller = TextEditingController();
  final invoicingAddress2Controller = TextEditingController();
  final invoicingZipController = TextEditingController();
  final invoicingCityController = TextEditingController();
  final invoicingCountryController = TextEditingController();
  final invoicingPhoneController = TextEditingController();
  final invoicingEmailController = TextEditingController();
  // Delivery settings
  final deliveryFeeController = TextEditingController();
  final pickupFeeController = TextEditingController();

  final formKeys = {
    0: GlobalKey<FormState>(),
    1: GlobalKey<FormState>(),
    2: GlobalKey<FormState>(),
    3: GlobalKey<FormState>(),
  };
  int indexedStackIndex = 0;

  Color color = Palette.white;
  Currency currency = defaultCurrency;
  Locale? language;

  List<int>? newImage;
  bool loadingImage = false;
  String? oldLogo;
  Map<String, String> localizedDescription = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(initialIndex: 0, length: 4, vsync: this);
    Future.microtask(() {
      ref.read(clientSettingsLogic.notifier).load();
      final loaded = cast<ClientSettingsLoaded>(ref.read(clientSettingsLogic));
      final editing = cast<ClientSettingsEditing>(ref.read(clientSettingsLogic));
      final client = loaded?.client ?? editing?.client;
      if (client != null) setState(() => _update(context, client));
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    nameController.dispose();
    descriptionController.dispose();
    phoneController.dispose();
    webController.dispose();
    emailController.dispose();
    languageController.dispose();
    descriptionLocalizedController.dispose();
    invoicingNameController.dispose();
    invoicingCompanyNumberIdController.dispose();
    invoicingCompanyVatIdController.dispose();
    invoicingAddress1Controller.dispose();
    invoicingAddress2Controller.dispose();
    invoicingZipController.dispose();
    invoicingCityController.dispose();
    invoicingCountryController.dispose();
    invoicingPhoneController.dispose();
    invoicingEmailController.dispose();
    deliveryFeeController.dispose();
    pickupFeeController.dispose();
    super.dispose();
  }

  @override
  String? getTitle() => LangKeys.clientSettingsListScreenTitle.tr();

  @override
  bool canCloseDrawer() {
    dismissUnsaved(notificationTag);
    return super.canCloseDrawer();
  }

  @override
  List<Widget>? buildAppBarActions() {
    final isMobile = ref.watch(layoutLogic).isMobile;
    return [
      Padding(
        padding: const EdgeInsets.symmetric(vertical: moleculeScreenPadding / 2),
        child: NotificationsWidget(),
      ),
      if (!isMobile) ...[
        const MoleculeItemHorizontalSpace(),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: moleculeScreenPadding / 2),
          child: _buildSaveButton(),
        ),
      ],
      const SizedBox(width: moleculeScreenPadding),
    ];
  }

  @override
  Widget buildBody(BuildContext context) {
    _listenToLogics(context);
    final state = ref.watch(clientSettingsLogic);
    if (state is ClientSettingsLoading || state is ClientSettingsInitial) return const CenteredWaitIndicator();
    if (state is ClientSettingsFailed || state is ClientSettingsLoadFailed)
      return StateErrorWidget(
        clientSettingsLogic,
        onReload: () => ref.read(clientSettingsLogic.notifier).refresh(),
      );
    final isMobile = ref.watch(layoutLogic).isMobile;
    return PullToRefresh(
      onRefresh: () async => ref.read(clientSettingsLogic.notifier).refresh(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildChips(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: moleculeScreenPadding),
              child: IndexedStack(
                index: indexedStackIndex,
                children: [
                  isMobile ? buildBasicSettingsMobileLayout() : buildBasicSettingsDefaultLayout(),
                  isMobile ? buildContactMobileLayout() : buildContactDefaultLayout(),
                  isMobile ? buildInvoicingMobileLayout() : buildInvoicingDefaultLayout(),
                  buildDeliveryDefaultLayout(),
                  isMobile ? buildIntegrationsSettingsMobileLayout() : buildIntegrationsSettingsDefaultLayout(),
                ],
              ),
            ),
          ),
          if (isMobile) ...[
            Padding(
              padding: const EdgeInsets.all(moleculeScreenPadding),
              child: _buildSaveButton(),
            ),
          ]
        ],
      ),
    );
  }

  void refresh([VoidCallback? fn]) {
    setState(fn ?? () {});
  }

  void _listenToLogics(BuildContext context) {
    ref.listen<ClientSettingsState>(clientSettingsLogic, (previous, next) {
      if (next is ClientSettingsLoaded) {
        _update(context, next.client);
        dismissUnsaved(notificationTag);
        ref.read(clientSettingsLogic.notifier).edit();
      }
      if (next is ClientSettingsSaved) {
        dismissUnsaved(notificationTag);
        Future.delayed(stateRefreshDuration, () => ref.read(clientSettingsLogic.notifier).edit());
      }
      if (next is ClientSettingsSavingFailed) {
        toastCoreError(next.error);
        delayedStateRefresh(() => ref.read(clientSettingsLogic.notifier).recoverFromSaveFailed());
      }
    });
  }

  void _update(BuildContext context, Client client) {
    nameController.text = client.name;
    color = client.color;
    currency = client.currency;
    oldLogo = client.logo;
    descriptionController.text = client.description ?? "";

    phoneController.text = client.phone;
    webController.text = client.web;
    emailController.text = client.email;
    languageController.text = supportedLanguages[0];
    descriptionLocalizedController.text = client.getDescription(supportedLanguages[0]);

    invoicingNameController.text = client.invoicingName;
    invoicingCompanyNumberIdController.text = client.invoicingCompanyNumber;
    invoicingCompanyVatIdController.text = client.invoicingCompanyVat;
    invoicingAddress1Controller.text = client.invoicingAddress1;
    invoicingAddress2Controller.text = client.invoicingAddress2;
    invoicingZipController.text = client.invoicingZip;
    invoicingCityController.text = client.invoicingCity;
    invoicingCountryController.text = client.invoicingCountry;
    invoicingPhoneController.text = client.invoicingPhone;
    invoicingEmailController.text = client.invoicingEmail;

    final locale = context.locale.languageCode;
    language = context.locale;
    final deliveryPriceCourier = client.deliveryPriceCourier;
    final deliveryPricePickup = client.deliveryPricePickup;
    deliveryFeeController.text = deliveryPriceCourier != null ? currency.format(deliveryPriceCourier, locale) : "";
    pickupFeeController.text = deliveryPricePickup != null ? currency.format(deliveryPricePickup, locale) : "";
  }

  Widget _buildChips() {
    final chipLabels = [
      LangKeys.clientSettingsBasicTab.tr(),
      LangKeys.clientSettingsContactTab.tr(),
      LangKeys.clientSettingsInvoicingTab.tr(),
      LangKeys.clientSettingsDeliveryTab.tr(),
      LangKeys.clientSettingsIntegrationsTab.tr(),
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
    final state = ref.watch(clientSettingsLogic);
    bool showSaveButton = state is ClientSettingsEditing ||
        state is ClientSettingsRefreshing ||
        state is ClientSettingsSaving ||
        state is ClientSettingsSaved ||
        state is ClientSettingsSavingFailed;
    if (!showSaveButton) return SizedBox();
    final locale = context.locale.languageCode;
    return MoleculeActionButton(
      title: LangKeys.buttonSave.tr(),
      successTitle: LangKeys.operationSuccessful.tr(),
      failTitle: LangKeys.operationFailed.tr(),
      buttonState: ref.watch(clientSettingsLogic).buttonState,
      onPressed: () {
        var validated = true;
        formKeys.forEach((key, formKey) {
          if (!(formKey.currentState?.validate() ?? false)) {
            toastError(LangKeys.toastInvalidFormData.tr());
            indexedStackIndex = key;
            validated = false;
          }
        });
        if (!validated) return refresh();
        ref.read(clientSettingsLogic.notifier).save(
              name: nameController.text,
              description: descriptionController.text,
              color: color,
              newImage: newImage,
              phone: phoneController.text,
              email: emailController.text,
              web: webController.text,
              localizedDescription: localizedDescription,
              invoicingName: invoicingNameController.text,
              invoicingCompanyNumber: invoicingCompanyNumberIdController.text,
              invoicingCompanyVat: invoicingCompanyVatIdController.text,
              invoicingAddress1: invoicingAddress1Controller.text,
              invoicingAddress2: invoicingAddress2Controller.text,
              invoicingZip: invoicingZipController.text,
              invoicingCity: invoicingCityController.text,
              invoicingCountry: invoicingCountryController.text,
              invoicingPhone: invoicingPhoneController.text,
              invoicingEmail: invoicingEmailController.text,
              deliveryPriceCourier: currency.parse(deliveryFeeController.text, locale),
              deliveryPricePickup: currency.parse(pickupFeeController.text, locale),
            );
      },
    );
  }
}

// eof
