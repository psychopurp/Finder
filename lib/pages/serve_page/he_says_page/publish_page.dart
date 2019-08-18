import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
// import 'package:flutter_screenutil/flutter_screenutil.dart';

class PublishPage extends StatefulWidget {
  @override
  _PublishPageState createState() => _PublishPageState();
}

class _PublishPageState extends State<PublishPage>
    with SingleTickerProviderStateMixin {
  TabController _tabController;
  File _image;
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void initState() {
    super.initState();
    _tabController = new TabController(vsync: this, length: 3, initialIndex: 1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          MaterialButton(
            onPressed: () {},
            child: Text('发布'),
          )
        ],
        // title: Text('Finders'),
        elevation: 0,
        // centerTitle: true,
        bottom: new TabBar(
          isScrollable: true,
          labelColor: Color(0xff333333),
          tabs: <Widget>[
            new Tab(
              child: Text('     头号说      '),
            ),
            new Tab(
              child: Text('     心动说      '),
            ),
            new Tab(
              child: Text('     对他说      '),
            ),
          ],
          controller: _tabController,
        ),
      ),
      backgroundColor: Theme.of(context).primaryColor.withOpacity(0.95),
      body: new TabBarView(
        controller: _tabController,
        children: <Widget>[touHaoShuo(), xinDongShuo(), duiTaShuo()],
      ),
    );
  }

  ListView xinDongShuo() {
    var nameLess = false;
    return ListView(
      children: <Widget>[
        TextField(
          decoration: InputDecoration(
              // border: UnderlineInputBorder(),
              fillColor: Colors.white,
              filled: true,
              hintText: '输入内容...'),
          maxLines: 12,
          autofocus: false,
        ),
        Container(
          decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: Colors.black12.withOpacity(0)),
                bottom: BorderSide(color: Colors.black12),
              )),
          child: ListTile(
            leading: Icon(
              Icons.arrow_downward,
              color: Colors.black,
            ),
            trailing: Icon(
              Icons.settings,
              color: Colors.blue,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(color: Colors.black12),
              )),
          child: ListTile(
            leading: Text('启用匿名'),
            trailing: Switch(
              value: nameLess,
              onChanged: (val) {
                setState(() {
                  nameLess = val;
                });
                print(nameLess);
              },
              activeColor: Colors.blue,
              activeTrackColor: Colors.green,
              inactiveThumbColor: Colors.white,
              inactiveTrackColor: Colors.white10,
            ),
          ),
        ),
      ],
    );
  }

  ListView touHaoShuo() {
    Future getImage() async {
      var image = await ImagePicker.pickImage(source: ImageSource.gallery);
      // var photo = await ImagePicker.pickImage(source: ImageSource.camera);
      // ImagePicker.pickVideo(source: ImageSource.camera);
      setState(() {
        _image = image;
      });
    }

    var nameLess = false;
    return ListView(
      children: <Widget>[
        TextField(
          decoration: InputDecoration(
              // border: OutlineInputBorder(
              //     borderSide: BorderSide(color: Colors.blue)),
              fillColor: Colors.white,
              filled: true,
              hintText: '输入内容...'),
          maxLines: 12,
          autofocus: false,
        ),
        Container(
          decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(color: Colors.black12),
              )),
          child: ListTile(
            title: Container(
              // color: Colors.blue,
              margin: EdgeInsets.only(
                left: 150,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  InkWell(
                    child: Icon(Icons.add_a_photo),
                    onTap: getImage,
                  ),
                  Icon(Icons.search),
                  Icon(Icons.search),
                  Icon(
                    Icons.settings,
                    color: Colors.blue,
                  ),
                ],
              ),
            ),
            leading: Icon(
              Icons.arrow_downward,
              color: Colors.black,
            ),
            // trailing: Icon(
            //   Icons.settings,
            //   color: Colors.blue,
            // ),
          ),
        ),
        InkWell(
          onTap: () {
            print('object');
          },
          child: Container(
            decoration: BoxDecoration(
                backgroundBlendMode: BlendMode.color,
                color: Colors.white,
                border: Border(
                  // top: BorderSide(color: Colors.black12.withOpacity(0)),
                  bottom: BorderSide(color: Colors.black12),
                )),
            child: ListTile(
              leading: Text('上传背景图'),
              trailing: Icon(
                Icons.arrow_forward_ios,
                // color: Colors.blue,
              ),
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(color: Colors.black12),
              )),
          child: ListTile(
            leading: Text('启用匿名'),
            trailing: Switch(
              value: nameLess,
              onChanged: (val) {
                setState(() {
                  nameLess = val;
                });
                print(nameLess);
              },
              activeColor: Colors.blue,
              activeTrackColor: Colors.green,
              inactiveThumbColor: Colors.white,
              inactiveTrackColor: Colors.white10,
            ),
          ),
        ),
        Center(
          child:
              _image == null ? Text('No image selected.') : Image.file(_image),
        ),
      ],
    );
  }

  ListView duiTaShuo() {
    var nameLess = false;
    return ListView(
      children: <Widget>[
        TextField(
          decoration: InputDecoration(
              // border: UnderlineInputBorder(),
              fillColor: Colors.white,
              filled: true,
              hintText: '输入内容...'),
          maxLines: 12,
          autofocus: false,
        ),
        Container(
          decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: Colors.black12.withOpacity(0.01)),
                bottom: BorderSide(color: Colors.black12),
              )),
          child: ListTile(
            leading: Icon(
              Icons.arrow_downward,
              color: Colors.black,
            ),
            trailing: Icon(
              Icons.settings,
              color: Colors.blue,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(color: Colors.black12),
              )),
          child: ListTile(
            leading: Text('启用匿名'),
            trailing: Switch(
              value: nameLess,
              onChanged: (val) {
                setState(() {
                  nameLess = val;
                });
                print(nameLess);
              },
              activeColor: Colors.blue,
              activeTrackColor: Colors.green,
              inactiveThumbColor: Colors.white,
              inactiveTrackColor: Colors.white10,
            ),
          ),
        ),
      ],
    );
  }
}
