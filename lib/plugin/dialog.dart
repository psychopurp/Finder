import 'package:flutter/material.dart';

///一些自己实现的dialog

class FinderDialog {
  ///载入框
  static Widget showLoading() => Center(
        child: Container(
          height: 65,
          width: 65,
          padding: EdgeInsets.all(15),
          child: CircularProgressIndicator(
            backgroundColor: Colors.white,
          ),
          decoration: BoxDecoration(
            color: Colors.black54,
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
}

void showErrorHint(BuildContext context, String text) {
  showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("提示"),
          content: Text(text),
          actions: <Widget>[
            FlatButton(
              child: Text("确认"),
              onPressed: () => Navigator.of(context).pop(), //关闭对话框
            ),
          ],
        );
      });
}
