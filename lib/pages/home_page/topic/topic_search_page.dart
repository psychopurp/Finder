import 'package:cached_network_image/cached_network_image.dart';
import 'package:finder/config/api_client.dart';
import 'package:finder/models/topic_model.dart';
import 'package:finder/routers/application.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_easyrefresh/material_footer.dart';
import 'package:finder/pages/home_page/more_topics.dart' show ImageItem;

class TopicSearchPage extends StatefulWidget {
  @override
  _TopicSearchPageState createState() => _TopicSearchPageState();
}

class _TopicSearchPageState extends State<TopicSearchPage> {
  List<TopicModelData> topics = [];
  bool loading = true;
  bool hasMore = true;
  bool isSearch = false;

  EasyRefreshController _refreshController;
  TextEditingController _controller;
  static const int ONSEARCH = 0;
  static const int NOTDOING = 1; //什么都不做
  int curruntState = -1;
  int pageCount = 2;

  // static cosnt int

  @override
  void initState() {
    _refreshController = EasyRefreshController();
    _controller = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _refreshController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
        // centerTitle: true,
        automaticallyImplyLeading: false,
        title: TextField(
          controller: _controller,
          cursorColor: Theme.of(context).primaryColor, //设置光标
          decoration: InputDecoration(
              //输入框decoration属性
              contentPadding: EdgeInsets.only(top: 15),
              // contentPadding: new EdgeInsets.only(left: 0.0),
              fillColor: Theme.of(context).dividerColor,
              filled: true,
              border: InputBorder.none,
              prefixIcon: IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: Icon(Icons.arrow_back, color: Colors.black),
              ),
              suffixIcon: IconButton(
                  icon: Icon(Icons.search, color: Colors.black),
                  onPressed: () {
                    if (this.curruntState == ONSEARCH) {
                      this.topics.clear();
                      this.loading = true;
                    }
                    getData();
                    setState(() {});
                  }),
              hintText: "来搜搜你喜欢的话题..",
              hintStyle: new TextStyle(fontSize: 14, color: Colors.black45)),
          style: new TextStyle(fontSize: 14, color: Colors.black),
        ),
      ),
      body: body,
    );
  }

  Widget get body {
    Widget child;
    switch (this.curruntState) {
      case NOTDOING:
        child = Container();
        break;
      case ONSEARCH:
        if (loading) {
          child = Container(
              alignment: Alignment.center,
              height: double.infinity,
              child: CupertinoActivityIndicator());
        } else {
          child = EasyRefresh.custom(
            enableControlFinishLoad: true,
            footer: MaterialFooter(),
            controller: _refreshController,
            onLoad: () async {
              await Future.delayed(Duration(milliseconds: 500), () {
                getMore(pageCount: this.pageCount);
              });
              _refreshController.finishLoad(
                  success: true, noMore: (!this.hasMore));
            },
            // scrollController: _scrollController,
            slivers: <Widget>[
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    return buildTopicsList(this.topics[index]);
                  },
                  childCount: this.topics.length,
                ),
              ),
            ],
          );
        }
        break;
      default:
    }

    return child;
  }

  buildTopicsList(TopicModelData item) {
    Widget child;
    child = CachedNetworkImage(
      key: ValueKey(item.image + item.title),
      imageUrl: item.image,
      imageBuilder: (context, imageProvider) {
        return ImageItem(
          item: item,
          imageProvider: imageProvider,
          onTap: () {
            Application.router.navigateTo(context,
                '/home/topicDetail?id=${item.id.toString()}&title=${Uri.encodeComponent(item.title)}&image=${Uri.encodeComponent(item.image)}');
          },
          key: ValueKey(item.image),
        );
      },
      errorWidget: (context, url, error) => Icon(Icons.error),
    );

    return child;
  }

  Future getData() async {
    String query = (_controller.text != null || _controller.text != "")
        ? _controller.text
        : "";
    // print(query);
    var data = await apiClient.getTopics(query: query, page: 1);
    // print(data);
    TopicModel topics = TopicModel.fromJson(data);

    setState(() {
      this.topics.addAll(topics.data);
      this.curruntState = ONSEARCH;
      this.loading = false;
      this.hasMore = topics.hasMore;
    });
  }

  Future getMore({int pageCount}) async {
    String query = _controller.text ?? "";
    var data = await apiClient.getTopics(query: query, page: pageCount);
    TopicModel topics = TopicModel.fromJson(data);

    setState(() {
      this.topics.addAll(topics.data);
      this.pageCount = this.pageCount + 1;
      this.curruntState = ONSEARCH;
      this.loading = false;
      this.hasMore = topics.hasMore;
    });
  }
}
