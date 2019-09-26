import 'package:finder/config/api_client.dart';
import 'package:finder/public.dart';
import 'package:flutter/material.dart';
import 'package:finder/models/topic_comments_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_easyrefresh/material_header.dart';

class TopicDetailPage extends StatefulWidget {
  final int topicId;
  final String topicImage;
  final String topicTitle;
  TopicDetailPage({this.topicId, this.topicImage, this.topicTitle});

  @override
  _TopicDetailPageState createState() => _TopicDetailPageState(
      topicId: topicId, topicImage: topicImage, topicTitle: topicTitle);
}

class _TopicDetailPageState extends State<TopicDetailPage> {
  final int topicId;
  final String topicImage;
  final String topicTitle;
  _TopicDetailPageState({this.topicId, this.topicImage, this.topicTitle});

  TopicCommentsModel topicComments;
  var followList = [];

  @override
  void initState() {
    getInitialData().then((val) {
      setState(() {
        this.topicComments = val;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Container(
            alignment: Alignment.center,
            child: Text("+ 参与话题"),
            width: ScreenUtil().setWidth(270),
            height: ScreenUtil().setHeight(70),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.white, width: 1.5)),
          ),
          elevation: 0,
        ),
        body: (this.topicComments != null)
            ? Container(
                color: Colors.black12.withOpacity(0.1),
                child: EasyRefresh(
                  header: MaterialHeader(),
                  onRefresh: () async {
                    await Future.delayed(Duration(seconds: 1), () {
                      setState(() {});
                    });
                  },
                  child: ListView(
                    children: <Widget>[
                      topImage(),
                      commentsPart(),
                    ],
                  ),
                ),
              )
            : Center(child: CupertinoActivityIndicator()));
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
                opacity: 0.1,
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

  Widget commentsPart() {
    var children = this
        .topicComments
        .data
        .map((item) => Container(
              // height: ScreenUtil().setHeight(400),
              // width: ScreenUtil().setWidth(400),
              padding: EdgeInsets.only(
                  left: ScreenUtil().setWidth(45),
                  right: ScreenUtil().setWidth(45),
                  top: ScreenUtil().setWidth(20)),
              color: Colors.white,
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
                            radius: 20.0,
                            backgroundImage: CachedNetworkImageProvider(
                              item.sender.avatar,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                                left: ScreenUtil().setWidth(20)),
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
                      InkWell(
                        onTap: () {
                          print(item.sender.nickname);
                          setState(() {
                            if (this.followList.contains(item.id)) {
                              this.followList.remove(item.id);
                            } else {
                              this.followList.add(item.id);
                            }
                          });
                        },
                        child: Container(
                          margin:
                              EdgeInsets.only(right: ScreenUtil().setWidth(20)),
                          padding: EdgeInsets.symmetric(
                              vertical: 4.0, horizontal: 5.0),
                          decoration: BoxDecoration(
                              color: (this.followList.contains(item.id))
                                  ? Colors.cyan[300]
                                  : Colors.cyan,
                              borderRadius: BorderRadius.circular(5)),
                          child: Text(
                            (this.followList.contains(item.id)) ? '已关注' : '+关注',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: ScreenUtil().setSp(40)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(
                        vertical: ScreenUtil().setHeight(20)),
                    height: 1,
                    color: Colors.black12,
                  ),
                  Container(
                    child: Text(item.content),
                  ),
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
            ))
        .toList();
    return Align(
      child: Container(
        width: ScreenUtil().setWidth(750),
        // color: Colors.black26,
        child: Column(children: children),
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
    var data = await apiClient.getTopicComments(topicId: topicId, page: 1);
    var topicComments = TopicCommentsModel.fromJson(data);
    print(data);
    return topicComments;
  }
}
