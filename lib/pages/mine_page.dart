import 'dart:io';

import 'package:finder/config/api_client.dart';
import 'package:finder/models/engage_topic_comment_model.dart';
import 'package:finder/models/user_model.dart';
import 'package:finder/pages/mine_page/user_content_tabview.dart';
import 'package:finder/pages/mine_page/user_topic_comments.dart';
import 'package:finder/plugin/gradient_generator.dart';
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

class _MinePageState extends State<MinePage> with TickerProviderStateMixin {
  Color backGroundColor = Colors.grey;
  double topPartHeight = 150;
  List<Asset> images = [];
  var cards;
  List<Map<String, dynamic>> tabs;
  TabController tabController;
  ScrollController scrollController;
  ScrollController innerController;
  PageController pageController;

  double firstPosition = 0;
  double lastPosition = 0;

  double appBarOpacity = 0;
  EngageTopicCommentModel topic;

  bool isUpdateBackground = false;
  final GlobalKey globalKey = GlobalKey();

  UserModel userInfo;
  UserProvider userProvider;

  @override
  void initState() {
    // getInitialData();
    pageController = PageController();
    // getTopicData();
    cards = {
      'topic': {'name': '话题 (待完善)'},
      'activity': {'name': '活动(待完善)'},
      'toHeSay': {'name': '表白Ta'},
      'message': {'name': '私信Ta'}
    };
    tabs = [
      {'name': '我参与的话题', 'body': UserTopicCommentsPage()},
      {'name': '我发布的话题', 'body': Container()},
      {'name': '我的活动', 'body': Container()},
      {'name': '最近浏览', 'body': Container()},
    ];
    tabController = TabController(length: tabs.length, vsync: this);
    innerController = ScrollController();
    scrollController = ScrollController()
      ..addListener(() {
        double offset = scrollController.offset;
        // print("offset==>$offset");
        if (offset > 108 && offset < 160) {
          setState(() {
            appBarOpacity = (offset / 100) % 1;
          });
        } else if (offset > 160) {
          setState(() {
            appBarOpacity = 1;
          });
        } else if (offset < 60) {
          setState(() {
            appBarOpacity = 0;
          });
        }
        // print(scrollController.offset);
      });

    super.initState();
  }

  @override
  void dispose() {
    tabController.dispose();
    scrollController.dispose();
    innerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context);
    this.userInfo = user.userInfo;
    this.userProvider = user;
    if (this.userInfo.backGround == null) {
      imageToColors(userInfo.avatar).then((val) {
        this.userInfo.backGround = val;
        setState(() {
          print('更新背景');
          this.isUpdateBackground = true;
        });
      });
    }

