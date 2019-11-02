import 'package:finder/public.dart';
import 'package:flutter/material.dart';

class DropDownTextWidget extends StatefulWidget {
  DropDownTextWidget({@required this.content});

  final String content;

  @override
  _DropDownTextWidgetState createState() => _DropDownTextWidgetState();
}

class _DropDownTextWidgetState extends State<DropDownTextWidget>
    with SingleTickerProviderStateMixin {
  static double lineHeight = 1.4;
  double fontSize = ScreenUtil().setSp(30);
  AnimationController controller;
  Animation animation;
  Tween<double> tween;
  bool isShowMore = false;
  bool isMoreText = false;
  double marginTop = 10;
  int lines;
  double maxHeight;
  Duration _defaultDuration = Duration(milliseconds: 200);
  Curve curve = Curves.easeInOut;
  bool init = false;
  double totalHeight;
  double minHeight;
  WidgetsBinding widgetsBinding;

  @override
  void initState() {
    super.initState();
    maxHeight = 5 * fontSize * lineHeight + marginTop;
    controller = AnimationController(vsync: this, duration: _defaultDuration);
    widgetsBinding=WidgetsBinding.instance;
    lines = 5;
  }

  initAnimation(){
    tween = Tween<double>(begin: maxHeight, end: totalHeight);
    animation =
        tween.animate(CurvedAnimation(curve: curve, parent: controller));
    animation.addListener(() {
      setState(() {
        maxHeight = animation.value;
      });
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget mainContent = Container(
      constraints: init ? BoxConstraints(maxHeight: maxHeight, minHeight: 0) : null,
      margin: EdgeInsets.only(top: marginTop),
      alignment: Alignment.topLeft,
      child: Builder(builder: (context){
        if(!init){
          widgetsBinding.addPostFrameCallback((outContext){
            if(!init){
              totalHeight = context.size.height;
              lines = ((totalHeight) / (fontSize * lineHeight)).round();
//              print("${widget.content.substring(0, 5)}- ${(totalHeight - marginTop) / (fontSize * lineHeight)}");
//              print("${widget.content.substring(0, 5)}- ${totalHeight - marginTop}");
//              print("${widget.content.substring(0, 5)}- ${totalHeight / (fontSize * lineHeight)}");
              if(lines < 5){
                maxHeight = lines * lineHeight * fontSize + marginTop;
              }
              setState(() {
                init = true;
              });
              initAnimation();
            }
          });
        }
        return Text(
          widget.content,
          textAlign: TextAlign.left,
          overflow: TextOverflow.ellipsis,
          maxLines: init ?  isMoreText ? 1000 : 5 : 1000,
          style: TextStyle(fontSize: fontSize, height: lineHeight),
        );
      })
    );
    TextStyle style = TextStyle(fontSize: 13, color: Color(0xFFF0AA89));
    return lines <= 5
        ? mainContent
        : Column(
      children: <Widget>[
        mainContent,
        Container(
          child: InkWell(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            child: isShowMore
                ? Text(
              "收起",
              style: style,
            )
                : Text(
              "查看全文",
              style: style,
            ),
            onTap: () {
              setState(() {
                if (isShowMore) {
                  controller.reverse();
                } else {
                  controller.forward();
                }
                isShowMore = !isShowMore;
                if (!isMoreText) {
                  isMoreText = true;
                }
              });
              if (!isShowMore) {
                Future.delayed(_defaultDuration).then((_) {
                  setState(() {
                    isMoreText = !isMoreText;
                  });
                });
              }
            },
          ),
          width: double.infinity,
          alignment: Alignment.topRight,
        )
      ],
    );
  }
}
