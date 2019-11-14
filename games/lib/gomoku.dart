import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Gomoku extends StatefulWidget {
  @override
  _GomokuState createState() => _GomokuState();
}

class _GomokuState extends State<Gomoku> {
  List<List<bool>> ground;
  int round = 0;
  static double outMargin = 5;
  static double margin = 10;
  bool robot = false;
  List<List<int>> judgeGround =
      List<List<int>>.generate(15, (i) => List<int>.generate(15, (j) => 0));

  double totalWidth =
      min(ScreenUtil.screenWidthDp, ScreenUtil.screenHeightDp) - 2 * outMargin;
  double width = (min(ScreenUtil.screenWidthDp, ScreenUtil.screenHeightDp) -
          2 * margin -
          2 * outMargin) /
      15;
  double scaleMargin;

  bool isWin() {
    bool color = round % 2 != 0;
    for (int i = 0; i < 15; i++) {
      for (int j = 0; j < 15; j++) {
        if (ground[i][j] == color) {
          bool flag = true;
          if (i + 4 < 15 && j + 4 < 15) {
            flag = false;
            for (int n = i + 1, m = j + 1; n < i + 5; n++, m++) {
              if (ground[n][m] != color) {
                flag = true;
                break;
              }
            }
          }
          if (!flag) {
            return true;
          }
          if (i - 4 >= 0 && j + 4 < 15) {
            flag = false;
            for (int n = i - 1, m = j + 1; m < j + 5; n--, m++) {
              if (ground[n][m] != color) {
                flag = true;
                break;
              }
            }
          }
          if (!flag) {
            return true;
          }
          if (i + 4 < 15) {
            flag = false;
            for (int n = i + 1; n < i + 5; n++) {
              if (ground[n][j] != color) {
                flag = true;
                break;
              }
            }
          }
          if (!flag) {
            return true;
          }
          if (j + 4 < 15) {
            flag = false;
            for (int n = j + 1; n < j + 5; n++) {
              if (ground[i][n] != color) {
                flag = true;
                break;
              }
            }
          }
          if (!flag) {
            return true;
          }
        }
      }
    }
    return false;
  }

  void nextStepSample() {
    Random random = Random();
    int i, j;
    while (true) {
      i = random.nextInt(15);
      j = random.nextInt(15);
      if (ground[i][j] == null) {
        break;
      }
    }
    setState(() {
      ground[i][j] = false;
      round++;
    });
  }

