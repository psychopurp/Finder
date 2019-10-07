import 'dart:io';

import 'package:finder/config/api_client.dart';
import 'package:finder/routers/application.dart';
import 'package:flutter/material.dart';
import 'package:finder/public.dart';
import 'package:finder/provider/user_provider.dart';
import 'package:provider/provider.dart';

class PublishTopicPage extends StatefulWidget {
  @override
  _PublishTopicPageState createState() => _PublishTopicPageState();
}

class _PublishTopicPageState extends State<PublishTopicPage> {
  String _title;
  File _imageFile;

  ///标签
  List<String> tags = [];

  bool onlyInSchool = false;

  TextEditingController _titleController = new TextEditingController();
  TextEditingController _tagController = new TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context);

    //仅本校可见部分
    var onlySchool = Container(
      margin: EdgeInsets.only(top: 20),
      child: ListTile(
        title: Text("仅本校可见"),
        trailing: Switch(
          activeTrackColor: Theme.of(context).primaryColor,
          activeColor: Colors.white,
          value: onlyInSchool,
          onChanged: (isSelect) {
            setState(() {
              this.onlyInSchool = isSelect;
            });
          },
        ),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.black),
        backgroundColor: Colors.white,
        title: Text(
          '创建话题',
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
                  publishTopic(user).then((val) {
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
        children: <Widget>[uploadImage(), titleForm(), onlySchool, tag()],
      ),
    );
  }

  ///标签
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
      child: InkWell(
          onTap: () async {
            var image = await getImage();
            setState(() {
              this._imageFile = image;
            });
          },
          child: (this._imageFile != null)
              ? Container(
                  margin: EdgeInsets.only(top: ScreenUtil().setHeight(40)),
                  height: ScreenUtil().setHeight(300),
                  width: ScreenUtil().setWidth(710),
                  decoration: BoxDecoration(
                    image: DecorationImage(
                        image: FileImage(this._imageFile), fit: BoxFit.fill),
                  ))
              : Container(
                  margin: EdgeInsets.only(top: ScreenUtil().setHeight(40)),
                  height: ScreenUtil().setHeight(300),
                  width: ScreenUtil().setWidth(710),
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
                      border: Border.all(color: Color(0xFFF0AA89), width: 1)))),
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

  Future publishTopic(UserProvider user) async {
    var imagePath = await apiClient.uploadImage(this._imageFile);
    var data = await user.addTopic(this._title, this.tags, imagePath,
        schoolId: this.onlyInSchool ? user.userInfo.school.id : null);
    return data;
  }
}
