import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rolley_app/AppFlow/LoginScreen.dart';
import 'package:rolley_app/AppFlow/MainTabScreen.dart';
import 'package:rolley_app/Common/Constants.dart';
import 'package:rolley_app/Common/SharedPref.dart';
import 'package:rolley_app/Common/Utils.dart';
import 'package:rolley_app/Common/app_theme.dart';
import 'package:rolley_app/Common/screen_size_utils.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Utils utils;
  SharedPref _sharedPref;

  @override
  void initState() {
    super.initState();

    utils = Utils(context: context);
    _sharedPref = SharedPref();

    new Future.delayed(new Duration(seconds: 2), () {
      readData();
    });
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([]);
    ScreenUtil.instance.init(context);

    return SafeArea(
      top: false,
      bottom: false,
      child: Scaffold(
        body: Container(
          color: AppTheme.themeBlue,
          height: double.infinity,
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/ic_appicon_logo.png',
                height: SV.setWidth(600),
                width: SV.setWidth(600),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> readData() async {
    // bool hashKey = await _sharedPref.containKey(_sharedPref.UserId);
    String userId = '';
    // if (hashKey) {
    userId = await _sharedPref.getUserId();
    printWrapped("userId: --------> $userId");
    // }

    if (utils.isValidationEmpty(userId)) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute<dynamic>(
          builder: (BuildContext context) => LoginScreen(),
        ),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute<dynamic>(
          builder: (BuildContext context) => MainTab(),
        ),
      );
    }
  }
}
