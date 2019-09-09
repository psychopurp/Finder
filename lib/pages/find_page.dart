import 'package:finder/public.dart';
import 'package:flutter/material.dart';
import 'package:finder/routers/application.dart';

import 'package:provider/provider.dart';
import 'package:finder/provider/user_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:dio/dio.dart';

class FindPage extends StatefulWidget {
  @override
  _FindPageState createState() => _FindPageState();
}

class _FindPageState extends State<FindPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('招募'),
          elevation: 0,
          centerTitle: true,
        ),
        backgroundColor: Color.fromRGBO(0, 0, 0, 0.03),
        body: Center(
          child: Consumer<UserProvider>(
            builder: (context, user, child) {
              if (user.isLogIn) {
                return ListView(
                  children: <Widget>[
                    RaisedButton(
                      // color: Colors.amber,
                      onPressed: () {
                        Application.router.navigateTo(context, '/publishTopic');
                      },
                      child: Text('发布话题'),
                    ),
                    Container(
                      height: ScreenUtil().setHeight(200),
                      color: Colors.amber,
                      child: Text('测试页！！'),
                    ),

                    // Text(user.userInfo.phone),
                    // Text(user.userInfo.nickname),
                    // Text(user.userInfo.introduction),
                    // Text(user.userInfo.birthday),
                    // CachedNetworkImage(
                    //   imageUrl: user.userInfo.avatar,
                    // ),
                    // FlatButton(
                    //     child: Text('image'),
                    //     onPressed: () async {
                    //       // var image = await getImage();
                    //       // var imagePath = await user.uploadImage(image);
                    //       // user.addTopic('我来测试了', ['计算机'], imagePath);
                    //       var data = await user.getFollowUsers();
                    //       print(data);
                    //     }),
                    // RaisedButton(
                    //   child: Text('test'),
                    //   onPressed: () async {
                    //     var image = await getImage();
                    //     var data = await uploadImage(image: image);
                    //     // print(data);
                    //   },
                    // )
                  ],
                );
              } else {
                return RaisedButton(
                    onPressed: () =>
                        user.login(phone: '15522005019', password: '3306'));
              }
            },
          ),
        ));
  }

  Future getImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.camera);
    return image;
  }

  Future uploadImage({File image}) async {
    var dio = new Dio();
    String path = image.path;
    var name = path.substring(path.lastIndexOf('/') + 1);
    print('图片名===========>$name');
    var formData = new FormData.from({
      'sender': 'Elyar',
      'title': 'image test',
      'poster': new UploadFileInfo(image, name,
          contentType: ContentType.parse('multipart/form-data'))
    });
    var data = {'sender': 'Elyar', 'title': 'image test'};

    try {
      Response response =
          await dio.post('http://192.168.80.1:8000/activity/', data: formData);
      print('respose==========>${response.data}');
      // print(ApiClient.host + response.data['url']);
      return response.data;
    } catch (e) {
      print('上传图片错误==========>$e');
    }
  }
}
