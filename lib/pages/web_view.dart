import 'package:finder/public.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';

class WebViewPage extends StatelessWidget {
  final String url;
  final String title;
  WebViewPage({@required this.url, this.title});
  @override
  Widget build(BuildContext context) {
    print('=================url====>$url');
    return WebviewScaffold(
      url: url,
      appBar: AppBar(),
      withZoom: true,
      withJavascript: true,
      withLocalStorage: true,
      userAgent: "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/77.0.3865.120 Safari/537.36",
      initialChild:
          Container(height: double.infinity, child: FinderDialog.showLoading()),
    );
  }
}
