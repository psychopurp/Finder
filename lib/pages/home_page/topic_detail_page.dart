import 'dart:convert';

import 'package:finder/config/api_client.dart';
import 'package:finder/plugin/avatar.dart';
import 'package:finder/plugin/pics_swiper.dart';
import 'package:finder/provider/user_provider.dart';
import 'package:finder/public.dart';
import 'package:finder/routers/application.dart';
import 'package:flutter/material.dart';
import 'package:finder/models/topic_comments_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_easyrefresh/material_footer.dart';
import 'package:provider/provider.dart';

class TopicDetailPage extends StatefulWidget {
  final int topicId;
  final String topicImage;
  final String topicTitle;
  TopicDetailPage({this.topicId, this.topicImage, this.topicTitle});

  @override
  _TopicDetailPageState createState() => _TopicDetailPageState();
}

class _TopicDetailPageState extends State<TopicDetailPage> {
  ScrollController _controller;
  double titileOpacity = 0;
  double bottomTitleOpacity = 0;

  @override
  void initState() {
    _controller = ScrollController()
      ..addListener(() {
        print(_controller.offset);
        if (_controller.offset < 160 && _controller.offset > 108) {
          setState(() {
            titileOpacity = (_controller.offset / 100) % 1;
            bottomTitleOpacity = ((_controller.offset / 100) > 1)
                ? 1
                : (_controller.offset / 100);
            // print(1 - titileOpacity);
          });
        } else if (_controller.offset > 160) {
          setState(() {
            titileOpacity = 1;
          });
        } else if (_controller.offset < 80) {
          setState(() {
            titileOpacity = 0;
            bottomTitleOpacity = 0;
          });
        }
        // print(titileOpacity);
      });
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var joinTopicButtton = Padding(
        padding: EdgeInsets.symmetric(horizontal: 120),
        child: MaterialButton(
          onPressed: () {
            Application.router.navigateTo(context,
                '/publishTopicComment?topicId=${widget.topicId.toString()}&&topicTitle=${Uri.encodeComponent(widget.topicTitle)}');
          },
          child: Text(
            "+ 参与话题",
            style: TextStyle(color: Colors.white),
          ),
          highlightElevation: 5,
          color: Theme.of(context).primaryColor,
          shape: StadiumBorder(side: BorderSide(color: Colors.white)),
          // minWidth: ScreenUtil().setWidth(100),
          height: ScreenUtil().setHeight(70),
        ));

    return Scaffold(
      body: Stack(
        children: <Widget>[
          NestedScrollView(
            controller: _controller,
            physics: ScrollPhysics(),
            headerSliverBuilder: _sliverBuilder,
            body: TopicComments(
              topicId: widget.topicId,
              controller: _controller,
            ),
          ),
          Positioned(
            child: joinTopicButtton,
            bottom: 20,
            left: 0,
            right: 0,
          )
        ],
      ),
    );
  }

