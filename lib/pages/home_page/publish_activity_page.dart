import 'dart:io';

import 'package:finder/config/api_client.dart';
import 'package:finder/provider/user_provider.dart';
import 'package:finder/public.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class PublishActivityPage extends StatefulWidget {
  @override
  _PublishActivityPageState createState() => _PublishActivityPageState();
}

class _PublishActivityPageState extends State<PublishActivityPage> {
  String _title;
  String _place;
  // String _poster;
  String _sponser;
  String _description;
  String startTime;
  String endTime;
  DateTime startDateTime;
  DateTime endDateTime;

  ///标签
  List<String> tags = [];

  File _imageFile;

  bool onlyInSchool = false;

  TextEditingController _titleController;
  TextEditingController _tagController;

  @override
  void initState() {
    _tagController = new TextEditingController();
    _titleController = new TextEditingController();

    DateTime time = new DateTime.now();
    startDateTime = time;
    startTime = time.year.toString() +
        '—' +
        time.month.toString() +
        '—' +
        time.day.toString() +
        '▼';
    endTime = "请选择活动结束时间";
    super.initState();
  }

  ///下拉选择活动类型
  final List<DropdownMenuItem> activityTypeItems = [
    DropdownMenuItem(value: '学术讲座', child: Text('学术讲座')),
    DropdownMenuItem(value: '文娱活动', child: Text('文娱活动')),
    DropdownMenuItem(value: '比赛', child: Text('比赛')),
    DropdownMenuItem(value: '约会', child: Text('约会')),
  ];
  var selectedTypeValue;

