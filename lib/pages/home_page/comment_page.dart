import 'package:finder/config/api_client.dart';
import 'package:finder/models/topic_comments_model.dart';
import 'package:finder/provider/user_provider.dart';
import 'package:finder/public.dart';
import 'package:finder/routers/application.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_easyrefresh/material_footer.dart';
import 'package:flutter_easyrefresh/material_header.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class CommentPage extends StatefulWidget {
  final int topicId;
  final int topicCommentId;

  CommentPage({this.topicCommentId, this.topicId});

  @override
  _CommentPageState createState() => _CommentPageState();
}

class _CommentPageState extends State<CommentPage> {
  TopicCommentsModel comment;
  TextEditingController _commentController;
  EasyRefreshController _refreshController;
  ScrollController _controller;
  FocusNode _commentFocusNode;
  int currentComment;
  String defaultHint = '喜欢就评论告诉Ta';
  String hintText = '喜欢就评论告诉Ta';
  int pageCount = 2;
  bool hasMore = true;

  @override
  void initState() {
    currentComment = widget.topicCommentId;
    getReplies();
    _commentController = TextEditingController()
      ..addListener(() {
        setState(() {});
      });
    _commentFocusNode = FocusNode()
      ..addListener(() {
        if (!_commentFocusNode.hasFocus) {
          setState(() {
            currentComment = widget.topicCommentId;
            hintText = defaultHint;
          });
        }
      });
    _controller = ScrollController()
      ..addListener(() {
        _commentFocusNode.unfocus();
      });
    _refreshController = EasyRefreshController();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    _refreshController.dispose();
    _commentController.dispose();
    _commentFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context);

    return Scaffold(
      // appBar: AppBar(
      //   title: Text("评论"),
      //   textTheme: TextTheme(
      //       title: Theme.of(context)
      //           .appBarTheme
      //           .textTheme
      //           .title
      //           .copyWith(color: Colors.black)),
      //   iconTheme: IconThemeData(color: Colors.black),
      //   backgroundColor: Colors.white,
      //   centerTitle: true,
      // ),
      body: Padding(
        padding: EdgeInsets.only(top: 0),
        child: Stack(
          children: <Widget>[
            GestureDetector(
              onTap: () {
                _commentFocusNode.unfocus();
              },
              child: EasyRefresh(
                enableControlFinishLoad: true,
                bottomBouncing: false,
                topBouncing: false,
                header: MaterialHeader(),
                footer: MaterialFooter(),
                controller: _refreshController,
                onRefresh: () async {
                  await getReplies();
                  _refreshController.resetLoadState();
                },
                onLoad: () async {
                  await getMore(this.pageCount);

                  await Future.delayed(Duration(milliseconds: 500), () {
                    _refreshController.finishLoad(
                        success: true, noMore: (!this.hasMore));
                  });
                },
                child: (this.comment != null)
                    ? ListView(
                        controller: _controller,
                        padding: EdgeInsets.only(
                            bottom: 20, top: kToolbarHeight / 2),
                        children: buildContent(user))
                    : Container(
                        height: 400,
                        child: CupertinoActivityIndicator(),
                      ),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: commentBar(user),
            )
          ],
        ),
      ),
    );
  }

