import "package:core_flutter/core_dart.dart";
import "package:flutter/material.dart";
import "package:flutter_inappwebview/flutter_inappwebview.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

class WhatsappScreen extends ConsumerStatefulWidget {
  const WhatsappScreen({super.key});

  @override
  createState() => _WhatsappState();
}

class _WhatsappState extends ConsumerState<WhatsappScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget buildOld(BuildContext context) {
    final endPoint = ApiClient().endPoint;
    final apiKey = ApiClient().apiKey;
    final device = ref.read(deviceRepository);
    final accessToken = device.get(DeviceKey.accessToken) as String;
    return Scaffold(
      appBar: AppBar(title: const Text("Meta integrations: Facebook / WhatsApp")),
      body: InAppWebView(
        initialUrlRequest: URLRequest(
          url: WebUri("$endPoint/public/integrations/whatsapp.html?u=$endPoint&k=$apiKey&t=$accessToken"),
        ),
        initialSettings: InAppWebViewSettings(
          javaScriptCanOpenWindowsAutomatically: true,
          supportMultipleWindows: true,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final endPoint = ApiClient().endPoint;
    final apiKey = ApiClient().apiKey;
    final device = ref.read(deviceRepository);
    final accessToken = device.get(DeviceKey.accessToken) as String;
    return Scaffold(
      appBar: AppBar(title: const Text("Meta integrations: Facebook / WhatsApp")),
      body: InAppWebView(
        initialUrlRequest: URLRequest(
          url: WebUri("$endPoint/public/integrations/whatsapp.html?u=$endPoint&k=$apiKey&t=$accessToken"),
        ),
        initialSettings: InAppWebViewSettings(
          javaScriptCanOpenWindowsAutomatically: true,
          supportMultipleWindows: true,
        ),
      ),
    );
  }
}

// eof
