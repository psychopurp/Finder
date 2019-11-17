import 'package:finder/public.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:url_launcher/url_launcher.dart';

const Color ActionColor = Color(0xFFDB6B5C);

class WebViewPage extends StatefulWidget {
  final String url;
  final String title;

  WebViewPage({@required this.url, this.title});

  @override
  _WebViewPageState createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  FlutterWebviewPlugin webController;
  Map<String, Map<String, dynamic>> menuItem;
  String nowUrl;
  bool error = false;

  @override
  void initState() {
    super.initState();
    nowUrl = widget.url;
    webController = FlutterWebviewPlugin();
    webController.onHttpError.listen((detail) async {
      String url = detail.url;
      if (!url.startsWith("http")) {
        if (await canLaunch(url)) {
          launch(url);
        }
        webController.goBack();
        return;
      }
//      if (url == nowUrl || !url.startsWith("http")) {
//        setState(() {
//          error = true;
//        });
//      }
    });
    webController.onUrlChanged.listen((url) async {
      nowUrl = url;
    });
    menuItem = {
      "浏览器打开": {"handle": _handleExplore, "icon": Icons.explore},
    };
  }

  _handleExplore() async {
    if (await canLaunch(nowUrl)) {
      launch(nowUrl);
    }
  }

  @override
  void dispose() {
    super.dispose();
    webController.dispose();
  }

  @override
  Widget build(BuildContext context) {
//    print('=================url====>${widget.url}');
    AppBar appBar = AppBar(
      actions: <Widget>[
        Padding(
          padding: EdgeInsets.only(right: 20),
          child: PopupMenuButton(
            padding: EdgeInsets.symmetric(horizontal: 18),
            color: Colors.white,
            itemBuilder: (context) {
              List<PopupMenuItem<String>> list = [];
              menuItem.forEach(
                (key, value) {
                  list.add(
                    PopupMenuItem<String>(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(menuItem[key]["icon"]),
                          Expanded(
                            flex: 1,
                            child: Text(
                              key,
                              textAlign: TextAlign.right,
                            ),
                          ),
                        ],
                      ),
                      value: key,
                    ),
                  );
                },
              );
              return list;
            },
            onSelected: (key) {
              menuItem[key]["handle"]();
            },
            child: Icon(
              Icons.more_horiz,
              color: Colors.white,
              size: 30,
            ),
          ),
        )
      ],
    );
    return !error
        ? WebviewScaffold(
            url: widget.url,
            appBar: appBar,
            withZoom: true,
            withJavascript: true,
            withLocalStorage: true,
            debuggingEnabled: false,
            userAgent:
                "Mozilla/5.0 (iPhone; CPU iPhone OS 12_1 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) CriOS/72.0.3626.101 Mobile/15E148 Safari/605.1",
            initialChild: Container(
                height: double.infinity, child: FinderDialog.showLoading()),
          )
        : Scaffold(
            appBar: appBar,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text("网页加载失败, 请尝试使用系统浏览器打开. "),
                  Padding(padding: EdgeInsets.all(30),),
                  FlatButton(
                    child: Text("使用浏览器打开"),
                    color: Theme.of(context).primaryColor,
                    highlightColor: Theme.of(context).primaryColor.withOpacity(0.7),
                    colorBrightness: Brightness.dark,
                    splashColor: Theme.of(context).primaryColor.withOpacity(0.9),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0)),
                    onPressed: () {
                      _handleExplore();
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
          );
  }
}
