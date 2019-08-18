import 'package:flutter/material.dart';
// import 'package:flutter/painting.dart';
// import 'package:movie_pro/public.dart';
// import 'home_page/top_news_banner.dart';
// import 'home_page/now_playing_movie.dart';
// import 'package:flutter/cupertino.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Finders'),
          elevation: 0,
          centerTitle: true,
        ),
        backgroundColor: Color.fromRGBO(0, 0, 0, 0.03),
        body: Center(
          child: Text('home page'),
        ));
  }
}
