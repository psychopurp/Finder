import 'package:finder/config/api_client.dart';
import 'package:finder/models/topic_comments_model.dart';
import 'package:finder/pages/serve_page/he_says_page.dart';
import 'package:finder/plugin/better_text.dart';
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
  final BoolCallback onDelete;
  final BoolCallback onComment;
  final ScrollController parentController;

  CommentPage(
      {this.topicCommentId,
      this.topicId,
      this.onDelete,
      this.onComment,
      this.parentController});

  @override
  _CommentPageState createState() => _CommentPageState();
}

class _CommentPageState extends State<CommentPage> {
  TopicCommentsModel comment;
  TextEditingController _commentController;
  ScrollController _controller;
  FocusNode _commentFocusNode;
  int currentComment;
  String defaultHint = '喜欢就评论告诉Ta';
  String hintText = '喜欢就评论告诉Ta';
  int pageCount = 2;
  bool hasMore = true;
  List<TopicCommentsModelData> comments = [];
  UserProvider userProvider;
  bool isLoading = true;
  bool canScroll = false;

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
      })
      ..addListener(() {
        // print(_controller.position);
        if (_controller.position.pixels ==
            _controller.position.minScrollExtent) {
          print('to the top....');
          setState(() {
            this.canScroll = false;
          });
        } else if (_controller.position.pixels ==
            _controller.position.maxScrollExtent) {
          print('loadmore');
          if (this.hasMore) {
            getMore(this.pageCount);
          }
        }
      });

    widget.parentController..addListener(this.myListener);
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    _commentController.dispose();
    _commentFocusNode.dispose();
    widget.parentController.removeListener(myListener);
    super.dispose();
  }

  void myListener() {
    if (widget.parentController.position.pixels ==
        widget.parentController.position.maxScrollExtent) {
      print("to the end....");
      setState(() {
        this.canScroll = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      body: Padding(
        padding: EdgeInsets.only(top: 0),
        child: Stack(
          children: <Widget>[
            GestureDetector(
                onTap: () {
                  _commentFocusNode.unfocus();
                },
                child: body),
            Positioned(
              bottom: 10,
              left: 0,
              right: 0,
              child: commentBar(),
            )
          ],
        ),
      ),
    );
  }

  Widget get body {
    Widget child;
    if (this.isLoading) {
      child = Container(
        height: double.infinity,
        alignment: Alignment.center,
        child: CupertinoActivityIndicator(),
      );
    } else {
      child = ListView.builder(
          controller: _controller,
          // shrinkWrap: true,
          physics:
              this.canScroll ? ScrollPhysics() : NeverScrollableScrollPhysics(),
          padding: EdgeInsets.only(bottom: 70, top: kToolbarHeight / 2),
          itemCount: this.comments.length,
          itemBuilder: (context, index) {
            if (this.hasMore) {
              if (index == this.comments.length - 1) {
                return Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: new Center(child: new CircularProgressIndicator()),
                );
              }
            }
            return buildContent(this.comments[index]);
          });
    }
    return child;
  }

  buildContent(TopicCommentsModelData item) {
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

    Widget singleItem = InkWell(
        onLongPress: () => handleDelete(item),
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
                      child: BetterText(
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
                                          color:
                                              Theme.of(context).primaryColor)),
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
                child: BetterText(getTimeString(item.time),
                    style: Theme.of(context).textTheme.body1),
              )
            ],
          ),
        ));

    return singleItem;
  }

  commentBar() {
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
                ? () => commentHandle()
                : null,
            color: Theme.of(context).primaryColor,
            minWidth: ScreenUtil().setWidth(100),
            height: ScreenUtil().setHeight(70),
            shape: StadiumBorder(),
            child: BetterText(
              "发送",
              style: TextStyle(color: Colors.white),
            ),
          )
        ],
      ),
    );
  }

  handleDelete(TopicCommentsModelData item) async {
    if (userProvider.isLogIn) {
      if (userProvider.userInfo.id == item.sender.id) {
        showDialog(
          context: context,
          builder: (_) {
            return AlertDialog(
              title: BetterText("提示"),
              content: BetterText("确认要删除此条回复吗? "),
              actions: <Widget>[
                FlatButton(
                  child: BetterText("取消"),
                  onPressed: () => Navigator.of(context).pop(), // 关闭对话框
                ),
                FlatButton(
                    child: BetterText("删除"),
                    onPressed: () async {
                      FinderDialog.showLoading();
                      var data = await apiClient.deleteTopicComment(
                          commentId: item.id);
                      widget.onDelete(data['status']);
                      if (data['status']) {
                        await getReplies();
                        _controller.animateTo(0,
                            duration: Duration(microseconds: 300),
                            curve: Curves.easeInOut);
                      }
                      Navigator.pop(context);
                    }),
              ],
            );
          },
        );
      }
    }
  }

  Future commentHandle() async {
    String msg = "";
    if (userProvider.isLogIn) {
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
      widget.onComment(data['status']);
      if (data['status'] == true) {
        await getReplies();
        _controller.animateTo(0,
            duration: Duration(microseconds: 300), curve: Curves.easeInOut);
      }

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
    this.comments = [];
    var data = await apiClient.getTopicComments(
        topicId: widget.topicId, page: 1, rootId: widget.topicCommentId);
    TopicCommentsModel topicComment = TopicCommentsModel.fromJson(data);
    // print("reply ==== $data");
    if (!mounted) return;
    setState(() {
      this.comments.addAll(topicComment.topicReplies);
      this.pageCount = 2;
      this.hasMore = topicComment.hasMore;
      this.isLoading = false;
    });
  }

  Future getMore(int pageCount) async {
    var data = await apiClient.getTopicComments(
        topicId: widget.topicId,
        page: pageCount,
        rootId: widget.topicCommentId);
    TopicCommentsModel topicComment = TopicCommentsModel.fromJson(data);

    setState(() {
      this.comments.addAll(topicComment.topicReplies);
      this.pageCount++;
      this.hasMore = topicComment.hasMore;
      this.isLoading = false;
    });
  }
}
