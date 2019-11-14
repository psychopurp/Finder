import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Sudoku extends StatefulWidget {
  @override
  _SudokuState createState() => _SudokuState();
}

class _SudokuState extends State<Sudoku> {
  static double outMargin = 5;
  static double margin = 10;
  double width = (min(ScreenUtil.screenWidthDp, ScreenUtil.screenHeightDp) -
          2 * margin -
          2 * outMargin) /
      9;

  List<List<int>> numbers;

  List<int> _rest(int i, int j) {
    List<bool> pos = List<bool>.generate(9, (i) => false);
    for (int n = 0; n < 9; n++) {
      if (numbers[n][j] != null) {
        pos[numbers[n][j]] = true;
      }
      if (numbers[i][n] != null) {
        pos[numbers[i][n]] = true;
      }
    }

    int blockI = i ~/ 3;
    int blockJ = j ~/ 3;

    for (int n = blockI * 3; n < blockI * 3 + 3; n++) {
      for (int m = blockJ * 3; m < blockJ * 3 + 3; m++) {
        if (numbers[n][m] != null) {
          pos[numbers[n][m]] = true;
        }
      }
    }

    List<int> res = [];
    for (int n = 0; n < 9; n++) {
      if (!pos[n]) {
        res.add(n);
      }
    }
    return res;
  }

  void createSudoku() {
    Random random = Random();
    numbers =
        List<List<int>>.generate(9, (i) => List<int>.generate(9, (j) => null));
    List<_ListData> restStack = [];
    for (int i = 0; i < 9; i++) {
      for (int j = 0; j < 9; j++) {
        List<int> rest;
        if (restStack.length > 0 &&
            restStack.last.i == i &&
            restStack.last.j == j) {
          rest = restStack.last.data;
          restStack.removeLast();
        } else {
          rest = _rest(i, j);
        }
        if (rest.length != 0) {
          int randomIndex = random.nextInt(rest.length);
          numbers[i][j] = rest[randomIndex];
          rest.removeAt(randomIndex);
          restStack.add(_ListData(i, j, rest));
        } else {
          numbers[i][j] = null;
          j -= 2;
          if (j < -1) {
            j = 7;
            i -= 1;
          }
          numbers[i][j + 1] = null;
        }
      }
    }
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    createSudoku();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("数独"),
      ),
      body: Column(
        children: <Widget>[
          Container(
            width: double.infinity,
            child: Stack(
              children: <Widget>[
                Container(
                  margin: EdgeInsets.all(margin + outMargin - 4),
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.black, width: 1)),
                  child: Row(
                    children: List.generate(
                      3,
                      (i) => Column(
                        children: List.generate(
                          3,
                          (j) => Container(
                            decoration: BoxDecoration(
                                border:
                                    Border.all(color: Colors.black, width: 1)),
                            child: Row(
                              children: List.generate(
                                3,
                                (n) => Column(
                                  children: List.generate(
                                    3,
                                    (m) => Container(
                                      width: width,
                                      height: width,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                            color: Colors.black, width: 1),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.all(margin + outMargin),
                  child: Row(
                    children: List<Widget>.generate(
                      9,
                      (i) => Column(
                        children: List<Widget>.generate(
                          9,
                          (j) => GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () async {},
                            child: Container(
                              alignment: Alignment.center,
                              width: width,
                              height: width,
                              child: Text("${numbers[i][j]}"),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
          RaisedButton(
            child: Text("刷新"),
            onPressed: () {
              createSudoku();
            },
          ),
        ],
      ),
    );
  }
}

class _ListData {
  _ListData(this.i, this.j, this.data);

  int i;
  int j;
  List<int> data;
}