  List<Widget> _sliverBuilder(BuildContext context, bool innerBoxIsScrolled) {
    return <Widget>[
      SliverAppBar(
        // automaticallyImplyLeading: false,
        elevation: 5,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          this.widget.topicTitle,
          style: TextStyle(
              fontSize: ScreenUtil().setSp(30),
              color: Colors.black.withOpacity(titileOpacity)),
        ),
        iconTheme: IconThemeData(color: Colors.black),
        centerTitle: true, //标题居中
        expandedHeight: 200.0, //展开高度200
        // floating: true, //不随着滑动隐藏标题
        // snap: true,
        pinned: true, //固定在顶部
        // forceElevated: innerBoxIsScrolled,
        flexibleSpace: FlexibleSpaceBar(
            titlePadding: EdgeInsets.only(
              left: 50,
              right: 50,
            ),
            centerTitle: true,
            title: Container(
              padding: EdgeInsets.only(left: 20, right: 20, top: 0, bottom: 50),
              // alignment: Alignment.center,
              // color: Colors.amber,
              child: Text(
                this.widget.topicTitle,
                softWrap: true,
                maxLines: 2,
                style: TextStyle(
                  color: Colors.white.withOpacity(1 - bottomTitleOpacity),
                  fontSize: ScreenUtil().setSp(22),
                ),
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
            background: Stack(
              fit: StackFit.expand,
              children: <Widget>[
                CachedNetworkImage(
                  imageUrl: widget.topicImage,
                  fit: BoxFit.fill,
                ),
                Opacity(
                  opacity: 0.35,
                  child: Container(
                    color: Colors.black,
                  ),
                )
              ],
            )),
      )
    ];
  }

  Widget topImage() {
    return CachedNetworkImage(
      imageUrl: this.widget.topicImage,
      imageBuilder: (context, imageProvider) => Align(
        alignment: Alignment.topCenter,
        child: Container(
          height: ScreenUtil().setHeight(400),
          width: ScreenUtil().setWidth(750),
          decoration: BoxDecoration(
            // color: Colors.green,
            image: DecorationImage(
              image: imageProvider,
              fit: BoxFit.fill,
            ),
          ),
          child: Stack(
            children: <Widget>[
              Opacity(
                opacity: 0.35,
                child: Container(
                  // width: ScreenUtil().setWidth(750),
                  decoration: BoxDecoration(
                    color: Colors.black,
                  ),
                ),
              ),
              Container(
                alignment: Alignment.center,
                // color: Colors.blue,
                padding: EdgeInsets.symmetric(horizontal: 20.0),
                child: Text(
                  this.widget.topicTitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    color: Colors.white.withOpacity(0.9),
                    fontSize: ScreenUtil().setSp(40),
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              )
            ],
          ),
        ),
      ),
      errorWidget: (context, url, error) => Icon(Icons.error),
    );
  }
}

class TopicComments extends StatefulWidget {
  final ScrollController controller;
  final int topicId;
  TopicComments({this.topicId, this.controller});
  @override
  _TopicCommentsState createState() => _TopicCommentsState();
}

class _TopicCommentsState extends State<TopicComments> {
  EasyRefreshController _refreshController;
  TopicCommentsModel topicComments;
  // List collectList = [];
  List likeList = [];
  int pageCount = 2;
  var buttonItem;
  bool ifComment = false;
  TextEditingController _commentController;
  FocusNode _commentFocusNode;
  FocusNode blackFocusNode;
  double commentHeight = 0;
  //FormState为Form的State类，可以通过 Form.of() 或GlobalKey获得。我们可以通过它来对
  //Form的子孙FormField进行统一操作。
  GlobalKey _formKey = new GlobalKey<FormState>();

  @override
  void initState() {
    getInitialData();
    _commentFocusNode = FocusNode();
    blackFocusNode = FocusNode();
    _commentController = TextEditingController();
    buttonItem = {
      'collect': {
        false: Icon(
          IconData(0xe646, fontFamily: 'myIcon'),
          color: Colors.black,
        ),
        true: Icon(
          IconData(0xe780, fontFamily: 'myIcon'),
          color: Colors.black,
        ),
        'handle': collectHandle
      },
      'comment': {
        'icon': Icon(
          IconData(0xe60d, fontFamily: 'myIcon'),
          color: Colors.black,
        ),
        'handle': commentHandle
      },
      'like': {
        true: Icon(
          IconData(0xe686, fontFamily: 'myIcon'),
          color: Colors.black,
        ),
        false: Icon(
          IconData(0xe66f, fontFamily: 'myIcon'),
          color: Colors.black,
        ),
        'handle': likeHandle
      }
    };
    _refreshController = EasyRefreshController();

    super.initState();
  }

  @override
  void deactivate() {
    getInitialData();
    super.deactivate();
  }

  @override
  void dispose() {
    _commentFocusNode.dispose();
    blackFocusNode.dispose();
    _commentController.dispose();
    _refreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context);

    return body(user);
  }

  Widget body(UserProvider user) {
    Widget child;
    if (this.topicComments == null) {
      child = Container(
          alignment: Alignment.center,
          height: double.infinity,
          child: CupertinoActivityIndicator());
    } else {
      List<Widget> widgets =
          List.generate(this.topicComments.data.length, (index) {
        return _singleItem(this.topicComments.data[index], user);
      });

      child = EasyRefresh(
        enableControlFinishLoad: true,
        // header: MaterialHeader(),
        footer: MaterialFooter(),
        topBouncing: false,
        bottomBouncing: false,
        controller: _refreshController,
        child: ListView(
          children: widgets,
        ),
        onLoad: () async {
          var data = await getMore(this.pageCount);
          _refreshController.finishLoad(
              success: true, noMore: (data.length == 0));
        },
      );
    }

    return AnimatedSwitcher(
        duration: Duration(milliseconds: 1000),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return FadeTransition(
              child: child,
              opacity:
                  CurvedAnimation(curve: Curves.easeInOut, parent: animation));
        },
        child: child);
  }

