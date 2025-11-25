import "dart:math";

import "package:core_dart/core_dart.dart";
import "package:core_flutter/core_widgets.dart";
import "package:core_flutter/extensions/geo_point.dart";
import "package:core_flutter/extensions/widget_ref.dart";
import "package:flutter/material.dart";
import "package:flutter_map/flutter_map.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:latlong2/latlong.dart";

import "../core_theme.dart";
import "map_cached_tile_provider.dart";
import "map_controls.dart";

const _defaultMarkerWidth = 36.0;
const _defaultMarkerHeight = 42.0;

class MapWidget<T> extends ConsumerStatefulWidget {
  final bool showMapControls;
  final List<T> objects;
  final GeoPoint? center;
  final T? selectedObject;

  final double markerWidth;
  final double markerHeight;

// TODO: nejdu generické
  // správne by malo byť:
  //
  // final GeoPoint Function(T object) getGeoPoint;
  //
  // ale to dáva chybu
  // type '(CouponViewModel) => GeoPoint' is not a subtype of type '(dynamic) => GeoPoint'
  final GeoPoint Function(dynamic object) getGeoPoint;
  //final Widget Function(dynamic object)? buildMarker;
  final void Function(GeoPoint point)? onCenterChanged;
  //final void Function(double zoom)? onZoomChanged;
  final void Function(dynamic object)? onMarkerTap;

  const MapWidget({
    required this.objects,
    required this.getGeoPoint,
    this.selectedObject,
    this.center,
    this.onCenterChanged,
    this.onMarkerTap,
    this.markerWidth = _defaultMarkerWidth,
    this.markerHeight = _defaultMarkerHeight,
    this.showMapControls = false,
    super.key,
  });

  @override
  createState() => _MapState<T>();
}

class _MapState<T> extends ConsumerState<MapWidget> with TickerProviderStateMixin {
  static const _urlTemplate = "https://tile.openstreetmap.org/{z}/{x}/{y}.png";

  final _mapController = MapController();
  MapCamera? _lastCamera;

  LatLng _convertFromGeoPoint(GeoPoint geoPoint) => LatLng(geoPoint.latitude, geoPoint.longitude);

  void _onMapMoveEnd(MapEventMoveEnd moveEnd) {
    final onCenterChanged = widget.onCenterChanged;
    if (onCenterChanged != null) {
      final center = _lastCamera?.center;
      if (center != null) onCenterChanged(GeoPoint(latitude: center.latitude, longitude: center.longitude));
    }
    //final onZoomChanged = widget.onZoomChanged;
    //final zoom = moveEnd.zoom;
    //if (onZoomChanged != null) onZoomChanged(zoom);
  }

  @override
  void initState() {
    super.initState();

    _mapController.mapEventStream.listen((event) {
      // TODO: MapEventFlingAnimationEnd nie je emitovaný
      final flingEnd = cast<MapEventFlingAnimationEnd>(event);
      if (flingEnd != null) {
        //print("MAPP flingEnd $flingEnd");
      }
      final mapMoveStart = cast<MapEventMoveStart>(event);
      if (mapMoveStart != null) _lastCamera = null; //_onMapMoveStart(mapMoveStart);
      final mapMoveEnd = cast<MapEventMoveEnd>(event);
      if (mapMoveEnd != null) _onMapMoveEnd(mapMoveEnd);
    });

    Future(() {
      final geoPoints = widget.objects.map((e) => _convertFromGeoPoint(widget.getGeoPoint(e))).toList();
      final bounds = LatLngBounds.fromPoints(geoPoints);
      final fit = CameraFit.bounds(bounds: bounds).fit(_mapController.camera);
      _mapController.move(fit.center, fit.zoom);
    });
  }

  @override
  void dispose() {
    super.dispose();
    _mapController.dispose();
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
                  // TODO: MapEventFlingAnimationEnd nie je emitovaný
                  //InteractiveFlag.flingAnimation |
                  InteractiveFlag.doubleTapZoom,
            ),
            initialCenter: widget.center?.toLatLng() ?? const LatLng(51.5, -0.09),
            initialZoom: 13,
            maxZoom: 18,
            minZoom: 0,
            onPositionChanged: (position, hasGesture) {
              if (!hasGesture) return;
              _lastCamera = position;
              //_onMapPosition(position);
            },
          ),
          children: [
            TileLayer(urlTemplate: _urlTemplate, tileProvider: CachedTileProvider()),
            MarkerLayer(
                markers: widget.objects
                    .map<Marker>(
                      (object) => Marker(
                        point: _convertFromGeoPoint(widget.getGeoPoint(object)),
                        width: widget.markerWidth,
                        height: widget.markerHeight,
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => widget.onMarkerTap?.call(object),
                          child: VegaIcon(
                            name: object == widget.selectedObject
                                ? AtomIcons.mapMarkerSelected
                                : AtomIcons.mapMarkerDefault,
                            size: max(_defaultMarkerWidth, _defaultMarkerHeight),
                            applyColorFilter: false,
                          ),
                        ),
                      ),
                    )
                    .toList()),
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
}

extension _MapStateAnimatedMove on _MapState {
  static const _startedId = "AnimatedMapController#MoveStarted";
  static const _inProgressId = "AnimatedMapController#MoveInProgress";
  static const _finishedId = "AnimatedMapController#MoveFinished";

  void _animatedMapMove(LatLng destLocation, double destZoom) {
    // Create some tweens. These serve to split up the transition from one location to another.
    // In our case, we want to split the transition be<tween> our current map center and the destination.
    final latTween = Tween<double>(begin: _mapController.camera.center.latitude, end: destLocation.latitude);
    final lngTween = Tween<double>(begin: _mapController.camera.center.longitude, end: destLocation.longitude);
    final zoomTween = Tween<double>(begin: _mapController.camera.zoom, end: destZoom);

    // Create a animation controller that has a duration and a TickerProvider.
    final controller = AnimationController(duration: const Duration(milliseconds: 500), vsync: this);
    // The animation determines what path the animation will take. You can try different Curves values, although I found
    // fastOutSlowIn to be my favorite.
    final Animation<double> animation = CurvedAnimation(parent: controller, curve: Curves.fastOutSlowIn);

    // Note this method of encoding the target destination is a workaround.
    // When proper animated movement is supported (see #1263) we should be able
    // to detect an appropriate animated movement event which contains the
    // target zoom/center.
    final startIdWithTarget = "$_startedId#${destLocation.latitude},${destLocation.longitude},$destZoom";
    bool hasTriggeredMove = false;

    controller.addListener(() {
      final String id;
      if (animation.value == 1.0) {
        id = _finishedId;
      } else if (!hasTriggeredMove) {
        id = startIdWithTarget;
      } else {
        id = _inProgressId;
      }

      hasTriggeredMove |= _mapController.move(
        LatLng(latTween.evaluate(animation), lngTween.evaluate(animation)),
        zoomTween.evaluate(animation),
        id: id,
      );
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
}



// eof
