import "package:core_flutter/core_flutter.dart";
import "package:flutter/material.dart";
import "package:flutter_map/flutter_map.dart";

class MapControls extends StatelessWidget {
  final MapController mapController;

  const MapControls({
    Key? key,
    required this.mapController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const VegaIcon(name: AtomIcons.minusCircle),
          onPressed: () => mapController.move(mapController.camera.center, mapController.camera.zoom - 1),
        ),
        IconButton(
          icon: const VegaIcon(name: AtomIcons.plusCircle),
          onPressed: () => mapController.move(mapController.camera.center, mapController.camera.zoom + 1),
        ),
      ],
    );
  }
}

// eof
