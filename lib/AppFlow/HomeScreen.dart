import 'package:flutter/material.dart';
import 'package:rolley_app/AppFlow/ShowCaseScreen.dart';
import 'package:rolley_app/Common/app_theme.dart';
import 'package:rolley_app/Common/screen_size_utils.dart';

class Home extends StatefulWidget {
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      bottom: false,
      child: Scaffold(
        appBar: AppBar(
          brightness: Brightness.light,
          backgroundColor: AppTheme.gray,
          title: Text(
            'Home',
            style: TextStyle(
              fontFamily: AppTheme.fontName,
              fontSize: SV.setSP(60),
              color: AppTheme.black,
            ),
          ),
          centerTitle: true,
          leadingWidth: SV.setWidth(130),
          leading: Container(
            color: Colors.transparent,
            child: Row(
              children: [
                SizedBox(width: SV.setWidth(20)),
                Image.asset(
                  'assets/images/ic_logo_appbar.png',
                  height: SV.setWidth(70),
                  width: SV.setWidth(70),
                ),
              ],
            ),
          ),
        ),
        body: Column(
          children: [
            SizedBox(height: 1.5),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute<dynamic>(
                            builder: (BuildContext context) => ShowCaseScreen(
                              postType: "Cars",
                            ),
                          ),
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppTheme.gray,
                          border: Border.all(color: Colors.white, width: 0.8),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(SV.setHeight(40)),
                          child: Image.asset(
                            'assets/images/car_gif.png',
                            fit: BoxFit.cover,
                            height: double.infinity,
                            width: double.infinity,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute<dynamic>(
                            builder: (BuildContext context) => ShowCaseScreen(
                              postType: "Trucks",
                            ),
                          ),
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppTheme.gray,
                          border: Border.all(color: Colors.white, width: 0.8),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(SV.setHeight(40)),
                          child: Image.asset(
                            'assets/images/truck_gif.png',
                            fit: BoxFit.cover,
                            height: double.infinity,
                            width: double.infinity,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute<dynamic>(
                            builder: (BuildContext context) => ShowCaseScreen(postType: "Motorcycle"),
                          ),
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppTheme.gray,
                          border: Border.all(color: Colors.white, width: 0.8),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(SV.setHeight(40)),
                          child: Image.asset(
                            'assets/images/bike_gif.png',
                            fit: BoxFit.cover,
                            height: double.infinity,
                            width: double.infinity,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute<dynamic>(
                            builder: (BuildContext context) => ShowCaseScreen(postType: "Miscellaneous"),
                          ),
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppTheme.gray,
                          border: Border.all(color: Colors.white, width: 0.8),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(SV.setHeight(40)),
                          child: Image.asset(
                            'assets/images/Miscellaneous _gif.png',
                            fit: BoxFit.cover,
                            height: double.infinity,
                            width: double.infinity,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 1.5),
            SizedBox(height: SV.setHeight(250))
          ],
        ),
      ),
    );
  }
}
