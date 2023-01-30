//FeedScreen
import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:marquee/marquee.dart';
import 'package:rolley_app/AppFlow/CommentScreen.dart';
import 'package:rolley_app/AppFlow/DeletePost.dart';
import 'package:rolley_app/AppFlow/PersonalProfileScreen.dart';
import 'package:rolley_app/AppFlow/editFeedScreen.dart';
import 'package:rolley_app/Common/ApiClient.dart';
import 'package:rolley_app/Common/Constants.dart';
import 'package:rolley_app/Common/SharedPref.dart';
import 'package:rolley_app/Common/Utils.dart';
import 'package:rolley_app/Common/app_theme.dart';
import 'package:rolley_app/Common/common_widget.dart';
import 'package:rolley_app/Common/screen_size_utils.dart';
import 'package:rolley_app/Model/DataArrayModel.dart';
import 'package:rolley_app/Model/DataModel.dart';
import 'package:rolley_app/Model/DataObjectResponse.dart';
import 'package:rolley_app/Model/video_list_data.dart';

class FeedScreen extends StatefulWidget {
  final String identify;

  const FeedScreen({Key key, this.identify}) : super(key: key);
  _FeedScreenState createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  bool isLinkFbVal = false;
  Utils _utils;
  SharedPref _sharedPref;
  List<DataModel> feedList = [];
  String userId;
  String image;

  List<String> editDeleteSave = [];

  // Date and time
  static final DateTime now = DateTime.now();
  static final DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm:ss');
  final String formattedDate = formatter.format(now);

  @override
  void initState() {
    super.initState();

    _utils = Utils(context: context);
    _sharedPref = SharedPref();

    setState(() {
      getUserId();
    });

    _utils.isNetwotkAvailable(true).then((value) => checkNetwork(value));
  }

  onBack() {
    _utils.isNetwotkAvailable(true).then((value) => checkNetwork(value));
  }

  getUserId() async {
    userId = await _sharedPref.getUserId();
  }

  Widget waterMark() {
    return Container(
      height: SV.setHeight(95),
      width: SV.setHeight(95),
      alignment: Alignment.center,
      margin: EdgeInsets.all(SV.setHeight(10)),
      decoration: BoxDecoration(
        color: Colors.black12,
        borderRadius: BorderRadius.circular(SV.setHeight(10)),
      ),
      child: Image.asset(
        "assets/images/logo_transparent.png",
        height: SV.setHeight(85),
      ),
    );
  }

