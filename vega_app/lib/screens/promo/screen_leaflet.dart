import "package:core_flutter/core_dart.dart" hide BlurHash;
import "package:core_flutter/core_flutter.dart";
import "package:flutter/material.dart";

import "../../caches.dart";
import "../screen_app.dart";

class ClientLeafletScreen extends AppScreen {
  final LeafletDetail leafletDetail;
  const ClientLeafletScreen(this.leafletDetail, {super.key});

  @override
  createState() => _LeafletScreenState();
}

class _LeafletScreenState extends AppScreenState<ClientLeafletScreen> {
  int get _pages => widget.leafletDetail.pages?.length ?? 0;

  @override
  PreferredSizeWidget? buildAppBar(BuildContext context) => VegaAppBar(
        title: widget.leafletDetail.name,
        cancel: true,
      );

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget buildBody(BuildContext context) {
    return ListView.builder(
        itemCount: _pages,
        itemBuilder: (context, index) {
          final image = widget.leafletDetail.pages![index];
          final imageBh = widget.leafletDetail.pagesBh?[index];
          return Padding(
            padding: const EdgeInsets.only(
              left: moleculeScreenPadding,
              top: moleculeScreenPadding,
              right: moleculeScreenPadding,
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                CachedImage(
                  config: Caches.leafletImage,
                  url: image,
                  blurHash: imageBh,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => Container(
                    decoration: moleculeOutlineDecoration(ref.scheme.content),
                    child: AspectRatio(
                      aspectRatio: 2,
                      child: Center(
                        child: SizedBox(
                          width: 64,
                          height: 64,
                          child: VegaIcon(name: AtomIcons.xCircle, color: ref.scheme.negative),
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          );
        });
  }
}

// eof
