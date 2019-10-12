import 'package:finder/public.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

class WebViewExample extends StatefulWidget {
  @override
  _WebViewExampleState createState() => _WebViewExampleState();
}

class _WebViewExampleState extends State<WebViewExample> {
  ///测试部分
  List<String> images = [
    'https://wx2.sinaimg.cn/orj360/6148b630ly1g7vc3s8rl7j20c808fdha.jpg',
    'https://wx2.sinaimg.cn/orj360/6148b630ly1g7vc3s7n8fj20u00kpdj7.jpg',
    'https://wx2.sinaimg.cn/orj360/6148b630ly1g7vc3s8rl7j20c808fdha.jpg',
    'https://wx2.sinaimg.cn/orj360/6148b630ly1g7vc3s7n8fj20u00kpdj7.jpg',
    'https://wx2.sinaimg.cn/orj360/6148b630ly1g7vc3s8rl7j20c808fdha.jpg',
    'https://wx2.sinaimg.cn/orj360/6148b630ly1g7vc3s7n8fj20u00kpdj7.jpg',
  ];
  String content = '''
【学术研究显示：#移动支付让人们花钱更多#， 用途更多元[话筒]】最新发布的一项学术研究表明：#移动支付能降低恩格尔系数#，促进居民消费，还推动消费结构升级。尤其对农村地区消费的影响更大。移动支付有助于释放低收入家庭消费潜力，促进中等收入家庭消费结构优化升级。
  ''';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Container(
        color: Colors.black12,
        height: ScreenUtil().setHeight(400),
        child: SingleChildScrollView(
          child: Html(
            data: getContent(),
            onLinkTap: (url) {
              print(url);
            },
            onImageTap: (url) {
              print(url);
            },
          ),
        ),
      ),
    );
  }

  String getContent() {
    String content = '''
<head>
    <style type="text/css">
         li {
            float: left;
            /* 往左浮动 */
        }
    </style>
</head>

<body>
    <div>
        <ul>
            <li>
                <img src="http://static.runoob.com/images/demo/demo1.jpg" alt="图片文本描述" width="100" height="100">
            </li>
            <li>
                <img src="http://static.runoob.com/images/demo/demo2.jpg" alt="图片文本描述" width="100" height="100">
            </li>
        </ul>
    </div>
</body>
    ''';

    return content;
  }
}
