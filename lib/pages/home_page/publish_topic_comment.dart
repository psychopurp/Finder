import 'dart:io';

import 'package:finder/config/api_client.dart';
import 'package:finder/provider/user_provider.dart';
import 'package:flutter/material.dart';
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
  List<File> imageFiles = [];
  int currentIndex;
  String error = "";
  static const double imageWidth = 220;

  @override
  void initState() {
    _contentFocusNode = FocusNode();
    _contentController = TextEditingController();
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
        title: Text(widget.topicTitle),
        elevation: 0,
        actions: <Widget>[
          Builder(builder: (context) {
            return FlatButton(
              // color: Colors.yellow,
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
                // await Future.delayed(Duration(seconds: 3), () {});
                // print(status);
                Navigator.pop(context);
                if (!status) {
                  // handleError();
                } else {
                  handleSuccess();
                }
              },
              child: Text(
                '发布',
                style: TextStyle(
                    color: Colors.white,
                    fontFamily: "normal",
                    fontSize: ScreenUtil().setSp(30)),
              ),
            );
          })
        ],
      ),
      body: Container(
        // height: ScreenUtil().setHeight(800),
        // width: ScreenUtil().setWidth(750),
        // color: Theme.of(context).dividerColor,
        child: Column(
          children: <Widget>[
            ///content
            Container(
              width: ScreenUtil().setWidth(750),
              color: Colors.white,
              child: TextField(
                style: TextStyle(fontFamily: 'normal', fontSize: 18),
                cursorColor: Theme.of(context).primaryColor,
                controller: _contentController,
                focusNode: _contentFocusNode,
                autofocus: true,
                decoration: InputDecoration(
                  // labelText: '活动名称',
                  filled: true,
                  hintText: '你的想法是 ?',
                  fillColor: Colors.white,
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(12),
                ),
                // expands: true,
                minLines: 3,
                maxLines: 8,
                maxLengthEnforced: true,
                maxLength: 1000,
              ),
            ),

            ///图片添加框
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                    padding: EdgeInsets.only(
                        top: 10, bottom: 20, left: ScreenUtil().setWidth(25)),
                    width: ScreenUtil().setWidth(750),
                    // height: ScreenUtil().setHeight(500),
                    color: Colors.white,
                    child: Wrap(
                        spacing: 10,
                        runSpacing: 5,
                        children: this.imageFiles.asMap().keys.map((index) {
                          return Container(
                            child: InkWell(
                                onTap: () {
                                  Future<void> loadAssets() async {
                                    String error = 'No Error Dectected';
                                    List<Asset> resultList;
                                    try {
                                      resultList =
                                          await MultiImagePicker.pickImages(
                                        maxImages: 9,
                                        enableCamera: false,
                                        selectedAssets: images,
                                        cupertinoOptions: CupertinoOptions(
                                            takePhotoIcon: "chat"),
                                        materialOptions: MaterialOptions(
                                          selectionLimitReachedText: '请选择一张图片',
                                          textOnNothingSelected: '请至少选择一张图片',
                                          actionBarColor: "#000000",
                                          statusBarColor: '#999999',
                                          actionBarTitle: "相册",
                                          allViewTitle: "全部图片",
                                          useDetailsView: true,
                                          startInAllView: true,
                                          lightStatusBar: true,
                                          selectCircleStrokeColor: "#000000",
                                        ),
                                      );
                                    } on Exception catch (e) {
                                      error = e.toString();
                                    }
                                    if (!mounted) return;
                                    // if (images.length != resultList.length)
                                    //   return;

                                    print(images);
                                    print(resultList);
                                    List<File> files = [];

                                    for (var r in resultList) {
                                      var t = await r.filePath;
                                      files.add(File(t));
                                    }

                                    setState(() {
                                      this.imageFiles = files;
                                      images = resultList;
                                      error = error;
                                    });
                                  }

                                  loadAssets();
                                },
                                child: Container(
                                  height: ScreenUtil().setWidth(imageWidth),
                                  width: ScreenUtil().setWidth(imageWidth),
                                  decoration: BoxDecoration(
                                      image: DecorationImage(
                                          image:
                                              FileImage(this.imageFiles[index]),
                                          fit: BoxFit.cover)),
                                )),
                          );
                        }).toList()
                          ..add(addImage()))),
              ),
            ),

            ///菜单栏
            //   Container(
            //     height: ScreenUtil().setHeight(100),
            //     width: ScreenUtil().setWidth(750),
            //     color: Colors.amber,
            //     child: Text('toolbar'),
            //   )
          ],
        ),
      ),
    );
  }

  Widget addImage() {
    ///从相册选择图片
    Future<void> loadAssets() async {
      String error = 'No Error Dectected';
      List<Asset> resultList = List<Asset>();
      try {
        resultList = await MultiImagePicker.pickImages(
          maxImages: 9,
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
      print(images);
      List<File> files = [];
      for (var r in resultList) {
        var t = await r.filePath;
        files.add(File(t));
      }

      setState(() {
        this.imageFiles = files;
        images = resultList;
        error = error;
      });
    }

    return Container(
      child: MaterialButton(
        onPressed: () {
          loadAssets();
        },
        minWidth: ScreenUtil().setWidth(imageWidth),
        height: ScreenUtil().setWidth(imageWidth),
        shape: RoundedRectangleBorder(side: BorderSide(color: Colors.white)),
        elevation: 0,
        highlightElevation: 0,
        color: Theme.of(context).dividerColor,
        child: Icon(Icons.add),
      ),
    );
  }

  void handleSuccess() {
    Navigator.pop(context);
    BotToast.showText(
        text: '参与话题成功',
        duration: Duration(milliseconds: 2000),
        align: Alignment(0, 0.3),
        textStyle:
            TextStyle(fontFamily: 'normal', color: Colors.white, fontSize: 17));
  }

  Future<bool> publishTopicComment(UserProvider user) async {
    List<String> imageString = [];
    for (var image in this.images) {
      String path = await image.filePath;
      String imagePath = await apiClient.uploadImage(File(path));
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
