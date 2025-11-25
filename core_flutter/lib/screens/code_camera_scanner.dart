import "dart:async";

import "package:collection/collection.dart";
import "package:core_dart/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:core_flutter/core_screens.dart";
import "package:core_flutter/states/provider.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:focus_detector/focus_detector.dart";
import "package:mobile_scanner/mobile_scanner.dart";

extension _BarcodeFormatToCodeType on BarcodeFormat {
  static final _convertMap = {
    BarcodeFormat.aztec: CodeType.aztec,
    BarcodeFormat.code128: CodeType.code128,
    BarcodeFormat.code39: CodeType.code39,
    BarcodeFormat.code93: CodeType.code93,
    BarcodeFormat.dataMatrix: CodeType.datamatrix,
    BarcodeFormat.ean13: CodeType.ean13,
    BarcodeFormat.ean8: CodeType.ean8,
    BarcodeFormat.itf: CodeType.itf14,
    BarcodeFormat.pdf417: CodeType.pdf417,
    BarcodeFormat.qrCode: CodeType.qr,
    BarcodeFormat.upcA: CodeType.upca,
    BarcodeFormat.upcE: CodeType.upce,
  };
  CodeType? get codeType => _convertMap[this];
}

class CodeCameraScreen extends Screen {
  final String title;
  final bool cancel;
  final void Function(CodeType? type, String number) onFinish;
  final Widget? child;

  const CodeCameraScreen({
    super.key,
    required this.title,
    required this.onFinish,
    this.cancel = false,
    this.child,
  });

  @override
  createState() => _CodeCameraState();
}

class _CodeCameraState extends ScreenState<CodeCameraScreen> with LoggerMixin {
  // WidgetsBindingObserver
  final MobileScannerController _scannerController = MobileScannerController(
    torchEnabled: false,
    //formats: [BarcodeFormat.all], //[BarcodeFormat.qrCode]
    // facing: CameraFacing.front,
    // detectionSpeed: DetectionSpeed.normal
    // detectionTimeoutMs: 1000,
    // returnImage: false,
  );

  //StreamSubscription<Object?>? _subscription;

  /*
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);
    _subscription = _scannerController.barcodes.listen(_onDetect);
    unawaited(_scannerController.start());
  }
  */

  @override
  void dispose() {
    //WidgetsBinding.instance.removeObserver(this);
    //unawaited(_subscription?.cancel());
    //_subscription = null;
    _scannerController.dispose();
    super.dispose();
  }

  /*
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_scannerController.value.hasCameraPermission) {
      return;
    }

    switch (state) {
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
        return;
      case AppLifecycleState.resumed:
        _subscription = _scannerController.barcodes.listen(_onDetect);
        unawaited(_scannerController.start());
      case AppLifecycleState.inactive:
        unawaited(_subscription?.cancel());
        _subscription = null;
        unawaited(_scannerController.stop());
    }
  }
  */

  @override
  PreferredSizeWidget? buildAppBar(BuildContext context) => VegaAppBar(
        title: widget.title,
        cancel: widget.cancel,
        actions: [
          IconButton(
            icon: VegaIcon(
              name: "zap",
              color: _scannerController.torchEnabled ? ref.scheme.primary : ref.scheme.content20,
            ),
            onPressed: () => _scannerController.toggleTorch(),
          )
        ],
      );

  @override
  Widget buildBody(BuildContext context) {
    //final isMobile = ref.watch(LayoutNotifierBase.provider).isMobile;
    final isMobile = ref.watch(layoutLogic).isMobile;
    return FocusDetector(
      onVisibilityGained: () {
        if (!mounted) return;
        _scannerController.start();
      },
      child: Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: moleculeScreenPadding),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: !isMobile ? ScreenFactor.tablet : double.infinity),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const MoleculeItemSpace(),
                AspectRatio(
                  aspectRatio: 86 / 54.0,
                  child: Container(
                    clipBehavior: Clip.hardEdge,
                    decoration: BoxDecoration(
                      color: ref.scheme.content20,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: ref.scheme.content20, width: 1),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          MobileScanner(
                            fit: BoxFit.cover,
                            controller: _scannerController,
                            errorBuilder: (context, exception, widget) {
                              debug(() => exception.toString());
                              return Center(
                                child: VegaIcon(name: AtomIcons.xCircle, size: 48, color: ref.scheme.negative),
                              );
                            },
                            onDetect: _onDetect,
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                const MoleculeItemSpace(),
                widget.child ?? const SizedBox(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onDetect(BarcodeCapture capture) {
    HapticFeedback.vibrate();
    final barcode = capture.barcodes.firstOrNull;
    final value = barcode?.rawValue;
    if (barcode == null || value == null) return;
    final type = barcode.format.codeType;
    _scannerController.stop();
    Future.delayed(fastRefreshDuration, () => widget.onFinish(type, value));
  }
}

// eof
