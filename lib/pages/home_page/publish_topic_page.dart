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

  GlobalKey _formKey = new GlobalKey<FormState>();
  TextEditingController _titleController = new TextEditingController();
  // TextEditingController _pwdController = new TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    // _pwdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('发布话题'),
        centerTitle: true,
        actions: <Widget>[
          Builder(
            builder: (BuildContext context) {
              return FlatButton(
                onPressed: () async {
                  var imagePath = await apiClient.uploadImage(_imageFile);
                  var data = await user.addTopic(
                    _title,
                    [],
                    imagePath,
                  );
                  String showText =
                      (data['status'] == true) ? '发布话题成功' : '发布失败';
                  if (data['status'] == false) {
                    // user.setToken(null);
                    Application.router.navigateTo(context, '/login');
                  }
                  Scaffold.of(context).showSnackBar(new SnackBar(
                    content: new Text("$showText"),
                    action: new SnackBarAction(
                      label: "取消",
                      onPressed: () {},
                    ),
                  ));
                },
                child: Text('发布'),
              );
            },
          )
        ],
        // title: Text('Finders'),
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        autovalidate: true,
        child: ListView(
          padding: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(40)),
          children: <Widget>[
            uploadImage(),
            titleForm(),
          ],
        ),
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
                            fontSize: ScreenUtil().setSp(50)),
                      )
                    ],
                  ),
                  decoration: BoxDecoration(
                      // color: Colors.amber,
                      border: Border.all(color: Color(0xFFF0AA89), width: 1)))),
    );
  }

  Widget titleForm() {
    return Container(
      // color: Colors.amber,
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
                  EdgeInsets.only(top: 20.0, left: 10, right: 10, bottom: 0),
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
}
