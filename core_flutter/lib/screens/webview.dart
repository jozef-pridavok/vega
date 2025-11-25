import "package:core_dart/core_dart.dart";
import "package:core_flutter/core_app.dart";
import "package:core_flutter/core_flutter.dart";
import "package:core_flutter/core_screens.dart";
import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:package_info_plus/package_info_plus.dart";
import "package:url_launcher/url_launcher.dart";
import "package:webview_flutter/webview_flutter.dart";

class WebViewScreen extends Screen {
  final String? title;
  final String? internalPage;
  final String? externalPage;
  final String? content;
  final bool allowJavascript;
  final bool showBackButton;

  const WebViewScreen(
    this.title, {
    this.internalPage,
    this.externalPage,
    this.content,
    this.showBackButton = true,
    this.allowJavascript = false,
    Key? key,
  }) : super(key: key);

  @override
  createState() => _WebViewScreenState();
}

class _WebViewScreenState extends ScreenState<WebViewScreen> with LoggerMixin {
  late WebViewController _controller;
  var _contentLoaded = false;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(widget.allowJavascript ? JavaScriptMode.unrestricted : JavaScriptMode.disabled)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (url) => Future.delayed(fastRefreshDuration, () => setState(() => _contentLoaded = true)),
          onHttpError: (HttpResponseError error) => context.toastError("HTTP response error: $error"),
          onWebResourceError: (WebResourceError error) => context.toastError("Web resource error: $error"),
          onNavigationRequest: (NavigationRequest navigation) async {
            //if (request.url.startsWith('https://www.youtube.com/')) {
            //  return NavigationDecision.prevent;
            //}
            //return NavigationDecision.navigate;
            if (!navigation.isMainFrame) {
              final url = Uri.parse(navigation.url);
              if (await canLaunchUrl(url)) {
                await launchUrl(url); //, forceSafariVC: false, forceWebView: false);
              } else {
                warning("Could not launch $url");
              }
              return NavigationDecision.prevent;
            } else {
              // TODO: ActionHandler
              //final actionHandler = ActionHandler(navigation.url);
              //if (actionHandler.isKarty()) {
              //  actionHandler.exec(context, ref);
              //  return NavigationDecision.prevent;
              //}
            }
            return NavigationDecision.navigate;
          },
        ),
      );

    Future.microtask(() async {
      if (widget.internalPage != null) {
        await _loadAsset();
      } else if (widget.externalPage != null) {
        await _controller.loadRequest(Uri.parse(widget.externalPage!));
      } else if (widget.content != null) {
        await _loadString(widget.content!);
      }
    });
  }

  Future<String> _processContent(String content) async {
    final info = await PackageInfo.fromPlatform();

    content = content.replaceAll("\$(version)", info.version);
    content = content.replaceAll("\$(build)", info.buildNumber);
    content = content.replaceAll("\$(translation)", "translation_version".tr());
    content = content.replaceAll("\$(translation_version)", "translation_version".tr());

    if (F().flavor != Flavor.prod) {
      var info = "<h1>Non production info</h1>";
      info += "Flavor: ${F().name}</br>";
      info += "Mode: ";
      info += kReleaseMode ? "Release" : "";
      info += kProfileMode ? "Profile" : "";
      info += kDebugMode ? "Debug" : "";
      info += "</br>Endpoint: ";
      info += F().apiHost;
      content = content.replaceAll("\$(debug)", info);
    } else {
      content = content.replaceAll("\$(debug)", "");
    }

    content = content.replaceAll("var(--bg-color)", ref.scheme.paper.toCore().toHtmlRgba());
    content = content.replaceAll("var(--fg-color)", ref.scheme.content.toCore().toHtmlRgba());

    return content;
  }

  Future<void> _loadContent(String content) async {
    //String url = Uri.dataFromString(content, mimeType: "text/html", encoding: Encoding.getByName("utf-8")).toString();
    try {
      await _controller.loadHtmlString(content /*url*/);
    } catch (e) {
      error("Error: $e");
    }
  }

  Future<void> _loadAsset() async {
    var content = "";

    var lang = context.languageCode;
    do {
      final key = "assets/html/$lang/${widget.internalPage}.html";
      try {
        content = await rootBundle.loadString(key);
        break;
      } catch (e) {
        error("Error loading assets $key: $e");
        if (lang == "en") break;
        lang = "en";
      }
    } while (true);

    content = await _processContent(content);
    await _loadContent(content);
  }

  Future<void> _loadString(String content) async {
    const start = """
<html>
    <head>
        <meta charset="UTF-8" />
        <meta name="viewport" content="width=device-width" />
        <meta name="viewport" content="initial-scale=1.0" />
        <style type="text/css">
        :root {
            --bg-color: white; 
            --fg-color: black; 
        }
        * {            
            background-color: var(--bg-color);
            color: var(--fg-color);
        }
        body {
            margin: 0;
            font-family: '-apple-system';
            font-size: 10pt;
        }
        h1, h2, h3 {
            font-size: 14pt;
        }
        html {
            -webkit-text-size-adjust:none;
        }
        </style>
    </head>
    <body>    
        """;
    const end = """
    </body>
</html>
        """;

    content = start + content + end;
    content = await _processContent(content);
    await _loadContent(content);
  }

  @override
  PreferredSizeWidget? buildAppBar(BuildContext context) => VegaAppBar(title: widget.title);

  @override
  Widget buildBody(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: moleculeScreenPadding),
      child: IndexedStack(
        index: _contentLoaded ? 1 : 0,
        children: <Widget>[
          const CenteredWaitIndicator(),
          WebViewWidget(controller: _controller),
          /*
          WebView(
            javascriptMode: widget.allowJavascript ? JavascriptMode.unrestricted : JavascriptMode.disabled,
            onWebViewCreated: (webViewController) {
              if (widget.internalPage != null) {
                _loadHtmlFromAssets(webViewController);
              } else if (widget.externalPage != null) {
                webViewController.loadUrl(widget.externalPage!);
              } else if (widget.content != null) {
                _loadHtmlFromString(webViewController, widget.content!);
              }
            },
            onPageFinished: (_) async {
              Future.delayed(const Duration(milliseconds: 250), () {
                setState(() {
                  _contentLoaded = true;
                });
              });
            },
            navigationDelegate: (navigation) async {
              // target="_blank"
              if (!navigation.isForMainFrame) {
                final url = Uri.parse(navigation.url);
                if (await canLaunchUrl(url)) {
                  await launchUrl(url); //, forceSafariVC: false, forceWebView: false);
                } else {
                  warning("Could not launch $url");
                }
                return NavigationDecision.prevent;
              } else {
                // TODO: ActionHandler
                //final actionHandler = ActionHandler(navigation.url);
                //if (actionHandler.isKarty()) {
                //  actionHandler.exec(context, ref);
                //  return NavigationDecision.prevent;
                //}
              }
              return NavigationDecision.navigate;
            },
          ),
          */
        ],
      ),
    );
  }
}

// eof
