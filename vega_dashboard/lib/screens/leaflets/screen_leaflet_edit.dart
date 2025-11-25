import "dart:typed_data";

import "package:collection/collection.dart";
import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:core_flutter/states/provider.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/src/consumer.dart";

import "../../extensions/select_item.dart";
import "../../states/leaflet_editor.dart";
import "../../states/locations.dart";
import "../../states/providers.dart";
import "../../strings.dart";
import "../../utils/image_picker.dart";
import "../../utils/validations.dart";
import "../../widgets/molecule_picker.dart";
import "../../widgets/molecule_picker_date.dart";
import "../../widgets/notifications.dart";
import "../screen_app.dart";

class ScreenLeafletEdit extends VegaScreen {
  const ScreenLeafletEdit({super.key});

  @override
  createState() => _EditState();
}

class _EditState extends VegaScreenState<ScreenLeafletEdit> with SingleTickerProviderStateMixin, LoggerMixin {
  // TODO: dať do konfigurácie klienta
  final _paperSize = PaperSize.a4;

  final notificationsTag = "a9595ee7-b0ad-4435-acef-2f449db7a8bf";

  final unsavedWarningText = LangKeys.notificationUnsavedData.tr();

  final _formKey = GlobalKey<FormState>();

  late String _name;
  late IntDate _validFrom;
  late IntDate _validTo;
  late Country _country;
  late String? _locationId;
  late List<Country> _eligibleCountries;

  bool _loadingPage = false;
  bool _addingToEnd = false;
  int _loadingIndex = 0;
  List<dynamic> _pages = [];

  @override
  void initState() {
    super.initState();

    final client = ref.read(deviceRepository).get(DeviceKey.client) as Client;
    _eligibleCountries = client.countries ?? [];

    final leaflet = (ref.read(leafletEditorLogic) as LeafletEditorEditing).leaflet;

    _name = leaflet.name;
    _validFrom = leaflet.validFrom;
    _validTo = leaflet.validTo;
    _country = leaflet.country;
    _locationId = leaflet.locationId;

    _pages = leaflet.pages.isEmpty ? <dynamic>[] : leaflet.pages.cast<dynamic>();

    Future.microtask(() => ref.read(locationsLogic.notifier).load());
    Future.microtask(() => ref.read(leafletEditorLogic.notifier).reedit());
  }

  @override
  String? getTitle() => LangKeys.screenLeafletTitle.tr();

  @override
  bool onBack(WidgetRef ref) {
    dismissUnsaved(notificationsTag);
    return super.onBack(ref);
  }

  @override
  List<Widget>? buildAppBarActions() {
    final isMobile = ref.watch(layoutLogic).isMobile;
    return [
      Padding(
        padding: const EdgeInsets.symmetric(vertical: moleculeScreenPadding / 2),
        child: NotificationsWidget(),
      ),
      const MoleculeItemHorizontalSpace(),
      if (!isMobile) ...[
        Padding(
          padding: const EdgeInsets.symmetric(vertical: moleculeScreenPadding / 2),
          child: _buildSaveButton(),
        ),
        const MoleculeItemHorizontalSpace(),
      ],
    ];
  }

