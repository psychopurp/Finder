import 'dart:io';

import 'package:finder/config/api_client.dart';
import 'package:finder/routers/application.dart';
import 'package:flutter/material.dart';
import 'package:finder/public.dart';
import 'package:finder/provider/user_provider.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:provider/provider.dart';
import 'package:image_cropper/image_cropper.dart';

class PublishTopicPage extends StatefulWidget {
  @override
  _PublishTopicPageState createState() => _PublishTopicPageState();
}

class _PublishTopicPageState extends State<PublishTopicPage> {
  File _imageFile;
  String errorHint = "";

  ///标签
  List<String> tags = [];
  List<Asset> images = [];

  bool onlyInSchool = false;

  TextEditingController _titleController;
  TextEditingController _tagController;

  @override
  void initState() {
    _titleController = TextEditingController();
    _tagController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context);

    //仅本校可见部分
    var onlySchool = Container(
      // margin: EdgeInsets.only(top: 20),
      child: ListTile(
        title: Text("仅本校可见"),
        trailing: Switch(
          activeTrackColor: Theme.of(context).primaryColor,
          activeColor: Colors.white,
          value: onlyInSchool,
          onChanged: (isSelect) {
            setState(() {
              this.onlyInSchool = isSelect;
            });
          },
        ),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.black),
        backgroundColor: Colors.white,
        title: Text(
          '创建话题',
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        actions: <Widget>[
          FlatButton(
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
              // bool status = true;
              bool status = await publishTopic(user);
              // await Future.delayed(Duration(seconds: 3), () {});
              // print(status);
              Navigator.pop(context);
              if (!status) {
                handleError();
              } else {
                handleSuccess();
              }
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
        // title: Text('Finders'),
        elevation: 0,
      ),
      body: ListView(
        padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(40)),
        children: <Widget>[uploadImage(), titleForm(), onlySchool, tag()],
      ),
    );
  }

