import 'package:finder/config/api_client.dart';
import 'package:finder/models/user_model.dart';
import 'package:finder/plugin/avatar.dart';
import 'package:finder/routers/application.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:finder/public.dart';
import 'package:finder/plugin/my_appbar.dart';

///用户信息详情页
class UserProfilePage extends StatefulWidget {
  final int senderId;
  final String heroTag;
  UserProfilePage({this.senderId, this.heroTag});
  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  UserModel user;
  double topPartHeight = 150;
  var cards;

  @override
  void initState() {
    getUserProfile();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print(widget.heroTag);
    return Scaffold(
        body: SafeArea(
            top: false,
            child: Container(
              child: MyAppBar(
                  appbar: AppBar(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                  ),
                  child: (this.user != null)
                      ? Stack(
                          alignment: Alignment.topCenter,
                          fit: StackFit.expand,
                          children: <Widget>[
                            ListView(
                                padding: EdgeInsets.all(0),
                                children: buildBackground(user)),
                            Positioned(
                                left: 0,
                                right: 0,
                                top: topPartHeight * 0.5,
                                child: userCard(user)),
                            Positioned(
                              // left: ScreenUtil().setWidth(0),
                              right: 0,
                              top: topPartHeight * 0.5 - 40,
                              child: avatar(),
                            )
                          ],
                        )
                      : Container(
                          height: double.infinity,
                          alignment: Alignment.center,
                          child: FinderDialog.showLoading(),
                        )),
            )));
  }

  avatar() => Hero(
        tag: widget.heroTag,
        child: Container(
          // margin: EdgeInsets.only(top: ScreenUtil().setHeight(0)),
          height: 90,
          width: 90,
          decoration: BoxDecoration(
              // shape: CircleBorder(),
              border: Border.all(color: Colors.white, width: 3),
              borderRadius: BorderRadius.all(Radius.circular(50)),
              image: DecorationImage(
                  image: CachedNetworkImageProvider(user.avatar))),
        ),
      );

  buildBackground(UserModel user) {
    double cardWidth = 130;

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

    Widget topPart = Container(
      height: topPartHeight,
      decoration: BoxDecoration(color: Theme.of(context).primaryColor),
    );

    content.add(topPart);
    content.add(Container(
      alignment: Alignment.center,
      padding: EdgeInsets.only(top: cardWidth + 10),
      child: Wrap(
        spacing: 12,
        runSpacing: 14,
        children: <Widget>[
          // getCard(cards['topic']),
          // getCard(cards['activity']),
          // getCard(cards['toHeSay']),
          // getCard(cards['message'])
        ],
      ),
    ));

    return content;
  }

  Widget userCard(UserModel user) {
    return Card(
        margin: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(100)),
        color: Colors.white,
        elevation: 10,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Container(
          padding: EdgeInsets.only(bottom: 15, top: 50),
          width: ScreenUtil().setWidth(750),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              ///昵称
              Text(
                user.nickname,
                style: TextStyle(color: Colors.black, fontSize: 20),
              ),

              ///学校专业
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text((user.school != null) ? user.school.name : "家里蹲大学"),
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

  getUserProfile() async {
    var data = await apiClient.getOtherProfile(userId: widget.senderId);
    UserModel userModel = UserModel.fromJson(data['data']);
    print(data);

    if (!mounted) return;
    setState(() {
      this.user = userModel;
    });
  }
}
