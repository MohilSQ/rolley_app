import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:rolley_app/AppFlow/ActivityScreen.dart';
import 'package:rolley_app/AppFlow/FeedScreen.dart';
import 'package:rolley_app/AppFlow/FollowAndInviteFriends.dart';
import 'package:rolley_app/AppFlow/LoginScreen.dart';
import 'package:rolley_app/AppFlow/PaymentHistory.dart';
import 'package:rolley_app/Common/ApiClient.dart';
import 'package:rolley_app/Common/Constants.dart';
import 'package:rolley_app/Common/SharedPref.dart';
import 'package:rolley_app/Common/Utils.dart';
import 'package:rolley_app/Common/app_theme.dart';
import 'package:rolley_app/Common/screen_size_utils.dart';
import 'package:rolley_app/Model/DataObjectResponse.dart';

class SettingsScreen extends StatefulWidget {
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  Utils _utils;
  SharedPref _sharedPref;

  var settingsArr = ["Save Post", "Follow and Invite Friends", "Notifications ", "Privacy and Security", "Payments", "Help", "About", "Log Out"];
  var settingsImgArr = ["ic_tab_unselected_03.png", "ic_settings_01.png", "ic_settings_02.png", "ic_settings_03.png", "ic_settings_04.png", "ic_settings_06.png", "ic_settings_07.png", "ic_settings_08.png"];

  @override
  void initState() {
    super.initState();

    _utils = Utils(context: context);
    _sharedPref = SharedPref();
  }

  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      bottom: false,
      child: Scaffold(
        appBar: AppBar(
          brightness: Brightness.light,
          backgroundColor: AppTheme.gray,
          titleSpacing: 0.0,
          automaticallyImplyLeading: false,
          centerTitle: true,
          leadingWidth: SV.setWidth(200),
          leading: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Container(
              color: Colors.transparent,
              child: Row(
                children: [
                  SizedBox(width: SV.setWidth(20)),
                  Image.asset(
                    'assets/images/ic_back.png',
                    height: SV.setWidth(70),
                    width: SV.setWidth(60),
                  ),
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
          title: Text(
            'Settings',
            style: TextStyle(
              fontFamily: AppTheme.fontName,
              fontSize: SV.setSP(60),
              color: AppTheme.black,
            ),
          ),
        ),
        body: ListView.builder(
          itemCount: settingsArr.length,
          itemBuilder: (context, index) {
            return Column(
              children: [
                GestureDetector(
                  onTap: () {
                    if (index == 0) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FeedScreen(
                            identify: "Save Feed",
                          ),
                        ),
                      );
                    } else if (index == 1) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FollowAndInviteFriends(),
                        ),
                      );
                    } else if (index == 2) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ActivityScreen(),
                        ),
                      );
                    } else if (index == 3) {
                    } else if (index == 4) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PaymentHistory(),
                        ),
                      );
                    } else if (index == 5) {
                    } else if (index == 6) {
                    } else if (index == 7) {
                      _utils.isNetwotkAvailable(true).then(
                            (value) => checkNetwork(value),
                          );
                    }
                  },
                  child: Container(
                    color: Colors.transparent,
                    padding: EdgeInsets.only(
                      left: SV.setWidth(60),
                      right: SV.setWidth(60),
                      top: SV.setWidth(40),
                      bottom: SV.setWidth(40),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(SV.setWidth(44.0)),
                          height: SV.setWidth(180),
                          width: SV.setWidth(180),
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), boxShadow: [
                            new BoxShadow(
                              color: Colors.black12,
                              offset: Offset(0.0, 1), //(x,y)
                              blurRadius: 6.0,
                            ),
                          ]),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.asset('assets/images/' + settingsImgArr[index]),
                          ),
                        ),
                        SizedBox(
                          width: SV.setWidth(60),
                        ),
                        Text(
                          settingsArr[index],
                          style: TextStyle(
                            fontFamily: AppTheme.fontName,
                            fontSize: SV.setSP(60),
                            color: AppTheme.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Divider(height: 0.5, color: AppTheme.Border),
              ],
            );
          },
        ),
      ),
    );
  }

  //*************************************
  // Add Remove Like :-
  //*************************************
  checkNetwork(bool value) {
    if (value) {
      _utils.showProgressDialog();
      Future<DataObjectResponse> user = logout();
      user.then((value) => responseAddRemoveLike(value));
    }
  }

  Future<DataObjectResponse> logout() async {
    try {
      FormData formData = FormData.fromMap({
        'id': await _sharedPref.getUserId(),
      });
      printWrapped('${formData.fields}---paRAM');
      Response response = await ApiClient().apiClientInstance(context, await _sharedPref.getToken()).post('logout', data: formData);
      return DataObjectResponse.fromJson(response.data);
    } catch (e) {
      printWrapped(e);
      return null;
    }
  }

  responseAddRemoveLike(DataObjectResponse value) {
    _utils.hideProgressDialog();
    if (value != null) {
      if (value.ResponseCode == 1) {
        storeData(value).then((value) => Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => LoginScreen()), (Route<dynamic> route) => false));

        // _utils.alertDialog(value.ResponseMessage);
      } else {
        _utils.alertDialog(value.ResponseMessage);
      }
    }
  }

  Future<void> storeData(DataObjectResponse objectResponse) async {
    _sharedPref.remove(_sharedPref.UserId);
    _sharedPref.remove(_sharedPref.Token);
    _sharedPref.remove(_sharedPref.UserResponse);
  }
}