  //*************************************
  // UI :-
  //*************************************
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      bottom: false,
      child: Scaffold(
        appBar: AppBar(
          brightness: Brightness.light,
          backgroundColor: AppTheme.gray,
          title: Text(
            widget.identify,
            style: TextStyle(
              fontFamily: AppTheme.fontName,
              fontSize: SV.setSP(60),
              color: AppTheme.black,
            ),
          ),
          leadingWidth: SV.setWidth(widget.identify == "Save Feed" ? 200 : 130),
          leading: GestureDetector(
            onTap: () {
              if (widget.identify == "Save Feed") {
                Navigator.pop(context);
              }
            },
            child: Container(
              color: Colors.transparent,
              child: Row(
                children: [
                  Visibility(
                    visible: widget.identify == "Save Feed",
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
            Padding(
              padding: EdgeInsets.all(14.0),
              child: Container(),
            ),
          ],
        ),
        body: Column(
          children: [
            Container(
              height: SV.setHeight(120),
              width: double.infinity,
              color: AppTheme.themeBlue,
              alignment: Alignment.center,
              child: Material(
                color: AppTheme.themeBlue,
                child: Marquee(
                  text: 'Welcome To ROLLEY  Welcome To ROLLEY Welcome To ROLLEY Welcome To ROLLEY Welcome To ROLLEY Welcome To ROLLEY Welcome To ROLLEY',
                  style: TextStyle(
                    fontSize: SV.setHeight(50),
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFCCD6E0),
                  ),
                  scrollAxis: Axis.horizontal,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  blankSpace: 10,
                  velocity: 100.0,
                  pauseAfterRound: Duration(seconds: 0),
                  startPadding: 10.0,
                  accelerationDuration: Duration(milliseconds: 0),
                  accelerationCurve: Curves.linear,
                  decelerationDuration: Duration(milliseconds: 0),
                  decelerationCurve: Curves.easeOut,
                ),
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () {
                  return Future.delayed(
                    Duration(seconds: 1),
                    () {
                      _utils.isNetwotkAvailable(true).then((value) => checkNetwork(value));
                    },
                  );
                },
                child: Visibility(
                  visible: feedList.isNotEmpty,
                  replacement: Center(
                    child: Text(
                      "No Feed found",
                      style: TextStyle(
                        fontFamily: AppTheme.fontName,
                        fontSize: SV.setSP(56),
                        color: AppTheme.black,
                      ),
                    ),
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: feedList?.length,
                    padding: EdgeInsets.all(SV.setWidth(40)),
                    separatorBuilder: (context, index) => SizedBox(height: SV.setHeight(50)),
                    itemBuilder: (context, index) {
                      VideoListData videoListData = feedList[index].post_images.isNotEmpty ? VideoListData("", feedList[index].post_images[0].image) : VideoListData("", "");
                      return Container(
                        color: AppTheme.gray,
                        child: Column(
                          children: [
                            Padding(
                              padding: EdgeInsets.all(SV.setWidth(30)),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          printWrapped(feedList[index].share_user_id + " -- " + userId);
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute<dynamic>(
                                              builder: (BuildContext context) => PersonalProfile(
                                                profileType: feedList[index].share_user_id == userId ? "personal" : "other",
                                                userId: feedList[index].share_user_id,
                                                isFrom: "otherProfile",
                                              ),
                                            ),
                                          ).then((value) => onBack());
                                        },
                                        child: Container(
                                          color: Colors.transparent,
                                          child: Row(
                                            children: [
                                              ClipRRect(
                                                borderRadius: BorderRadius.circular(
                                                  SV.setWidth(80.0),
                                                ),
                                                child: CachedNetworkImage(
                                                  imageUrl: feedList[index].share_details != null && feedList[index].share_details.isNotEmpty ? feedList[index].share_details[0].profile_image : feedList[index].profile_image,
                                                  placeholder: (context, url) => Image.asset('assets/images/ic_default_profile.png'),
                                                  errorWidget: (context, url, error) => Image.asset('assets/images/ic_default_profile.png'),
                                                  fit: BoxFit.cover,
                                                  height: SV.setWidth(160),
                                                  width: SV.setWidth(160),
                                                ),
                                              ),
                                              SizedBox(width: SV.setWidth(40)),
                                              Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    feedList[index].share_details != null && feedList[index].share_details.isNotEmpty ? feedList[index].share_details[0].name : feedList[index].name,
                                                    style: TextStyle(
                                                      fontFamily: AppTheme.fontName,
                                                      fontSize: SV.setSP(48),
                                                      color: AppTheme.black,
                                                    ),
                                                  ),
                                                  Text(
                                                    feedList[index].share_details != null && feedList[index].share_details.isNotEmpty ? feedList[index].share_starting_date ?? "" : feedList[index].starting_date,
                                                    style: TextStyle(
                                                      fontFamily: AppTheme.fontName,
                                                      fontSize: SV.setSP(40),
                                                      color: AppTheme.lightGray,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Container(
                                        width: SV.setWidth(100),
                                        child: PopupMenuButton<String>(
                                          onSelected: (value) {
                                            switch (value) {
                                              case 'Save':
                                                printWrapped("Save ------------>>>>> ${feedList[index].id}");
                                                _utils.isNetwotkAvailable(true).then((value) => checkNetworkForSave(value, feedList[index].id));
                                                break;
                                              case 'Edit':
                                                printWrapped("Edit ------------>>>>> ");
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) => EditFeedScreen(
                                                      postId: feedList[index].id,
                                                      type: feedList[index].post_type,
                                                      title: feedList[index].post_title,
                                                      caption: feedList[index].description,
                                                      tag: feedList[index].tag,
                                                      location: feedList[index].location,
                                                      size: feedList[index].size,
                                                      application: feedList[index].application,
                                                      finishes: feedList[index].finishes,
                                                      offsets: feedList[index].offsets,
                                                      priceStart: feedList[index].starting_price,
                                                      priceEnd: feedList[index].ending_price,
                                                      postItem: feedList[index].post_images,
                                                    ),
                                                  ),
                                                ).then((value) => onBack());
                                                break;
                                              case 'Delete':
                                                printWrapped("Save ------------>>>>> ${feedList[index].id}");
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) => DeleatPost(
                                                      postid: feedList[index].id,
                                                      postdata: feedList[index],
                                                      callback: (val) {
                                                        if (val == "") {
                                                          _utils.isNetwotkAvailable(true).then((value) => checkNetwork(value));
                                                        }
                                                      },
                                                    ),
                                                  ),
                                                );
                                                break;
                                            }
                                          },
                                          padding: EdgeInsets.symmetric(horizontal: 5),
                                          icon: Icon(Icons.more_vert_rounded),
                                          itemBuilder: (BuildContext context) {
                                            editDeleteSave.clear();
                                            if (feedList[index].is_share != "1") {
                                              if (feedList[index].user_id == userId) {
                                                widget.identify == "Save Feed" ? "" : editDeleteSave.add("Save");
                                                editDeleteSave.add("Edit");
                                                editDeleteSave.add("Delete");
                                              } else if (widget.identify != "Save Feed") {
                                                editDeleteSave.add("Save");
                                              }
                                            } else {
                                              if (feedList[index].share_user_id == userId) {
                                                widget.identify == "Save Feed" ? "" : editDeleteSave.add("Save");
                                                editDeleteSave.add("Delete");
                                              } else if (widget.identify != "Save Feed") {
                                                editDeleteSave.add("Save");
                                              }
                                            }
                                            return editDeleteSave.map((String choice) {
                                              return PopupMenuItem<String>(
                                                value: choice,
                                                child: Text(choice),
                                              );
                                            }).toList();
                                          },
                                        ),
                                      )
                                    ],
                                  ),
                                  Visibility(
                                    visible: feedList[index].is_share == "0" && feedList[index].description.isNotEmpty,
                                    child: Column(
                                      children: [
                                        SizedBox(height: SV.setHeight(10)),
                                        Text(
                                          feedList[index].description,
                                          style: TextStyle(
                                            fontFamily: AppTheme.fontName,
                                            fontSize: SV.setSP(40),
                                            color: AppTheme.black,
                                          ),
                                          textAlign: TextAlign.left,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Visibility(
                              visible: feedList[index].is_share == "1",
                              replacement: Visibility(
                                visible: feedList[index].post_images != null && feedList[index].post_images.isNotEmpty,
                                child: Container(
                                  height: SV.setWidth(700),
                                  color: AppTheme.gray,
                                  child: Stack(
                                    alignment: Alignment.bottomRight,
                                    children: [
                                      ClipRect(
                                        child: CommonVideoPlayer(
                                          images: videoListData,
                                          isVideo: feedList[index].post_images.isNotEmpty && feedList[index].post_images[0].video_thumb != "",
                                        ),
                                      ),
                                      waterMark(),
                                    ],
                                  ),
                                ),
                              ),
                              child: Container(
                                padding: EdgeInsets.only(left: SV.setWidth(15), top: SV.setWidth(40), right: SV.setWidth(15), bottom: SV.setWidth(15)),
                                margin: EdgeInsets.symmetric(horizontal: SV.setWidth(40)),
                                decoration: BoxDecoration(
                                  border: Border.all(color: AppTheme.lightGray.withOpacity(0.5), width: 0.6),
                                  color: AppTheme.gray,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        GestureDetector(
                                          onTap: () {
                                            printWrapped(feedList[index].user_id + " -- " + userId);
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute<dynamic>(
                                                builder: (BuildContext context) => PersonalProfile(
                                                  profileType: feedList[index].user_id == userId ? "personal" : "other",
                                                  userId: feedList[index].user_id,
                                                  isFrom: "otherProfile",
                                                ),
                                              ),
                                            ).then((value) => onBack());
                                          },
                                          child: Container(
                                            color: Colors.transparent,
                                            child: Row(
                                              children: [
                                                ClipOval(
                                                  child: CachedNetworkImage(
                                                    imageUrl: feedList[index].profile_image,
                                                    placeholder: (context, url) => Image.asset('assets/images/ic_default_profile.png'),
                                                    errorWidget: (context, url, error) => Image.asset('assets/images/ic_default_profile.png'),
                                                    height: SV.setWidth(160),
                                                    width: SV.setWidth(160),
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                                SizedBox(width: SV.setWidth(40)),
                                                Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      feedList[index].name,
                                                      style: TextStyle(
                                                        fontFamily: AppTheme.fontName,
                                                        fontSize: SV.setSP(48),
                                                        color: AppTheme.black,
                                                      ),
                                                    ),
                                                    Text(
                                                      feedList[index].starting_date,
                                                      style: TextStyle(
                                                        fontFamily: AppTheme.fontName,
                                                        fontSize: SV.setSP(40),
                                                        color: AppTheme.lightGray,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Visibility(
                                      visible: feedList[index].description.isNotEmpty,
                                      child: Column(
                                        children: [
                                          SizedBox(height: SV.setHeight(10)),
                                          Text(
                                            feedList[index].description,
                                            style: TextStyle(
                                              fontFamily: AppTheme.fontName,
                                              fontSize: SV.setSP(40),
                                              color: AppTheme.black,
                                            ),
                                            textAlign: TextAlign.left,
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(height: SV.setWidth(40)),
                                    Visibility(
                                      visible: feedList[index].post_images.isNotEmpty,
                                      child: Container(
                                        height: SV.setWidth(700),
                                        color: AppTheme.gray,
                                        child: Stack(
                                          alignment: Alignment.bottomRight,
                                          children: [
                                            ClipRect(
                                              child: CommonVideoPlayer(
                                                images: videoListData,
                                                isVideo: feedList[index].post_images.isNotEmpty && feedList[index].post_images[0].video_thumb != "",
                                              ),
                                            ),
                                            waterMark(),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(SV.setWidth(40)),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      _utils.isNetwotkAvailable(true).then((value) => checkNetworkForLike(value, 'like', feedList[index].id, index));
                                    },
                                    child: Container(
                                      color: Colors.transparent,
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Image.asset(
                                            'assets/images/ic_like_black.png',
                                            height: SV.setHeight(50.0),
                                            width: SV.setHeight(50.0),
                                          ),
                                          SizedBox(width: SV.setHeight(12)),
                                          Text(
                                            feedList[index].total_like,
                                            style: TextStyle(
                                              fontFamily: AppTheme.fontName,
                                              fontSize: SV.setSP(44),
                                              color: AppTheme.black,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: SV.setHeight(25)),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute<dynamic>(
                                          builder: (BuildContext context) => CommentScreen(
                                            postId: feedList[index].id,
                                            dataModel: feedList[index],
                                          ),
                                        ),
                                      ).then((value) {
                                        getPost(index, value);
                                        onBack();
                                      });
                                    },
                                    child: Container(
                                      color: Colors.transparent,
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Image.asset(
                                            'assets/images/ic_comment_black.png',
                                            height: SV.setHeight(50.0),
                                            width: SV.setHeight(50.0),
                                          ),
                                          SizedBox(width: SV.setHeight(12)),
                                          Text(
                                            feedList[index].total_comment ?? "",
                                            style: TextStyle(
                                              fontFamily: AppTheme.fontName,
                                              fontSize: SV.setSP(44),
                                              color: AppTheme.black,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: SV.setHeight(25)),
                                  Visibility(
                                    visible: feedList[index].user_id != userId && feedList[index].is_share == '0',
                                    child: GestureDetector(
                                      onTap: () {
                                        _utils.isNetwotkAvailable(true).then((value) => checkNetworkForShare(value, feedList[index].id));
                                      },
                                      child: Icon(
                                        CupertinoIcons.arrowshape_turn_up_right,
                                        size: SV.setHeight(58),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            SizedBox(height: SV.setHeight(130)),
          ],
        ),
      ),
    );
  }

  //*************************************
  // Feed List :-
  //*************************************
  checkNetwork(bool value) {
    if (value) {
      _utils.showProgressDialog();
      Future<DataArrayModel> user = feedsList();
      user.then((value) => responsePostList(value));
    }
  }

  Future<DataArrayModel> feedsList() async {
    try {
      FormData formData = FormData.fromMap({
        'user_id': await _sharedPref.getUserId(),
        'current_date': formattedDate,
      });
      printWrapped('${formData.fields}---paRAM');
      Response response = await ApiClient()
          .apiClientInstance(
            context,
            await _sharedPref.getToken(),
          )
          .post(
            widget.identify == "Save Feed" ? 'getMyCollection' : 'FeedList',
            data: formData,
          );

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
          feedList = value.Result;
        });
      } else {
        _utils.alertDialog(value.ResponseMessage);
      }
    }
  }

  //*************************************
  // Add Remove Like :-
  //*************************************
  checkNetworkForLike(bool value, type, id, pos) {
    if (value) {
      _utils.showProgressDialog();
      Future<DataObjectResponse> user = addRemoveLike(type, id);
      user.then((value) => responseLike(value, pos));
    }
  }

  Future<DataObjectResponse> addRemoveLike(type, id) async {
    try {
      FormData formData = FormData.fromMap({
        'user_id': await _sharedPref.getUserId(),
        'post_id': id,
        'type': type,
        'date_time': formattedDate,
      });
      printWrapped('${formData.fields}---paRAM');
      Response response = await ApiClient().apiClientInstance(context, await _sharedPref.getToken()).post('addRemoveLike', data: formData);
      return DataObjectResponse.fromJson(response.data);
    } catch (e) {
      printWrapped(e);
      return null;
    }
  }

  responseLike(DataObjectResponse value, pos) {
    _utils.hideProgressDialog();
    if (value != null) {
      if (value.ResponseCode == 1) {
        debugPrint("value.ResponseMessage -------->>>${value.ResponseMessage}");
        int currentCount = int.parse(feedList[pos].total_like);
        setState(() {});
        if (value.ResponseMessage == "like successfully") {
          currentCount++;
          feedList[pos].total_like = currentCount.toString();
          setState(() {});
        } else if (value.ResponseMessage == "dislike successfully") {
          currentCount--;
          feedList[pos].total_like = currentCount.toString();
          setState(() {});
        }
      } else {
        _utils.alertDialog(value.ResponseMessage);
      }
    }
  }

  //*************************************
  // Save Post :-
  //*************************************
  checkNetworkForSave(bool value, String id) {
    if (value) {
      _utils.showProgressDialog();
      Future<DataArrayModel> user = save(id);
      user.then((value) => responseForSave(value));
    }
  }

  Future<DataArrayModel> save(String id) async {
    try {
      FormData formData = FormData.fromMap({
        'user_id': await _sharedPref.getUserId(),
        'post_id': id,
      });
      printWrapped('${formData.fields}---paRAM');
      Response response = await ApiClient().apiClientInstance(context, await _sharedPref.getToken()).post('savePost', data: formData);

      return DataArrayModel.fromJson(response.data);
    } catch (e) {
      printWrapped(e);
      return null;
    }
  }

  responseForSave(DataArrayModel value) {
    _utils.hideProgressDialog();
    if (value != null) {
      if (value.ResponseCode == 1) {
        _utils.alertDialog(value.ResponseMessage);
        setState(() {});
      } else {
        _utils.alertDialog(value.ResponseMessage);
      }
    }
  }

  //*************************************
  // Share Post :-
  //*************************************
  checkNetworkForShare(bool value, String id) {
    if (value) {
      Future<DataArrayModel> user = share(id);
      user.then((value) => responseForShare(value));
    }
  }

  Future<DataArrayModel> share(String id) async {
    try {
      FormData formData = FormData.fromMap({
        'user_id': await _sharedPref.getUserId(),
        'post_id': id,
      });
      printWrapped('${formData.fields}---paRAM');
      Response response = await ApiClient().apiClientInstance(context, await _sharedPref.getToken()).post('sharePost', data: formData);

      return DataArrayModel.fromJson(response.data);
    } catch (e) {
      printWrapped(e);
      return null;
    }
  }

  responseForShare(DataArrayModel value) {
    if (value != null) {
      if (value.ResponseCode == 1) {
        _utils.isNetwotkAvailable(true).then((value) => checkNetwork(value));
        setState(() {});
      } else {
        _utils.alertDialog(value.ResponseMessage);
      }
    }
  }

  getPost(int num, value) {
    if (value != null) {
      Map<String, dynamic> map = jsonDecode(value);
      DataModel obj = DataModel.fromJson(map);
      if (obj != null) {
        setState(() {
          feedList[num] = obj;
        });
      }
    }
  }
}