  @override
  Widget buildBody(BuildContext context) {
    _listenToLogics(context);
    final isMobile = ref.watch(layoutLogic).isMobile;
    return Padding(
      padding: const EdgeInsets.all(moleculeScreenPadding),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: isMobile ? _buildMobileLayout() : _buildDefaultLayout(),
        ),
      ),
    );
  }

  void _listenToLogics(BuildContext context) {
    ref.listen<LeafletEditorState>(leafletEditorLogic, (previous, next) {
      if (next is LeafletEditorFailed) {
        toastCoreError(next.error);
        delayedStateRefresh(() => ref.read(leafletEditorLogic.notifier).reedit());
      } else if (next is LeafletEditorSaved) {
        delayedStateRefresh(() => ref.read(leafletEditorLogic.notifier).reedit());
        dismissUnsaved(notificationsTag);
        var key = ref.read(activeLeafletsLogic.notifier).reset();
        ref.read(refreshLogic.notifier).mark(key);
        key = ref.read(preparedLeafletsLogic.notifier).reset();
        ref.read(refreshLogic.notifier).mark(key);
      }
    });
  }

  Widget _buildMobileLayout() => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildName(),
          const MoleculeItemSpace(),
          Row(
            children: [
              Flexible(child: _buildDateFrom()),
              const MoleculeItemHorizontalSpace(),
              Flexible(child: _buildDateTo()),
            ],
          ),
          const MoleculeItemSpace(),
          Row(
            children: [
              Flexible(child: _buildCountries()),
              const MoleculeItemHorizontalSpace(),
              Flexible(child: _buildLocation()),
            ],
          ),
          const MoleculeItemSpace(),
          SizedBox(
            height: _paperSize.height.toDouble(),
            child: _buildPages(),
          ),
          const MoleculeItemSpace(),
          Center(
            child: MoleculeSecondaryButton(
              titleText: LangKeys.buttonAddLeafletPage.tr(),
              onTap: () => _pickFile(true, 0),
              //title: VegaIcon(name: AtomIcons.add),
            ),
          ),
          const MoleculeItemSpace(),
          _buildSaveButton(),
          const MoleculeItemSpace(),
        ],
      );

  Widget _buildDefaultLayout() => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(child: _buildName()),
              const MoleculeItemHorizontalSpace(),
              Flexible(child: _buildDateFrom()),
              const MoleculeItemHorizontalSpace(),
              Flexible(child: _buildDateTo()),
            ],
          ),
          const MoleculeItemSpace(),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(child: _buildCountries()),
              const MoleculeItemHorizontalSpace(),
              Flexible(child: _buildLocation()),
            ],
          ),
          const MoleculeItemSpace(),
          SizedBox(
            height: _paperSize.height.toDouble(),
            child: _buildPages(),
          ),
          const MoleculeItemSpace(),
          Center(
            child: MoleculeSecondaryButton(
              titleText: LangKeys.buttonAddLeafletPage.tr(),
              onTap: () => _pickFile(true, 0),
              //title: VegaIcon(name: AtomIcons.add),
            ),
          ),
        ],
      );

  Widget _buildName() => MoleculeInput(
        title: LangKeys.labelName.tr(),
        maxLines: 1,
        initialValue: _name,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        validator: (value) => (value?.length ?? 0) < 1 ? LangKeys.validationValueRequired.tr() : null,
        onChanged: (value) {
          notifyUnsaved(notificationsTag);
          _name = value;
        },
      );

  Widget _buildDateFrom() => MoleculeDatePicker(
        title: LangKeys.labelValidFrom.tr(),
        hint: "",
        initialValue: _validFrom.toDate(),
        onChanged: (value) {
          notifyUnsaved(notificationsTag);
          _validFrom = IntDate.fromDate(value);
        },
      );

  Widget _buildDateTo() => MoleculeDatePicker(
        title: LangKeys.labelValidTo.tr(),
        hint: "",
        initialValue: _validTo.toDate(),
        onChanged: (value) {
          notifyUnsaved(notificationsTag);
          _validTo = IntDate.fromDate(value);
        },
      );

  Widget _buildCountries() => MoleculeSingleSelect(
        title: LangKeys.labelCountry.tr(),
        hint: LangKeys.locationEverywhere.tr(),
        items: _eligibleCountries.toSelectItems(),
        selectedItem: _country.toSelectItem(),
        onChanged: (selectedItem) {
          notifyUnsaved(notificationsTag);
          _country = _eligibleCountries.firstWhereOrNull((e) => e.code == selectedItem.value) ?? _country;
        },
      );

  Widget _buildLocation() {
    final locations = cast<LocationsSucceed>(ref.watch(locationsLogic))?.locations ?? [];
    return MoleculeSingleSelect(
      title: LangKeys.labelLocation.tr(),
      hint: LangKeys.locationEverywhere.tr(),
      items: locations.toSelectItems(),
      selectedItem: locations.firstWhereOrNull((e) => e.locationId == _locationId)?.toSelectItem(),
      onChangedOrClear: (selectedItem) {
        notifyUnsaved(notificationsTag);
        _locationId = selectedItem?.value;
      },
    );
  }

  void _showPageDropdownMenu(BuildContext context, TapUpDetails details, int index) {
    final offset = details.globalPosition;
    showMenu(
      position: RelativeRect.fromLTRB(
        offset.dx,
        offset.dy,
        MediaQuery.of(context).size.width - offset.dx,
        MediaQuery.of(context).size.height - offset.dy,
      ),
      context: context,
      items: [
        PopupMenuItem(
          child: MoleculeItemBasic(
            title: LangKeys.leafletReplaceImage.tr(),
            icon: AtomIcons.refresh,
            onAction: () {
              context.pop();
              _pickFile(false, index);
            },
          ),
        ),
        PopupMenuItem(
          child: MoleculeItemBasic(
            title: LangKeys.leafletDeleteImage.tr(),
            icon: AtomIcons.delete,
            onAction: () {
              context.pop();
              setState(() => _pages.removeAt(index));
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPages() {
    final length = _pages.length + (_loadingPage && _addingToEnd ? 1 : 0);
    return ReorderableListView.builder(
      proxyDecorator: createMoleculeDragDecorator(Colors.transparent),
      scrollDirection: Axis.horizontal,
      buildDefaultDragHandles: false,
      physics: vegaScrollPhysic,
      itemCount: length,
      itemBuilder: (context, index) => ReorderableDelayedDragStartListener(
        index: index,
        key: Key("page-$index"),
        child: Padding(
          padding: const EdgeInsets.only(right: moleculeScreenPadding),
          child: Container(
            decoration: moleculeShadowDecoration(ref.scheme.paperCard),
            child: _loadingPage && ((_addingToEnd && index > length - 2) || (!_addingToEnd && _loadingIndex == index))
                ? SizedBox(width: _paperSize.width.toDouble(), child: const CenteredWaitIndicator())
                : _buildPage(context, index),
          ),
        ),
      ),
      onReorder: (int oldIndex, int newIndex) {
        notifyUnsaved(notificationsTag);
        if (oldIndex < newIndex) newIndex -= 1;
        final item = _pages.removeAt(oldIndex);
        _pages.insert(newIndex, item);
      },
    );
  }

  Widget _buildPage(context, index) {
    final page = _pages[index];
    if (page is String) {
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapUp: (details) => _showPageDropdownMenu(context, details, index),
        child: Image.network(
          page,
          width: _paperSize.width.toDouble(),
          loadingBuilder: (context, child, loading) => loading == null ? child : const CenteredWaitIndicator(),
        ),
      );
    } else if (page is List<int>) {
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapUp: (details) => _showPageDropdownMenu(context, details, index),
        child: Image.memory(
          Uint8List.fromList(page),
          width: _paperSize.width.toDouble(),
          cacheWidth: _paperSize.width,
        ),
      );
    } else {
      return Container();
    }
  }

  void _pickFile(bool addToEnd, int index) async {
    setState(() {
      _loadingPage = true;
      _loadingIndex = index;
      _addingToEnd = addToEnd;
    });
    final scale = 2;
    final image = await ImagePicker().pickImage(width: _paperSize.width * scale, height: _paperSize.height * scale);
    if (image == null) return setState(() => _loadingPage = false);
    final imageData = image.toList();
    if (addToEnd) {
      setState(() => _loadingPage = false);
      return _pages.add(imageData);
    }
    _pages[index] = imageData;
    setState(() => _loadingPage = false);
    notifyUnsaved(notificationsTag);
  }

  Widget _buildSaveButton() {
    final buttonState = ref.watch(leafletEditorLogic).buttonState;
    return MoleculeActionButton(
      title: LangKeys.buttonSave.tr(),
      successTitle: LangKeys.operationSuccessful.tr(),
      failTitle: LangKeys.operationFailed.tr(),
      buttonState: buttonState,
      onPressed: () async {
        if (!_formKey.currentState!.validate()) return;
        if (!isValidFromTo(ref, _validFrom, _validTo, validFromInFuture: false, validToIsRequired: true)) return;
        if (_pages.isEmpty) return toastError(LangKeys.toastValidationImageRequired.tr());
        ref.read(leafletEditorLogic.notifier).save(
              name: _name,
              validFrom: _validFrom,
              validTo: _validTo,
              country: _country,
              locationId: _locationId,
              pages: _pages,
            );
      },
    );
  }
}

// eof
