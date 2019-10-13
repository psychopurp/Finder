import 'dart:io';

import 'package:finder/config/api_client.dart';
import 'package:finder/provider/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:finder/public.dart';
import 'package:provider/provider.dart';

class PublishTopicCommentPage extends StatefulWidget {
  final int topicId;
  final String topicTitle;
  PublishTopicCommentPage({this.topicId, this.topicTitle});
  @override
  _PublishTopicCommentPageState createState() =>
      _PublishTopicCommentPageState();
}

class _PublishTopicCommentPageState extends State<PublishTopicCommentPage> {
  TextEditingController _contentController;
  FocusNode _contentFocusNode;
  List<Widget> wrapList = [];
  List<Asset> images = [];
  String error = "";

  @override
  void initState() {
    _contentFocusNode = FocusNode();
    _contentController = TextEditingController()
      ..addListener(() {
        print(_contentController.text);
      });
    wrapList.add(addImage());
    super.initState();
  }

  @override
  void dispose() {
    _contentFocusNode.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(widget.topicTitle + widget.topicId.toString()),
        elevation: 0,
        actions: <Widget>[
          FlatButton(
            color: Colors.yellow,
            highlightColor: Theme.of(context).primaryColor.withOpacity(0.1),
            onPressed: () async {
              showDialog(
                context: context,
                barrierDismissible: false, //点击遮罩不关闭对话框
                builder: (context) {
                  return AlertDialog(
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        CircularProgressIndicator(),
                        Padding(
                          padding: const EdgeInsets.only(top: 26.0),
                          child: Text("正在发布，请稍后..."),
                        )
                      ],
                    ),
                  );
                },
              );
              bool status = await publishTopicComment(user);
              // print(status);
              // Navigator.pop(context);
              // if (!status) {
              //   handleError();
              // } else {
              //   handleSuccess();
              // }
            },
            child: Text(
              '发布',
              style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontFamily: "Poppins",
                  fontSize: ScreenUtil().setSp(30)),
            ),
          )
        ],
      ),
      body: Container(
        // height: ScreenUtil().setHeight(800),
        // width: ScreenUtil().setWidth(750),
        // color: Colors.amber,
        child: ListView(
          children: <Widget>[
            Container(
              height: ScreenUtil().setHeight(500),
              // child: Html(
              child: Text(_contentController.text),
              // ),
            ),

            Container(
              width: ScreenUtil().setWidth(420),
              // color: Colors.amber,
              child: TextField(
                cursorColor: Theme.of(context).primaryColor,
                controller: _contentController,
                focusNode: _contentFocusNode,
                autofocus: true,
                decoration: InputDecoration(
                  // labelText: '活动名称',
                  filled: true,
                  hintText: '请输入活动名称',
                  fillColor: Colors.white,
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(12),
                ),
                // expands: true,
                minLines: 3,
                maxLines: null,
                maxLengthEnforced: true,
                maxLength: 1000,
              ),
            ),

            Container(
                padding: EdgeInsets.symmetric(horizontal: 12),
                // width: ScreenUtil().setWidth(420),
                // height: ScreenUtil().setHeight(500),
                color: Colors.cyan,
                child: Wrap(
                    spacing: 5,
                    runSpacing: 5,
                    children: this.images.map((image) {
                      return Container(
                        child: AssetThumb(
                          asset: image,
                          width: ScreenUtil().setWidth(200).toInt(),
                          height: ScreenUtil().setHeight(200).toInt(),
                        ),
                      );
                    }).toList()
                      ..add(addImage())))

            // MyApp(),
          ],
        ),
      ),
    );
  }

  Widget addImage() {
    ///从相册选择图片
    Future<void> loadAssets() async {
      List<Asset> resultList = List<Asset>();
      String error = 'No Error Dectected';
      try {
        resultList = await MultiImagePicker.pickImages(
          maxImages: 10,
          enableCamera: true,
          selectedAssets: images,
          cupertinoOptions: CupertinoOptions(takePhotoIcon: "chat"),
          materialOptions: MaterialOptions(
            selectionLimitReachedText: '请选择一张图片',
            textOnNothingSelected: '请至少选择一张图片',
            actionBarColor: "#000000",
            statusBarColor: '#999999',
            actionBarTitle: "相册",
            allViewTitle: "全部图片",
            useDetailsView: true,
            selectCircleStrokeColor: "#000000",
          ),
        );
      } on Exception catch (e) {
        error = e.toString();
      }
      if (!mounted) return;

      setState(() {
        images = resultList;
        error = error;
      });
    }

    return Container(
      child: InkWell(
        onTap: () {
          print('tapped');
          loadAssets();
        },
        child: Container(
          width: ScreenUtil().setWidth(200),
          height: ScreenUtil().setHeight(200),
          color: Colors.grey,
          child: Icon(Icons.add),
        ),
      ),
    );
  }

  Future<bool> publishTopicComment(UserProvider user) async {
    List<String> imageString = [];
    for (var image in this.images) {
      String path = await image.filePath;
      String imagePath = ApiClient.host + await user.uploadImage(File(path));
      imageString.add(imagePath);
    }

    String text = _contentController.text;

    ///如果啥内容没有
    if (imageString.length == 0 && (text == null || text == "")) {
      error = "请填写内容";
      return false;
    }
    String content = contentToJson(images: imageString, text: text);
    var data =
        await user.addTopicComment(topicId: widget.topicId, content: content);
    print(data);
    return true;
  }
}
