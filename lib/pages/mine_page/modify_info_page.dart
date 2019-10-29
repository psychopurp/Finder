import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:finder/config/api_client.dart';
import 'package:finder/models/user_model.dart';
import 'package:finder/plugin/avatar.dart';
import 'package:finder/plugin/dialog.dart';
import 'package:finder/provider/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:provider/provider.dart';

class ModifyInfoPage extends StatefulWidget {
  @override
  _ModifyInfoPageState createState() => _ModifyInfoPageState();
}

class _ModifyInfoPageState extends State<ModifyInfoPage> {
  TextEditingController _nicknameController;
  TextEditingController _realNameController;
  TextEditingController _studentIdController;
  TextEditingController _introductionController;
  List<School> schools = [];
  List<School> majors = [];
  static School notSelect = School(id: 0, name: "请选择");
  School selectedSchool = notSelect;
  School selectedMajor = notSelect;
  List<Asset> images = [];
  String avatarUrl = "";
  String avatarRealUrl = "";

  Future<void> getSchools() async {
    String url = 'get_schools/';
    try {
      Dio dio = ApiClient.dio;
      Response response = await dio.get(url);
      Map<String, dynamic> result = response.data;
      if (result["status"]) {
        setState(() {
          schools = [notSelect]..addAll(List<School>.generate(
              result["data"].length,
              (index) => School.fromJson(result["data"][index])));
        });
      }
    } on DioError catch (e) {
      print(e);
      print(url);
      setState(() {
        if (schools == null) {
          schools = [notSelect];
        }
      });
    }
  }

  Future<void> getMajors() async {
    String url = 'get_majors/';
    try {
      Dio dio = ApiClient.dio;
      Response response = await dio.get(url);
      Map<String, dynamic> result = response.data;
      if (result["status"]) {
        setState(() {
          majors = [notSelect]..addAll(List<School>.generate(
              result["data"].length,
              (index) => School.fromJson(result["data"][index])));
        });
      }
    } on DioError catch (e) {
      print(e);
      print(url);
      setState(() {
        if (majors == null) {
          majors = [notSelect];
        }
      });
    }
  }

  Future<void> postData() async {
    String nickname = _nicknameController.value.text.trim();
    if (nickname == "") {
      showErrorHint(context, "请输入用户名");
      return;
    }
    String realName = _realNameController.value.text.trim();
    if (realName == "") {
      showErrorHint(context, "请输入真实姓名");
      return;
    }
    String studentId = _studentIdController.value.text.trim();
    if (studentId == "") {
      showErrorHint(context, "请输入学号");
      return;
    }
    if (selectedSchool.id == 0) {
      showErrorHint(context, "请选择学校");
      return;
    }
    if (selectedMajor.id == 0) {
      showErrorHint(context, "请选择专业");
      return;
    }
    String introduction = _introductionController.value.text.trim();
    String url = 'register_profile/';
    try {
      Dio dio = ApiClient.dio;
      Map<String, dynamic> data = {
        "nickname": nickname,
        "avatar": avatarUrl,
        "introduction": introduction,
        "major": selectedMajor.name,
        "school": selectedSchool.id,
        "student_id": studentId,
        "real_name": realName
      };
      Response response = await dio.post(url, data: json.encode(data));
      Map<String, dynamic> result = response.data;
      if (result["status"]) {
        Provider.of<UserProvider>(context).getData();
        Navigator.of(context).pop();
      } else {
        showErrorHint(context, result["error"]);
      }
    } on DioError catch (e) {
      print(e);
      print(url);
    }
  }

  @override
  void initState() {
    super.initState();
    _nicknameController = TextEditingController();
    _realNameController = TextEditingController();
    _studentIdController = TextEditingController();
    _introductionController = TextEditingController();
    Future.delayed(Duration(milliseconds: 400), (){
      UserModel user = Provider.of<UserProvider>(context).userInfo;
      _nicknameController.text = user.nickname;
      _realNameController.text = user.realName;
      _studentIdController.text = user.studentId;
      _introductionController.text = user.introduction;
      avatarRealUrl = user.avatar;
      getSchools().then((x) {
        getMajors().then((x) {
          schools.forEach((e) {
            if (e.id == user.school.id) {
              selectedSchool = e;
            }
          });
          majors.forEach((e) {
            if (e.name == user.major) {
              selectedMajor = e;
            }
          });
        });
      });
    });
//    showErrorHint(context, "由于本软件属于校园社交软件, 需要实名认证信息, 请务必保证信息的准确性.");
  }