  commentHandle(UserProvider user, TopicCommentsModelData item) async {
    String content = _commentController.text;
    String msg = "";
    if ((_formKey.currentState as FormState).validate()) {
      var data = await user.addTopicComment(
          topicId: widget.topicId, content: content, referComment: item.id);
      Navigator.pop(context);
      msg = (data['status']) ? "评论成功" : "评论失败";
      Fluttertoast.showToast(
          msg: msg,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM);
    }
  }

  likeHandle(UserProvider user, TopicCommentsModelData item) async {
    if (user.isLogIn) {
      var data;
      if (item.isLike == true) {
        data = await apiClient.likeTopicComment(topicCommentId: item.id);
        item.isLike = false;
        item.likes--;
      } else {
        data = await apiClient.likeTopicComment(topicCommentId: item.id);
        item.likes++;
        item.isLike = true;
      }
      // Future.delayed(Duration(milliseconds: 500), () {
      //   Scaffold.of(context).showSnackBar(new SnackBar(
      //     duration: Duration(milliseconds: 200),
      //     content: new Text("${data}"),
      //     action: new SnackBarAction(
      //       label: "取消",
      //       onPressed: () {},
      //     ),
      //   ));
      // });

      setState(() {});
    } else {
      //TODO 添加未登录的状态
    }
  }

  collectHandle(UserProvider user, TopicCommentsModelData item) async {
    String showText = "";
    if (user.isLogIn) {
      if (item.isCollected == true) {
        var data = await apiClient.deleteCollection(
            modelId: item.id, type: ApiClient.COMMENT);
        if (data['status'] == true) {
          showText = '取消收藏成功';
          item.isCollected = false;
        } else {
          showText = '取消收藏失败';
        }
      } else {
        var data =
            await apiClient.addCollection(type: ApiClient.COMMENT, id: item.id);
        if (data['status'] == true) {
          showText = '收藏成功';
          item.isCollected = true;
        } else {
          showText = '收藏失败';
        }
      }
      Future.delayed(Duration(milliseconds: 500), () {
        Scaffold.of(context).showSnackBar(new SnackBar(
          duration: Duration(milliseconds: 200),
          content: new Text("$showText"),
          action: new SnackBarAction(
            label: "取消",
            onPressed: () {},
          ),
        ));
      });

      setState(() {});
    } else {
      //TODO 添加未登录的状态
    }
  }

