import 'dart:io';

import 'package:finder/config/api_client.dart';
import 'package:finder/models/activity_model.dart';
import 'package:finder/provider/user_provider.dart';
import 'package:finder/public.dart';
import 'package:finder/routers/application.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:finder/plugin/better_text.dart';

class PublishActivityPage extends StatefulWidget {
  @override
  _PublishActivityPageState createState() => _PublishActivityPageState();
}

class _PublishActivityPageState extends State<PublishActivityPage> {
  String errorHint = "";
  String startTime;
  String endTime;
  DateTime startDateTime;
  DateTime endDateTime;

  FocusNode titleNode;
  FocusNode sponsorNode;
  FocusNode placeNode;
  FocusNode descriptionNode;
  FocusNode tagNode;

  static const Color inputColor = Color.fromARGB(255, 245, 241, 241);

  ///标签
  List<String> tags = [];

  File _imageFile;

  bool onlyInSchool = false;

  TextEditingController _titleInputController;
  TextEditingController _placeInputController;
  TextEditingController _descriptionInputController;
  TextEditingController _linkInputController;
  TextEditingController _sponsorInputController;

  TextEditingController _tagInputController;

  @override
  void initState() {
    getActivityType();
    _descriptionInputController = TextEditingController();
    _placeInputController = TextEditingController();
    _linkInputController = TextEditingController();
    _sponsorInputController = TextEditingController();
    _tagInputController = new TextEditingController();
    _titleInputController = new TextEditingController();

    descriptionNode = FocusNode();
    placeNode = FocusNode();
    titleNode = FocusNode();
    sponsorNode = FocusNode();
    tagNode = FocusNode();

    DateTime time = new DateTime.now();
    startDateTime = time;
    startTime = time.year.toString() +
        '—' +
        time.month.toString() +
        '—' +
        time.day.toString() +
        '▼';
    endTime = "请选择活动结束时间";
    super.initState();
  }

  ///下拉选择活动类型
  int selectedActivityTypeValue;

  List<ActivityTypesModelData> activityTypes = [];

