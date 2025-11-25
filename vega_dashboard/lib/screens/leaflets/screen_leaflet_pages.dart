import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:flutter/material.dart";

import "../../strings.dart";
import "../screen_app.dart";

class ScreenLeafletPages extends VegaScreen {
  final Leaflet leaflet;

  const ScreenLeafletPages({super.key, required this.leaflet});

  @override
  createState() => _EditState();
}

class _EditState extends VegaScreenState<ScreenLeafletPages> {
  Leaflet get _leaflet => widget.leaflet;

  late List<String> _pages = [];

  @override
  void initState() {
    super.initState();
    _pages = _leaflet.pages;
  }

  @override
  String? getTitle() => LangKeys.leafletTitleShowPages.tr();

  @override
  Widget buildBody(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(moleculeScreenPadding),
      child: ListView.builder(
        physics: vegaScrollPhysic,
        itemCount: _pages.length,
        itemBuilder: (BuildContext context, int index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: moleculeScreenPadding),
            child: Image.network(
              _pages[index],
              //scale: 1,
              //width: 200,
              loadingBuilder: (context, child, loading) => loading == null ? child : const CenteredWaitIndicator(),
              //errorBuilder: (context, error, stackTrace) {
              //  return Text("NOT EXIST ${_pages[index]}");
              //},
            ),
          );
        },
      ),
    );
  }
}


// eof
