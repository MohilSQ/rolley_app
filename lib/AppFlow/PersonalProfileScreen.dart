import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rolley_app/AppFlow/DeletePost.dart';
import 'package:rolley_app/AppFlow/EditProfileScreen.dart';
import 'package:rolley_app/AppFlow/ManufacturingProfileScreen.dart';
import 'package:rolley_app/AppFlow/SettingsScreen.dart';
import 'package:rolley_app/Common/ApiClient.dart';
import 'package:rolley_app/Common/Constants.dart';
import 'package:rolley_app/Common/SharedPref.dart';
import 'package:rolley_app/Common/Utils.dart';
import 'package:rolley_app/Common/app_theme.dart';
import 'package:rolley_app/Common/screen_size_utils.dart';
import 'package:rolley_app/Model/DataModel.dart';
import 'package:rolley_app/Model/DataObjectResponse.dart';

import 'ChatScreen.dart';

class PersonalProfile extends StatefulWidget {
  String profileType, userId, isFrom;

  PersonalProfile({this.profileType, this.userId, this.isFrom});

  _PersonalProfileScreenState createState() => _PersonalProfileScreenState();
}

class _PersonalProfileScreenState extends State<PersonalProfile> {
  Utils _utils;
  SharedPref _sharedPref;

  String profileImg = '', bio = '', follower = '', following = '', posts = '', name = '', email = '', contactNumber = '', website = '', address = '', parts = '', isFollow = '';
  List<DataModel> postList = [];

  // Date and time
  static final DateTime now = DateTime.now();
  static final DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm:ss');
  final String formattedDate = formatter.format(now);