  @override
  void dispose() {
    _tagInputController.dispose();
    _placeInputController.dispose();
    _descriptionInputController.dispose();
    _linkInputController.dispose();
    _sponsorInputController.dispose();
    _titleInputController.dispose();
    descriptionNode.dispose();
    placeNode.dispose();
    titleNode.dispose();
    sponsorNode.dispose();
    tagNode.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context);
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.black),
        backgroundColor: Colors.white,
        title: BetterText(
          '创建活动',
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        actions: <Widget>[
          FlatButton(
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
                          child: BetterText("正在发布，请稍后..."),
                        )
                      ],
                    ),
                  );
                },
              );
              // bool status = true;
              bool status = await publishActivity(user);
              // await Future.delayed(Duration(seconds: 3), () {});

              Navigator.pop(context);
              if (!status) {
                handleError();
              } else {
                handleSuccess();
              }
            },
            child: BetterText(
              '发布',
              style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontSize: ScreenUtil().setSp(30)),
            ),
          ),
        ],
        // title: BetterText('Finders'),
        elevation: 0,
      ),
      body: ListView(
        padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(40)),
        children: <Widget>[topPart(), bottomPart(), tag()],
      ),
    );
  }

  topPart() => Container(
        // height: ScreenUtil().setHeight(600),
        width: ScreenUtil().setWidth(220),
        margin: EdgeInsets.only(bottom: ScreenUtil().setHeight(20)),
        // color: Colors.amber,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            uploadImage(),
            Container(
              // color: Colors.amber,
              padding: EdgeInsets.only(left: ScreenUtil().setWidth(30)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  ///活动名称
                  Container(
                    width: ScreenUtil().setWidth(420),
                    padding: EdgeInsets.only(top: ScreenUtil().setHeight(20)),
                    // color: Colors.amber,
                    child: TextField(
                      maxLines: 1,
                      // maxLength: 20,
                      minLines: 1,
                      focusNode: titleNode,
                      onEditingComplete: () {
                        FocusScope.of(context).requestFocus(sponsorNode);
                      },
                      cursorColor: Theme.of(context).primaryColor,
                      controller: _titleInputController,
                      decoration: InputDecoration(
                        labelText: '活动名称',
                        filled: true,
                        hintText: '请输入活动名称',
                        fillColor: Color.fromARGB(255, 245, 241, 241),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: EdgeInsets.all(12),
                      ),
                    ),
                  ),

                  ///主办方
                  Container(
                    width: ScreenUtil().setWidth(420),
                    padding: EdgeInsets.only(top: 20),
                    // color: Colors.amber,
                    child: TextField(
                      maxLines: 1,
                      // maxLength: 30,
                      minLines: 1,
                      focusNode: sponsorNode,
                      cursorColor: Theme.of(context).primaryColor,
                      controller: _sponsorInputController,
                      decoration: InputDecoration(
                        labelText: '主办方',
                        filled: true,
                        hintText: '请输入主办方',
                        fillColor: Color.fromARGB(255, 245, 241, 241),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: EdgeInsets.all(12),
                      ),
                    ),
                  ),

                  ///选择活动类型
                  Container(
                      height: ScreenUtil().setHeight(70),
                      width: ScreenUtil().setWidth(420),
                      margin: EdgeInsets.only(top: 20),
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                          color: Color.fromARGB(255, 245, 241, 241),
                          borderRadius: BorderRadius.circular(20)),
                      child: DropdownButton(
                        hint: BetterText('请选择活动类型'),
                        items: activityTypes.map((item) {
                          return DropdownMenuItem(
                            value: item.id,
                            child: BetterText(item.name),
                          );
                        }).toList(),
                        value: this.selectedActivityTypeValue,
                        isExpanded: true,
                        underline: BetterText(''),
                        onChanged: (t) {
                          setState(() {
                            this.selectedActivityTypeValue = t;
                          });
                        },
                      )),
                ],
              ),
            ),
          ],
        ),
      );

  bottomPart() => Container(
          // height: ScreenUtil().setHeight(400),
          // color: Colors.cyan,
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          ///选择活动时间
          Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                BetterText(
                  "活动时间",
                  style: TextStyle(fontSize: ScreenUtil().setSp(30)),
                ),
                Container(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                        color: inputColor,
                        borderRadius: BorderRadius.circular(15)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        InkWell(
                          onTap: () {
                            showDatePicker(
                                    locale: Locale('zh'),
                                    context: context,
                                    initialDate: new DateTime.now(),
                                    firstDate: new DateTime.now().subtract(
                                        new Duration(days: 10)), // 减 30 天
                                    lastDate: new DateTime.now()
                                        .add(new Duration(days: 80)))
                                .then((time) {
                              setState(() {
                                startDateTime = time;
                                startTime = time.year.toString() +
                                    '—' +
                                    time.month.toString() +
                                    '—' +
                                    time.day.toString() +
                                    '▼';
                              });
                            });
                          },
                          child: Container(
                            padding: EdgeInsets.all(5),
                            child: BetterText(startTime),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            showDatePicker(
                                    locale: Locale('zh'),
                                    context: context,
                                    initialDate: new DateTime.now(),
                                    firstDate: new DateTime.now().subtract(
                                        new Duration(days: 10)), // 减 30 天
                                    lastDate: new DateTime.now()
                                        .add(new Duration(days: 180)))
                                .then((time) {
                              setState(() {
                                endDateTime = time;
                                endTime = time.year.toString() +
                                    '—' +
                                    time.month.toString() +
                                    '—' +
                                    time.day.toString() +
                                    '▼';
                              });
                            });
                          },
                          child: Container(
                            padding: EdgeInsets.all(5),
                            child: BetterText(endTime),
                          ),
                        ),
                      ],
                    )),
              ],
            ),
          ),

          ///活动地点
          Container(
            // width: ScreenUtil().setWidth(420),
            margin: EdgeInsets.symmetric(vertical: ScreenUtil().setHeight(20)),
            padding: EdgeInsets.only(top: ScreenUtil().setHeight(20)),
            // color: Colors.amber,
            child: TextField(
              maxLines: 3,
              maxLength: 100,
              minLines: 1,
              focusNode: placeNode,
              onEditingComplete: () {
                FocusScope.of(context).requestFocus(descriptionNode);
              },
              cursorColor: Theme.of(context).primaryColor,
              controller: _placeInputController,
              decoration: InputDecoration(
                labelText: '活动地点',
                filled: true,
                hintText: '请输入活动地点',
                fillColor: Color.fromARGB(255, 245, 241, 241),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.all(12),
              ),
            ),
          ),

          ///活动详情
          Container(
            height: ScreenUtil().setHeight(400),
            width: ScreenUtil().setWidth(670),
            child: TextField(
              decoration: InputDecoration(
                // border: UnderlineInputBorder(),
                fillColor: inputColor,
                filled: true,
                hintText: '请输入活动详情',
                border: InputBorder.none,
              ),
              focusNode: descriptionNode,
              onEditingComplete: () {
                FocusScope.of(context).requestFocus(tagNode);
              },
              expands: true,
              maxLines: null,
              maxLengthEnforced: true,
              maxLength: 1000,
              autofocus: false,
              cursorColor: Theme.of(context).primaryColor,
              controller: _descriptionInputController,
            ),
          ),

          ///报名链接
          Container(
              margin:
                  EdgeInsets.symmetric(vertical: ScreenUtil().setHeight(20)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  RichText(
                    text: TextSpan(
                      text: '报名链接 ',
                      style: TextStyle(color: Colors.black),
                      children: <TextSpan>[
                        TextSpan(
                            text: '选填 ',
                            style: TextStyle(
                                color: Theme.of(context).primaryColor)),
                      ],
                    ),
                  ),
                  Container(
                    // width: ScreenUtil().setWidth(420),
                    margin: EdgeInsets.symmetric(
                        vertical: ScreenUtil().setHeight(20)),
                    // color: Colors.amber,
                    child: TextField(
                      maxLines: 1,
                      maxLength: 100,
                      minLines: 1,
                      cursorColor: Theme.of(context).primaryColor,
                      controller: _linkInputController,
                      decoration: InputDecoration(
                        // labelText: '报名链接',
                        filled: true,
                        hintText: '请输入报名链接',
                        fillColor: Color.fromARGB(255, 245, 241, 241),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: EdgeInsets.all(12),
                      ),
                    ),
                  ),
                ],
              )),
        ],
      ));

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
                  controller: _tagInputController,
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
              IconButton(
                icon: Icon(Icons.add),
                onPressed: () {
                  _tag = _tagInputController.text.toString();
                  setState(() {
                    if (_tag != null) {
                      tags.add(_tag.toString());
                      _tagInputController.clear();
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
                  label: BetterText(val),
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
    /**
     * 进行上传图片并显示操作
     */
    double picWidth = ScreenUtil().setWidth(220);
    double picHeight = picWidth * 1.4;

    Future getImage() async {
      var image = await ImagePicker.pickImage(source: ImageSource.gallery);
      var cropImage = await ImageCropper.cropImage(
          aspectRatio: CropAspectRatio(ratioX: 3, ratioY: 4),
          sourcePath: image.path,
          // aspectRatioPresets: [
          // CropAspectRatioPreset.square,
          // CropAspectRatioPreset.ratio3x2,
          // CropAspectRatioPreset.original,
          //   CropAspectRatioPreset.ratio4x3,
          // CropAspectRatioPreset.ratio16x9
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
      child: Container(
        // color: Colors.amber,
        padding: EdgeInsets.only(top: ScreenUtil().setHeight(40)),
        child: InkWell(
          onTap: () async {
            var image = await getImage();
            setState(() {
              this._imageFile = image;
            });
          },
          child: (this._imageFile != null)
              ? Container(
                  // margin: EdgeInsets.only(top: ScreenUtil().setHeight(40)),
                  height: picHeight,
                  width: picWidth,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(3),
                    image: DecorationImage(
                        image: FileImage(this._imageFile), fit: BoxFit.fill),
                  ))
              : Container(
                  // margin: EdgeInsets.only(top: ScreenUtil().setHeight(40)),
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
                      BetterText(
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
                      borderRadius: BorderRadius.circular(3),
                      border: Border.all(color: Color(0xFFF0AA89), width: 1))),
        ),
      ),
    );
  }

  void handleSuccess() {
    Navigator.pop(context);
    BotToast.showText(
        text: '创建活动成功',
        duration: Duration(milliseconds: 2000),
        align: Alignment(0, 0.3),
        textStyle:
            TextStyle(fontFamily: 'normal', color: Colors.white, fontSize: 17));
    Application.router.navigateTo(context, Routes.moreActivities);
  }

  void handleError() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: BetterText("提示"),
            content: BetterText(errorHint),
            actions: <Widget>[
              FlatButton(
                child: BetterText("确认"),
                onPressed: () => Navigator.of(context).pop(), //关闭对话框
              ),
            ],
          );
        });
  }

  Future<bool> publishActivity(UserProvider user) async {
    if (this._imageFile == null) {
      errorHint = "请上传图片";
      return false;
    }
    String title = _titleInputController.text;
    if (title == "" || title == null) {
      errorHint = "请输入标题";
      return false;
    }
    String sponsor = _sponsorInputController.text;
    if (sponsor == null || sponsor == "") {
      errorHint = "请输入主办方";
      return false;
    }
    String imagePath = await apiClient.uploadImage(this._imageFile);
    if (imagePath == null) {
      errorHint = "图片上传失败, 请重试";
      return false;
    }

    String place = _placeInputController.text;
    if (place == null || place == "") {
      errorHint = "请输入活动地点";
      return false;
    }

    String signUpLocation = _linkInputController.text;

    String description = _descriptionInputController.text;
    if (description == null || description == "") {
      errorHint = "请输入活动详情";
      return false;
    }
    ActivityModelData activity = ActivityModelData(
        title: title,
        place: place,
        poster: imagePath,
        description: description,
        typeId: [this.selectedActivityTypeValue],
        startTime: this.startDateTime,
        endTime: this.endDateTime,
        tagsString: this.tags,
        sponsor: sponsor,
        signUpLocation: signUpLocation);

    var data = await apiClient.addActivity(activity: activity);

    if (!data["status"]) {
      errorHint = '接口错误：' + data["error"];
      return false;
    } else {
      return true;
    }
  }

  Future getActivityType() async {
    try {
      var response = await ApiClient.dio.get('get_activity_types/');
      ActivityTypesModel activityTypes =
          ActivityTypesModel.fromJson(response.data);
      setState(() {
        this.activityTypes = activityTypes.data;
      });
    } catch (e) {
      print('获取错误==========>$e');
    }
  }
}