  void nextStep() {
    bool myColor = false;
    int i, j;

    judgeGround = List<List<int>>.generate(15,
        (i) => List<int>.generate(15, (j) => ground[i][j] != null ? -100 : 0));

    for (int i = 0; i < 15; i++) {
      for (int j = 0; j < 15; j++) {
        if (ground[i][j] == myColor) {
          int n = i;
          int m = j;

          int count = 0;

          while (n < 15 && m < 15 && ground[n][m] == myColor) {
            n++;
            count++;
          }

          if (count == 3 &&
              n < 14 &&
              ground[n][m] == null &&
              ground[n + 1][m] == myColor) {
            judgeGround[n][m] = 10000;
          } else if (count == 2 &&
              n < 13 &&
              ground[n][m] == null &&
              ground[n + 1][m] == myColor &&
              ground[n + 2][m] == myColor) {
            judgeGround[n][m] = 10000;
          } else if (count == 2 &&
              i - 1 >= 0 &&
              n < 13 &&
              ground[i - 1][m] == null &&
              ground[n][m] == null &&
              ground[n + 1][m] == myColor &&
              ground[n + 2][m] == null) {
            judgeGround[n][m] = 1000;
          } else if (count == 2 &&
              i - 1 >= 0 &&
              n < 14 &&
              ground[i - 1][m] == null &&
              ground[n][m] == null &&
              ground[n + 1][m] == myColor) {
            judgeGround[n][m] = 100;
          } else if (count == 2 &&
              n < 13 &&
              ground[n][m] == null &&
              ground[n + 1][m] == myColor &&
              ground[n + 2][m] == null) {
            judgeGround[n][m] = 100;
          } else if (count == 1 &&
              n < 12 &&
              ground[n][m] == null &&
              ground[n + 1][m] == myColor &&
              ground[n + 2][m] == myColor &&
              ground[n + 3][m] == null &&
              i - 1 >= 0 &&
              ground[i - 1][m] == null) {
            judgeGround[n][m] = 1000;
          } else if (count == 1 &&
              n < 12 &&
              ground[n][m] == null &&
              ground[n + 1][m] == myColor &&
              ground[n + 2][m] == myColor &&
              ground[n + 3][m] == myColor) {
            judgeGround[n][m] = 10000;
          } else if (count == 1 &&
              n < 12 &&
              ground[n][m] == null &&
              ground[n + 1][m] == myColor &&
              ground[n + 2][m] == myColor &&
              ground[n + 3][m] == null) {
            judgeGround[n][m] = 100;
          } else if (count == 1 &&
              n < 13 &&
              ground[n][m] == null &&
              ground[n + 1][m] == myColor &&
              ground[n + 2][m] == myColor &&
              i - 1 >= 0 &&
              ground[i - 1][m] == null) {
            judgeGround[n][m] = 100;
          } else if (count == 1 &&
              n < 13 &&
              ground[n][m] == null &&
              ground[n + 1][m] == myColor &&
              ground[n + 2][m] == null &&
              i - 1 >= 0 &&
              ground[i - 1][m] == null) {
            judgeGround[n][m] = 100;
          } else if (count == 4 && n < 15 && ground[n][m] == null) {
            judgeGround[n][m] += 10000;
          } else if (i - 1 >= 0 && count == 4 && ground[i - 1][m] == null) {
            judgeGround[i - 1][m] += 10000;
          } else if (count == 3 &&
              i - 1 >= 0 &&
              ground[i - 1][m] == null &&
              n < 15 &&
              ground[n][m] == null) {
            judgeGround[i - 1][m] += 1000;
            judgeGround[n][m] += 1000;
          } else if (count == 3 && i - 1 >= 0 && ground[i - 1][m] == null) {
            judgeGround[i - 1][m] += 100;
          } else if (count == 3 && n < 15 && ground[n][m] == null) {
            judgeGround[n][m] += 100;
          } else if (count == 2 &&
              i - 1 >= 0 &&
              ground[i - 1][m] == null &&
              n < 15 &&
              ground[n][m] == null) {
            judgeGround[i - 1][m] += 100;
            judgeGround[n][m] += 100;
          } else if (count == 2 && i - 1 >= 0 && ground[i - 1][m] == null) {
            judgeGround[i - 1][m] += 30;
          } else if (count == 2 && n < 15 && ground[n][m] == null) {
            judgeGround[n][m] += 30;
          } else if (count == 1 &&
              i - 1 >= 0 &&
              ground[i - 1][m] == null &&
              n < 15 &&
              ground[n][m] == null) {
            judgeGround[i - 1][m] += 10;
            judgeGround[n][m] += 10;
          } else if (count == 1 && i - 1 >= 0 && ground[i - 1][m] == null) {
            judgeGround[i - 1][m] += 5;
          } else if (count == 1 && n < 15 && ground[n][m] == null) {
            judgeGround[n][m] += 5;
          }

          count = 0;
          n = i;
          m = j;
          while (n >= 0 && m < 15 && ground[n][m] == myColor) {
            m++;
            n--;
            count++;
          }
          if (count == 3 &&
              m < 14 &&
              n >= 1 &&
              ground[n][m] == null &&
              ground[n - 1][m + 1] == myColor) {
            judgeGround[n][m] = 10000;
          } else if (count == 2 &&
              m < 13 &&
              n >= 2 &&
              ground[n][m] == null &&
              ground[n - 1][m + 1] == myColor &&
              ground[n - 2][m + 2] == myColor) {
            judgeGround[n][m] = 10000;
          } else if (count == 2 &&
              i + 1 < 15 &&
              j - 1 > 0 &&
              n >= 2 &&
              m < 13 &&
              ground[i + 1][j - 1] == null &&
              ground[n][m] == null &&
              ground[n - 1][m + 1] == myColor &&
              ground[n - 2][m + 2] == null) {
            judgeGround[n][m] = 1000;
          } else if (count == 2 &&
              i + 1 < 15 &&
              j - 1 >= 0 &&
              n >= 1 &&
              m < 14 &&
              ground[i + 1][j - 1] == null &&
              ground[n][m] == null &&
              ground[n - 1][m + 1] == myColor) {
            judgeGround[n][m] = 100;
          } else if (count == 2 &&
              n >= 2 &&
              m < 13 &&
              ground[n][m] == null &&
              ground[n - 1][m + 1] == myColor &&
              ground[n - 2][m + 2] == null) {
            judgeGround[n][m] = 100;
          } else if (count == 1 &&
              n >= 3 &&
              m < 12 &&
              ground[n][m] == null &&
              ground[n - 1][m + 1] == myColor &&
              ground[n - 2][m + 2] == myColor &&
              ground[n - 3][m + 3] == myColor) {
            judgeGround[n][m] = 10000;
          } else if (count == 1 &&
              n >= 3 &&
              m < 12 &&
              ground[n][m] == null &&
              ground[n - 1][m + 1] == myColor &&
              ground[n - 2][m + 2] == myColor &&
              ground[n - 3][m + 3] == null &&
              i + 1 < 15 &&
              j - 1 >= 0 &&
              ground[i + 1][j - 1] == null) {
            judgeGround[n][m] = 1000;
          } else if (count == 1 &&
              n >= 3 &&
              m < 12 &&
              ground[n][m] == null &&
              ground[n - 1][m + 1] == myColor &&
              ground[n - 2][m + 2] == myColor &&
              ground[n - 3][m + 3] == null) {
            judgeGround[n][m] = 100;
          } else if (count == 1 &&
              n >= 2 &&
              m < 13 &&
              ground[n][m] == null &&
              ground[n - 1][m + 1] == myColor &&
              ground[n - 2][m + 2] == myColor &&
              i + 1 < 15 &&
              j - 1 >= 0 &&
              ground[i + 1][j - 1] == null) {
            judgeGround[n][m] = 100;
          } else if (count == 1 &&
              n >= 2 &&
              m < 13 &&
              ground[n][m] == null &&
              ground[n - 1][m + 1] == myColor &&
              ground[n - 2][m + 2] == null &&
              i + 1 < 15 &&
              j - 1 >= 0 &&
              ground[i + 1][j - 1] == null) {
            judgeGround[n][m] = 100;
          } else if (count == 4 && n >= 0 && m < 15 && ground[n][m] == null) {
            judgeGround[n][m] += 10000;
          } else if (j - 1 >= 0 &&
              i + 1 < 15 &&
              count == 4 &&
              ground[i + 1][j - 1] == null) {
            judgeGround[i + 1][j - 1] += 10000;
          } else if (count == 3 &&
              i + 1 < 15 &&
              j - 1 >= 0 &&
              ground[i + 1][j - 1] == null &&
              n >= 0 &&
              m < 15 &&
              ground[n][m] == null) {
            judgeGround[i + 1][j - 1] += 1000;
            judgeGround[n][m] += 1000;
          } else if (count == 3 &&
              j - 1 >= 0 &&
              i + 1 < 15 &&
              ground[i + 1][j - 1] == null) {
            judgeGround[i + 1][j - 1] += 100;
          } else if (count == 3 && n >= 0 && m < 15 && ground[n][m] == null) {
            judgeGround[n][m] += 100;
          } else if (count == 2 &&
              i + 1 < 15 &&
              j - 1 >= 0 &&
              ground[i + 1][j - 1] == null &&
              n >= 0 &&
              m < 15 &&
              ground[n][m] == null) {
            judgeGround[i + 1][j - 1] += 100;
            judgeGround[n][m] += 100;
          } else if (count == 2 &&
              j - 1 >= 0 &&
              i + 1 < 15 &&
              ground[i + 1][j - 1] == null) {
            judgeGround[i + 1][j - 1] += 30;
          } else if (count == 2 && n >= 0 && m < 15 && ground[n][m] == null) {
            judgeGround[n][m] += 30;
          } else if (count == 1 &&
              j - 1 >= 0 &&
              i + 1 < 15 &&
              ground[i + 1][j - 1] == null &&
              n >= 0 &&
              m < 15 &&
              ground[n][m] == null) {
            judgeGround[i + 1][j - 1] += 10;
            judgeGround[n][m] += 10;
          } else if (count == 1 &&
              j - 1 >= 0 &&
              i + 1 < 15 &&
              ground[i + 1][j - 1] == null) {
            judgeGround[i + 1][j - 1] += 5;
          } else if (count == 1 && n >= 0 && m < 15 && ground[n][m] == null) {
            judgeGround[n][m] += 5;
          }

          count = 0;
          n = i;
          m = j;
          while (n < 15 && m < 15 && ground[n][m] == myColor) {
            m++;
            count++;
          }
          if (count == 3 &&
              m < 14 &&
              ground[n][m] == null &&
              ground[n][m + 1] == myColor) {
            judgeGround[n][m] = 10000;
          } else if (count == 2 &&
              m < 13 &&
              ground[n][m] == null &&
              ground[n][m + 1] == myColor &&
              ground[n][m + 2] == myColor) {
            judgeGround[n][m] = 10000;
          } else if (count == 2 &&
              j - 1 >= 0 &&
              m < 13 &&
              ground[n][j - 1] == null &&
              ground[n][m] == null &&
              ground[n][m + 1] == myColor &&
              ground[n][m + 2] == null) {
            judgeGround[n][m] = 1000;
          } else if (count == 2 &&
              j - 1 >= 0 &&
              m < 14 &&
              ground[n][j - 1] == null &&
              ground[n][m] == null &&
              ground[n][m + 1] == myColor) {
            judgeGround[n][m] = 100;
          } else if (count == 2 &&
              m < 13 &&
              ground[n][m] == null &&
              ground[n][m + 1] == myColor &&
              ground[n][m + 2] == null) {
            judgeGround[n][m] = 100;
          } else if (count == 1 &&
              m < 12 &&
              ground[n][m] == null &&
              ground[n][m + 1] == myColor &&
              ground[n][m + 2] == myColor &&
              ground[n][m + 3] == null &&
              j - 1 >= 0 &&
              ground[n][j - 1] == null) {
            judgeGround[n][m] = 1000;
          } else if (count == 1 &&
              m < 12 &&
              ground[n][m] == null &&
              ground[n][m + 1] == myColor &&
              ground[n][m + 2] == myColor &&
              ground[n][m + 3] == null) {
            judgeGround[n][m] = 100;
          } else if (count == 1 &&
              m < 12 &&
              ground[n][m] == null &&
              ground[n][m + 1] == myColor &&
              ground[n][m + 2] == myColor &&
              ground[n][m + 3] == myColor) {
            judgeGround[n][m] = 10000;
          } else if (count == 1 &&
              m < 13 &&
              ground[n][m] == null &&
              ground[n][m + 1] == myColor &&
              ground[n][m + 2] == myColor &&
              j - 1 >= 0 &&
              ground[n][j - 1] == null) {
            judgeGround[n][m] = 100;
          } else if (count == 1 &&
              m < 13 &&
              ground[n][m] == null &&
              ground[n][m + 1] == myColor &&
              ground[n][m + 2] == null &&
              j - 1 >= 0 &&
              ground[n][j - 1] == null) {
            judgeGround[n][m] = 100;
          } else if (count == 4 && m < 15 && ground[n][m] == null) {
            judgeGround[n][m] += 10000;
          } else if (j - 1 >= 0 && count == 4 && ground[n][j - 1] == null) {
            judgeGround[n][j - 1] += 10000;
          } else if (count == 3 &&
              j - 1 >= 0 &&
              ground[n][j - 1] == null &&
              m < 15 &&
              ground[n][m] == null) {
            judgeGround[n][j - 1] += 1000;
            judgeGround[n][m] += 1000;
          } else if (count == 3 && j - 1 >= 0 && ground[n][j - 1] == null) {
            judgeGround[n][j - 1] += 100;
          } else if (count == 3 && m < 15 && ground[n][m] == null) {
            judgeGround[n][m] += 100;
          } else if (count == 2 &&
              j - 1 >= 0 &&
              ground[n][j - 1] == null &&
              m < 15 &&
              ground[n][m] == null) {
            judgeGround[n][j - 1] += 100;
            judgeGround[n][m] += 100;
          } else if (count == 2 && j - 1 >= 0 && ground[n][j - 1] == null) {
            judgeGround[n][j - 1] += 30;
          } else if (count == 2 && m < 15 && ground[n][m] == null) {
            judgeGround[n][m] += 30;
          } else if (count == 1 &&
              j - 1 >= 0 &&
              ground[n][j - 1] == null &&
              m < 15 &&
              ground[n][m] == null) {
            judgeGround[n][j - 1] += 10;
            judgeGround[n][m] += 10;
          } else if (count == 1 && j - 1 >= 0 && ground[n][j - 1] == null) {
            judgeGround[n][j - 1] += 5;
          } else if (count == 1 && m < 15 && ground[n][m] == null) {
            judgeGround[n][m] += 5;
          }

          count = 0;
          n = i;
          m = j;
          while (n < 15 && m < 15 && ground[n][m] == myColor) {
            m++;
            n++;
            count++;
          }

          if (count == 3 &&
              n < 14 &&
              m < 14 &&
              ground[n][m] == null &&
              ground[n + 1][m + 1] == myColor) {
            judgeGround[n][m] = 10000;
          } else if (count == 2 &&
              m < 13 &&
              n < 13 &&
              ground[n][m] == null &&
              ground[n + 1][m + 1] == myColor &&
              ground[n + 2][m + 2] == myColor) {
            judgeGround[n][m] = 10000;
          } else if (count == 2 &&
              i - 1 >= 0 &&
              j - 1 > 0 &&
              n < 13 &&
              m < 13 &&
              ground[i - 1][j - 1] == null &&
              ground[n][m] == null &&
              ground[n + 1][m + 1] == myColor &&
              ground[n + 2][m + 2] == null) {
            judgeGround[n][m] = 1000;
          } else if (count == 2 &&
              i - 1 >= 0 &&
              j - 1 >= 0 &&
              n < 14 &&
              m < 14 &&
              ground[i - 1][j - 1] == null &&
              ground[n][m] == null &&
              ground[n + 1][m + 1] == myColor) {
            judgeGround[n][m] = 100;
          } else if (count == 2 &&
              n < 13 &&
              m < 13 &&
              ground[n][m] == null &&
              ground[n + 1][m + 1] == myColor &&
              ground[n + 2][m + 2] == null) {
            judgeGround[n][m] = 100;
          } else if (count == 1 &&
              n < 12 &&
              m < 12 &&
              ground[n][m] == null &&
              ground[n + 1][m + 1] == myColor &&
              ground[n + 2][m + 2] == myColor &&
              ground[n + 3][m + 3] == null &&
              i - 1 >= 0 &&
              j - 1 >= 0 &&
              ground[i - 1][j - 1] == null) {
            judgeGround[n][m] = 1000;
          } else if (count == 1 &&
              n < 12 &&
              m < 12 &&
              ground[n][m] == null &&
              ground[n + 1][m + 1] == myColor &&
              ground[n + 2][m + 2] == myColor &&
              ground[n + 3][m + 3] == myColor) {
            judgeGround[n][m] = 10000;
          } else if (count == 1 &&
              n < 12 &&
              m < 12 &&
              ground[n][m] == null &&
              ground[n + 1][m + 1] == myColor &&
              ground[n + 2][m + 2] == myColor &&
              ground[n + 3][m + 3] == null) {
            judgeGround[n][m] = 100;
          } else if (count == 1 &&
              n < 13 &&
              m < 13 &&
              ground[n][m] == null &&
              ground[n + 1][m + 1] == myColor &&
              ground[n + 2][m + 2] == myColor &&
              i - 1 >= 0 &&
              j - 1 >= 0 &&
              ground[i - 1][j - 1] == null) {
            judgeGround[n][m] = 100;
          } else if (count == 1 &&
              n < 13 &&
              m < 13 &&
              ground[n][m] == null &&
              ground[n + 1][m + 1] == myColor &&
              ground[n + 2][m + 2] == null &&
              i - 1 >= 0 &&
              j - 1 >= 0 &&
              ground[i - 1][j - 1] == null) {
            judgeGround[n][m] = 100;
          } else if (count == 4 && n < 15 && m < 15 && ground[n][m] == null) {
            judgeGround[n][m] += 10000;
          } else if (j - 1 >= 0 &&
              i - 1 >= 0 &&
              count == 4 &&
              ground[i - 1][j - 1] == null) {
            judgeGround[i - 1][j - 1] += 10000;
          } else if (count == 3 &&
              i - 1 >= 0 &&
              j - 1 >= 0 &&
              ground[i - 1][j - 1] == null &&
              n < 15 &&
              m < 15 &&
              ground[n][m] == null) {
            judgeGround[i - 1][j - 1] += 1000;
            judgeGround[n][m] += 1000;
          } else if (count == 3 &&
              j - 1 >= 0 &&
              i - 1 >= 0 &&
              ground[i - 1][j - 1] == null) {
            judgeGround[i - 1][j - 1] += 100;
          } else if (count == 3 && n < 15 && m < 15 && ground[n][m] == null) {
            judgeGround[n][m] += 100;
          } else if (count == 2 &&
              i - 1 >= 0 &&
              j - 1 >= 0 &&
              ground[i - 1][j - 1] == null &&
              n < 15 &&
              m < 15 &&
              ground[n][m] == null) {
            judgeGround[i - 1][j - 1] += 100;
            judgeGround[n][m] += 100;
          } else if (count == 2 &&
              j - 1 >= 0 &&
              i - 1 >= 0 &&
              ground[i - 1][j - 1] == null) {
            judgeGround[i - 1][j - 1] += 30;
          } else if (count == 2 && n < 15 && m < 15 && ground[n][m] == null) {
            judgeGround[n][m] += 30;
          } else if (count == 1 &&
              j - 1 >= 0 &&
              i - 1 >= 0 &&
              ground[i - 1][j - 1] == null &&
              n < 15 &&
              m < 15 &&
              ground[n][m] == null) {
            judgeGround[i - 1][j - 1] += 10;
            judgeGround[n][m] += 10;
          } else if (count == 1 &&
              j - 1 >= 0 &&
              i - 1 >= 0 &&
              ground[i - 1][j - 1] == null) {
            judgeGround[i - 1][j - 1] += 5;
          } else if (count == 1 && n < 15 && m < 15 && ground[n][m] == null) {
            judgeGround[n][m] += 5;
          }
        } else if (ground[i][j] == !myColor) {
          int n = i;
          int m = j;

          int count = 0;

          while (n < 15 && m < 15 && ground[n][m] == !myColor) {
            n++;
            count++;
          }
          if (count == 3 &&
              n < 14 &&
              ground[n][m] == null &&
              ground[n + 1][m] == !myColor) {
            judgeGround[n][m] = 8000;
          } else if (count == 2 &&
              n < 13 &&
              ground[n][m] == null &&
              ground[n + 1][m] == !myColor &&
              ground[n + 2][m] == !myColor) {
            judgeGround[n][m] = 8000;
          } else if (count == 2 &&
              i - 1 >= 0 &&
              n < 13 &&
              ground[i - 1][m] == null &&
              ground[n][m] == null &&
              ground[n + 1][m] == !myColor &&
              ground[n + 2][m] == null) {
            judgeGround[n][m] = 1000;
          } else if (count == 2 &&
              i - 1 >= 0 &&
              n < 14 &&
              ground[i - 1][m] == null &&
              ground[n][m] == null &&
              ground[n + 1][m] == !myColor) {
            judgeGround[n][m] = 100;
          } else if (count == 2 &&
              n < 13 &&
              ground[n][m] == null &&
              ground[n + 1][m] == !myColor &&
              ground[n + 2][m] == null) {
            judgeGround[n][m] = 100;
          } else if (count == 1 &&
              n < 12 &&
              ground[n][m] == null &&
              ground[n + 1][m] == !myColor &&
              ground[n + 2][m] == !myColor &&
              ground[n + 3][m] == null &&
              i - 1 >= 0 &&
              ground[i - 1][m] == null) {
            judgeGround[n][m] = 1000;
          } else if (count == 1 &&
              n < 12 &&
              ground[n][m] == null &&
              ground[n + 1][m] == !myColor &&
              ground[n + 2][m] == !myColor &&
              ground[n + 3][m] == null) {
            judgeGround[n][m] = 100;
          } else if (count == 1 &&
              n < 13 &&
              ground[n][m] == null &&
              ground[n + 1][m] == !myColor &&
              ground[n + 2][m] == !myColor &&
              i - 1 >= 0 &&
              ground[i - 1][m] == null) {
            judgeGround[n][m] = 100;
          } else if (count == 1 &&
              n < 12 &&
              ground[n][m] == null &&
              ground[n + 1][m] == !myColor &&
              ground[n + 2][m] == !myColor &&
              ground[n + 3][m] == !myColor) {
            judgeGround[n][m] = 8000;
          } else if (count == 1 &&
              n < 13 &&
              ground[n][m] == null &&
              ground[n + 1][m] == !myColor &&
              ground[n + 2][m] == null &&
              i - 1 >= 0 &&
              ground[i - 1][m] == null) {
            judgeGround[n][m] = 100;
          } else if (count == 4 && n < 15 && ground[n][m] == null) {
            judgeGround[n][m] += 8000;
          } else if (i - 1 >= 0 && count == 4 && ground[i - 1][m] == null) {
            judgeGround[i - 1][m] += 8000;
          } else if (count == 3 &&
              i - 1 >= 0 &&
              ground[i - 1][m] == null &&
              n < 15 &&
              ground[n][m] == null) {
            judgeGround[i - 1][m] += 5000;
            judgeGround[n][m] += 5000;
          } else if (count == 3 && i - 1 >= 0 && ground[i - 1][m] == null) {
            judgeGround[i - 1][m] += 100;
          } else if (count == 3 && n < 15 && ground[n][m] == null) {
            judgeGround[n][m] += 100;
          } else if (count == 2 &&
              i - 1 >= 0 &&
              ground[i - 1][m] == null &&
              n < 15 &&
              ground[n][m] == null) {
            judgeGround[i - 1][m] += 100;
            judgeGround[n][m] += 100;
          } else if (count == 2 && i - 1 >= 0 && ground[i - 1][m] == null) {
            judgeGround[i - 1][m] += 30;
          } else if (count == 2 && n < 15 && ground[n][m] == null) {
            judgeGround[n][m] += 30;
          } else if (count == 1 &&
              i - 1 >= 0 &&
              ground[i - 1][m] == null &&
              n < 15 &&
              ground[n][m] == null) {
            judgeGround[i - 1][m] += 10;
            judgeGround[n][m] += 10;
          } else if (count == 1 && i - 1 >= 0 && ground[i - 1][m] == null) {
            judgeGround[i - 1][m] += 5;
          } else if (count == 1 && n < 15 && ground[n][m] == null) {
            judgeGround[n][m] += 5;
          }

          count = 0;
          n = i;
          m = j;
          while (n >= 0 && m < 15 && ground[n][m] == !myColor) {
            m++;
            n--;
            count++;
          }
          if (count == 3 &&
              m < 14 &&
              n >= 1 &&
              ground[n][m] == null &&
              ground[n - 1][m + 1] == !myColor) {
            judgeGround[n][m] = 8000;
          } else if (count == 2 &&
              m < 13 &&
              n >= 2 &&
              ground[n][m] == null &&
              ground[n - 1][m + 1] == !myColor &&
              ground[n - 2][m + 2] == !myColor) {
            judgeGround[n][m] = 8000;
          } else if (count == 2 &&
              i + 1 < 15 &&
              j - 1 > 0 &&
              n >= 2 &&
              m < 13 &&
              ground[i + 1][j - 1] == null &&
              ground[n][m] == null &&
              ground[n - 1][m + 1] == !myColor &&
              ground[n - 2][m + 2] == null) {
            judgeGround[n][m] = 1000;
          } else if (count == 2 &&
              i + 1 < 15 &&
              j - 1 >= 0 &&
              n >= 1 &&
              m < 14 &&
              ground[i + 1][j - 1] == null &&
              ground[n][m] == null &&
              ground[n - 1][m + 1] == !myColor) {
            judgeGround[n][m] = 100;
          } else if (count == 2 &&
              n >= 2 &&
              m < 13 &&
              ground[n][m] == null &&
              ground[n - 1][m + 1] == !myColor &&
              ground[n - 2][m + 2] == null) {
            judgeGround[n][m] = 100;
          } else if (count == 1 &&
              n >= 3 &&
              m < 12 &&
              ground[n][m] == null &&
              ground[n - 1][m + 1] == !myColor &&
              ground[n - 2][m + 2] == !myColor &&
              ground[n - 3][m + 3] == null &&
              i + 1 < 15 &&
              j - 1 >= 0 &&
              ground[i + 1][j - 1] == null) {
            judgeGround[n][m] = 1000;
          } else if (count == 1 &&
              n >= 3 &&
              m < 12 &&
              ground[n][m] == null &&
              ground[n - 1][m + 1] == !myColor &&
              ground[n - 2][m + 2] == !myColor &&
              ground[n - 3][m + 3] == null) {
            judgeGround[n][m] = 100;
          } else if (count == 1 &&
              n >= 2 &&
              m < 13 &&
              ground[n][m] == null &&
              ground[n - 1][m + 1] == !myColor &&
              ground[n - 2][m + 2] == !myColor &&
              i + 1 < 15 &&
              j - 1 >= 0 &&
              ground[i + 1][j - 1] == null) {
            judgeGround[n][m] = 100;
          } else if (count == 1 &&
              n >= 3 &&
              m < 12 &&
              ground[n][m] == null &&
              ground[n - 1][m + 1] == !myColor &&
              ground[n - 2][m + 2] == !myColor &&
              ground[n - 3][m + 3] == !myColor) {
            judgeGround[n][m] = 8000;
          } else if (count == 1 &&
              n >= 2 &&
              m < 13 &&
              ground[n][m] == null &&
              ground[n - 1][m + 1] == !myColor &&
              ground[n - 2][m + 2] == null &&
              i + 1 < 15 &&
              j - 1 >= 0 &&
              ground[i + 1][j - 1] == null) {
            judgeGround[n][m] = 100;
          } else if (count == 4 && n >= 0 && m < 15 && ground[n][m] == null) {
            judgeGround[n][m] += 8000;
          } else if (j - 1 >= 0 &&
              i + 1 < 15 &&
              count == 4 &&
              ground[i + 1][j - 1] == null) {
            judgeGround[i + 1][j - 1] += 8000;
          } else if (count == 3 &&
              i + 1 < 15 &&
              j - 1 >= 0 &&
              ground[i + 1][j - 1] == null &&
              n >= 0 &&
              m < 15 &&
              ground[n][m] == null) {
            judgeGround[i + 1][j - 1] += 5000;
            judgeGround[n][m] += 5000;
          } else if (count == 3 &&
              j - 1 >= 0 &&
              i + 1 < 15 &&
              ground[i + 1][j - 1] == null) {
            judgeGround[i + 1][j - 1] += 100;
          } else if (count == 3 && n >= 0 && m < 15 && ground[n][m] == null) {
            judgeGround[n][m] += 100;
          } else if (count == 2 &&
              i + 1 < 15 &&
              j - 1 >= 0 &&
              ground[i + 1][j - 1] == null &&
              n >= 0 &&
              m < 15 &&
              ground[n][m] == null) {
            judgeGround[i + 1][j - 1] += 100;
            judgeGround[n][m] += 100;
          } else if (count == 2 &&
              j - 1 >= 0 &&
              i + 1 < 15 &&
              ground[i + 1][j - 1] == null) {
            judgeGround[i + 1][j - 1] += 30;
          } else if (count == 2 && n >= 0 && m < 15 && ground[n][m] == null) {
            judgeGround[n][m] += 30;
          } else if (count == 1 &&
              j - 1 >= 0 &&
              i + 1 < 15 &&
              ground[i + 1][j - 1] == null &&
              n >= 0 &&
              m < 15 &&
              ground[n][m] == null) {
            judgeGround[i + 1][j - 1] += 10;
            judgeGround[n][m] += 10;
          } else if (count == 1 &&
              j - 1 >= 0 &&
              i + 1 < 15 &&
              ground[i + 1][j - 1] == null) {
            judgeGround[i + 1][j - 1] += 5;
          } else if (count == 1 && n >= 0 && m < 15 && ground[n][m] == null) {
            judgeGround[n][m] += 5;
          }

          count = 0;
          n = i;
          m = j;
          while (n < 15 && m < 15 && ground[n][m] == !myColor) {
            m++;
            count++;
          }
          if (count == 3 &&
              m < 14 &&
              ground[n][m] == null &&
              ground[n][m + 1] == !myColor) {
            judgeGround[n][m] = 8000;
          } else if (count == 2 &&
              m < 13 &&
              ground[n][m] == null &&
              ground[n][m + 1] == !myColor &&
              ground[n][m + 2] == !myColor) {
            judgeGround[n][m] = 8000;
          } else if (count == 2 &&
              j - 1 >= 0 &&
              m < 13 &&
              ground[n][j - 1] == null &&
              ground[n][m] == null &&
              ground[n][m + 1] == !myColor &&
              ground[n][m + 2] == null) {
            judgeGround[n][m] = 1000;
          } else if (count == 2 &&
              j - 1 >= 0 &&
              m < 14 &&
              ground[n][j - 1] == null &&
              ground[n][m] == null &&
              ground[n][m + 1] == !myColor) {
            judgeGround[n][m] = 100;
          } else if (count == 2 &&
              m < 13 &&
              ground[n][m] == null &&
              ground[n][m + 1] == !myColor &&
              ground[n][m + 2] == null) {
            judgeGround[n][m] = 100;
          } else if (count == 1 &&
              m < 12 &&
              ground[n][m] == null &&
              ground[n][m + 1] == !myColor &&
              ground[n][m + 2] == !myColor &&
              ground[n][m + 3] == null &&
              j - 1 >= 0 &&
              ground[n][j - 1] == null) {
            judgeGround[n][m] = 1000;
          } else if (count == 1 &&
              m < 12 &&
              ground[n][m] == null &&
              ground[n][m + 1] == !myColor &&
              ground[n][m + 2] == !myColor &&
              ground[n][m + 3] == !myColor) {
            judgeGround[n][m] = 8000;
          } else if (count == 1 &&
              m < 12 &&
              ground[n][m] == null &&
              ground[n][m + 1] == !myColor &&
              ground[n][m + 2] == !myColor &&
              ground[n][m + 3] == null) {
            judgeGround[n][m] = 100;
          } else if (count == 1 &&
              m < 13 &&
              ground[n][m] == null &&
              ground[n][m + 1] == !myColor &&
              ground[n][m + 2] == !myColor &&
              j - 1 >= 0 &&
              ground[n][j - 1] == null) {
            judgeGround[n][m] = 100;
          } else if (count == 1 &&
              m < 13 &&
              ground[n][m] == null &&
              ground[n][m + 1] == !myColor &&
              ground[n][m + 2] == null &&
              j - 1 >= 0 &&
              ground[n][j - 1] == null) {
            judgeGround[n][m] = 100;
          } else if (count == 4 && m < 15 && ground[n][m] == null) {
            judgeGround[n][m] += 8000;
          } else if (j - 1 >= 0 && count == 4 && ground[n][j - 1] == null) {
            judgeGround[n][j - 1] += 8000;
          } else if (count == 3 &&
              j - 1 >= 0 &&
              ground[n][j - 1] == null &&
              m < 15 &&
              ground[n][m] == null) {
            judgeGround[n][j - 1] += 5000;
            judgeGround[n][m] += 5000;
          } else if (count == 3 && j - 1 >= 0 && ground[n][j - 1] == null) {
            judgeGround[n][j - 1] += 100;
          } else if (count == 3 && m < 15 && ground[n][m] == null) {
            judgeGround[n][m] += 100;
          } else if (count == 2 &&
              j - 1 >= 0 &&
              ground[n][j - 1] == null &&
              m < 15 &&
              ground[n][m] == null) {
            judgeGround[n][j - 1] += 100;
            judgeGround[n][m] += 100;
          } else if (count == 2 && j - 1 >= 0 && ground[n][j - 1] == null) {
            judgeGround[n][j - 1] += 30;
          } else if (count == 2 && m < 15 && ground[n][m] == null) {
            judgeGround[n][m] += 30;
          } else if (count == 1 &&
              j - 1 >= 0 &&
              ground[n][j - 1] == null &&
              m < 15 &&
              ground[n][m] == null) {
            judgeGround[n][j - 1] += 10;
            judgeGround[n][m] += 10;
          } else if (count == 1 && j - 1 >= 0 && ground[n][j - 1] == null) {
            judgeGround[n][j - 1] += 5;
          } else if (count == 1 && m < 15 && ground[n][m] == null) {
            judgeGround[n][m] += 5;
          }

          count = 0;
          n = i;
          m = j;
          while (n < 15 && m < 15 && ground[n][m] == !myColor) {
            m++;
            n++;
            count++;
          }
          if (count == 3 &&
              n < 14 &&
              m < 14 &&
              ground[n][m] == null &&
              ground[n + 1][m + 1] == !myColor) {
            judgeGround[n][m] = 8000;
          } else if (count == 2 &&
              m < 13 &&
              n < 13 &&
              ground[n][m] == null &&
              ground[n + 1][m + 1] == myColor &&
              ground[n + 2][m + 2] == myColor) {
            judgeGround[n][m] = 8000;
          } else if (count == 2 &&
              i - 1 >= 0 &&
              j - 1 > 0 &&
              n < 13 &&
              m < 13 &&
              ground[i - 1][j - 1] == null &&
              ground[n][m] == null &&
              ground[n + 1][m + 1] == !myColor &&
              ground[n + 2][m + 2] == null) {
            judgeGround[n][m] = 1000;
          } else if (count == 2 &&
              i - 1 >= 0 &&
              j - 1 >= 0 &&
              n < 14 &&
              m < 14 &&
              ground[i - 1][j - 1] == null &&
              ground[n][m] == null &&
              ground[n + 1][m + 1] == !myColor) {
            judgeGround[n][m] = 100;
          } else if (count == 2 &&
              n < 13 &&
              m < 13 &&
              ground[n][m] == null &&
              ground[n + 1][m + 1] == !myColor &&
              ground[n + 2][m + 2] == null) {
            judgeGround[n][m] = 100;
          } else if (count == 1 &&
              n < 12 &&
              m < 12 &&
              ground[n][m] == null &&
              ground[n + 1][m + 1] == !myColor &&
              ground[n + 2][m + 2] == !myColor &&
              ground[n + 3][m + 3] == !myColor) {
            judgeGround[n][m] = 8000;
          } else if (count == 1 &&
              n < 12 &&
              m < 12 &&
              ground[n][m] == null &&
              ground[n + 1][m + 1] == !myColor &&
              ground[n + 2][m + 2] == !myColor &&
              ground[n + 3][m + 3] == null &&
              i - 1 >= 0 &&
              j - 1 >= 0 &&
              ground[i - 1][j - 1] == null) {
            judgeGround[n][m] = 1000;
          } else if (count == 1 &&
              n < 12 &&
              m < 12 &&
              ground[n][m] == null &&
              ground[n + 1][m + 1] == !myColor &&
              ground[n + 2][m + 2] == !myColor &&
              ground[n + 3][m + 3] == null) {
            judgeGround[n][m] = 100;
          } else if (count == 1 &&
              n < 13 &&
              m < 13 &&
              ground[n][m] == null &&
              ground[n + 1][m + 1] == !myColor &&
              ground[n + 2][m + 2] == !myColor &&
              i - 1 >= 0 &&
              j - 1 >= 0 &&
              ground[i - 1][j - 1] == null) {
            judgeGround[n][m] = 100;
          } else if (count == 1 &&
              n < 13 &&
              m < 13 &&
              ground[n][m] == null &&
              ground[n + 1][m + 1] == !myColor &&
              ground[n + 2][m + 2] == null &&
              i - 1 >= 0 &&
              j - 1 >= 0 &&
              ground[i - 1][j - 1] == null) {
            judgeGround[n][m] = 100;
          } else if (count == 4 && n < 15 && m < 15 && ground[n][m] == null) {
            judgeGround[n][m] += 8000;
          } else if (j - 1 >= 0 &&
              i - 1 >= 0 &&
              count == 4 &&
              ground[i - 1][j - 1] == null) {
            judgeGround[i - 1][j - 1] += 8000;
          } else if (count == 3 &&
              i - 1 >= 0 &&
              j - 1 >= 0 &&
              ground[i - 1][j - 1] == null &&
              n < 15 &&
              m < 15 &&
              ground[n][m] == null) {
            judgeGround[i - 1][j - 1] += 5000;
            judgeGround[n][m] += 5000;
          } else if (count == 3 &&
              j - 1 >= 0 &&
              i - 1 >= 0 &&
              ground[i - 1][j - 1] == null) {
            judgeGround[i - 1][j - 1] += 100;
          } else if (count == 3 && n < 15 && m < 15 && ground[n][m] == null) {
            judgeGround[n][m] += 100;
          } else if (count == 2 &&
              i - 1 >= 0 &&
              j - 1 >= 0 &&
              ground[i - 1][j - 1] == null &&
              n < 15 &&
              m < 15 &&
              ground[n][m] == null) {
            judgeGround[i - 1][j - 1] += 100;
            judgeGround[n][m] += 100;
          } else if (count == 2 &&
              j - 1 >= 0 &&
              i - 1 >= 0 &&
              ground[i - 1][j - 1] == null) {
            judgeGround[i - 1][j - 1] += 30;
          } else if (count == 2 && n < 15 && m < 15 && ground[n][m] == null) {
            judgeGround[n][m] += 30;
          } else if (count == 1 &&
              j - 1 >= 0 &&
              i - 1 >= 0 &&
              ground[i - 1][j - 1] == null &&
              n < 15 &&
              m < 15 &&
              ground[n][m] == null) {
            judgeGround[i - 1][j - 1] += 10;
            judgeGround[n][m] += 10;
          } else if (count == 1 &&
              j - 1 >= 0 &&
              i - 1 >= 0 &&
              ground[i - 1][j - 1] == null) {
            judgeGround[i - 1][j - 1] += 5;
          } else if (count == 1 && n < 15 && m < 15 && ground[n][m] == null) {
            judgeGround[n][m] += 5;
          }
        }
      }
    }
    int max = -1;
    Map<int, List<List<int>>> maxValues = {};
    for (int i = 0; i < 15; i++) {
      for (int j = 0; j < 15; j++) {
        if (judgeGround[i][j] < -1) {
          continue;
        }
        if (judgeGround[i][j] > max) {
          maxValues[judgeGround[i][j]] = [
            [i, j]
          ];
          max = judgeGround[i][j];
        } else {
          if (maxValues.containsKey(judgeGround[i][j]))
            maxValues[judgeGround[i][j]].add(<int>[i, j]);
          else
            maxValues[judgeGround[i][j]] = [
              [i, j]
            ];
        }
      }
    }
    List<List<int>> maxs = maxValues[max];
    Random random = Random();
    List<int> pair = maxs[random.nextInt(maxs.length)];
    i = pair[0];
    j = pair[1];
    Future.delayed(Duration(milliseconds: 50), () async {
      setState(() {
        goStep(i, j, myColor);
      });
      if (isWin()) {
        await showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                  title: Text("结束"),
                  content: Text(round % 2 != 0 ? "黑子胜" : "白子胜"),
                  actions: <Widget>[
                    FlatButton(
                      child: Text("再来一局"),
                      onPressed: () => Navigator.of(context).pop(), //关闭
                      // 对话框
                    ),
                  ]);
            });
        setState(() {
          round = 0;
          ground = List<List<bool>>.generate(
              15, (index) => List<bool>.generate(15, (index) => null));
        });
      }
    });
  }

  List<List<int>> steps = [];

  goStep(int i, int j, bool color) {
    ground[i][j] = color;
    round++;
    steps.add([i, j]);
  }

  @override
  void initState() {
    super.initState();
    scaleMargin = outMargin;
    ground = List<List<bool>>.generate(
        15, (index) => List<bool>.generate(15, (index) => null));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("五子棋"),
      ),
      body: Column(
        children: <Widget>[
          Container(
            width: double.infinity,
            child: Stack(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.all(outMargin),
                  child: CustomPaint(
                    size: Size(totalWidth, totalWidth), //指定画布大小
                    painter: Background(outMargin, scaleMargin),
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(margin + outMargin),
                  child: Row(
                    children: List<Widget>.generate(
                      15,
                      (i) => Column(
                        children: List<Widget>.generate(
                          15,
                          (j) => GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () async {
                              if (ground[i][j] == null) {
                                goStep(i, j, round % 2 == 0);
                                setState(() {});
                                if (isWin()) {
                                  await showDialog(
                                      context: context,
                                      builder: (context) {
                                        return AlertDialog(
                                            title: Text("结束"),
                                            content: Text(
                                                round % 2 != 0 ? "黑子胜" : "白子胜"),
                                            actions: <Widget>[
                                              FlatButton(
                                                child: Text("再来一局"),
                                                onPressed: () =>
                                                    Navigator.of(context)
                                                        .pop(), //关闭
                                                // 对话框
                                              ),
                                            ]);
                                      });
                                  setState(() {
                                    round = 0;
                                    ground = List<List<bool>>.generate(
                                        15,
                                        (index) => List<bool>.generate(
                                            15, (index) => null));
                                  });
                                }
                                if (robot && round % 2 != 0) {
                                  nextStep();
                                }
                              }
                            },
                            child: Container(
                              width: width,
                              height: width,
                              alignment: Alignment.center,
                              child: ground[i][j] == null
//                                  ? Text("${judgeGround[i][j]}")
                                  ? Text(" ")
                                  : ground[i][j]
                                      ? CustomPaint(
                                          painter: Black(
                                              active: steps.length < 2 ||
                                                  ((steps.last[0] == i &&
                                                          steps.last[1] == j) ||
                                                      (steps[steps.length - 2]
                                                                  [0] ==
                                                              i &&
                                                          steps[steps.length -
                                                                  2][1] ==
                                                              j))),
                                          size: Size(width, width),
                                        )
                                      : CustomPaint(
                                          painter: White(
                                              active: steps.length < 2 ||
                                                  ((steps.last[0] == i &&
                                                          steps.last[1] == j) ||
                                                      (steps[steps.length - 2]
                                                                  [0] ==
                                                              i &&
                                                          steps[steps.length -
                                                                  2][1] ==
                                                              j))),
                                          size: Size(width, width),
                                        ),
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
            child: Text(robot ? "切换为玩家对弈" : "切换为人机模式"),
            onPressed: () {
              setState(() {
                robot = !robot;
                if (robot && round % 2 == 1) {
                  nextStep();
                }
              });
            },
          ),
          Container(
            child: Text(
              "当前为 ${round % 2 == 0 ? "黑" : "白"}棋 回合",
              style: TextStyle(fontSize: 16),
            ),
          )
        ],
      ),
    );
  }
}

class Background extends CustomPainter {
  Background(this.outMargin, this.scaleMargin);

  double outMargin;
  double scaleMargin;

  @override
  void paint(Canvas canvas, Size size) {
    double eWidth = (size.width - outMargin * 2 - scaleMargin * 2) / 15;
    double eHeight = (size.height - outMargin * 2 - scaleMargin * 2) / 15;
    var paint = Paint()
      ..isAntiAlias = true
      ..style = PaintingStyle.fill
      ..color = Color(0x77cdb175);
    canvas.drawRect(Offset.zero & size, paint);
    paint
      ..style = PaintingStyle.stroke
      ..color = Colors.black;
    for (int i = 0; i < 15; i++) {
      canvas.drawLine(
          Offset(outMargin + eWidth / 2 + scaleMargin,
              eHeight * i + outMargin + eWidth / 2 + scaleMargin),
          Offset(size.width - outMargin - eWidth / 2 - scaleMargin,
              eHeight * i + outMargin + eWidth / 2 + scaleMargin),
          paint);
      canvas.drawLine(
          Offset(eWidth * i + scaleMargin + outMargin + eHeight / 2,
              scaleMargin + outMargin + eHeight / 2),
          Offset(eWidth * i + scaleMargin + outMargin + eHeight / 2,
              size.height - scaleMargin - outMargin - eHeight / 2),
          paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

class White extends CustomPainter {
  White({this.active: false});

  bool active;

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..isAntiAlias = true
      ..style = PaintingStyle.fill
      ..color = Colors.white;
    canvas.drawCircle(Offset(size.width / 2, size.height / 2),
        size.width / (active ? 2.5 : 3), paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return oldDelegate.runtimeType != White ||
        (oldDelegate as White).active != active;
  }
}

class Black extends CustomPainter {
  Black({this.active: false});

  bool active;

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..isAntiAlias = true
      ..style = PaintingStyle.fill
      ..color = Colors.black;
    canvas.drawCircle(Offset(size.width / 2, size.height / 2),
        size.width / (active ? 2.5 : 3), paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return oldDelegate.runtimeType != Black ||
        (oldDelegate as Black).active != active;
  }
}