    return Scaffold(
      body: SafeArea(
        top: false,
        child: Container(child: body),
      ),
    );
  }

  Widget get body {
    // print(this.userInfo);
    Widget child;
    if (this.userInfo == null) {
      child = Stack(children: <Widget>[
        buildBackground(),
        Container(
            alignment: Alignment.center,
            height: double.infinity,
            child: CupertinoActivityIndicator())
      ]);
    } else {
      Widget userInfoCard = Container(
          // color: Colors.amber,
          key: globalKey,
          alignment: Alignment.center,
          padding: EdgeInsets.only(bottom: 100, top: 80),
          child: Stack(
            fit: StackFit.loose,
            alignment: Alignment.topCenter,
            children: <Widget>[
              Container(
                  padding: EdgeInsets.only(top: 50),
                  child: userCard(this.userInfo)),
              Positioned(
                top: 0,
                // left: 0,
                // top: topPartHeight * 1.5 - 40,
                child: avatar(this.userInfo),
              )
            ],
          ));

      Widget scrollBody = CustomScrollView(
        controller: scrollController,
        slivers: <Widget>[
          SliverPersistentHeader(
              floating: true,
              pinned: true,
              delegate: AppbarDelegate(
                  child: UserAppBar(
                title: Padding(
                  padding: EdgeInsets.only(top: 18.0),
                  child: Text(userInfo.nickname,
                      style: TextStyle(
                          fontSize: 20,
                          color: Colors.black.withOpacity(appBarOpacity))),
                ),
                color: Colors.white.withOpacity(appBarOpacity),
              ))),
          SliverToBoxAdapter(
            child: userInfoCard,
          ),
          sliverTabBar(),
          // sliverTabBody()
        ],
      );

      child = Stack(
        alignment: Alignment.topCenter,
        fit: StackFit.expand,
        children: <Widget>[
          buildBackground(),
          scrollBody,
        ],
      );
    }

    return Container(
        height: ScreenUtil.screenHeightDp,
        width: double.infinity,
        // color: Colors.amber,
        child: child);
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

  sliverTabBar() {
    Widget child = SliverPersistentHeader(
        pinned: true,
        // floating: true,
        delegate: StickyTabBarDelegate(
            child: PreferredSize(
          preferredSize: Size.fromHeight(ScreenUtil.screenHeightDp),
          child: Stack(
            children: <Widget>[
              TabView(userId: userInfo.id),
              Listener(
                onPointerDown: (detail) {
                  // print("down==>${detail.position}");
                  setState(() {
                    firstPosition = detail.position.dy;
                  });
                },
                onPointerMove: (detail) {
                  // print(firstPosition);
                  double del = detail.position.dy - firstPosition;
                  // print(
                  //     "scrollController.offset===>${scrollController.offset}");
                  // print("del===>$del");
                  // print("detail======>${detail.position.dy}");
                  // if (scrollController.offset > 470) {
                  //   scrollController.jumpTo(scrollController.offset - del);
                  // }
                  // if (del > 0) {
                  //   scrollController.jumpTo(scrollController.offset - del);
                  // }
                  // print("del=====>$del");
                  // if (scrollController.offset > 50) {
                  //   scrollController.jumpTo(scrollController.offset - del);
                  // }

                  // print("move==>${detail.position}");
                },
                onPointerUp: (detail) {
                  // print(firstPosition);
                  // double del = detail.position.dy - firstPosition;
                  // print("up==>${detail.position}");
                  // // if ((detail.position.dy - firstPosition) > 140) {
                  // // print('ok');
                  // // print("offset=====>${scrollController.offset}");
                  // scrollController.jumpTo(scrollController.offset - del);
                },
                behavior: HitTestBehavior.translucent,
                child: Container(
                  height: ScreenUtil.screenHeightDp,
                  width: ScreenUtil.screenWidthDp,
                ),
              )
            ],
          ),
        )));
    return child;
  }

  sliverTabBody() {
    Widget child = SliverFillRemaining(
      // 剩余补充内容TabBarView
      // child: Padding(
      //   padding: EdgeInsets.only(top: 50.0),
      //   child: PageView(
      //     controller: pageController,
      //     children: this.tabs.map((tab) {
      //       Widget child = tab['body'];
      //       return child;
      //     }).toList(),
      //   ),
      child: TabBarView(
        controller: this.tabController,
        children: this.tabs.map((tab) {
          Widget body = tab['body'];
          return body;
        }).toList(),
      ),

      // child: Padding(
      //   padding: EdgeInsets.only(top: 0.0),
      //   child: TabBarView(
      //     physics: AlwaysScrollableScrollPhysics(),
      //     controller: this.tabController,
      //     children: this.tabs.map((tab) {
      //       Widget body = tab['body'];
      //       return body;
      //     }).toList(),
      //   ),
      // ),
    );
    return child;
  }

  buildBackground() {
    double cardWidth = 130;
    List<Color> backGroundColor = this.userInfo.backGround != null
        ? this.userInfo.backGround
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
      key: ValueKey(this.isUpdateBackground),
      height: ScreenUtil.screenHeightDp,
      decoration: BoxDecoration(
          gradient: GradientGenerator.linear(backGroundColor.first,
              begin: Alignment.bottomLeft, end: Alignment.topRight)),
    );

    backGround = AnimatedSwitcher(
      switchInCurve: Curves.easeIn,
      switchOutCurve: Curves.easeOut,
      duration: Duration(milliseconds: 3000),
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
//          getCard(cards['topic']),
//          getCard(cards['activity']),
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
    var data = await userProvider.upLoadUserProfile(user);
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
    Widget card = Card(
        key: ValueKey(this.userInfo),
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
              // Padding(
              //   padding: EdgeInsets.only(left: ScreenUtil().setWidth(430)),
              //   child: MaterialButton(
              //     shape: CircleBorder(),
              //     onPressed: () {
              //       Navigator.push(context, CupertinoPageRoute(builder: (_) {
              //         return ChangeProfilePage(
              //           user: user,
              //         );
              //       }));
              //     },
              //     child: Icon(Icons.settings),
              //   ),
              // ),
              SizedBox(height: 50),

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

              Container(
                  padding: EdgeInsets.symmetric(vertical: 5),
                  child: Text((user.introduction != null)
                      ? "简介：" + user.introduction
                      : "简介：")),

              ///关注
              Container(
                // color: Colors.amber,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    MaterialButton(
                      onPressed: () {
                        Application.router.navigateTo(context,
                            "${Routes.fansFollowPage}?userId=${user.id.toString()}&isFan=false");
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
                            "${Routes.fansFollowPage}?userId=${user.id.toString()}&isFan=true");
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
    return card;
  }

  getInitialData() async {
    var data = await apiClient.getUserProfile();
    UserModel userData = UserModel.fromJson(data['data']);
    setState(() {
      this.userInfo = userData;
      print('更新用户信息');
    });
    List<Color> colors = await imageToColors(userData.avatar);
    this.userInfo.backGround = colors;
    setState(() {
      print('更新背景');
      this.isUpdateBackground = true;
    });
  }

  // getTopicData() async {
  //   var data = await apiClient.getEngageTopics(page: 1);
  //   EngageTopicCommentModel topic = EngageTopicCommentModel.fromJson(data);
  //   // print(topic);
  //   topic.topics.forEach((f) {
  //     print(f.title);
  //   });

  //   setState(() {
  //     this.topic = topic;
  //   });
  //   // print(data);
  // }
}

class StickyTabBarDelegate extends SliverPersistentHeaderDelegate {
  final PreferredSizeWidget child;
  final Color color;
  StickyTabBarDelegate({@required this.child, this.color});
  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    var border = BorderSide(color: Colors.black12, width: 0.5);
    return Container(
      height: this.child.preferredSize.height,
      // alignment: Alignment.center,
      child: this.child,
      // margin: EdgeInsets.only(top: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: border, bottom: border),
      ),
    );
    // return child;
  }

  @override
  double get maxExtent => this.child.preferredSize.height;
  @override
  double get minExtent => this.child.preferredSize.height;
  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}

class AppbarDelegate extends SliverPersistentHeaderDelegate {
  final PreferredSizeWidget child;
  AppbarDelegate({@required this.child});
  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(color: Colors.transparent, child: this.child);
  }

  @override
  double get maxExtent => this.child.preferredSize.height;
  @override
  double get minExtent => this.child.preferredSize.height;
  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}

class UserAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget title;
  final Color color;
  UserAppBar({this.title, this.color});
  @override
  Widget build(BuildContext context) {
    return Container(
      color: color,
      alignment: Alignment.center,
      height: kToolbarHeight + ScreenUtil.statusBarHeight - 10,
      child: title,
    );
  }

  @override
  Size get preferredSize =>
      Size.fromHeight(kToolbarHeight + ScreenUtil.statusBarHeight - 10);
}