  Widget get avatar => Padding(
        padding: EdgeInsets.only(top: 18.0),
        child: MaterialButton(
          onPressed: () async {
            Future getImage() async {
              var image;
              List<Asset> resultList = List<Asset>();
              try {
                resultList = await MultiImagePicker.pickImages(
                  maxImages: 1,
                  enableCamera: true,
                  selectedAssets: images,
                  cupertinoOptions: CupertinoOptions(takePhotoIcon: "chat"),
                  materialOptions: MaterialOptions(
                    selectionLimitReachedText: '请选择一张图片',
                    textOnNothingSelected: '请至少选择一张图片',
                    actionBarColor: "#000000",
                    statusBarColor: '#999999',
                    actionBarTitle: "相册",
                    allViewTitle: "全部图片",
                    useDetailsView: true,
                    selectCircleStrokeColor: "#000000",
                  ),
                );
              } on Exception catch (e) {
                print(e);
              }
              if (resultList.length != 0) {
                var t = await resultList[0].filePath;
                image = File(t);
              }

              var cropImage = await ImageCropper.cropImage(
                  sourcePath: image.path,
                  aspectRatio: CropAspectRatio(ratioX: 16, ratioY: 16),
                  androidUiSettings: AndroidUiSettings(
                      showCropGrid: false,
                      toolbarTitle: '图片剪切',
                      toolbarColor: Theme.of(context).primaryColor,
                      toolbarWidgetColor: Colors.white,
                      initAspectRatio: CropAspectRatioPreset.original,
                      lockAspectRatio: true),
                  iosUiSettings: IOSUiSettings(
                      minimumAspectRatio: 1.0, aspectRatioLockEnabled: true));
              return cropImage;
            }

            File image = await getImage();
            await imageUpdate(image);
          },
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.circular(60),
            ),
            width: 120,
            height: 120,
            child: UnconstrainedBox(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(59),
                ),
                width: 118,
                height: 118,
                child: avatarRealUrl != ""
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(59),
                        child: Image.network(avatarRealUrl))
                    : Icon(
                        Icons.add,
                        size: 40,
                        color: Theme.of(context).primaryColor,
                      ),
              ),
            ),
          ),
        ),
      );

  imageUpdate(File image) async {
    var imageStr = await apiClient.uploadImage(image);
    if (imageStr == null) {
      showErrorHint(context, "图片上传失败, 请稍后再试");
    }
    setState(() {
      avatarUrl = imageStr;
      imageStr = Avatar.getImageUrl(imageStr);
      avatarRealUrl = imageStr;
    });
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    _introductionController.dispose();
    _studentIdController.dispose();
    _realNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("修改个人信息"),
        centerTitle: true,
        leading: Container(),
        actions: <Widget>[
          MaterialButton(
            onPressed: () {
              postData();
            },
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            child: Icon(
              Icons.check,
              color: Colors.white,
              size: 30,
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          child: Column(
            children: <Widget>[
              Container(
                child: avatar,
              ),
              Padding(
                padding: EdgeInsets.all(20),
              ),
              singleLineTestField(
                  controller: _nicknameController,
                  hint: "请输入昵称",
                  label: "* 昵称"),
              singleLineTestField(
                  controller: _realNameController,
                  hint: "请输入您的真实姓名",
                  label: "* 姓名"),
              singleLineTestField(
                  controller: _studentIdController,
                  hint: "请输入您的学号",
                  label: "* 学号",
                  inputType: TextInputType.numberWithOptions(
                      signed: false, decimal: false)),
              singleLineTestField(
                  controller: _introductionController,
                  hint: "请简单的介绍一下自己吧!(非必填)",
                  label: "简介",
                  maxLine: null,
                  minLine: null,
                  expand: true),
              Selector(
                  onChange: (school) {
                    setState(() {
                      selectedSchool = school;
                    });
                  },
                  schools: schools,
                  selected: selectedSchool,
                  verbose: "选择学校"),
              Selector(
                  onChange: (major) {
                    setState(() {
                      selectedMajor = major;
                    });
                  },
                  schools: majors,
                  selected: selectedMajor,
                  verbose: "选择专业"),
            ],
          ),
        ),
      ),
    );
  }

  Widget singleLineTestField(
      {TextEditingController controller,
      String label,
      String hint,
      bool obscureText = false,
      TextInputType inputType = TextInputType.text,
      int maxLine = 1,
      int minLine = 1,
      bool expand = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: TextField(
        maxLines: maxLine,
        minLines: minLine,
        expands: false,
        obscureText: obscureText,
        keyboardType: inputType,
        cursorColor: Theme.of(context).primaryColor,
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          hintText: hint,
          fillColor: Color.fromARGB(255, 245, 241, 241),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}

typedef FilterChangeCallBack = void Function(School);

class Selector extends StatefulWidget {
  Selector({this.onChange, this.schools, this.selected, this.verbose});

  final FilterChangeCallBack onChange;
  final List<School> schools;
  final School selected;
  final String verbose;

  @override
  _SelectorState createState() => _SelectorState();
}

class _SelectorState extends State<Selector> with TickerProviderStateMixin {
  bool isOpen = false;

  List<School> get _schools => widget.schools;

  School get _selected => widget.selected;

  School _tempSelected;
  AnimationController _animationController;
  AnimationController _rotateController;
  Animation _rotateAnimation;
  Animation _animation;
  Animation _curve;

  double _oldHeight = 0;

  @override
  void initState() {
    super.initState();
    _tempSelected = _selected;
    const Duration duration = Duration(milliseconds: 300);
    _animationController = AnimationController(vsync: this, duration: duration);
    _rotateController = AnimationController(vsync: this, duration: duration);
    _animationController.addListener(() {
      setState(() {});
    });
    _curve =
        CurvedAnimation(parent: _animationController, curve: Curves.easeInOut);
    _animation = Tween<double>(begin: 0, end: 1).animate(_curve);
    _rotateAnimation = Tween<double>(begin: 0, end: pi / 2).animate(
        CurvedAnimation(curve: Curves.easeInOut, parent: _rotateController));
  }

  Future<void> changeHeightTo(height) async {
    double oldHeight = _oldHeight;
    _animationController.reset();
    _animation = Tween<double>(begin: oldHeight, end: height).animate(_curve);
    await _animationController.forward();
    _oldHeight = height;
  }

  Future<void> changeHeight() async {
    int length = _schools.length; // 获取较大的列表长度
    double height = (length / 2).ceil() * 65.0 + 31;
    await changeHeightTo(height);
  }

  @override
  void dispose() {
    super.dispose();
    _animationController.dispose();
    _rotateController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget child;
    child = Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 20),
      margin: EdgeInsets.symmetric(vertical: 5),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              getTag(_selected.name),
              Expanded(
                flex: 1,
                child: Container(),
              ),
              MaterialButton(
                onPressed: () {
                  if (!isOpen) {
                    open();
                  } else {
                    close();
                  }
                },
                minWidth: 10,
                padding: EdgeInsets.symmetric(horizontal: 13),
                child: Row(
                  children: <Widget>[
                    Text(
                      widget.verbose,
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xff444444),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(3),
                    ),
                    Transform.rotate(
                      angle: _rotateAnimation.value,
                      child: Icon(
                        Icons.arrow_forward_ios,
                        size: 11,
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
          Container(
            height: _animation.value,
            padding: EdgeInsets.symmetric(vertical: 10),
            child: SingleChildScrollView(
              physics: NeverScrollableScrollPhysics(),
              child: Column(
                children: <Widget>[
                  Wrap(
                    children: List<Widget>.generate(
                        _schools.length,
                        (index) => GestureDetector(
                              onTap: () {
                                setState(() {
                                  _tempSelected = _schools[index];
                                  (widget.onChange ?? (b) {})(_tempSelected);
                                });
                              },
                              child: getTag(_schools[index].name,
                                  select:
                                      _schools[index].id == _tempSelected.id),
                            )),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      MaterialButton(
                        onPressed: () {
                          close();
                        },
                        child: Text(
                          "取消",
                          style: TextStyle(color: Color(0xff999999)),
                        ),
                        minWidth: 10,
                      ),
                      MaterialButton(
                        textColor: Theme.of(context).primaryColor,
                        onPressed: () {
                          (widget.onChange ?? (b) {})(_tempSelected);
                          close();
                        },
                        child: Text(
                          "确定",
                        ),
                        minWidth: 10,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
    return child;
  }

  Future<void> close() async {
    _rotateController.reverse();
    await changeHeightTo(0.0);
    _tempSelected = _selected;
    isOpen = false;
    setState(() {});
  }

  Future<void> open() async {
    _tempSelected = _selected;
    _rotateController.forward();
    await changeHeight();
    isOpen = true;
  }

  Widget getTag(String tag, {bool select = true}) {
    return Builder(
      builder: (context) {
        return Container(
          margin: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          padding: EdgeInsets.symmetric(vertical: 5, horizontal: 15),
          decoration: BoxDecoration(
              color: !select
                  ? Color.fromARGB(255, 204, 204, 204)
                  : Theme.of(context).accentColor,
              borderRadius: BorderRadius.circular(15)),
          child: Text(
            tag,
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
            ),
          ),
        );
      },
    );
  }
}