  ///标签
  tag() {
    String _tag;
    return Container(
      // margin: EdgeInsets.symmetric(vertical: ScreenUtil().setHeight(50)),
      // color: Colors.amber,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(
                width: ScreenUtil().setWidth(500),
                margin:
                    EdgeInsets.symmetric(vertical: ScreenUtil().setHeight(20)),
                padding: EdgeInsets.only(top: ScreenUtil().setHeight(20)),
                // color: Colors.amber,
                child: TextField(
                  maxLines: 1,
                  // maxLength: 100,
                  minLines: 1,
                  cursorColor: Theme.of(context).primaryColor,
                  controller: _tagController,
                  decoration: InputDecoration(
                    labelText: '添加标签',
                    filled: true,
                    hintText: '请输入标签',
                    fillColor: Color.fromARGB(255, 245, 241, 241),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: EdgeInsets.all(12),
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Container(),
              ),
              IconButton(
                icon: Icon(
                  Icons.add,
                  size: 30,
                ),
                onPressed: () {
                  _tag = _tagController.text.toString();
                  setState(() {
                    if (_tag != null && _tag != "") {
                      tags.add(_tag.toString());
                      _tagController.clear();
                    }
                  });
                },
              ),
            ],
          ),
          Container(
            // color: Colors.yellow,
            height: ScreenUtil().setHeight(400),
            child: Wrap(
              spacing: 5,
              children: tags.map((val) {
                return Chip(
                  onDeleted: () {
                    setState(() {
                      tags.remove(val);
                    });
                  },
                  deleteButtonTooltipMessage: "删除此标签",
                  deleteIconColor: Colors.black38,
                  backgroundColor:
                      Theme.of(context).primaryColor.withOpacity(0.5),
                  labelStyle: TextStyle(color: Colors.white),
                  label: Text(val),
                );
              }).toList(),
            ),
          )
        ],
      ),
    );
  }

  //处理图片部分
  Widget uploadImage() {
    ///宽高比 1.6/1
    double picHeight = ScreenUtil().setHeight(400);
    double picWidth = picHeight * 1.6;
    /**
     * 进行上传图片并显示操作
     */
    Future getImage() async {
      var image;
      // var image = await ImagePicker.pickImage(source: ImageSource.gallery);
      String error = 'No Error Dectected';
      List<Asset> resultList = List<Asset>();
      try {
        resultList = await MultiImagePicker.pickImages(
          maxImages: 1,
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
      if (resultList.length != 0) {
        var t = await resultList[0].filePath;
        image = File(t);
      }

      var cropImage = await ImageCropper.cropImage(
          sourcePath: image.path,
          aspectRatio: CropAspectRatio(ratioX: 16, ratioY: 10),
          // aspectRatioPresets: [
          //   CropAspectRatioPreset.square,
          //   CropAspectRatioPreset.ratio3x2,
          //   CropAspectRatioPreset.original,
          //   CropAspectRatioPreset.ratio4x3,
          //   CropAspectRatioPreset.ratio16x9
          // ],
          androidUiSettings: AndroidUiSettings(
              showCropGrid: false,
              toolbarTitle: '图片剪切',
              toolbarColor: Theme.of(context).primaryColor,
              toolbarWidgetColor: Colors.white,
              initAspectRatio: CropAspectRatioPreset.original,
              lockAspectRatio: true),
          iosUiSettings: IOSUiSettings(
              minimumAspectRatio: 1.0, aspectRatioLockEnabled: true));
      return cropImage;
    }

    return Align(
      child: InkWell(
          onTap: () async {
            var image = await getImage();
            setState(() {
              this._imageFile = image;
            });
          },
          child: (this._imageFile != null)
              ? Container(
                  margin: EdgeInsets.only(top: ScreenUtil().setHeight(40)),
                  height: picHeight,
                  width: picWidth,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                        image: FileImage(this._imageFile), fit: BoxFit.cover),
                  ))
              : Container(
                  margin: EdgeInsets.only(top: ScreenUtil().setHeight(40)),
                  height: picHeight,
                  width: picWidth,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(
                        Icons.add,
                        color: Color(0xFFF0AA89),
                        size: ScreenUtil().setSp(100),
                      ),
                      Text(
                        '上传背景图',
                        style: TextStyle(
                            fontFamily: 'Poppins',
                            color: Color(0xFFF0AA89),
                            fontSize: ScreenUtil().setSp(40)),
                      )
                    ],
                  ),
                  decoration: BoxDecoration(
                      // color: Colors.amber,
                      border: Border.all(color: Color(0xFFF0AA89), width: 1)))),
    );
  }

  //处理标题部分
  Widget titleForm() {
    return Container(
      width: ScreenUtil().setWidth(420),
      padding: EdgeInsets.only(top: 20),
      // color: Colors.amber,
      child: TextField(
        maxLines: 1,
        maxLength: 30,
        minLines: 1,
        cursorColor: Theme.of(context).primaryColor,
        controller: _titleController,
        decoration: InputDecoration(
          labelText: '话题标题',
          filled: true,
          hintText: '请输入标题',
          fillColor: Color.fromARGB(255, 245, 241, 241),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          contentPadding: EdgeInsets.all(12),
        ),
      ),
    );
  }

  void handleSuccess() {
    Navigator.pop(context);
    BotToast.showText(
        text: '创建话题成功',
        duration: Duration(milliseconds: 2000),
        align: Alignment(0, 0.3),
        textStyle:
            TextStyle(fontFamily: 'normal', color: Colors.white, fontSize: 17));

    Application.router.navigateTo(context, Routes.moreTopics);
  }

  void handleError() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("提示"),
            content: Text(errorHint),
            actions: <Widget>[
              FlatButton(
                child: Text("确认"),
                onPressed: () => Navigator.of(context).pop(), //关闭对话框
              ),
            ],
          );
        });
  }

  Future publishTopic(UserProvider user) async {
    if (this._imageFile == null) {
      errorHint = "请上传图片";
      return false;
    }
    String title = _titleController.text;
    if (title == "" || title == null) {
      errorHint = "请输入标题";
      return false;
    }
    String imagePath = await apiClient.uploadImage(this._imageFile);
    if (imagePath == null) {
      errorHint = "图片上传失败, 请重试";
      return false;
    }
    if (this.onlyInSchool && user.userInfo.school == null) {
      if (imagePath == null) {
        errorHint = "家里蹲大学不能发布校内话题哟~ \n请尝试考个大学吧! ";
        return false;
      }
    }
    var data = await user.addTopic(title, this.tags, imagePath,
        schoolId: this.onlyInSchool ? user.userInfo.school.id : null);
    print(data);
    if (!data["status"]) {
      errorHint = '当前话题已存在！';
      return false;
    } else {
      return true;
    }
  }
}
