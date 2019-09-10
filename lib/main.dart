import 'package:flutter/material.dart';
import 'package:finder/pages/login_page.dart';
import 'package:finder/pages/index_page.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:finder/config/api_client.dart';
//路由管理
import 'routers/application.dart';
import 'package:fluro/fluro.dart';
import 'routers/routes.dart';
//状态管理
import 'package:finder/provider/user_provider.dart';

void main() {
  Future(() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    print('token---------${prefs.getString('userToken')}');
    print('正在进行初始化.....');
    var token = prefs.getString("userToken");
    var data = await apiClient.getUserProfile(token);
    return data['status'];
  }).then((isLogin) => runApp(MyApp(
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
        theme: ThemeData(primaryColor: Color.fromRGBO(219, 107, 92, 1)),
        title: 'Finder',
        debugShowCheckedModeBanner: false,
        home: StartApp(
          isLogin: this.isLogin,
        ),
      ),
    );
  }
}

class StartApp extends StatefulWidget {
  final bool isLogin;
  StartApp({this.isLogin});
  @override
  _StartAppState createState() => _StartAppState();
}

class _StartAppState extends State<StartApp> {
  bool isLogin = false;
  String token;

  @override
  void initState() {
    this.isLogin = widget.isLogin;
    super.initState();
    // _validateToken();
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context);
    ScreenUtil.instance = ScreenUtil(width: 750, height: 1334)..init(context);
    if (this.isLogin) {
      print('startapp isrunning.......');
      if (!user.isLogIn) {
        getToken(user);
      }
      return IndexPage();
    } else {
      return LoginPage();
    }
  }

  Future _validateToken({BuildContext context, UserProvider user}) async {
    /* 
    返回 bool 类型 判断token是否有效
    */
    print('validate is running ');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    print('token---------${prefs.getString('userToken')}');
    var token = prefs.getString("userToken");
    var data = await apiClient.getUserProfile(token);
    if (data['status'] == true) {
      setState(() {
        this.token = token;
        isLogin = true;
      });
    } else {
      setState(() {
        isLogin = false;
      });
    }
  }

  Future getToken(UserProvider user) async {
    /*
  获得token 同时获得用户信息
  */
    if (await user.getToken()) {
      user.getUserProfile();
    }
  }
}