  @override
  void dispose() {
    _titleController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context);

    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.black),
        backgroundColor: Colors.white,
        title: Text(
          '创建活动',
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        actions: <Widget>[
          Builder(
            builder: (BuildContext context) {
              return FlatButton(
                highlightColor: Theme.of(context).primaryColor.withOpacity(0.1),
                onPressed: () async {
                  publishActivity(user).then((val) {
                    String showText =
                        (val['status'] == true) ? '发布话题成功' : '发布失败';

                    Scaffold.of(context).showSnackBar(new SnackBar(
                      content: new Text("$showText"),
                      action: new SnackBarAction(
                        label: "取消",
                        onPressed: () {},
                      ),
                    ));
                    if (val["status"] == true) {}
                  });
                },
                child: Text(
                  '发布',
                  style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontFamily: "Poppins",
                      fontSize: ScreenUtil().setSp(30)),
                ),
              );
            },
          )
        ],
        // title: Text('Finders'),
        elevation: 0,
      ),
      body: ListView(
        padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(40)),
        children: <Widget>[topPart(), bottomPart(), tag()],
      ),
    );
  }

  topPart() => Container(
        height: ScreenUtil().setHeight(400),
        width: ScreenUtil().setWidth(220),
        // color: Colors.amber,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            uploadImage(),
            Container(
              // color: Colors.amber,
              padding: EdgeInsets.only(left: ScreenUtil().setWidth(50)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  ///活动名称
                  Container(
                    // height: ScreenUtil().setHeight(200),
                    width: ScreenUtil().setWidth(400),
                    // padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        // color: Colors.amber,
                        borderRadius: BorderRadius.circular(20)),
                    child: TextField(
                      // focusNode: passwordNode,
                      onChanged: (String value) => _title = value,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderSide:
                                BorderSide(width: 0, style: BorderStyle.none),
                            borderRadius: BorderRadius.circular(20)),
                        focusedBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(width: 5, style: BorderStyle.none),
                            borderRadius: BorderRadius.circular(20)),
                        hintText: '请输入活动名称',
                        fillColor: Colors.black12,
                        hoverColor: Colors.green,
                        focusColor: Colors.white,
                        filled: true,
                        // prefixIcon: Icon(Icons.person),
                        contentPadding: EdgeInsets.all(7),
                      ),
                    ),
                  ),

                  ///主办方
                  Container(
                    // height: ScreenUtil().setHeight(200),
                    width: ScreenUtil().setWidth(400),
                    padding: EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                        // color: Colors.amber,
                        borderRadius: BorderRadius.circular(20)),
                    child: TextField(
                      // focusNode: passwordNode,
                      onChanged: (String value) => _sponser = value,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderSide:
                                BorderSide(width: 0, style: BorderStyle.none),
                            borderRadius: BorderRadius.circular(20)),
                        focusedBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(width: 5, style: BorderStyle.none),
                            borderRadius: BorderRadius.circular(20)),
                        hintText: '请输入主办方',
                        fillColor: Colors.black12,
                        hoverColor: Colors.green,
                        focusColor: Colors.white,
                        filled: true,
                        // prefixIcon: Icon(Icons.person),
                        contentPadding: EdgeInsets.all(7),
                      ),
                    ),
                  ),

                  ///选择活动类型
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                          height: ScreenUtil().setHeight(70),
                          width: ScreenUtil().setWidth(400),
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                              color: Colors.black12,
                              borderRadius: BorderRadius.circular(20)),
                          child: DropdownButton(
                            hint: Text('请选择活动类型'),
                            items: activityTypeItems,
                            value: this.selectedTypeValue,
                            isExpanded: true,
                            underline: Text(''),
                            onChanged: (t) {
                              setState(() {
                                this.selectedTypeValue = t;
                              });
                            },
                          )),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      );

  bottomPart() => Container(
          // height: ScreenUtil().setHeight(400),
          // color: Colors.cyan,
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          ///选择活动时间
          Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  "活动时间",
                  style: TextStyle(fontSize: ScreenUtil().setSp(30)),
                ),
                Container(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                        color: Colors.black12,
                        borderRadius: BorderRadius.circular(20)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        InkWell(
                          onTap: () {
                            showDatePicker(
                                    locale: Locale('zh'),
                                    context: context,
                                    initialDate: new DateTime.now(),
                                    firstDate: new DateTime.now().subtract(
                                        new Duration(days: 10)), // 减 30 天
                                    lastDate: new DateTime.now()
                                        .add(new Duration(days: 80)))
                                .then((time) {
                              setState(() {
                                startDateTime = time;
                                startTime = time.year.toString() +
                                    '—' +
                                    time.month.toString() +
                                    '—' +
                                    time.day.toString() +
                                    '▼';
                              });
                            });
                          },
                          child: Container(
                            padding: EdgeInsets.all(5),
                            child: Text(startTime),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            showDatePicker(
                                    locale: Locale('zh'),
                                    context: context,
                                    initialDate: new DateTime.now(),
                                    firstDate: new DateTime.now().subtract(
                                        new Duration(days: 10)), // 减 30 天
                                    lastDate: new DateTime.now()
                                        .add(new Duration(days: 180)))
                                .then((time) {
                              setState(() {
                                endDateTime = time;
                                endTime = time.year.toString() +
                                    '—' +
                                    time.month.toString() +
                                    '—' +
                                    time.day.toString() +
                                    '▼';
                              });
                            });
                          },
                          child: Container(
                            padding: EdgeInsets.all(5),
                            child: Text(endTime),
                          ),
                        ),
                      ],
                    )),
              ],
            ),
          ),

          ///活动地点
          Container(
              margin:
                  EdgeInsets.symmetric(vertical: ScreenUtil().setHeight(20)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "活动地点",
                    style: TextStyle(fontSize: ScreenUtil().setSp(30)),
                  ),
                  SizedBox(
                    height: ScreenUtil().setHeight(10),
                  ),
                  Container(
                    child: TextField(
                      // focusNode: passwordNode,
                      onChanged: (String value) => _place = value,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderSide:
                                BorderSide(width: 0, style: BorderStyle.none),
                            borderRadius: BorderRadius.circular(20)),
                        focusedBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(width: 5, style: BorderStyle.none),
                            borderRadius: BorderRadius.circular(20)),
                        hintText: '请输入活动地点',
                        fillColor: Colors.black12,
                        hoverColor: Colors.green,
                        focusColor: Colors.white,
                        filled: true,

                        // prefixIcon: Icon(Icons.person),
                        contentPadding: EdgeInsets.all(10),
                      ),
                    ),
                  )
                ],
              )),

          ///活动详情
          Container(
              margin:
                  EdgeInsets.symmetric(vertical: ScreenUtil().setHeight(20)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "活动详情",
                    style: TextStyle(fontSize: ScreenUtil().setSp(30)),
                  ),
                  SizedBox(
                    height: ScreenUtil().setHeight(10),
                  ),
                  Container(
                    // color: Colors.yellow,

                    child: TextField(
                      maxLines: 5,
                      // focusNode: passwordNode,
                      onChanged: (String value) => _description = value,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderSide:
                                BorderSide(width: 0, style: BorderStyle.none),
                            borderRadius: BorderRadius.circular(20)),
                        focusedBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(width: 5, style: BorderStyle.none),
                            borderRadius: BorderRadius.circular(20)),
                        hintText: '请输入活动详情',
                        fillColor: Colors.black12,
                        hoverColor: Colors.green,
                        focusColor: Colors.white,
                        filled: true,

                        // prefixIcon: Icon(Icons.person),
                        contentPadding: EdgeInsets.all(10),
                      ),
                    ),
                  )
                ],
              )),

          ///报名链接
          Container(
              margin:
                  EdgeInsets.symmetric(vertical: ScreenUtil().setHeight(20)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  RichText(
                    text: TextSpan(
                      text: '报名链接 ',
                      style: TextStyle(color: Colors.black),
                      children: <TextSpan>[
                        TextSpan(
                            text: '选填 ',
                            style: TextStyle(
                                color: Theme.of(context).primaryColor)),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: ScreenUtil().setHeight(10),
                  ),
                  Container(
                    // color: Colors.yellow,

                    child: TextField(
                      maxLines: 1,
                      // focusNode: passwordNode,
                      onChanged: (String value) => _title = value,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderSide:
                                BorderSide(width: 0, style: BorderStyle.none),
                            borderRadius: BorderRadius.circular(20)),
                        focusedBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(width: 5, style: BorderStyle.none),
                            borderRadius: BorderRadius.circular(20)),
                        hintText: '请输入报名链接',
                        fillColor: Colors.black12,
                        hoverColor: Colors.green,
                        focusColor: Colors.white,
                        filled: true,

                        // prefixIcon: Icon(Icons.person),
                        contentPadding: EdgeInsets.all(10),
                      ),
                    ),
                  )
                ],
              )),
        ],
      ));

  tag() {
    String _tag;
    return Container(
      margin: EdgeInsets.symmetric(vertical: ScreenUtil().setHeight(50)),
      // color: Colors.amber,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Container(
                width: ScreenUtil().setWidth(500),
                child: TextField(
                  maxLines: 1,
                  // focusNode: passwordNode,
                  controller: _tagController,
                  onChanged: (String value) => _tag = value,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderSide:
                            BorderSide(width: 0, style: BorderStyle.none),
                        borderRadius: BorderRadius.circular(20)),
                    focusedBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(width: 5, style: BorderStyle.none),
                        borderRadius: BorderRadius.circular(20)),
                    hintText: '添加标签',
                    fillColor: Colors.black12,
                    hoverColor: Colors.green,
                    focusColor: Colors.white,
                    filled: true,
                    // prefixIcon: Icon(Icons.person),
                    contentPadding: EdgeInsets.all(10),
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.add),
                onPressed: () {
                  setState(() {
                    if (_tag != null) {
                      tags.add(_tag.toString());
                      _tagController.clear();
                    }
                  });
                },
              ),
            ],
          ),
          Container(
            // color: Colors.yellow,
            child: Wrap(
              spacing: 5,
              children: tags.map((val) {
                return Chip(
                  onDeleted: () {
                    setState(() {
                      tags.remove(val);
                    });
                  },
                  deleteButtonTooltipMessage: "删除此标签",
                  deleteIconColor: Colors.black38,
                  backgroundColor:
                      Theme.of(context).primaryColor.withOpacity(0.5),
                  labelStyle: TextStyle(color: Colors.white),
                  label: Text(val),
                );
              }).toList(),
            ),
          )
        ],
      ),
    );
  }

  //处理图片部分
  Widget uploadImage() {
    /**
     * 进行上传图片并显示操作
     */
    Future getImage() async {
      var image = await ImagePicker.pickImage(source: ImageSource.gallery);
      return image;
    }

    return Align(
      child: Container(
        // color: Colors.amber,
        padding: EdgeInsets.only(top: ScreenUtil().setHeight(40)),
        child: InkWell(
          onTap: () async {
            var image = await getImage();
            setState(() {
              this._imageFile = image;
            });
          },
          child: (this._imageFile != null)
              ? Container(
                  // margin: EdgeInsets.only(top: ScreenUtil().setHeight(40)),
                  height: ScreenUtil().setHeight(310),
                  width: ScreenUtil().setWidth(220),
                  decoration: BoxDecoration(
                    image: DecorationImage(
                        image: FileImage(this._imageFile), fit: BoxFit.fill),
                  ))
              : Container(
                  // margin: EdgeInsets.only(top: ScreenUtil().setHeight(40)),
                  height: ScreenUtil().setHeight(310),
                  width: ScreenUtil().setWidth(220),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(
                        Icons.add,
                        color: Color(0xFFF0AA89),
                        size: ScreenUtil().setSp(100),
                      ),
                      Text(
                        '上传背景图',
                        style: TextStyle(
                            fontFamily: 'Poppins',
                            color: Color(0xFFF0AA89),
                            fontSize: ScreenUtil().setSp(40)),
                      )
                    ],
                  ),
                  decoration: BoxDecoration(
                      // color: Colors.amber,
                      border: Border.all(color: Color(0xFFF0AA89), width: 1))),
        ),
      ),
    );
  }

  //处理标题部分
  Widget titleForm() {
    return Container(
      margin: EdgeInsets.only(top: 50),
      child: TextFormField(
          onChanged: (val) {
            setState(() {
              this._title = val;
            });
          },
          autofocus: false,
          controller: _titleController,
          decoration: InputDecoration(
              // focusColor: Colors.amber,
              // fillColor: Colors.amber,
              // labelText: 'elyar',
              hintText: '请输出话题标题',
              contentPadding:
                  EdgeInsets.only(top: 20.0, left: 20, right: 10, bottom: 0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20.0),
                // prefixIcon: Icon(Icons.person),
              )),
          // 校验用户名（不能为空）
          validator: (v) {
            return v.trim().isNotEmpty ? null : '话题标题不能为空';
          }),
    );
  }

  Future publishActivity(UserProvider user) async {
    String imagePath = await apiClient.uploadImage(this._imageFile);
    print(startDateTime.month);
    var data = await user.addActivity(
        title: _title,
        place: _place,
        poster: imagePath.split('/')[2],
        description: _description,
        startTime: getTime(
            month: startDateTime.month,
            day: startDateTime.day,
            year: startDateTime.year),
        endTime: getTime(
            month: endDateTime.month,
            day: endDateTime.day,
            year: endDateTime.year),
        categories: tags,
        sponser: _sponser);
    return data;
  }
}
