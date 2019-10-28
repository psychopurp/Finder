import 'dart:io';

import 'package:bot_toast/bot_toast.dart';
import 'package:finder/config/api_client.dart';
import 'package:finder/models/user_model.dart';
import 'package:finder/plugin/avatar.dart';
import 'package:finder/provider/user_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:provider/provider.dart';

class ChangeProfilePage extends StatefulWidget {
  final UserModel user;
  ChangeProfilePage({this.user});
  @override
  _ChangeProfilePageState createState() => _ChangeProfilePageState();
}

class _ChangeProfilePageState extends State<ChangeProfilePage> {
  Map listItem;
  TextEditingController _controller;

  @override
  void initState() {
    _controller = TextEditingController();

    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    apiClient.upLoadUserProfile(widget.user);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    listItem = {
      'avatar': {
        'name': '头像',
        'data': widget.user.avatar,
        'handler': imageUpdate
      },
      'introduction': {
        'name': '简介',
        'data': widget.user.introduction,
        'handler': handleIntroduction
      },
      'nickName': {
        'name': '昵称',
        'data': widget.user.nickname,
        'handler': handleIntroduction
      },
      'realName': {
        'name': '真实姓名',
        'data': widget.user.realName,
        'handler': handleIntroduction
      },
      'school': {
        'name': '学校',
        'data': widget.user.school.name,
        'handler': handleIntroduction
      },
      'major': {
        'name': '专业',
        'data': widget.user.major,
        'handler': handleIntroduction
      },
      'phone': {
        'name': '手机号',
        'data': widget.user.phone,
        'handler': handleIntroduction
      },
      'birthday': {
        'name': '生日',
        'data': widget.user.birthday,
        'handler': handleBirthDay
      },
    };

    return Scaffold(
      appBar: AppBar(
        title: Text('个人信息'),
      ),
      body: body(userProvider),
    );
  }

  Widget body(UserProvider userProvider) {
    List<Widget> widgets = [];
    listItem.keys.forEach((item) {
      widgets.add(builListTile(listItem[item], userProvider));
    });
    widgets = ListTile.divideTiles(context: context, tiles: widgets).toList();

    return ListView(
      children: widgets,
    );
  }

  builListTile(Map item, UserProvider userProvider) {
    Widget child;

    if (item['data'] == null) {
      child = Text('');
    } else if (item['data'].toString().startsWith('http')) {
      child = Card(
        // color: Colors.yellow,
        shape: CircleBorder(),
        margin: EdgeInsets.all(0),
        elevation: 4,
        child: Avatar(
          url: item['data'],
          avatarHeight: 40,
        ),
      );
    } else if (item['data'] is DateTime) {
      child = Text(item['data'].toString().split(' ').first);
    } else {
      child = Text(item['data'].toString());
    }

    return ListTile(
      title: Text(item['name']),
      trailing: child,
      onTap: () {
        _controller.text = item['data'].toString();
        if (item['name'] == '头像') {
          item['handler'](userProvider);
        } else if (item['name'] == '生日') {
          item['handler']();
        } else {
          item['handler'](item['name']);
        }
      },
    );
  }

  handleIntroduction(String title) {
    int maxLength;
    String showText = "";
    bool validate = false;
    bool enable = true;
    bool autufocus = true;
    switch (title) {
      case '简介':
        maxLength = 30;
        break;
      case '昵称':
        maxLength = 15;
        showText = "昵称不能为空";
        validate = true;
        break;
      case '手机号':
        enable = false;
        autufocus = false;
        break;
      default:
    }

    Navigator.push(
        context,
        CupertinoPageRoute(
            title: title,
            builder: (_) {
              return Scaffold(
                appBar: AppBar(
                  title: Text(title),
                  actions: <Widget>[
                    Center(
                      child: Padding(
                        padding:
                            EdgeInsets.only(top: 15, bottom: 15, right: 10),
                        child: MaterialButton(
                          onPressed: () {
                            String text = _controller.text;
                            switch (title) {
                              case '简介':
                                widget.user.introduction = text;
                                break;
                              case '昵称':
                                widget.user.nickname = text;
                                break;
                              case '手机号':
                                widget.user.phone = text;
                                break;
                              case '专业':
                                widget.user.major = text;
                                break;
                              case '真实姓名':
                                widget.user.realName = text;
                                break;
                              default:
                            }
                            Navigator.pop(context);
                          },
                          shape: StadiumBorder(),
                          color: Colors.white,
                          child: Text('保存'),
                          minWidth: 30,
                        ),
                      ),
                    )
                  ],
                ),
                body: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: TextFormField(
                    enabled: enable,
                    validator: (str) {
                      return str.trim().length > 0 ? null : showText;
                    },
                    autovalidate: validate,
                    maxLength: maxLength,
                    controller: _controller,
                    autofocus: autufocus,
                    decoration: InputDecoration(
                        contentPadding: EdgeInsets.only(left: 10, top: 15),
                        suffixIcon: IconButton(
                          onPressed: () {
                            _controller.clear();
                          },
                          icon: Icon(Icons.clear),
                          color: Colors.black38,
                        ),
                        focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.black38)),
                        enabledBorder: InputBorder.none),
                  ),
                ),
              );
            }));
  }

  handleBirthDay() async {
    DateTime time = await showDatePicker(
      locale: Locale('zh'),
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1960),
      lastDate: DateTime.now(),
    );
    widget.user.birthday = time != null ? time : widget.user.birthday;
    setState(() {});
  }

  Future imageUpdate(UserProvider userProvider) async {
    Future getImage() async {
      File image;
      List<Asset> resultList = List<Asset>();
      try {
        resultList = await MultiImagePicker.pickImages(
          maxImages: 1,
          enableCamera: true,
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
        print(e);
      }
      if (resultList.length != 0) {
        var t = await resultList[0].filePath;
        image = File(t);
      }

      var cropImage = await ImageCropper.cropImage(
          sourcePath: image.path,
          aspectRatio: CropAspectRatio(ratioX: 16, ratioY: 16),
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

    File image = await getImage();
    String preAvatar = widget.user.avatar;
    var imageStr = await apiClient.uploadImage(image);
    imageStr = Avatar.getImageUrl(imageStr);
    widget.user.avatar = imageStr;
    var data = await userProvider.upLoadUserProfile(widget.user);
    String text = "";
    if (data['status'] == true) {
      text = '修改成功';
    } else {
      text = '修改失败';
      widget.user.avatar = preAvatar;
    }
    setState(() {});

    BotToast.showText(text: text);
  }
}
