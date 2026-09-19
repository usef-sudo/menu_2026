import "package:flutter/material.dart";
import "package:webview_flutter/webview_flutter.dart";

class InAppWebViewPage extends StatefulWidget {
  const InAppWebViewPage({
    required this.title,
    required this.uri,
    super.key,
  });

  final String title;
  final Uri uri;

  @override
  State<InAppWebViewPage> createState() => _InAppWebViewPageState();
}

class _InAppWebViewPageState extends State<InAppWebViewPage> {
  late final WebViewController _controller;
  int _progress = 0;
  bool _canGoBack = false;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            if (mounted) {
              setState(() => _progress = progress);
            }
          },
          onPageFinished: (_) => _refreshCanGoBack(),
          onNavigationRequest: (NavigationRequest request) {
            final Uri? uri = Uri.tryParse(request.url);
            if (uri == null) {
              return NavigationDecision.prevent;
            }
            if (uri.scheme == "http" ||
                uri.scheme == "https" ||
                uri.scheme == "about" ||
                uri.scheme == "data" ||
                uri.scheme == "blob") {
              return NavigationDecision.navigate;
            }
            return NavigationDecision.prevent;
          },
        ),
      )
      ..loadRequest(widget.uri);
  }

  Future<void> _refreshCanGoBack() async {
    final bool canGoBack = await _controller.canGoBack();
    if (mounted) {
      setState(() => _canGoBack = canGoBack);
    }
  }

  Future<void> _handleBack() async {
    if (await _controller.canGoBack()) {
      await _controller.goBack();
      return;
    }
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_canGoBack,
      onPopInvokedWithResult: (bool didPop, Object? result) async {
        if (didPop) {
          return;
        }
        await _handleBack();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          leading: IconButton(
            icon: const Icon(Icons.close_rounded),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: Column(
          children: <Widget>[
            if (_progress < 100)
              LinearProgressIndicator(
                value: _progress == 0 ? null : _progress / 100,
                minHeight: 2,
              ),
            Expanded(
              child: WebViewWidget(controller: _controller),
            ),
          ],
        ),
      ),
    );
  }
}
