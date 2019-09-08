import 'dart:io';

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
  String _image;
  File _imageFile;

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context);
    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          Builder(
            builder: (BuildContext context) {
              return FlatButton(
                onPressed: () async {
                  var imagePath = await user.uploadImage(_imageFile);
                  var data = await user.addTopic(
                    _title,
                    [],
                    imagePath,
                  );
                  String showText =
                      (data['status'] == true) ? '发布话题成功' : '发布失败';
                  if (data['status'] == false) {
                    user.setToken(null);
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
      body: ListView(
        children: <Widget>[
          TextField(
            // maxLines: ,
            maxLength: 100,
            maxLines: 5,
            keyboardType: TextInputType.text,
            decoration: InputDecoration(
              alignLabelWithHint: true,
              border: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.black, width: 1)),
              labelText: '输入内容...',
            ),
            onChanged: (String value) {
              _title = value;
            },
          ),
          FlatButton(
            color: Colors.yellow,
            onPressed: () async {
              var image = await getImage();
              setState(() {
                _imageFile = image;
              });
            },
            child: Text('选择图片'),
          ),
          (_imageFile != null) ? Image.file(_imageFile) : Icon(Icons.gavel),
        ],
      ),
    );
  }

  Future getImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    return image;
  }
}
