import 'dart:convert';

import 'package:finder/config/api_client.dart';
import 'package:finder/public.dart';
import 'package:finder/routers/application.dart';
import 'package:flutter/material.dart';
import 'package:finder/models/topic_comments_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_easyrefresh/material_footer.dart';
import 'package:flutter_easyrefresh/material_header.dart';
import 'package:flutter_html/flutter_html.dart';

class TopicDetailPage extends StatelessWidget {
  final int topicId;
  final String topicImage;
  final String topicTitle;
  TopicDetailPage({this.topicId, this.topicImage, this.topicTitle});

  @override
  Widget build(BuildContext context) {
    var joinTopicButtton = Padding(
        padding: EdgeInsets.symmetric(horizontal: 120),
        child: MaterialButton(
          onPressed: () {
            Application.router.navigateTo(context,
                '/publishTopicComment?topicId=${topicId.toString()}&&topicTitle=${Uri.encodeComponent(topicTitle)}');
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
      body: NestedScrollView(
        headerSliverBuilder: _sliverBuilder,
        body: TopicComments(
          topicId: topicId,
        ),
      ),
    );
  }

  List<Widget> _sliverBuilder(BuildContext context, bool innerBoxIsScrolled) {
    return <Widget>[
      SliverAppBar(
        // automaticallyImplyLeading: false,
        backgroundColor: Colors.black,
        centerTitle: true, //标题居中
        expandedHeight: 200.0, //展开高度200
        floating: true, //不随着滑动隐藏标题
        snap: true,
        pinned: true, //固定在顶部
        // forceElevated: innerBoxIsScrolled,
        flexibleSpace: FlexibleSpaceBar(
            titlePadding: EdgeInsets.only(
              left: 50,
              right: 50,
            ),
            centerTitle: true,
            title: Container(
              padding: EdgeInsets.only(left: 20, right: 20, top: 0, bottom: 18),
              // alignment: Alignment.center,
              // color: Colors.amber,
              child: Text(
                this.topicTitle,
                softWrap: true,
                maxLines: 2,
                style: TextStyle(
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
                  imageUrl: topicImage,
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
      imageUrl: this.topicImage,
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
                  this.topicTitle,
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
  final int topicId;
  TopicComments({this.topicId});
  @override
  _TopicCommentsState createState() => _TopicCommentsState();
}

class _TopicCommentsState extends State<TopicComments> {
  EasyRefreshController _refreshController;
  TopicCommentsModel topicComments;
  var followList = [];

  @override
  void initState() {
    _refreshController = EasyRefreshController();
    getInitialData();
    super.initState();
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return EasyRefresh.custom(
      enableControlFinishLoad: true,
      header: MaterialHeader(),
      footer: MaterialFooter(),
      controller: _refreshController,
      onRefresh: () async {
        await Future.delayed(Duration(microseconds: 500), () {
          // _getInitialTopicsData(2);
        });
        _refreshController.resetLoadState();
      },
      onLoad: () async {
        // var data = await _getMore(this.pageCount);
        // _refreshController.finishLoad(
        // success: true, noMore: (data.length == 0));
      },
      slivers: <Widget>[
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              return _singleItem(this.topicComments.data[index]);
            },
            childCount: this.topicComments.data.length,
          ),
        ),
      ],
    );
  }

  Widget _singleItem(TopicCommentsModelData item) {
    return Container(
      // height: ScreenUtil().setHeight(400),
      // width: ScreenUtil().setWidth(400),
      padding: EdgeInsets.only(
          left: ScreenUtil().setWidth(45),
          right: ScreenUtil().setWidth(45),
          top: ScreenUtil().setWidth(20)),
      // color: Colors.white,
      margin: EdgeInsets.only(bottom: ScreenUtil().setHeight(20)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Row(
                children: <Widget>[
                  CircleAvatar(
                    backgroundColor: Theme.of(context).dividerColor,
                    radius: 20.0,
                    backgroundImage: CachedNetworkImageProvider(
                      item.sender.avatar,
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
          Divider(
            height: 30,
            thickness: 1,
            color: Colors.black12,
          ),
          contentPart(item.content),
          Container(
            margin: EdgeInsets.only(top: ScreenUtil().setHeight(20)),
            height: 1,
            color: Colors.black12,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              _singleButtonItem(
                  Icon(
                    IconData(0xe646, fontFamily: 'myIcon'),
                    color: Colors.black,
                  ),
                  '收藏数',
                  '收藏'),
              _singleButtonItem(
                  Icon(
                    IconData(0xe60d, fontFamily: 'myIcon'),
                    color: Colors.black,
                  ),
                  '收藏数',
                  '评论'),
              _singleButtonItem(
                  Icon(
                    IconData(0xe6b4, fontFamily: 'myIcon'),
                    color: Colors.black,
                  ),
                  '收藏数',
                  '点赞'),
            ],
          ),
        ],
      ),
    );
  }

  ///话题评论--内容部分
  Widget contentPart(String content) {
    var json = jsonDecode(content);
    List images = json['images'];
    String text = json['text'];

    return Container(
      // color: Colors.amber,
      // height: ScreenUtil().setHeight(400),
      width: ScreenUtil().setWidth(750),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            text,
            style: TextStyle(
                fontWeight: FontWeight.w500,
                fontFamily: 'normal',
                fontSize: ScreenUtil().setSp(30)),
          ),
          Container(
            color: Colors.white,
            child: Wrap(
              spacing: 5,
              runSpacing: 5,
              children: images.map((image) {
                return CachedNetworkImage(
                  imageUrl: image,
                  errorWidget: (context, url, error) => Icon(Icons.error),
                  imageBuilder: (content, imageProvider) => InkWell(
                    onTap: () {},
                    child: Container(
                      height: ScreenUtil().setHeight(200),
                      width: ScreenUtil().setWidth(200),
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

  _singleButtonItem(Icon icon, String count, item) {
    // Color myColor = Colors.white;
    // switch (item) {
    //   case '收藏':
    //     myColor = Colors.amber;
    //     print('sho');
    //     break;
    //   case '评论':
    //     myColor = Colors.cyan;
    //     print('ping');
    //     break;
    //   case '点赞':
    //     myColor = Colors.deepPurple;
    //     break;
    //   default:
    //     myColor = Colors.blue;
    // }

    return Material(
      color: Colors.white,
      child: InkWell(
        // hoverColor: Colors.black,
        // focusColor: Colors.amber,
        // highlightColor: Colors.blue,
        // splashColor: Colors.amber,
        onTap: () {
          print('object');
        },
        child: Container(
          alignment: Alignment.center,
          padding: EdgeInsets.symmetric(vertical: ScreenUtil().setHeight(30)),
          // color: myColor,
          width: ScreenUtil().setWidth(220),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              icon,
              Text(count),
            ],
          ),
        ),
      ),
    );
  }

  Future getInitialData() async {
    var data =
        await apiClient.getTopicComments(topicId: widget.topicId, page: 1);
    var topicComments = TopicCommentsModel.fromJson(data);

    if (!mounted) return;
    setState(() {
      this.topicComments = topicComments;
    });
  }
}
