import 'package:finder/pages/home_page.dart';
import 'package:flutter/material.dart';
import 'package:finder/pages/login_page.dart';
import 'package:finder/pages/index_page.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
//路由管理
import 'routers/application.dart';
import 'package:fluro/fluro.dart';
import 'routers/routes.dart';
//状态管理
import 'package:finder/provider/user_provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp() {
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
        theme: ThemeData(primaryColor: Colors.white),
        title: 'Finder',
        debugShowCheckedModeBanner: false,
        home: LoginPage(),
      ),
    );
  }
}
