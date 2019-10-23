import 'package:flutter/material.dart';

typedef ListBuildCallBack = Widget Function(int index);

ListView listBuilder(
    List<Widget> preItems, ListBuildCallBack builder, int length) {
  return ListView.builder(
    itemBuilder: (context, index) {
      if (index < preItems.length) {
        return preItems[index];
      } else {
        return builder(index - preItems.length);
      }
    },
    itemCount: preItems.length + length,
    padding: EdgeInsets.all(0),
    physics: AlwaysScrollableScrollPhysics(),
  );
}
