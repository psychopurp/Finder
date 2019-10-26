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
