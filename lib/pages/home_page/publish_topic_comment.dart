import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:finder/public.dart';

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
  String error = "";

  @override
  void initState() {
    _contentFocusNode = FocusNode();
    _contentController = TextEditingController();
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
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        // title: Text(widget.topicTitle),
        elevation: 0,
      ),
      body: Container(
        // height: ScreenUtil().setHeight(800),
        // width: ScreenUtil().setWidth(750),
        color: Colors.amber,
        child: ListView(
          children: <Widget>[
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
      List<File> files = [];
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

        resultList.forEach((image) async {
          String path = await image.filePath;
          files.add(File(path));
        });
      } on Exception catch (e) {
        error = e.toString();
      }
      if (!mounted) return;

      setState(() {
        images = resultList;
        this.imageFiles = files;
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
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List<Asset> images = List<Asset>();
  String _error = 'No Error Dectected';

  @override
  void initState() {
    super.initState();
  }

  Widget buildGridView() {
    return GridView.count(
      crossAxisCount: 3,
      children: List.generate(images.length, (index) {
        Asset asset = images[index];
        return AssetThumb(
          asset: asset,
          width: 300,
          height: 300,
        );
      }),
    );
  }

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
      for (var r in resultList) {
        var t = await r.filePath;
        print(t);
      }
    } on Exception catch (e) {
      error = e.toString();
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      images = resultList;
      _error = error;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Center(child: Text('Error: $_error')),
        RaisedButton(
          child: Text("Pick images"),
          onPressed: loadAssets,
        ),
        Expanded(
          child: buildGridView(),
        )
      ],
    );
  }
}