  Widget playBotton() {
    return Container(
      height: double.infinity,
      color: Colors.transparent,
      alignment: Alignment.center,
      child: Icon(
        Icons.play_circle_fill_rounded,
        color: AppTheme.orange,
        size: SV.setHeight(90),
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    _utils = Utils(context: context);
    _sharedPref = SharedPref();

    _utils.isNetwotkAvailable(true).then((value) => checkNetwork(value, widget.userId));
  }

  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      bottom: false,
      child: Scaffold(
        appBar: AppBar(
          brightness: Brightness.light,
          backgroundColor: AppTheme.gray,
          centerTitle: true,
          title: Text(
            'Personal Profile',
            style: TextStyle(
              fontFamily: AppTheme.fontName,
              fontSize: SV.setSP(60),
              color: AppTheme.black,
            ),
          ),
          leadingWidth: SV.setWidth(widget.isFrom == "otherProfile" ? 200 : 130),
          leading: GestureDetector(
            onTap: () {
              if (widget.isFrom == "otherProfile") {
                Navigator.pop(context);
              }
            },
            child: Container(
              color: Colors.transparent,
              child: Row(
                children: [
                  Visibility(
                    visible: widget.isFrom == "otherProfile",
                    child: Row(
                      children: [
                        SizedBox(width: SV.setWidth(20)),
                        Image.asset(
                          'assets/images/ic_back.png',
                          height: SV.setWidth(70),
                          width: SV.setWidth(60),
                        ),
                      ],
                    ),
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
          actions: [
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute<dynamic>(
                    builder: (BuildContext context) => ManufacturingProfileScreen(),
                  ),
                );
              },
              child: Padding(
                padding: EdgeInsets.only(top: 14, bottom: 14),
                child: Image.asset(
                  'assets/images/ic_tab_unselected_02.png',
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute<dynamic>(
                    builder: (BuildContext context) => SettingsScreen(),
                  ),
                );
              },
              child: Padding(
                padding: EdgeInsets.all(14.0),
                child: Image.asset(
                  'assets/images/ic_setting.png',
                ),
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView(
                padding: EdgeInsets.all(SV.setWidth(50)),
                children: [
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: CachedNetworkImage(
                          imageUrl: profileImg,
                          placeholder: (context, url) => Image.asset('assets/images/ic_default_profile.png'),
                          errorWidget: (context, url, error) => Image.asset('assets/images/ic_default_profile.png'),
                          fit: BoxFit.cover,
                          height: SV.setWidth(300),
                          width: SV.setWidth(300),
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
                              name,
                              style: TextStyle(
                                fontFamily: AppTheme.fontName,
                                fontSize: SV.setSP(66),
                                color: AppTheme.black,
                              ),
                            ),
                            Text(
                              bio,
                              style: TextStyle(
                                fontFamily: AppTheme.fontName,
                                fontSize: SV.setSP(40),
                                color: AppTheme.lightGray,
                              ),
                            ),
                            Row(
                              children: [
                                GestureDetector(
                                  onTap: () {},
                                  child: widget.profileType != "personal"
                                      ? GestureDetector(
                                          onTap: () async {
                                            DataModel someMap = new DataModel();
                                            someMap.profile_image = profileImg;
                                            someMap.name = name;
                                            someMap.roomNo = await _sharedPref.getUserId() + "-" + widget.userId;
                                            someMap.user_id = widget.userId;

                                            printWrapped("someMap ---------->>> $someMap");
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute<dynamic>(
                                                builder: (BuildContext context) => ChatScreen(
                                                  userObject: someMap,
                                                  isFromProfile: true,
                                                ),
                                              ),
                                            );
                                          },
                                          child: Container(
                                            height: SV.setHeight(88.0),
                                            width: SV.setHeight(88.0),
                                            padding: EdgeInsets.all(SV.setWidth(18)),
                                            decoration: BoxDecoration(
                                              color: AppTheme.lightGray,
                                              borderRadius: BorderRadius.circular(6.0),
                                            ),
                                            child: Image.asset('assets/images/ic_chat_white.png'),
                                          ),
                                        )
                                      : Container(),
                                ),
                                SizedBox(
                                  width: SV.setWidth(20),
                                ),
                                widget.profileType == "personal"
                                    ? FlatButton(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(6.0),
                                          side: BorderSide(
                                            color: AppTheme.orange,
                                            width: 2,
                                          ),
                                        ),
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute<dynamic>(
                                              builder: (BuildContext context) => EditProfileScreen(
                                                profileImg,
                                                widget.userId,
                                                name,
                                                bio,
                                                email,
                                                contactNumber,
                                                website,
                                                address,
                                                parts,
                                                (val) {
                                                  if (val != "") {
                                                    _utils.isNetwotkAvailable(true).then(
                                                          (value) => checkNetwork(value, widget.userId),
                                                        );
                                                  }
                                                },
                                              ),
                                            ),
                                          );
                                        },
                                        color: AppTheme.orange,
                                        textColor: Colors.white,
                                        padding: EdgeInsets.symmetric(
                                          horizontal: SV.setWidth(70),
                                          vertical: SV.setHeight(26),
                                        ),
                                        child: Row(
                                          children: [
                                            Text(
                                              "Edit Profile",
                                              style: TextStyle(
                                                fontSize: SV.setSP(40),
                                                color: Colors.white,
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                    : FlatButton(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(6.0),
                                          side: BorderSide(
                                            color: AppTheme.orange,
                                            width: 2,
                                          ),
                                        ),
                                        onPressed: () {
                                          _utils.isNetwotkAvailable(true).then(
                                                (value) => checkNetworkFollow(value),
                                              );
                                        },
                                        color: AppTheme.orange,
                                        textColor: Colors.white,
                                        padding: EdgeInsets.symmetric(
                                          horizontal: SV.setWidth(70),
                                          vertical: SV.setHeight(
                                            26,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Text(
                                              isFollow == '1' ? 'Following' : 'Follow',
                                              style: TextStyle(
                                                fontSize: SV.setSP(40),
                                                color: Colors.white,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: SV.setHeight(60),
                  ),
                  Container(
                    height: 1.0,
                    decoration: BoxDecoration(
                      color: AppTheme.Border,
                    ),
                  ),
                  SizedBox(
                    height: SV.setHeight(60),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              'Follower',
                              style: TextStyle(
                                fontSize: SV.setSP(44),
                                color: AppTheme.lightGray,
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Text(
                              follower,
                              style: TextStyle(
                                fontSize: SV.setSP(56),
                                color: AppTheme.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              "Following",
                              style: TextStyle(
                                fontSize: SV.setSP(44),
                                color: AppTheme.lightGray,
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Text(
                              following,
                              style: TextStyle(
                                fontSize: SV.setSP(56),
                                color: AppTheme.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              "Posts",
                              style: TextStyle(
                                fontSize: SV.setSP(44),
                                color: AppTheme.lightGray,
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Text(
                              posts,
                              style: TextStyle(
                                fontSize: SV.setSP(56),
                                color: AppTheme.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: SV.setHeight(60),
                  ),
                  Container(
                    height: 1,
                    decoration: BoxDecoration(
                      color: AppTheme.Border,
                    ),
                  ),
                  SizedBox(
                    height: SV.setHeight(60),
                  ),
                  GridView.builder(
                    
                    shrinkWrap: true,
                    itemCount: postList.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                    ),
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: EdgeInsets.all(
                          SV.setHeight(10.0),
                        ),
                        child: GestureDetector(
                          onTap: () {
                            if (widget.profileType == "personal") {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DeleatPost(
                                    postid: postList[index].id,
                                    postdata: postList[index],
                                    callback: (val) {
                                      if (val == "") {
                                        _utils.isNetwotkAvailable(true).then(
                                              (value) => checkNetwork(value, widget.userId),
                                            );
                                      }
                                    },
                                  ),
                                ),
                              );
                            }
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: AppTheme.lightGray,
                                width: 1,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: postList[index].post_images.isNotEmpty
                                  ? Stack(
                                      fit: StackFit.expand,
                                      children: [
                                        Container(
                                          height: double.infinity,
                                          width: double.infinity,
                                          child: CachedNetworkImage(
                                            imageUrl: postList[index].post_images[0].video_thumb == "" ? postList[index].post_images[0].image : postList[index].post_images[0].video_thumb,
                                            placeholder: (context, url) => Image.asset(
                                              'assets/images/ic_manue_defalt.jpg',
                                              fit: BoxFit.cover,
                                            ),
                                            errorWidget: (context, url, error) => Image.asset(
                                              'assets/images/ic_manue_defalt.jpg',
                                              fit: BoxFit.cover,
                                            ),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        postList[index].post_images[0].video_thumb != "" ? playBotton() : Container(),
                                      ],
                                    )
                                  : Image.asset(
                                      'assets/images/ic_manue_defalt.jpg',
                                      fit: BoxFit.cover,
                                    ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            SizedBox(height: SV.setHeight(130)),
          ],
        ),
      ),
    );
  }

  //*************************************
  // Load Personal Profile data :-
  //*************************************
  checkNetwork(bool value, userId) {
    if (value) {
      _utils.showProgressDialog();
      Future<DataObjectResponse> user = loadPersonalProfile(userId);
      user.then((value) => responseProfile(value));
    }
  }

  Future<DataObjectResponse> loadPersonalProfile(userId) async {
    try {
      FormData formData = FormData.fromMap({
        'user_id': await _sharedPref.getUserId(),
        'other_id': widget.userId,
      });
      printWrapped('${formData.fields}---paRAM');
      Response response = await ApiClient().apiClientInstance(context, await _sharedPref.getToken()).post('ProfileDetails', data: formData);
      return DataObjectResponse.fromJson(response.data);
    } catch (e) {
      printWrapped(e);
      return null;
    }
  }

  responseProfile(DataObjectResponse value) {
    _utils.hideProgressDialog();
    if (value != null) {
      if (value.ResponseCode == 1) {
        //alertDialog(value.ResponseMessage);
        setState(() {
          profileImg = value.Result.profile_image;
          name = value.Result.name;
          bio = value.Result.bio;
          follower = value.Result.followers;
          following = value.Result.followings;
          posts = value.Result.posts;
          email = value.Result.email;
          contactNumber = value.Result.contact_number;
          website = value.Result.website;
          address = value.Result.address;
          parts = value.Result.manufacturing_parts;
          postList = value.Result.post_list;
          isFollow = value.Result.is_follow;
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
      Future<DataObjectResponse> user = followUnFollowAPI();
      user.then((value) => responseFollow(value));
    }
  }

  Future<DataObjectResponse> followUnFollowAPI() async {
    try {
      FormData formData = FormData.fromMap({
        'user_id': await _sharedPref.getUserId(),
        'other_id': widget.userId,
        'date_time': formattedDate,
      });
      printWrapped('${formData.fields}---paRAM');
      Response response = await ApiClient().apiClientInstance(context, await _sharedPref.getToken()).post('Follow', data: formData);
      return DataObjectResponse.fromJson(response.data);
    } catch (e) {
      printWrapped(e);
      return null;
    }
  }

  responseFollow(DataObjectResponse value) {
    _utils.hideProgressDialog();
    if (value != null) {
      if (value.ResponseCode == 1) {
        _utils.isNetwotkAvailable(true).then((value) => checkNetwork(value, widget.userId));
      } else {
        _utils.alertDialog(value.ResponseMessage);
      }
    }
  }
}
