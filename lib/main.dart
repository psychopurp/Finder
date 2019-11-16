import 'dart:io';
import 'dart:ui';

import 'package:finder/pages/index_page.dart';
import 'package:finder/plugin/better_text.dart';
import 'package:finder/pages/login_page.dart';
import 'package:finder/public.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:finder/config/global.dart';

//路由管理
import 'routers/application.dart';
import 'package:fluro/fluro.dart';
import 'routers/routes.dart';

//状态管理
import 'package:finder/provider/user_provider.dart';

const Color ActionColor = Color(0xFFDB6B5C);

void main() {
  MyApp app = MyApp();
  runApp(app);
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

  ErrorWidget.builder = (FlutterErrorDetails flutterErrorDetails) {
    print(flutterErrorDetails);
    return Center(
      child: Column(
        children: <Widget>[
          Icon(
            Icons.error,
            color: ActionColor,
            size: 40,
          ),
          BetterText(
            "出错了",
            style: TextStyle(color: ActionColor, fontSize: 18),
            textDirection: TextDirection.ltr,
          ),
          BetterText(
            "请尝试刷新或重启App, 如未能解决, 请反馈问题!",
            style: TextStyle(color: Colors.grey, fontSize: 12),
            textDirection: TextDirection.ltr,
          )
        ],
      ),
    );
  };
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isLogin;
  bool error = false;
  final Router router = Router();

  _MyAppState() {
    Routes.configureRoutes(router);
    Application.router = router;
  }

  @override
  void initState() {
    super.initState();
    globalInit();
  }

  Future<void> globalInit() async {
    global.init().then((isLogin) {
      if (isLogin == null) {
        setState(() {
          error = true;
        });
      } else {
        setState(() {
          this.isLogin = isLogin;
        });
      }
      if (Platform.isAndroid) {
        SystemUiOverlayStyle systemUiOverlayStyle = SystemUiOverlayStyle(
            // statusBarColor: Colors.white,
            );
        SystemChrome.setSystemUIOverlayStyle(systemUiOverlayStyle);
        // print("systemUiOverlayStyle");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (error) {
      return Container(
        color: Colors.white,
        height: double.infinity,
        width: double.infinity,
        child: Center(
          child: Column(
            children: <Widget>[
              InkWell(
                child: Icon(
                  Icons.error,
                  color: ActionColor,
                  size: 40,
                ),
                onTap: globalInit,
              ),
              InkWell(
                child: BetterText(
                  "网络连接失败, 点击重试",
                  textDirection: TextDirection.ltr,
                ),
                onTap: globalInit,
              ),
            ],
          ),
        ),
      );
    }
    if (isLogin == null) {
      return Container(
        color: Colors.white,
        height: double.infinity,
        width: double.infinity,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image.asset("assets/logo.png"),
              BetterText(
                "Finders",
                style: TextStyle(
                  color: ActionColor,
                  fontSize: 60,
                  fontFamily: "Yellowtail"
                ),
                textDirection: TextDirection.ltr,
              ),
              Padding(padding: EdgeInsets.all(60),),
            ],
          ),
        ),
      );
    }
    return MultiProvider(
        //全局状态管理
        providers: [
          ChangeNotifierProvider(
            builder: (_) => UserProvider(),
          )
        ],
        child: BotToastInit(
          child: MaterialApp(
            localizationsDelegates: [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
            ],
            supportedLocales: [
              const Locale('zh', 'CH'),
              const Locale('en', 'US'),
            ],
            navigatorObservers: [BotToastNavigatorObserver()],
            onGenerateRoute: Application.router.generator,
            theme: _buildAppTheme(),
            //设置App主题
            title: 'Findes寻你',
            debugShowCheckedModeBanner: false,
            home: isLogin ? IndexPage() : LoginPage(),
//            home: isLogin && false ? IndexPage() : RegisterPage(),
          ),
        ));
  }
}

//全局颜色主题
final ThemeData appTheme = _buildAppTheme();

ThemeData _buildAppTheme() {
  ThemeData base = ThemeData(
    //指定平台，应用特定平台控件风格
    // platform: TargetPlatform.android,
    brightness: Brightness.light,
    // 主题颜色样本
    // primarySwatch: Colors.orange,
  );
  return base.copyWith(
      //主色，决定导航栏颜色
      primaryColor: Color.fromRGBO(219, 107, 92, 1),
      //次级色，决定大多数Widget的颜色，如进度条、开关等。
      accentColor: Color.fromRGBO(219, 107, 92, 1),
      // scaffoldBackgroundColor: Color.fromRGBO(0, 0, 0, 0.03),
      accentIconTheme: base.accentIconTheme.copyWith(color: Colors.white),
      dividerColor: Color.fromARGB(255, 245, 241, 241),
      appBarTheme: base.appBarTheme.copyWith(
          // color: Colors.white,
          textTheme:
              TextTheme(title: TextStyle(color: Colors.white, fontSize: 20)),
          iconTheme: IconThemeData(color: Colors.white),
          elevation: 0),

      // Icon的默认样式
      iconTheme:
          base.iconTheme.copyWith(color: Color.fromRGBO(219, 107, 92, 1)),
      //字体主题，包括标题、body等文字样式
      textTheme: _buildTextTheme(base.textTheme),
      primaryTextTheme: _buildTextTheme(base.primaryTextTheme),
      accentTextTheme: _buildTextTheme(base.accentTextTheme),
      inputDecorationTheme: InputDecorationTheme(
          hintStyle: TextStyle(
              color: Colors.black12, fontSize: 15, fontFamily: 'Poppins')));
}

//全局字体主题  --apply 应用在copywith里面的属性
TextTheme _buildTextTheme(TextTheme base) {
  return base
      .copyWith(
          title: base.title.copyWith(fontSize: 20),
          body1: base.body1.copyWith(fontSize: 14),

          ///回复页内容
          body2: base.body2.copyWith(fontSize: 12))
      .apply(
        fontFamily: "Poppins",
      );
}
