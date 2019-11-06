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
      hidden: true,
      initialChild:
          Container(height: double.infinity, child: FinderDialog.showLoading()),
    );
  }
}
