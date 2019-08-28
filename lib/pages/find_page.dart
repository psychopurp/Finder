import 'package:finder/public.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:finder/provider/user_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:finder/model/user_model.dart';

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
                    Text(user.token),
                    Text(user.userInfo.phone),
                    Text(user.userInfo.nickname),
                    Text(user.userInfo.introduction),
                    Text(user.userInfo.birthday),
                    CachedNetworkImage(
                      imageUrl: user.userInfo.avatar,
                    ),
                    FlatButton(
                        child: Text('image'),
                        onPressed: () async {
                          var image = await getImage();
                          var imagePath = await user.uploadImage(image);
                          // user.upLoadUserProfile(new UserModel(
                          //   nickname: 'Elyar',
                          //   school: '南开大学',
                          //   major: '计算机',
                          //   birthday: getTime(year: 2019, month: 8, day: 5),
                          //   phone: '15522005019',
                          //   introduction: 'this is elyar',
                          //   avatar: imagePath,
                          // ));
                        })
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
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    return image;
  }
}
