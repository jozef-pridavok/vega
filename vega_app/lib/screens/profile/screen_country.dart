import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:flutter/material.dart";
import "package:vega_app/screens/screen_app.dart";
import "package:vega_app/states/providers.dart";
import "package:vega_app/strings.dart";

class CountryScreen extends AppScreen {
  final bool cancel;
  const CountryScreen({super.key, this.cancel = false});

  @override
  createState() => _CountryState();
}

class _CountryState extends AppScreenState<CountryScreen> {
  late Country selectedCountry;

  @override
  void initState() {
    super.initState();
    final user = ref.read(deviceRepository).get(DeviceKey.user) as User;
    selectedCountry = CountryCode.fromCode(user.country, def: Country.slovakia);
  }

  @override
  PreferredSizeWidget? buildAppBar(BuildContext context) => VegaAppBar(
        title: LangKeys.screenRegionTitle.tr(),
        cancel: widget.cancel,
      );

  @override
  Widget buildBody(BuildContext context) {
    final countries = <Country>[];
    countries.addAll(Country.values);
    countries.sort((a, b) => a.name.compareToIgnoringDiacritics(b.name));

    return Padding(
      padding: const EdgeInsets.all(moleculeScreenPadding),
      child: ListView(
        physics: vegaScrollPhysic,
        children: countries.map((country) => _buildRow(context, country)).toList(),
      ),
    );
  }

  Widget _buildRow(BuildContext context, Country country) {
    return MoleculeItemBasic(
      title: country.localizedName,
      icon: "country_${country.code}",
      applyColorFilter: false,
      actionIcon: selectedCountry == country ? "check" : null,
      onAction: () {
        setState(() => selectedCountry = country);
        ref.read(userUpdateLogic.notifier).update(country: country);
        if (widget.cancel) context.pop();
      },
    );
  }
}

// eof