  void onComment(TopicCommentsModelData item, UserProvider user) {
    showBottomSheet(
        // elevation: 10,
        backgroundColor: Colors.black38,
        context: context,
        builder: (context) {
          return Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                Expanded(child: GestureDetector(
                  onTap: () {
                    print('tapped');
                    Navigator.pop(context);
                  },
                )),
                Container(
                  color: Theme.of(context).dividerColor,
                  padding: EdgeInsets.only(top: 10, left: 10, bottom: 10),
                  child: Row(
                    children: <Widget>[
                      Container(
                        width: ScreenUtil().setWidth(580),
                        padding: EdgeInsets.only(right: 10),
                        child: TextFormField(
                          validator: (str) {
                            return str.trim().length > 0 ? null : "内容不能为空";
                          },
                          style: TextStyle(fontFamily: 'normal', fontSize: 18),
                          cursorColor: Theme.of(context).primaryColor,
                          controller: _commentController,
                          focusNode: _commentFocusNode,
                          autofocus: true,
                          decoration: InputDecoration(
                            // labelText: '活动名称',
                            filled: true,
                            hintText: '@' + item.sender.nickname,
                            fillColor: Colors.white,
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.all(12),
                          ),
                          // expands: true,
                          minLines: 3,
                          maxLines: 4,
                          maxLengthEnforced: true,
                          // maxLength: 1000,
                        ),
                      ),
                      MaterialButton(
                        disabledColor: Colors.black,
                        onPressed: () {
                          buttonItem['comment']['handle'](user, item);
                        },
                        color: Theme.of(context).primaryColor,
                        minWidth: ScreenUtil().setWidth(100),
                        height: ScreenUtil().setHeight(70),
                        shape: StadiumBorder(),
                        child: Text(
                          "发送",
                          style: TextStyle(color: Colors.white),
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          );
        });
  }

  handleDelete(UserProvider user, TopicCommentsModelData item) async {
    if (user.isLogIn) {
      if (user.userInfo.id == item.sender.id) {
        showDialog(
            context: context,
            builder: (_) {
              return GestureDetector(
                onTap: () async {
                  Navigator.pop(context);
                  showDialog(
                      context: context,
                      builder: (_) {
                        return FinderDialog.showLoading();
                      });

                  var data =
                      await apiClient.deleteTopicComment(commentId: item.id);
                  await getInitialData();

                  widget.controller.animateTo(0,
                      duration: Duration(milliseconds: 300),
                      curve: Curves.bounceIn);

                  Navigator.pop(context);
                },
                child: CupertinoAlertDialog(
                  title: Text('删除话题评论',
                      style: TextStyle(
                          fontFamily: 'normal', fontWeight: FontWeight.w200)),
                ),
              );
            });
      }
    }
  }

  Widget _singleItem(TopicCommentsModelData item, UserProvider user) {
    String likeCount = item.likes.toString();
    String replyCount = item.replyCount.toString();
    if (item.likes == 0) {
      likeCount = "";
    } else if (item.likes > 999) {
      likeCount = "999+";
    }
    if (item.replyCount == 0) {
      replyCount = "";
    } else if (item.replyCount > 999) {
      replyCount = "999+";
    }

    return InkWell(
      onLongPress: () {
        handleDelete(user, item);
      },
      child: Container(
        padding: EdgeInsets.only(
            left: ScreenUtil().setWidth(35),
            right: ScreenUtil().setWidth(35),
            top: ScreenUtil().setWidth(20)),
        // color: Colors.amber,
        margin: EdgeInsets.only(bottom: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            ///头部
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    InkWell(
                      onTap: () {
                        Application.router.navigateTo(context,
                            "${Routes.userProfile}?senderId=${item.sender.id}&heroTag=${item.id.toString() + item.sender.id.toString() + 'topic'}");
                      },
                      child: Hero(
                        tag: item.id.toString() +
                            item.sender.id.toString() +
                            'topic',
                        child: Avatar(
                          url: item.sender.avatar,
                          avatarHeight: ScreenUtil().setHeight(90),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: ScreenUtil().setWidth(20)),
                      child: Text(
                        item.sender.nickname,
                        style: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w200,
                            fontSize: ScreenUtil().setSp(35)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(
              height: 15,
            ),
            contentPart(item.content),
            Divider(
              color: Colors.black12,
              thickness: 0.4,
              height: 0.1,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                ///收藏
                AnimatedSwitcher(
                  transitionBuilder: (child, anim) {
                    return ScaleTransition(child: child, scale: anim);
                  },
                  duration: Duration(milliseconds: 500),
                  child: MaterialButton(
                    key: ValueKey<bool>(item.isCollected),
                    onPressed: () =>
                        buttonItem['collect']['handle'](user, item),
                    shape: RoundedRectangleBorder(),
                    child: buttonItem['collect'][item.isCollected],
                    // color: Colors.amber,
                    splashColor: Colors.white,
                    minWidth: ScreenUtil().setWidth(226),
                    height: 30,
                  ),
                ),

                ///评论
                MaterialButton(
                  onPressed: () {
                    // onComment(item, user);
                    String topicId = widget.topicId.toString();
                    Application.router.navigateTo(context,
                        "${Routes.commentPage}?topicCommentId=${item.id}&topicId=$topicId");
                  },
                  shape: RoundedRectangleBorder(),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      buttonItem['comment']['icon'],
                      Padding(
                        padding: EdgeInsets.only(left: 5),
                        child: Text(replyCount),
                      )
                    ],
                  ),
                  // color: Colors.amber,
                  splashColor: Colors.white,
                  minWidth: ScreenUtil().setWidth(226),
                  height: 30,
                ),

                ///点赞
                AnimatedSwitcher(
                  transitionBuilder: (child, anim) {
                    return ScaleTransition(child: child, scale: anim);
                  },
                  duration: Duration(milliseconds: 500),
                  child: MaterialButton(
                    key: ValueKey<bool>(item.isLike),
                    onPressed: () => buttonItem['like']['handle'](user, item),
                    shape: RoundedRectangleBorder(),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        buttonItem['like'][item.isLike],
                        Padding(
                          padding: EdgeInsets.only(left: 5),
                          child: Text(likeCount),
                        )
                      ],
                    ),
                    minWidth: ScreenUtil().setWidth(226),
                    // color: Colors.amber,
                    splashColor: Colors.white,
                    height: 30,
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  ///话题评论--内容部分
  Widget contentPart(String content) {
    bool isSinglePic = false;
    var json = jsonDecode(content);
    List imagesJson = json['images'];
    List<String> images = [];
    String text = json['text'];
    imagesJson.forEach((i) {
      images.add(i);
    });

    return Container(
      // color: Colors.amber,
      // height: ScreenUtil().setHeight(400),
      width: ScreenUtil().setWidth(750),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            text,
            maxLines: 5,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                fontWeight: FontWeight.w500,
                fontFamily: 'normal',
                fontSize: ScreenUtil().setSp(30)),
          ),
          SizedBox(
            height: (text == "" || text == null) ? 0 : 10,
          ),
          Container(
            width: ScreenUtil().setWidth(680),
            // color: Colors.green,
            child: Wrap(
              spacing: ScreenUtil().setWidth(10),
              runSpacing: 5,
              children: images.asMap().keys.map((index) {
                isSinglePic = (images.length == 1) ? true : false;
                var _singlePic = Container(
                  child: CachedNetworkImage(
                    imageUrl: images[index],
                    fit: BoxFit.fitWidth,
                    placeholder: (context, _) {
                      return Center(
                        child: CupertinoActivityIndicator(),
                      );
                    },
                  ),
                  constraints: BoxConstraints(maxHeight: 400, minWidth: 400),
                );
                return CachedNetworkImage(
                  imageUrl: images[index],
                  errorWidget: (context, url, error) => Icon(Icons.error),
                  imageBuilder: (content, imageProvider) => InkWell(
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          fullscreenDialog: false,
                          builder: (_) {
                            return PicSwiper(
                              index: index,
                              pics: images,
                            );
                          }));
                    },
                    child: (isSinglePic)
                        ? _singlePic
                        : Container(
                            height: ScreenUtil().setHeight(220),
                            width: ScreenUtil().setWidth(220),
                            decoration: BoxDecoration(
                                image: DecorationImage(
                                    image: imageProvider, fit: BoxFit.fill)),
                          ),
                  ),
                );
              }).toList(),
            ),
          )
        ],
      ),
    );
  }

  Future getInitialData() async {
    var data =
        await apiClient.getTopicComments(topicId: widget.topicId, page: 1);
    // print(data);
    var topicComments = TopicCommentsModel.fromJson(data);

    if (!mounted) return;
    setState(() {
      this.topicComments = topicComments;
      this.pageCount = 2;
      this._refreshController.resetLoadState();
    });
  }

  Future getMore(int pageCount) async {
    var data = await apiClient.getTopicComments(
        topicId: widget.topicId, page: pageCount);
    TopicCommentsModel comments = TopicCommentsModel.fromJson(data);

    setState(() {
      this.topicComments.data.addAll(comments.data);
      this.pageCount++;
    });
    return comments.data;
  }
}
