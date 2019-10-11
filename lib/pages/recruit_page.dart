import 'package:finder/config/api_client.dart';
import 'package:finder/config/global.dart';
import 'package:finder/models/recruit_model.dart';
import 'package:finder/public.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_easyrefresh/material_footer.dart';
import 'package:flutter_easyrefresh/material_header.dart';
import 'package:finder/pages/recruit_page/recruit_search_page.dart';
import 'package:image_cropper/image_cropper.dart';

class RecruitPage extends StatefulWidget {
  @override
  _RecruitPageState createState() => _RecruitPageState();
}

class _RecruitPageState extends State<RecruitPage> {
  RecruitModel recruits;
  RecruitTypesModel recruitTypes;
  EasyRefreshController _refreshController;

  List<int> selectedTypeList = [];

  @override
  void initState() {
    _refreshController = EasyRefreshController();
    recruitTypes = global.recruitTypes;
    getRecruitsData();
    super.initState();
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            '招募 · 寻你',
            style: TextStyle(color: Colors.black),
          ),
          elevation: 0,
          centerTitle: true,
          actions: <Widget>[
            Padding(
              padding: EdgeInsets.symmetric(vertical: 14, horizontal: 10),
              child: MaterialButton(
                onPressed: () {
                  showSearch(
                      context: context, delegate: RecruitSearchDelegate());
                },
                color: Theme.of(context).dividerColor,
                minWidth: ScreenUtil().setWidth(130),
                padding: EdgeInsets.only(right: 25),
                // color: ActionColor,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                child: Icon(Icons.search),
              ),
            )
          ],
        ),
        // backgroundColor: Color.fromRGBO(0, 0, 0, 0.03),
        body: (this.recruits != null)
            ? Container(
                color: Colors.white.withOpacity(0.1),
                child: Column(
                  children: <Widget>[
                    topTypesBanner(),
                    SizedBox(
                      height: ScreenUtil().setHeight(10),
                    ),
                    recruitContent(),
                  ],
                ),
              )
            : Center(
                child: CupertinoActivityIndicator(),
              ));
  }

  ///招募类型
  topTypesBanner() => Container(
        width: ScreenUtil().setWidth(750),
        height: ScreenUtil().setHeight(250),
        // color: Colors.green,
        decoration: BoxDecoration(color: Colors.white, boxShadow: [
          BoxShadow(
              color: Colors.black12,
              offset: Offset(0.5, 1),
              blurRadius: 2,
              spreadRadius: 1)
        ]),
        padding: EdgeInsets.only(left: 20, right: 10, top: 5),
        child: SingleChildScrollView(
          child: Wrap(
            spacing: 10,
            children: this.recruitTypes.data.map((val) {
              return InkWell(
                  onTap: () {
                    setState(() {
                      this.selectedTypeList.add(val.id);
                    });
                  },
                  child: (this.selectedTypeList.contains(val.id))
                      ? Chip(
                          backgroundColor: Colors.blue,
                          onDeleted: () {
                            setState(() {
                              this.selectedTypeList.remove(val.id);
                            });
                          },
                          label: Text(
                            val.name,
                            style: TextStyle(color: Colors.white),
                          ))
                      : Chip(
                          backgroundColor: Theme.of(context).primaryColor,
                          label: Text(
                            val.name,
                            style: TextStyle(color: Colors.white),
                          )));
            }).toList(),
          ),
        ),
      );

  ///招募内容
  recruitContent() => Container(
      // color: Colors.amber,
      height: ScreenUtil().setHeight(790),
      width: ScreenUtil().setWidth(750),
      child: EasyRefresh(
          enableControlFinishLoad: true,
          header: MaterialHeader(),
          footer: MaterialFooter(),
          controller: _refreshController,
          onRefresh: () async {
            await Future.delayed(Duration(seconds: 1), () {
              setState(() {});
            });
          },
          onLoad: () async {
            // var data = await _getMore(this.pageCount);
            // _refreshController.finishLoad(
            //     success: true, noMore: (data.length == 0));
          },
          child: ListView(
            children: this.recruits.data.map((item) {
              return _singleItem(item);
            }).toList(),
          )));

  Widget _singleItem(RecruitModelData recruit) {
    return Align(
      child: InkWell(
        onTap: () {},
        child: Container(
          // height: ScreenUtil().setHeight(450),
          margin: EdgeInsets.only(top: ScreenUtil().setHeight(20)),
          width: ScreenUtil().setWidth(600),
          decoration: BoxDecoration(
              // color: Colors.cyan,
              border: Border(
                  bottom: BorderSide(color: Theme.of(context).dividerColor))),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                recruit.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: ScreenUtil().setSp(32)),
              ),
              SizedBox(
                height: ScreenUtil().setHeight(10),
              ),
              Text(
                recruit.sender.nickname,
                style: TextStyle(fontSize: ScreenUtil().setSp(30)),
              ),
              SizedBox(
                height: ScreenUtil().setHeight(20),
              ),
              Text(
                recruit.introduction,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: ScreenUtil().setSp(25)),
              ),
              Align(
                alignment: Alignment.bottomRight,
                child: Container(
                  margin: EdgeInsets.only(
                    top: ScreenUtil().setHeight(20),
                    bottom: ScreenUtil().setHeight(20),
                  ),
                  padding: EdgeInsets.all(7),
                  decoration: BoxDecoration(
                      // color: Colors.amber,
                      border: Border.all(color: Color(0xFFF0AA89)),
                      borderRadius: BorderRadius.all(Radius.circular(20))),
                  child: Text(
                    "  详情  ",
                    style: TextStyle(
                        fontSize: ScreenUtil().setSp(22),
                        color: Color(0xFFF0AA89)),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Future getRecruitsData({int pageCount = 1, List<int> typesId}) async {
    var formData = {
      'recruits': await apiClient.getRecruits(),
    };
    if (!mounted) return;
    setState(() {
      this.recruits = RecruitModel.fromJson(formData['recruits']);
    });
  }

  Future getMore({int pageCount = 1, List<int> typesId}) async {
    var formData = {
      'recruits': await apiClient.getRecruits(),
    };
    if (!mounted) return;
    // if(typesId!=null){
    //   this.recruits.data.clear();
    // }
    // for (var typeId in typesId) {
    //   var recruitsData =
    //       await apiClient.getRecruits(page: pageCount, typeId: typeId);
    //   RecruitModel recruits = RecruitModel.fromJson(recruitsData);
    //   this.recruits.data.addAll(recruits.data);
    // }

    setState(() {
      this.recruits = RecruitModel.fromJson(formData['recruits']);
    });
  }
}
