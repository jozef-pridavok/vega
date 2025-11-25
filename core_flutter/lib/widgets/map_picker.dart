import "package:core_flutter/core_dart.dart";
import "package:core_flutter/extensions/geo_point.dart";
import "package:flutter/material.dart";
import "package:flutter_map/flutter_map.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:latlong2/latlong.dart";

import "../core_flutter.dart";
import "map_cached_tile_provider.dart";
import "map_controls.dart";

class MapPickerWidget extends ConsumerStatefulWidget {
  final bool showMapControls;
  final bool usePin;
  final GeoPoint initial;
  final Function(GeoPoint point) onChanged;

  const MapPickerWidget({
    Key? key,
    required this.initial,
    required this.onChanged,
    this.showMapControls = false,
    this.usePin = true,
  }) : super(key: key);

  @override
  createState() => _MapPickerWidgetState();
}

class _MapPickerWidgetState extends ConsumerState<MapPickerWidget> with LoggerMixin, TickerProviderStateMixin {
  static const _urlTemplate = "https://tile.openstreetmap.org/{z}/{x}/{y}.png";

  late LatLng _picker;
  static const _sizeActualIndicator = 96.0;
  static const _defaultMarkerWidth = 36.0;
  static const _defaultMarkerHeight = 42.0;
  bool _moving = false;
  final _mapController = MapController();

  @override
  void initState() {
    super.initState();
    _picker = widget.initial.toLatLng();
    _mapController.mapEventStream.listen((event) {
      final mapMoveStart = cast<MapEventMoveStart>(event);
      if (mapMoveStart != null) _onMapMoveStart(mapMoveStart);
      final mapMoveEnd = cast<MapEventMoveEnd>(event);
      if (mapMoveEnd != null) _onMapMoveEnd(mapMoveEnd);
    });
    Future.delayed(const Duration(milliseconds: 250), () {
      _animatedMapMove(widget.initial.toLatLng(), 8);
      Future.delayed(const Duration(milliseconds: 750), () {
        _animatedMapMove(widget.initial.toLatLng(), 14);
        Future.delayed(const Duration(milliseconds: 1250), () {
          _animatedMapMove(widget.initial.toLatLng(), 18);
        });
      });
    });
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  void _animatedMapMove(LatLng destLocation, double destZoom) {
    if (!mounted) return;

    // Create some tweens. These serve to split up the transition from one location to another.
    // In our case, we want to split the transition be<tween> our current map center and the destination.
    final latTween = Tween<double>(begin: _mapController.camera.center.latitude, end: destLocation.latitude);
    final lngTween = Tween<double>(begin: _mapController.camera.center.longitude, end: destLocation.longitude);
    final zoomTween = Tween<double>(begin: _mapController.camera.zoom, end: destZoom);

    // Create a animation controller that has a duration and a TickerProvider.
    var controller = AnimationController(duration: const Duration(milliseconds: 500), vsync: this);
    // The animation determines what path the animation will take. You can try different Curves values, although I found
    // fastOutSlowIn to be my favorite.
    Animation<double> animation = CurvedAnimation(parent: controller, curve: Curves.fastOutSlowIn);

    controller.addListener(() {
      _mapController.move(
          LatLng(latTween.evaluate(animation), lngTween.evaluate(animation)), zoomTween.evaluate(animation));
    });

    animation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        controller.dispose();
      } else if (status == AnimationStatus.dismissed) {
        controller.dispose();
      }
    });

    controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.drag |
                  //InteractiveFlag.pinchMove |
                  InteractiveFlag.pinchZoom |
                  InteractiveFlag.flingAnimation |
                  InteractiveFlag.doubleTapZoom,
            ),
            initialCenter: widget.initial.toLatLng(),
            initialZoom: 5, //13.0,
            onPositionChanged: (camera, hasGesture) {
              if (!hasGesture) return;
              _onMapPosition(camera);
            },
          ),
          children: [
            TileLayer(urlTemplate: _urlTemplate, tileProvider: CachedTileProvider()),
            MarkerLayer(
              markers: [
                Marker(
                  width: widget.usePin ? _defaultMarkerWidth : _sizeActualIndicator,
                  height: widget.usePin ? _defaultMarkerHeight : _sizeActualIndicator,
                  point: _picker,
                  // TODO: tu sa nevykresluje "direction" lebo alpha... treba celý prvok nakresliť ručne s animáciou pulzácie
                  child: VegaIcon(
                    name: widget.usePin
                        ? (!_moving ? AtomIcons.mapMarkerDefault : AtomIcons.mapMarkerSelected)
                        : (!_moving ? AtomIcons.mapActualSmall : AtomIcons.mapActualBig),
                    size: _sizeActualIndicator,
                    applyColorFilter: false,
                  ),
                ),
              ],
            ),
          ],
        ),
        if (widget.showMapControls)
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.all(moleculeScreenPadding / 2),
              child: Container(
                decoration: moleculeOutlineDecoration(ref.scheme.paperBold, ref.scheme.paper),
                child: MapControls(mapController: _mapController),
              ),
            ),
          ),
      ],
    );
  }

  void _onMapPosition(MapCamera camera) {
    final center = camera.center;
    if (!mounted) return;
    setState(() => _picker = center);
    widget.onChanged(center.toGeoPoint());
  }

  void _onMapMoveStart(MapEventMoveStart moveStart) {
    setState(() => _moving = true);
  }

  void _onMapMoveEnd(MapEventMoveEnd moveEnd) {
    setState(() => _moving = false);
  }
}

// eof
