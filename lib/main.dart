import 'package:finder/pages/login_page.dart';
import 'package:flutter/material.dart';
import 'package:finder/pages/index_page.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:finder/config/global.dart';
//路由管理
import 'routers/application.dart';
import 'package:fluro/fluro.dart';
import 'routers/routes.dart';
//状态管理
import 'package:finder/provider/user_provider.dart';

void main() {
  Global.init().then((isLogin) => runApp(MyApp(
        isLogin: isLogin,
      )));
}

class MyApp extends StatelessWidget {
  final bool isLogin;
  MyApp({this.isLogin}) {
    final router = Router();
    Routes.configureRoutes(router);
    Application.router = router;
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      //全局状态管理
      providers: [
        ChangeNotifierProvider(
          builder: (_) => UserProvider(),
        )
      ],
      child: MaterialApp(
          localizationsDelegates: [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          supportedLocales: [
            const Locale('zh', 'CH'),
            const Locale('en', 'US'),
          ],
          onGenerateRoute: Application.router.generator,
          theme: _buildAppTheme(),
          title: 'Finder',
          debugShowCheckedModeBanner: false,
          home: LoginPage()),
    );
  }
}

//全局颜色主题
final ThemeData appTheme = _buildAppTheme();

ThemeData _buildAppTheme() {
  const MaterialColor white = const MaterialColor(
    0xFFFFFFFF,
    const <int, Color>{
      50: const Color(0xFFFFFFFF),
      100: const Color(0xFFFFFFFF),
      200: const Color(0xFFFFFFFF),
      300: const Color(0xFFFFFFFF),
      400: const Color(0xFFFFFFFF),
      500: const Color(0xFFFFFFFF),
      600: const Color(0xFFFFFFFF),
      700: const Color(0xFFFFFFFF),
      800: const Color(0xFFFFFFFF),
      900: const Color(0xFFFFFFFF),
    },
  );
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

      // Icon的默认样式
      iconTheme:
          base.iconTheme.copyWith(color: Color.fromRGBO(219, 107, 92, 1)),
      //字体主题，包括标题、body等文字样式
      textTheme: _buildTextTheme(base.textTheme),
      primaryTextTheme: _buildTextTheme(base.primaryTextTheme),
      accentTextTheme: _buildTextTheme(base.accentTextTheme),
      inputDecorationTheme: base.inputDecorationTheme);
}

//全局字体主题  --apply 应用在copywith里面的属性
TextTheme _buildTextTheme(TextTheme base) {
  return base
      .copyWith(
        title: base.title.copyWith(fontSize: 25),
        body1: base.body1.copyWith(fontSize: 13),
      )
      .apply(
        fontFamily: "Poppins",
      );
}
