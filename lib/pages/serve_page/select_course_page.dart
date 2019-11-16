import 'package:flutter/material.dart';
import 'package:finder/plugin/better_text.dart';

class SelectCoursePage extends StatefulWidget {
  @override
  _SelectCoursePageState createState() => _SelectCoursePageState();
}

class _SelectCoursePageState extends State<SelectCoursePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          titleSpacing: 8,
          actions: <Widget>[
            Padding(
              padding: EdgeInsets.only(right: 15),
              child: Icon(
                IconData(0xe63e, fontFamily: 'myIcon'),
                color: Colors.black,
              ),
            )
          ],
          title: Container(
            margin: EdgeInsets.only(right: 5),
            height: 30,
            // color: Colors.blue,
            // decoration: BoxDecoration(
            //     border: Border.all(width: 1),
            //     borderRadius: BorderRadius.circular(15)),
            child: TextField(
              onChanged: (text) {
                print(text);
              },
              onSubmitted: (text) {
                print(text + '  submit');
              },
              decoration: InputDecoration(
                  // suffixIcon: Icon(
                  //   Icons.cancel,
                  //   color: Colors.black,
                  // ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: Colors.black,
                  ),
                  contentPadding: EdgeInsets.only(
                      top: 10.0, left: 10, right: 10, bottom: -5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  )),
            ),
          ),
          elevation: 1,
          centerTitle: true,
        ),
        backgroundColor: Theme.of(context).primaryColor.withOpacity(0.95),
        body: Center(
          child: BetterText('home page'),
        ));
  }
}
