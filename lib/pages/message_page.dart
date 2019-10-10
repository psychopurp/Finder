import 'dart:convert';

import 'package:finder/provider/store.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MessagePage extends StatefulWidget {
  @override
  _MessagePageState createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("消息"),
        elevation: 0,
        centerTitle: true,
      ),
      body: body,
    );
  }

  Widget get body {
//    return ListView.builder(itemBuilder: );
  }
}