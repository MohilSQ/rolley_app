import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
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

class FollowAndInviteFriends extends StatefulWidget {
  @override
  _FollowAndInviteFriendsState createState() => _FollowAndInviteFriendsState();
}

class _FollowAndInviteFriendsState extends State<FollowAndInviteFriends> {
  Utils _utils;
  SharedPref _sharedPref;
  List<DataModel> userList = [];

  String search = '';
  String userId;
  String myUserId;
  String isfollow;

  static final DateTime now = DateTime.now();
  static final DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm:ss');
  final String formattedDate = formatter.format(now);

  getUserId() async {
    myUserId = await _sharedPref.getUserId();
  }

  @override
  void initState() {
    super.initState();

    _utils = Utils(context: context);
    _sharedPref = SharedPref();
    getUserId();
    _utils.isNetwotkAvailable(true).then((value) => checkNetwork(value));
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.instance.init(context);
    return SafeArea(
      top: false,
      bottom: false,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          automaticallyImplyLeading: false,
          titleSpacing: 0.0,
          brightness: Brightness.light,
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
            'Follow & Following',
            style: TextStyle(
              fontFamily: AppTheme.fontName,
              fontSize: SV.setSP(60),
              color: AppTheme.black,
            ),
          ),
        ),
        body: Container(
          child: Column(
            children: [
              Expanded(
                child: Visibility(
                  visible: userList.isNotEmpty,
                  replacement: Center(
                    child: Text(
                      "No User found",
                      style: TextStyle(
                        fontFamily: AppTheme.fontName,
                        fontSize: SV.setSP(56),
                        color: AppTheme.black,
                      ),
                    ),
                  ),
                  child: ListView.separated(
                    padding: EdgeInsets.all(SV.setWidth(30)),
                    itemCount: userList.length,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      return userList[index].id == myUserId
                          ? Container()
                          : Container(
                              child: Column(
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      debugPrint("user_id ------------>>>> ${userList[index].id}");
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute<dynamic>(
                                          builder: (BuildContext context) => PersonalProfile(
                                            profileType: userList[index].id == myUserId ? "personal" : "other",
                                            userId: userList[index].id,
                                            isFrom: "otherProfile",
                                          ),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      padding: EdgeInsets.fromLTRB(
                                        SV.setWidth(40),
                                        SV.setWidth(40),
                                        SV.setWidth(40),
                                        SV.setWidth(40),
                                      ),
                                      color: AppTheme.gray,
                                      child: Row(
                                        children: [
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(12),
                                            child: CachedNetworkImage(
                                              imageUrl: userList[index].profile_image,
                                              placeholder: (context, url) => Image.asset(
                                                'assets/images/ic_default_profile.png',
                                                fit: BoxFit.cover,
                                              ),
                                              errorWidget: (context, url, error) => Image.asset(
                                                'assets/images/ic_default_profile.png',
                                                fit: BoxFit.cover,
                                              ),
                                              height: SV.setWidth(150),
                                              width: SV.setWidth(150),
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                          SizedBox(
                                            width: SV.setWidth(40),
                                          ),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  userList[index].name + ' ',
                                                  overflow: TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    fontFamily: AppTheme.fontName,
                                                    fontSize: SV.setSP(50),
                                                    color: AppTheme.black,
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: SV.setHeight(5),
                                                ),
                                                Text(
                                                  userList[index].bio,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    fontFamily: AppTheme.fontName,
                                                    fontSize: SV.setSP(40),
                                                    color: AppTheme.lightGray,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                userId = userList[index].id;
                                              });
                                              _utils.isNetwotkAvailable(true).then(
                                                    (value) => checkNetworkFollow(value),
                                                  );
                                            },
                                            child: Container(
                                              height: SV.setHeight(85),
                                              width: SV.setWidth(240),
                                              alignment: Alignment.center,
                                              decoration: BoxDecoration(
                                                color: userList[index].is_follow == "1" ? AppTheme.gray : AppTheme.orange,
                                                borderRadius: BorderRadius.all(
                                                  Radius.circular(
                                                    SV.setSP(13),
                                                  ),
                                                ),
                                                border: userList[index].is_follow == "1"
                                                    ? Border.all(
                                                        color: AppTheme.orange,
                                                        width: 2,
                                                      )
                                                    : null,
                                              ),
                                              child: Text(
                                                userList[index].is_follow == "1" ? "Following" : "Follow",
                                                style: TextStyle(
                                                  fontFamily: AppTheme.fontName,
                                                  fontSize: SV.setSP(40),
                                                  color: userList[index].is_follow == "1" ? AppTheme.orange : AppTheme.gray,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
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
            ],
          ),
        ),
      ),
    );
  }

  //*************************************
  // Users List :-
  //*************************************
  checkNetwork(bool value) {
    if (value) {
      _utils.showProgressDialog();
      Future<DataArrayModel> user = usersList();
      user.then((value) => responsePostList(value));
    }
  }

  Future<DataArrayModel> usersList() async {
    try {
      FormData formData = FormData.fromMap({
        'user_id': await _sharedPref.getUserId(),
      });
      printWrapped('${formData.fields}---paRAM');
      Response response = await ApiClient()
          .apiClientInstance(
            context,
            await _sharedPref.getToken(),
          )
          .post('userList', data: formData);
      return DataArrayModel.fromJson(response.data);
    } catch (e) {
      printWrapped(e);
      return null;
    }
  }

  responsePostList(DataArrayModel value) {
    _utils.hideProgressDialog();
    if (value != null) {
      if (value.ResponseCode == 1) {
        setState(() {
          userList = value.Result;
        });
      } else {
        _utils.alertDialog(value.ResponseMessage);
      }
    }
  }

  //*************************************
// follow & Following API :-
//*************************************
  checkNetworkFollow(bool value) {
    if (value) {
      _utils.showProgressDialog();
      Future<DataArrayModel> user = followUnFollowAPI();
      user.then((value) => responseFollow(value));
    }
  }

  Future<DataArrayModel> followUnFollowAPI() async {
    try {
      FormData formData = FormData.fromMap({
        'user_id': await _sharedPref.getUserId(),
        'other_id': userId,
        'date_time': formattedDate,
      });
      printWrapped("-------------User Id------------$userId");
      printWrapped('${formData.fields}---paRAM');
      Response response = await ApiClient()
          .apiClientInstance(
            context,
            await _sharedPref.getToken(),
          )
          .post('Follow', data: formData);
      return DataArrayModel.fromJson(response.data);
    } catch (e) {
      printWrapped(e);
      return null;
    }
  }

  responseFollow(DataArrayModel value) {
    _utils.hideProgressDialog();
    if (value != null) {
      if (value.ResponseCode == 1) {
        _utils.isNetwotkAvailable(true).then((value) => checkNetwork(value));
      } else {
        _utils.alertDialog(value.ResponseMessage);
      }
    }
  }
}
