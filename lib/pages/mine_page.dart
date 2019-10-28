import 'dart:convert';
import 'dart:io';

import 'package:finder/config/api_client.dart';
import 'package:finder/models/user_model.dart';
import 'package:finder/pages/mine_page/change_profile_page.dart';
import 'package:finder/plugin/gradient_generator.dart';
import 'package:finder/plugin/my_appbar.dart';
import 'package:finder/public.dart';
import 'package:finder/routers/application.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:finder/provider/user_provider.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:provider/provider.dart';

class MinePage extends StatefulWidget {
  @override
  _MinePageState createState() => _MinePageState();
}

class _MinePageState extends State<MinePage> {
  Color backGroundColor = Colors.grey;
  double topPartHeight = 150;
  List<Asset> images = [];
  var cards;

  @override
  void initState() {
    cards = {
      'topic': {'name': '话题 (待完善)'},
      'activity': {'name': '活动(待完善)'},
      'toHeSay': {'name': '表白Ta'},
      'message': {'name': '私信Ta'}
    };
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<UserProvider>(builder: (context, user, child) {
        if (user.userInfo.backGround == null) {
          imageToColors(user.userInfo.avatar).then((val) {
            user.userInfo.backGround = val;
            setState(() {});
          });
        }

        print(user.collection);
        return SafeArea(
          top: false,
          child: Container(
            child: MyAppBar(
              appbar: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
              ),
              child: Stack(
                alignment: Alignment.topCenter,
                fit: StackFit.expand,
                children: <Widget>[
                  buildBackground(user.userInfo),
                  Positioned(
                      left: 0,
                      right: 0,
                      top: topPartHeight * 0.5,
                      child: userCard(user.userInfo)),
                  Positioned(
                    // left: ScreenUtil().setWidth(0),
                    // right: 0,
                    top: topPartHeight * 0.5 - 40,
                    child: avatar(user.userInfo),
                  )
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  avatar(UserModel userInfo) => GestureDetector(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  fullscreenDialog: true,
                  builder: (_) {
                    return GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Container(
                        constraints: BoxConstraints.expand(height: 500),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            CachedNetworkImage(imageUrl: userInfo.avatar),
                            Padding(
                              padding: EdgeInsets.only(top: 18.0),
                              child: MaterialButton(
                                onPressed: () async {
                                  Future getImage() async {
                                    var image;
                                    // var image = await ImagePicker.pickImage(source: ImageSource.gallery);
                                    String error = 'No Error Dectected';
                                    List<Asset> resultList = List<Asset>();
                                    try {
                                      resultList =
                                          await MultiImagePicker.pickImages(
                                        maxImages: 1,
                                        enableCamera: true,
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

                                    var cropImage =
                                        await ImageCropper.cropImage(
                                            sourcePath: image.path,
                                            aspectRatio: CropAspectRatio(
                                                ratioX: 16, ratioY: 16),
                                            androidUiSettings:
                                                AndroidUiSettings(
                                                    showCropGrid: false,
                                                    toolbarTitle: '图片剪切',
                                                    toolbarColor:
                                                        Theme.of(context)
                                                            .primaryColor,
                                                    toolbarWidgetColor:
                                                        Colors.white,
                                                    initAspectRatio:
                                                        CropAspectRatioPreset
                                                            .original,
                                                    lockAspectRatio: true),
                                            iosUiSettings: IOSUiSettings(
                                                minimumAspectRatio: 1.0,
                                                aspectRatioLockEnabled: true));
                                    return cropImage;
                                  }

                                  File image = await getImage();
                                  var data = await imageUpdate(image, userInfo);
                                  Navigator.pop(context);
                                },
                                shape: StadiumBorder(
                                    side: BorderSide(color: Colors.white)),
                                child: Text(
                                  "修改图片",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    );
                  }));
        },
        child: Hero(
          tag: 'profile',
          child: Container(
            // margin: EdgeInsets.only(top: ScreenUtil().setHeight(0)),
            height: 90,
            width: 90,
            child: Avatar(
              url: userInfo.avatar,
              avatarHeight: 90,
            ),
            decoration: BoxDecoration(
              // shape: CircleBorder(),
              border: Border.all(color: Colors.white, width: 3),
              borderRadius: BorderRadius.all(Radius.circular(50)),
            ),
          ),
        ),
      );

  buildBackground(UserModel user) {
    double cardWidth = 130;
    List<Color> backGroundColor = user.backGround != null
        ? user.backGround
        : [Theme.of(context).primaryColor];

    Widget getCard(item) => Card(
          color: Colors.white,
          elevation: 5,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: Container(
            alignment: Alignment.center,
            height: cardWidth,
            width: cardWidth * 2,
            child: Text(item['name']),
          ),
        );

    List<Widget> content = [];

    Widget backGround = Container(
      key: ValueKey(user.backGround),
      height: ScreenUtil.screenHeightDp,
      decoration: BoxDecoration(
          gradient: GradientGenerator.linear(
              backGroundColor[backGroundColor.length ~/ 2],
              begin: Alignment.bottomLeft,
              end: Alignment.topRight)),
    );

    backGround = AnimatedSwitcher(
      switchInCurve: Curves.easeIn,
      switchOutCurve: Curves.easeOut,
      duration: Duration(milliseconds: 5000),
      child: backGround,
    );

    // content.add(backGround);
    content.add(Container(
      alignment: Alignment.center,
      padding: EdgeInsets.only(top: cardWidth * 2),
      child: Wrap(
        spacing: 12,
        runSpacing: 14,
        children: <Widget>[
          getCard(cards['topic']),
          getCard(cards['activity']),
          // getCard(cards['toHeSay']),
          // getCard(cards['message'])
        ],
      ),
    ));

    return Stack(
      children: <Widget>[
        backGround,
        ListView(
          children: content,
        )
      ],
    );
  }

  imageUpdate(File image, UserModel user) async {
    String preAvatar = user.avatar;
    var imageStr = await apiClient.uploadImage(image);
    imageStr = Avatar.getImageUrl(imageStr);
    user.avatar = imageStr;
    var data = await apiClient.upLoadUserProfile(user);
    String text = "";
    if (data['status'] == true) {
      text = '修改成功';
    } else {
      text = '修改失败';
      user.avatar = preAvatar;
    }
    BotToast.showText(text: text);

    return data;
  }

  Widget userCard(UserModel user) {
    return Card(
        margin: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(100)),
        color: Colors.white,
        elevation: 10,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: EdgeInsets.only(bottom: 15, top: 0),
          width: ScreenUtil().setWidth(550),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: GradientGenerator.linear(Theme.of(context).primaryColor,
                  gradient: 2)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(left: ScreenUtil().setWidth(430)),
                child: MaterialButton(
                  shape: CircleBorder(),
                  onPressed: () {
                    Navigator.push(context, CupertinoPageRoute(builder: (_) {
                      return ChangeProfilePage(
                        user: user,
                      );
                    }));
                  },
                  child: Icon(Icons.settings),
                ),
              ),
              // SizedBox(height: 50),

              ///昵称
              Text(
                user.nickname,
                style: TextStyle(color: Colors.black, fontSize: 20),
              ),

              ///学校专业
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(user?.school?.name ?? "家里蹲大学"),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 5),
                    height: 14,
                    width: 1,
                    color: Theme.of(context).primaryColor,
                  ),
                  Text((user.major != null) ? user.major : ""),
                ],
              ),

              ///关注
              Container(
                // color: Colors.amber,
                padding: EdgeInsets.only(top: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    MaterialButton(
                      onPressed: () {
                        Application.router.navigateTo(context,
                            "${Routes.fansFollowPage}?userId=${user.id.toString()}&isFollow=true");
                      },
                      shape: RoundedRectangleBorder(),
                      child: Column(
                        children: <Widget>[
                          Text(user.followCount.toString()),
                          Text('关注')
                        ],
                      ),
                    ),
                    MaterialButton(
                      onPressed: () {
                        Application.router.navigateTo(context,
                            "${Routes.fansFollowPage}?userId=${user.id.toString()}&isFollow=false");
                      },
                      shape: RoundedRectangleBorder(),
                      child: Column(
                        children: <Widget>[
                          Text(user.fanCount.toString()),
                          Text('粉丝')
                        ],
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ));
  }
}
