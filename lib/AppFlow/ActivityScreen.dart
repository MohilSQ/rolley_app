import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rolley_app/AppFlow/PersonalProfileScreen.dart';
import 'package:rolley_app/Common/ApiClient.dart';
import 'package:rolley_app/Common/Constants.dart';
import 'package:rolley_app/Common/SharedPref.dart';
import 'package:rolley_app/Common/Utils.dart';
import 'package:rolley_app/Common/app_theme.dart';
import 'package:rolley_app/Common/screen_size_utils.dart';
import 'package:rolley_app/Model/DataArrayModel.dart';
import 'package:rolley_app/Model/DataModel.dart';

class ActivityScreen extends StatefulWidget {
  _ActivityScreenState createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  //Constants.ScreenPortrait();
  Utils _utils;
  SharedPref _sharedPref;
  List<DataModel> activityList = [];

  // Date and time
  static final DateTime now = DateTime.now();
  static final DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm:ss');
  final String formattedDate = formatter.format(now);

  String search = '';
  String userId;

  @override
  void initState() {
    super.initState();

    _utils = Utils(context: context);
    _sharedPref = SharedPref();

    _utils.isNetwotkAvailable(true).then((value) => checkNetwork(value));
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        automaticallyImplyLeading: false,
        titleSpacing: 0.0,
        backgroundColor: AppTheme.gray,
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
          'Activity',
          style: TextStyle(
            fontFamily: AppTheme.fontName,
            fontSize: SV.setSP(60),
            color: AppTheme.black,
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        bottom: false,
        child: Container(
          child: activityList.isEmpty
              ? Center(
                  child: Text(
                    "No Notification found",
                    style: TextStyle(
                      fontFamily: AppTheme.fontName,
                      fontSize: SV.setSP(56),
                      color: AppTheme.black,
                    ),
                  ),
                )
              : ListView.separated(
                  padding: EdgeInsets.all(SV.setWidth(30)),
                  itemCount: activityList.length,
                  itemBuilder: (context, index) {
                    return Container(
                      padding: EdgeInsets.all(SV.setWidth(40)),
                      color: AppTheme.gray,
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute<dynamic>(
                                  builder: (BuildContext context) => PersonalProfile(
                                    profileType: "other",
                                    userId: activityList[index].user_id,
                                    isFrom: "otherProfile",
                                  ),
                                ),
                              );
                            },
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: CachedNetworkImage(
                                imageUrl: activityList[index].user_image,
                                placeholder: (context, url) => Image.asset(
                                  'assets/images/ic_default_profile.png',
                                  fit: BoxFit.cover,
                                ),
                                errorWidget: (context, url, error) => Image.asset(
                                  'assets/images/ic_default_profile.png',
                                  fit: BoxFit.cover,
                                ),
                                height: SV.setWidth(200),
                                width: SV.setWidth(200),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          SizedBox(width: SV.setWidth(40)),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                RichText(
                                  text: TextSpan(
                                    children: <TextSpan>[
                                      TextSpan(
                                        text: activityList[index].user_name + ' ',
                                        style: TextStyle(
                                          fontFamily: AppTheme.fontName,
                                          fontSize: SV.setSP(50),
                                          color: AppTheme.black,
                                        ),
                                      ),
                                      TextSpan(
                                        text: activityList[index].massage,
                                        style: TextStyle(
                                          fontFamily: AppTheme.fontName,
                                          fontSize: SV.setSP(50),
                                          color: AppTheme.lightGray,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: SV.setHeight(20)),
                                Text(
                                  activityList[index].date_time,
                                  style: TextStyle(
                                    fontFamily: AppTheme.fontName,
                                    fontSize: SV.setSP(38),
                                    color: AppTheme.lightGray,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  separatorBuilder: (context, index) => Divider(
                    height: 0,
                    thickness: 1.5,
                  ),
                ),
        ),
      ),
    );
  }

  //*************************************
  // Activity List :-
  //*************************************
  checkNetwork(bool value) {
    if (value) {
      _utils.showProgressDialog();
      Future<DataArrayModel> user = activitysList();
      user.then((value) => responsePostList(value));
    }
  }

  Future<DataArrayModel> activitysList() async {
    try {
      FormData formData = FormData.fromMap({
        'user_id': await _sharedPref.getUserId(),
      });
      printWrapped('${formData.fields}---paRAM');
      Response response = await ApiClient().apiClientInstance(context, await _sharedPref.getToken()).post('notificationList', data: formData);
      return DataArrayModel.fromJson(response.data);
    } catch (e) {
      printWrapped(e.toString());
      return null;
    }
  }

  responsePostList(DataArrayModel value) {
    _utils.hideProgressDialog();
    if (value != null) {
      if (value.ResponseCode == 1) {
        setState(() {
          printWrapped("value.Result ---------->> " + value.Result.toString());
          activityList = value.Result;
        });
      } else {
        _utils.alertDialog(value.ResponseMessage);
      }
    }
  }
}