  List<Widget> buildContent(UserProvider user) {
    String getTimeString(DateTime time) {
      DateTime now = DateTime.now();

      if (now.month == now.month) {
        if (now.difference(time).inMinutes < 60) {
          if (now.difference(time).inMinutes == 0) {
            return "刚刚";
          } else {
            return now.difference(time).inMinutes.toString() + '分钟前';
          }
        }
        if ((now.difference(time).inHours) < 24) {
          return (now.difference(time).inHours).toString() + '小时前';
        } else {
          return (now.difference(time).inDays).toString() + '天前';
        }
      }
      return time.month.toString() + '月' + time.day.toString() + '日';
    }

    List<Widget> content = [];
    this.comment.data.forEach((item) {
      Widget singleItem = InkWell(
          onLongPress: () => handleDelete(user, item),
          onTap: () {
            setState(() {
              this.hintText = "@" + item.sender.nickname;
              this.currentComment = item.id;
            });
            FocusScope.of(context).requestFocus(_commentFocusNode);
          },
          child: Container(
            padding: EdgeInsets.only(top: 10.0, left: 15.0, bottom: 20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                InkWell(
                  onTap: () {
                    Application.router.navigateTo(context,
                        "${Routes.userProfile}?senderId=${item.sender.id.toString()}&heroTag=${item.id.toString() + item.sender.id.toString() + 'comment'}");
                  },
                  child: Hero(
                    tag: item.id.toString() +
                        item.sender.id.toString() +
                        'comment',
                    child: Avatar(
                      url: item.sender.avatar,
                      avatarHeight: 40,
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(left: 10.0),
                        child: Text(
                          item.sender.nickname,
                          style: Theme.of(context)
                              .textTheme
                              .body1
                              .copyWith(fontSize: 15),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 10.0, top: 5.0),
                        child: (item.replyTo.id != widget.topicCommentId)
                            ? Text.rich(TextSpan(children: [
                                TextSpan(
                                    text: " @" + item.replyTo.sender.nickname,
                                    style: Theme.of(context)
                                        .textTheme
                                        .body2
                                        .copyWith(
                                            color: Theme.of(context)
                                                .primaryColor)),
                                TextSpan(text: " : " + item.content)
                              ]))
                            : Text(
                                item.content,
                                style: Theme.of(context).textTheme.body2,
                              ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(right: 15.0),
                  child: Text(getTimeString(item.time),
                      style: Theme.of(context).textTheme.body1),
                )
              ],
            ),
          ));

      content.add(singleItem);
    });

    return content;
  }

  commentBar(UserProvider user) {
    return Container(
      // color: Colors.white,
      padding: EdgeInsets.only(top: 10, left: 10, bottom: 10),
      child: Row(
        children: <Widget>[
          Container(
            // color: Colors.yellow,
            width: ScreenUtil().setWidth(580),
            padding: EdgeInsets.only(right: 10),
            child: TextField(
              style: TextStyle(
                  letterSpacing: 0.4, fontSize: 14, fontFamily: 'normal'),
              cursorColor: Theme.of(context).primaryColor,
              controller: _commentController,
              focusNode: _commentFocusNode,
              autofocus: false,
              decoration: InputDecoration(
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none),
                // labelText: '活动名称',
                filled: true,
                hintText: hintText,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none),
                contentPadding: EdgeInsets.all(12),
              ),
              // expands: true,
              minLines: 1,
              maxLines: 4,
              maxLengthEnforced: true,
              // maxLength: 1000,
            ),
          ),
          MaterialButton(
            disabledColor: Colors.black26,
            onPressed: (_commentController.text != null &&
                    _commentController.text != "")
                ? () => commentHandle(user)
                : null,
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
    );
  }

  handleDelete(UserProvider user, TopicCommentsModelData item) async {
    if (user.isLogIn) {
      if (user.userInfo.id == item.sender.id) {
        showDialog(
          context: context,
          builder: (_) {
            return AlertDialog(
              title: Text("提示"),
              content: Text("确认要删除此条回复吗? "),
              actions: <Widget>[
                FlatButton(
                  child: Text("取消"),
                  onPressed: () => Navigator.of(context).pop(), // 关闭对话框
                ),
                FlatButton(
                    child: Text("删除"),
                    onPressed: () async {
                      FinderDialog.showLoading();
                      var data = await apiClient.deleteTopicComment(
                          commentId: item.id);
                      Navigator.pop(context);
                      _refreshController.callRefresh();
                    }),
              ],
            );
          },
        );
      }
    }
  }

  Future commentHandle(UserProvider user) async {
    String msg = "";
    if (user.isLogIn) {
      String content = _commentController.text;
      _commentController.clear();
      var data = await apiClient.addTopicComment(
          topicId: widget.topicId,
          content: content,
          referComment: currentComment);
      hintText = defaultHint;
      currentComment = widget.topicCommentId;
      // _commentController.clear();
      _commentFocusNode.unfocus();
      _refreshController.callRefresh();

      msg = (data['status']) ? "评论成功" : "评论失败";
    } else {
      //TODO 未登录
    }
    Future.delayed(Duration(milliseconds: 200), () {
      BotToast.showText(
          text: msg,
          align: Alignment(0, 0.5),
          contentColor: Colors.black38,
          duration: Duration(milliseconds: 500));
    });
  }

  Future getReplies() async {
    var data = await apiClient.getTopicComments(
        topicId: widget.topicId, page: 1, rootId: widget.topicCommentId);
    TopicCommentsModel topicComment = TopicCommentsModel.fromJson(data);
    // print("reply ==== ${jsonEncode(data)}");
    if (!mounted) return;
    setState(() {
      this.comment = topicComment;
      this.pageCount = 2;
      this.hasMore = topicComment.hasMore;
    });
  }

  Future getMore(int pageCount) async {
    var data = await apiClient.getTopicComments(
        topicId: widget.topicId,
        page: pageCount,
        rootId: widget.topicCommentId);
    TopicCommentsModel topicComment = TopicCommentsModel.fromJson(data);

    setState(() {
      this.comment.data.addAll(topicComment.data);
      this.pageCount++;
      this.hasMore = topicComment.hasMore;
    });
    return topicComment.data;
  }
}
