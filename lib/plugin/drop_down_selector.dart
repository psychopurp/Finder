import 'dart:math';

import 'package:finder/plugin/better_text.dart';
import 'package:flutter/material.dart';

class DropDownItem {
  String name;
  int id;
}

typedef DropDownSelectorCallBack<T extends DropDownItem> = void Function(T);

class DropDownSelector<T extends DropDownItem> extends StatefulWidget {
  DropDownSelector(
      {this.onChange,
      this.nowType,
      this.types,
      this.changeOnSelect = false,
      this.search = false,
      this.verbose = "修改分类",
      Key key})
      : super(key: key);

  final DropDownSelectorCallBack onChange;
  final List<T> types;
  final T nowType;
  final bool changeOnSelect;
  final bool search;
  final String verbose;

  @override
  _DropDownSelectorState createState() => _DropDownSelectorState();
}

class _DropDownSelectorState extends State<DropDownSelector>
    with TickerProviderStateMixin {
  bool isOpen = false;

  List<DropDownItem> get _allTypes => widget.types;
  List<DropDownItem> _types;

  DropDownItem get _nowType => widget.nowType;

  DropDownItem _tempType;
  AnimationController _animationController;
  AnimationController _rotateController;
  Animation _rotateAnimation;
  Animation _animation;
  Animation _curve;

  TextEditingController _searchController;
  FocusNode _focusNode;

  double _oldHeight = 0;
  double _totalHeight;
  bool init = false;
  WidgetsBinding widgetsBinding;
  int lastChangeTime;
  bool focusLock = false;
  bool onSearch = false;
  bool closing = false;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    widgetsBinding = WidgetsBinding.instance;
    _tempType = _nowType;
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
    _types = [];
    _allTypes.forEach((e) => _types.add(e));
    _focusNode = FocusNode();
    _focusNode.addListener(() {
//      print("focus: ${_focusNode.hasFocus}");
//      print("focusLock: $focusLock");
      if (_focusNode.hasFocus) {
        if (!focusLock) {
          focusLock = true;
          setState(() {
            onSearch = true;
            _focusNode.unfocus();
            Future.delayed(Duration(milliseconds: 100), () {
              _focusNode.requestFocus();
            });
          });
        } else {
          focusLock = false;
        }
      } else {
        if (!focusLock) {
          onSearch = false;
          Future.delayed(Duration(milliseconds: 60), () {
            if (!closing) changeHeight();
          });
        }
      }
    });
  }

  Future<void> changeHeightTo(height) async {
    double oldHeight = _oldHeight;
    _animationController.reset();
    _animation = Tween<double>(begin: oldHeight, end: height).animate(_curve);
    await _animationController.forward();
    _oldHeight = height;
  }

  Future<void> changeHeight() async {
    await changeHeightTo(_totalHeight);
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
      height: init ? null : 48,
      padding: EdgeInsets.symmetric(horizontal: 20),
      margin: EdgeInsets.symmetric(vertical: 5),
      child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                getTag(_nowType.name),
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
                      BetterText(
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
            Builder(builder: (context) {
              if (!init) {
                widgetsBinding.addPostFrameCallback((outContext) {
                  if (!init) {
                    try{
                      _totalHeight = context.size.height;
                      setState(() {
                        init = true;
                      });
                    }on Exception catch(e){
                      print("DropDownSelector");
                      print(e);
                    }
                  }
                });
              }
              if (onSearch) {
                Future.delayed(Duration(milliseconds: 50), () {
                  _totalHeight = context.size.height;
                });
              }
              List<Widget> children = <Widget>[
                Wrap(
                  children: List<Widget>.generate(
                      _types.length,
                      (index) => GestureDetector(
                            onTap: () {
                              setState(() {
                                _tempType = _types[index];
                                if (widget.changeOnSelect) {
                                  (widget.onChange ?? (b) {})(_tempType);
                                }
                              });
                            },
                            child: getTag(_types[index].name,
                                select: _types[index].id == _tempType.id),
                          )),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    MaterialButton(
                      onPressed: () {
                        close();
                      },
                      child: BetterText(
                        "取消",
                        style: TextStyle(color: Color(0xff999999)),
                      ),
                      minWidth: 10,
                    ),
                    MaterialButton(
                      textColor: Theme.of(context).primaryColor,
                      onPressed: () {
                        (widget.onChange ?? (b) {})(_tempType);
                        close();
                      },
                      child: BetterText(
                        "确定",
                      ),
                      minWidth: 10,
                    ),
                  ],
                ),
              ];
              if (widget.search)
                children.insert(
                  0,
                  Container(
                    height: 50,
                    margin: EdgeInsets.symmetric(vertical: 5),
                    child: TextField(
                      focusNode: _focusNode,
                      expands: false,
                      keyboardType: TextInputType.text,
                      cursorColor: Theme.of(context).primaryColor,
                      controller: _searchController,
                      onEditingComplete: () {
                        _focusNode.unfocus();
                      },
                      onChanged: (value) {
                        setState(() {
                          _types = [];
                          _allTypes.forEach((e) {
                            if (e.name.contains(value)) {
                              _types.add(e);
                            }
                          });
                        });
                      },
                      decoration: InputDecoration(
                        labelText: "筛选",
                        filled: true,
                        hintText: "输入文字, 搜索搜索!",
                        fillColor: Color.fromARGB(255, 245, 241, 241),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                );
              return Container(
                height: !init || onSearch ? null : _animation.value,
                padding: EdgeInsets.symmetric(vertical: 10),
                child: SingleChildScrollView(
                  physics: NeverScrollableScrollPhysics(),
                  child: Column(children: children),
                ),
              );
            }),
          ],
        ),
        physics: NeverScrollableScrollPhysics(),
      ),
    );
    return child;
  }

  Future<void> close() async {
    closing = true;
    if (_focusNode.hasFocus) {
      _focusNode.unfocus();
      setState(() {
        onSearch = false;
      });
    }
    _rotateController.reverse();
    await changeHeightTo(0.0);
    _tempType = _nowType;
    isOpen = false;
    closing = false;
    setState(() {});
  }

  Future<void> open() async {
    if (_focusNode.hasFocus) {
      _focusNode.unfocus();
      setState(() {
        onSearch = false;
      });
    }
    _tempType = _nowType;
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
          child: BetterText(
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
