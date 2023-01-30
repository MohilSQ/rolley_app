//DetailsScreen
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:intl/intl.dart';
import 'package:rolley_app/AppFlow/PersonalProfileScreen.dart';
import 'package:rolley_app/AppFlow/fullScreenDetails.dart';
import 'package:rolley_app/AppFlow/mapView.dart';
import 'package:rolley_app/Common/ApiClient.dart';
import 'package:rolley_app/Common/CommonStrings.dart';
import 'package:rolley_app/Common/Constants.dart';
import 'package:rolley_app/Common/SharedPref.dart';
import 'package:rolley_app/Common/Utils.dart';
import 'package:rolley_app/Common/app_theme.dart';
import 'package:rolley_app/Common/screen_size_utils.dart';
import 'package:rolley_app/Model/DataArrayModel.dart';
import 'package:rolley_app/Model/DataModel.dart';
import 'package:rolley_app/Model/DataObjectResponse.dart';

import 'SubscriptionScreen.dart';

class DetailsScreen extends StatefulWidget {
  String post;
  String address;
  String lat;
  String lon;
  DetailsScreen({
    this.post = "",
    this.address = "",
    this.lat = "",
    this.lon = "",
  });

  _DetailsScreenState createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  String search = '';
  String comment = '';
  List<DataModel> postList = [];

  int imgCount = 0;
  String profileImg = '';
  String vehicleName = '';
  String likeCount = '0';
  String dislikeCount = '0';
  String rate = '5';
  String size = '';
  String application = '';
  String finishes = '';
  String offsets = '';
  String priceStart = '';
  String priceEnd = '';
  String follower = '';
  String following = '';
  String posts = '';
  String reviewTotal = '';
  String avrageRate = '1';
  String isSubscribed = '0';
  String name = '';
  String profileImage = '';
  String postUserId = '';
  List<DataModel> review = [];
  List<DataModel> images = [];

  Utils _utils;
  SharedPref _sharedPref;

  TextEditingController msg = TextEditingController();
  String userId = '';
  String postId = '';

  // Date and time
  static final DateTime now = DateTime.now();
  static final DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm:ss');
  final String formattedDate = formatter.format(now);

  @override
  void initState() {
    super.initState();

    _utils = Utils(context: context);
    _sharedPref = SharedPref();

    _utils.isNetwotkAvailable(true).then(
          (value) => checkNetwork(value),
        );
  }

  // Rate Dialog :-
  Dialog agentIdDialog({String identify}) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24.0),
      ),
      child: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          child: Wrap(
            children: [
              Column(
                children: [
                  SizedBox(
                    height: SV.setHeight(50),
                  ),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(SV.setWidth(140.0)),
                    child: CachedNetworkImage(
                      imageUrl: profileImg,
                      placeholder: (context, url) => Image.asset(
                        'assets/images/ic_default_profile.png',
                        fit: BoxFit.cover,
                      ),
                      errorWidget: (context, url, error) => Image.asset(
                        'assets/images/ic_default_profile.png',
                        fit: BoxFit.cover,
                      ),
                      fit: BoxFit.cover,
                      height: SV.setWidth(280),
                      width: SV.setWidth(280),
                    ),
                  ),
                  SizedBox(
                    height: SV.setHeight(20),
                  ),
                  Text(
                    vehicleName ?? "",
                    style: TextStyle(
                      fontFamily: AppTheme.fontName,
                      fontSize: SV.setSP(70),
                      color: AppTheme.black,
                    ),
                  ),
                  RatingBar.builder(
                    initialRating: 5,
                    minRating: 1,
                    direction: Axis.horizontal,
                    allowHalfRating: true,
                    itemCount: 5,
                    itemSize: 20,
                    itemPadding: EdgeInsets.symmetric(horizontal: 1.6),
                    itemBuilder: (context, _) => Icon(Icons.star, color: Colors.amber),
                    onRatingUpdate: (double value) {
                      rate = value.toString();
                    },
                  ),
                  Container(
                    margin: EdgeInsets.all(
                      SV.setHeight(40),
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.gray,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: SV.setWidth(30),
                    ),
                    child: TextField(
                      style: TextStyle(
                        fontFamily: AppTheme.fontName,
                        fontSize: SV.setSP(50),
                      ),
                      controller: msg,
                      cursorColor: AppTheme.themeBlue,
                      keyboardType: TextInputType.multiline,
                      maxLength: null,
                      maxLines: 3,
                      onChanged: (val) {
                        comment = val;
                      },
                      decoration: InputDecoration(
                        hintText: 'Comment',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: SV.setWidth(40),
                        ),
                        Expanded(
                          child: FlatButton(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6.0),
                              side: BorderSide(color: AppTheme.lightGray, width: 2),
                            ),
                            onPressed: () {
                              Navigator.of(context, rootNavigator: true).pop();
                            },
                            color: Colors.white,
                            textColor: AppTheme.lightGray,
                            padding: EdgeInsets.symmetric(
                              vertical: SV.setHeight(30),
                            ),
                            child: Text(
                              "Cancel",
                              style: TextStyle(
                                fontSize: SV.setSP(50),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: SV.setWidth(20),
                        ),
                        Expanded(
                          child: FlatButton(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6.0),
                              side: BorderSide(color: AppTheme.lightGray, width: 2),
                            ),
                            onPressed: () {
                              if (identify == "AddReview") {
                                _utils.isNetwotkAvailable(true).then(
                                      (value) => checkNetworkForAddReview(value),
                                    );
                              } else if (identify == "EditReview") {
                                _utils.isNetwotkAvailable(true).then(
                                      (value) => checkNetworkForUpdateReview(value),
                                    );
                              }
                            },
                            color: AppTheme.lightGray,
                            textColor: Colors.white,
                            padding: EdgeInsets.symmetric(
                              vertical: SV.setHeight(30),
                            ),
                            child: Text(
                              "Submit",
                              style: TextStyle(
                                fontSize: SV.setSP(50),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: SV.setWidth(40),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: SV.setHeight(60),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

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

  Widget waterMark() {
    return Container(
      height: double.infinity,
      color: Colors.transparent,
      alignment: Alignment.bottomRight,
      margin: EdgeInsets.all(SV.setHeight(10)),
      child: Image.asset(
        "assets/images/logo_transparent.png",
        height: SV.setHeight(70),
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
            'Details',
            style: TextStyle(
              fontFamily: AppTheme.fontName,
              fontSize: SV.setSP(60),
              color: AppTheme.black,
            ),
          ),
          automaticallyImplyLeading: false,
          centerTitle: true,
        ),
        body: ListView(
          children: [
            // 4 Image Container
            imgCount >= 4 && isSubscribed == "1"
                ? Container(
                    height: SV.setHeight(500),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 7,
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => FullScreenDetails(
                                    images: images,
                                    index: 0,
                                    is_subscribed: "1",
                                  ),
                                ),
                              );
                            },
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                Container(
                                  width: double.infinity,
                                  height: double.infinity,
                                  child: CachedNetworkImage(
                                    imageUrl: images[0].video_thumb == "" ? images[0].image : images[0].video_thumb,
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
                                waterMark(),
                                images[0].video_thumb != "" ? playBotton() : Container(),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          width: SV.setHeight(2),
                        ),
                        Expanded(
                          flex: 3,
                          child: Container(
                            child: Column(
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => FullScreenDetails(
                                            images: images,
                                            index: 1,
                                            is_subscribed: "1",
                                          ),
                                        ),
                                      );
                                    },
                                    child: Stack(
                                      fit: StackFit.expand,
                                      children: [
                                        Container(
                                          width: double.infinity,
                                          child: CachedNetworkImage(
                                            imageUrl: images[1].video_thumb == "" ? images[1].image : images[1].video_thumb,
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
                                        waterMark(),
                                        images[1].video_thumb != "" ? playBotton() : Container(),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: SV.setHeight(2),
                                ),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => FullScreenDetails(
                                            images: images,
                                            index: 2,
                                            is_subscribed: "1",
                                          ),
                                        ),
                                      );
                                    },
                                    child: Stack(
                                      fit: StackFit.expand,
                                      children: [
                                        Container(
                                          width: double.infinity,
                                          child: CachedNetworkImage(
                                            imageUrl: images[2].video_thumb == "" ? images[2].image : images[2].video_thumb,
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
                                        waterMark(),
                                        images[2].video_thumb != "" ? playBotton() : Container(),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: SV.setHeight(2),
                                ),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => FullScreenDetails(
                                            images: images,
                                            index: 3,
                                            is_subscribed: "1",
                                          ),
                                        ),
                                      );
                                    },
                                    child: Stack(
                                      fit: StackFit.expand,
                                      children: [
                                        Container(
                                          width: double.infinity,
                                          child: CachedNetworkImage(
                                            imageUrl: images[3].video_thumb == "" ? images[3].image : images[3].video_thumb,
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
                                        waterMark(),
                                        images[3].video_thumb != "" ? playBotton() : Container(),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : Container(),
            // 3 Image Container
            imgCount == 3 && isSubscribed == "1"
                ? Container(
                    height: SV.setHeight(500),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 7,
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => FullScreenDetails(
                                    images: images,
                                    index: 0,
                                    is_subscribed: "1",
                                  ),
                                ),
                              );
                            },
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                Container(
                                  width: double.infinity,
                                  height: MediaQuery.of(context).size.height,
                                  child: CachedNetworkImage(
                                    imageUrl: images[0].video_thumb == "" ? images[0].image : images[0].video_thumb,
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
                                waterMark(),
                                images[0].video_thumb != "" ? playBotton() : Container(),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          width: SV.setHeight(2),
                        ),
                        Expanded(
                          flex: 2,
                          child: Container(
                            child: Column(
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => FullScreenDetails(
                                            images: images,
                                            index: 1,
                                            is_subscribed: "1",
                                          ),
                                        ),
                                      );
                                    },
                                    child: Stack(
                                      fit: StackFit.expand,
                                      children: [
                                        Container(
                                          width: double.infinity,
                                          height: MediaQuery.of(context).size.height,
                                          child: CachedNetworkImage(
                                            imageUrl: images[1].video_thumb == "" ? images[1].image : images[1].video_thumb,
                                            fit: BoxFit.cover,
                                            placeholder: (context, url) => Image.asset(
                                              'assets/images/ic_manue_defalt.jpg',
                                              fit: BoxFit.cover,
                                            ),
                                            errorWidget: (context, url, error) => Image.asset(
                                              'assets/images/ic_manue_defalt.jpg',
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                        waterMark(),
                                        images[1].video_thumb != "" ? playBotton() : Container(),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: SV.setHeight(2),
                                ),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => FullScreenDetails(
                                            images: images,
                                            index: 2,
                                            is_subscribed: "1",
                                          ),
                                        ),
                                      );
                                    },
                                    child: Stack(
                                      fit: StackFit.expand,
                                      children: [
                                        Container(
                                          width: double.infinity,
                                          height: MediaQuery.of(context).size.height,
                                          child: CachedNetworkImage(
                                            imageUrl: images[2].video_thumb == "" ? images[2].image : images[2].video_thumb,
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
                                        waterMark(),
                                        images[2].video_thumb != "" ? playBotton() : Container(),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : Container(),
            // 2 Image Container
            imgCount == 2 && isSubscribed == "1"
                ? Container(
                    height: SV.setHeight(500),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 5,
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => FullScreenDetails(
                                    images: images,
                                    index: 0,
                                    is_subscribed: "1",
                                  ),
                                ),
                              );
                            },
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                Container(
                                  height: double.infinity,
                                  child: CachedNetworkImage(
                                    imageUrl: images[0].video_thumb == "" ? images[0].image : images[0].video_thumb,
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
                                waterMark(),
                                images[0].video_thumb != "" ? playBotton() : Container(),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          width: SV.setHeight(2),
                        ),
                        Expanded(
                          flex: 5,
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => FullScreenDetails(
                                    images: images,
                                    index: 1,
                                    is_subscribed: "1",
                                  ),
                                ),
                              );
                            },
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                Container(
                                  height: double.infinity,
                                  child: CachedNetworkImage(
                                    imageUrl: images[1].video_thumb == "" ? images[1].image : images[1].video_thumb,
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
                                waterMark(),
                                images[1].video_thumb != "" ? playBotton() : Container(),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : Container(),
            // 1 Image Container
            imgCount == 1 && isSubscribed == "1"
                ? Container(
                    height: SV.setHeight(500),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 5,
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => FullScreenDetails(
                                    images: images,
                                    index: 0,
                                    is_subscribed: "1",
                                  ),
                                ),
                              );
                            },
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                Container(
                                  height: double.infinity,
                                  width: MediaQuery.of(context).size.width,
                                  child: CachedNetworkImage(
                                    imageUrl: images[0].video_thumb == "" ? images[0].image : images[0].video_thumb,
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
                                waterMark(),
                                images[0].video_thumb != "" ? playBotton() : Container(),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : Container(),
            isSubscribed == "0" && images.length > 0
                ? GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FullScreenDetails(
                            images: images,
                            index: 0,
                            is_subscribed: "0",
                          ),
                        ),
                      );
                    },
                    child: Container(
                      height: SV.setHeight(500),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Container(
                            height: double.infinity,
                            width: double.infinity,
                            child: CachedNetworkImage(
                              imageUrl: images[0].video_thumb == "" ? images[0].image : images[0].video_thumb,
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
                          waterMark(),
                          images[0].video_thumb != "" ? playBotton() : Container(),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute<dynamic>(
                                    builder: (BuildContext context) => SubscriptionScreen(),
                                  ),
                                );
                              },
                              child: Padding(
                                padding: EdgeInsets.all(
                                  SV.setWidth(15),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(5),
                                  ),
                                  child: Container(
                                    color: AppTheme.orange,
                                    child: Padding(
                                      padding: EdgeInsets.all(SV.setWidth(10)),
                                      child: Text(
                                        CommonStrings.see_more,
                                        style: TextStyle(
                                          fontFamily: AppTheme.fontName,
                                          fontSize: SV.setSP(50),
                                          color: AppTheme.gray,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : Container(),

            Container(
              padding: EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute<dynamic>(
                          builder: (BuildContext context) => PersonalProfile(
                            profileType: postUserId == userId ? "personal" : "other",
                            userId: postUserId,
                            isFrom: "otherProfile",
                          ),
                        ),
                      );
                    },
                    child: Container(
                      color: Colors.transparent,
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(SV.setWidth(80.0)),
                            child: CachedNetworkImage(
                              imageUrl: profileImg,
                              placeholder: (context, url) => Image.asset('assets/images/ic_default_profile.png'),
                              errorWidget: (context, url, error) => Image.asset('assets/images/ic_default_profile.png'),
                              fit: BoxFit.cover,
                              height: SV.setWidth(160),
                              width: SV.setWidth(160),
                            ),
                          ),
                          SizedBox(width: SV.setWidth(40)),
                          Text(
                            name,
                            style: TextStyle(
                              fontFamily: AppTheme.fontName,
                              fontSize: SV.setSP(48),
                              color: AppTheme.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: SV.setHeight(20),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              vehicleName,
                              style: TextStyle(
                                fontFamily: AppTheme.fontName,
                                fontSize: SV.setSP(60),
                                color: AppTheme.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              msg.text = "";
                              showDialog(
                                context: context,
                                builder: (BuildContext context) => agentIdDialog(identify: "AddReview"),
                              );
                            },
                            child: Container(
                              height: SV.setHeight(70.0),
                              width: SV.setHeight(90.0),
                              padding: EdgeInsets.all(SV.setWidth(18)),
                              decoration: BoxDecoration(
                                color: AppTheme.lightGray,
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: Image.asset('assets/images/ic_rate_plus.png'),
                            ),
                          ),
                          SizedBox(
                            width: SV.setHeight(10),
                          ),
                          GestureDetector(
                            onTap: () {
                              _utils.isNetwotkAvailable(true).then(
                                    (value) => checkNetworkForLike(value, 'like'),
                                  );
                            },
                            child: Container(
                              // height: SV.setHeight(70.0),
                              // width: SV.setHeight(130.0),
                              padding: EdgeInsets.all(
                                SV.setWidth(18),
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.lightGray,
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: Row(
                                children: [
                                  Image.asset(
                                    'assets/images/ic_like.png',
                                    height: SV.setHeight(42.0),
                                    width: SV.setHeight(42.0),
                                  ),
                                  SizedBox(
                                    width: SV.setHeight(8),
                                  ),
                                  Text(
                                    likeCount,
                                    style: TextStyle(
                                      fontFamily: AppTheme.fontName,
                                      fontSize: SV.setSP(30),
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(width: SV.setHeight(10)),
                          GestureDetector(
                            onTap: () {
                              _utils.isNetwotkAvailable(true).then(
                                    (value) => checkNetworkForLike(value, 'dislike'),
                                  );
                            },
                            child: Container(
                              // height: SV.setHeight(70.0),
                              // width: SV.setHeight(130.0),
                              padding: EdgeInsets.all(
                                SV.setWidth(18),
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.lightGray,
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: Row(
                                children: [
                                  Image.asset(
                                    'assets/images/ic_dislike.png',
                                    height: SV.setHeight(42.0),
                                    width: SV.setHeight(42.0),
                                  ),
                                  SizedBox(
                                    width: SV.setHeight(8),
                                  ),
                                  Text(
                                    dislikeCount,
                                    style: TextStyle(
                                      fontFamily: AppTheme.fontName,
                                      fontSize: SV.setSP(30),
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(
                            width: SV.setHeight(10),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => MapView(
                                    lon: widget.lon,
                                    lat: widget.lat,
                                    address: widget.address,
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              height: SV.setHeight(70.0),
                              width: SV.setHeight(90.0),
                              padding: EdgeInsets.all(SV.setWidth(18)),
                              decoration: BoxDecoration(
                                color: AppTheme.lightGray,
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: Image.asset('assets/images/ic_location_pin.png'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  RatingBar.builder(
                    initialRating: double.parse(avrageRate),
                    minRating: 1,
                    direction: Axis.horizontal,
                    allowHalfRating: true,
                    itemCount: 5,
                    itemSize: 20,
                    itemPadding: EdgeInsets.symmetric(horizontal: 1.6),
                    itemBuilder: (context, _) => Icon(Icons.star, color: Colors.amber),
                    onRatingUpdate: (value) {},
                  ),
                  SizedBox(
                    height: SV.setHeight(40),
                  ),
                  Row(
                    children: [
                      RichText(
                        text: TextSpan(
                          children: <TextSpan>[
                            TextSpan(
                              text: 'Size: ',
                              style: TextStyle(
                                fontFamily: AppTheme.fontName,
                                fontSize: SV.setSP(44),
                                color: AppTheme.lightGray,
                              ),
                            ),
                            TextSpan(
                              text: size,
                              style: TextStyle(
                                fontFamily: AppTheme.fontName,
                                fontSize: SV.setSP(44),
                                color: AppTheme.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: SV.setHeight(14),
                      ),
                      Container(
                        width: 1.0,
                        height: SV.setHeight(40.0),
                        decoration: BoxDecoration(
                          color: AppTheme.Border,
                        ),
                      ),
                      SizedBox(
                        width: SV.setHeight(14),
                      ),
                      Expanded(
                        child: RichText(
                          overflow: TextOverflow.ellipsis,
                          text: TextSpan(
                            children: <TextSpan>[
                              TextSpan(
                                text: 'Application: ',
                                style: TextStyle(
                                  fontFamily: AppTheme.fontName,
                                  fontSize: SV.setSP(44),
                                  color: AppTheme.lightGray,
                                ),
                              ),
                              TextSpan(
                                text: application,
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
                    ],
                  ),
                  SizedBox(
                    height: SV.setHeight(20),
                  ),
                  RichText(
                    text: TextSpan(
                      children: <TextSpan>[
                        TextSpan(
                          text: 'Finishes: ',
                          style: TextStyle(
                            fontFamily: AppTheme.fontName,
                            fontSize: SV.setSP(44),
                            color: AppTheme.lightGray,
                          ),
                        ),
                        TextSpan(
                          text: finishes,
                          style: TextStyle(
                            fontFamily: AppTheme.fontName,
                            fontSize: SV.setSP(44),
                            color: AppTheme.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: SV.setHeight(20),
                  ),
                  RichText(
                    text: TextSpan(
                      children: <TextSpan>[
                        TextSpan(
                          text: 'Offsets: ',
                          style: TextStyle(
                            fontFamily: AppTheme.fontName,
                            fontSize: SV.setSP(44),
                            color: AppTheme.lightGray,
                          ),
                        ),
                        TextSpan(
                          text: offsets,
                          style: TextStyle(
                            fontFamily: AppTheme.fontName,
                            fontSize: SV.setSP(44),
                            color: AppTheme.black,
                          ),
                        )
                      ],
                    ),
                  ),
                  SizedBox(
                    height: SV.setHeight(20),
                  ),
                  RichText(
                    text: TextSpan(
                      children: <TextSpan>[
                        TextSpan(
                          text: 'Price Range: ',
                          style: TextStyle(
                            fontFamily: AppTheme.fontName,
                            fontSize: SV.setSP(44),
                            color: AppTheme.lightGray,
                          ),
                        ),
                        TextSpan(
                          text: '\$ ' + priceStart + ' - \$ ' + priceEnd + '',
                          style: TextStyle(
                            fontFamily: AppTheme.fontName,
                            fontSize: SV.setSP(44),
                            color: AppTheme.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: SV.setHeight(40),
                  ),
                ],
              ),
            ),
            Divider(height: 0.5, color: AppTheme.Border),
            SizedBox(
              height: SV.setHeight(40),
            ),
            Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        "Follower",
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
              height: SV.setHeight(40),
            ),
            Divider(height: 0.5, color: AppTheme.Border),
            SizedBox(
              height: SV.setHeight(10),
            ),
            Container(
              padding: EdgeInsets.all(12.0),
              child: Text(
                'Reviews, (' + reviewTotal + ')',
                style: TextStyle(
                  fontFamily: AppTheme.fontName,
                  fontSize: SV.setSP(60),
                  color: AppTheme.black,
                ),
              ),
            ),
            SizedBox(
              height: SV.setHeight(10),
            ),
            Divider(height: 0.5, color: AppTheme.Border),
            ListView.builder(
              shrinkWrap: true,
              itemCount: review.length,
              itemBuilder: (context, index) {
                return Container(
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.only(
                          left: SV.setWidth(60),
                          right: SV.setWidth(60),
                          top: SV.setWidth(40),
                          bottom: SV.setWidth(40),
                        ),
                        color: AppTheme.gray,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(
                                    SV.setWidth(80.0),
                                  ),
                                  child: CachedNetworkImage(
                                    imageUrl: review[index].profile_image,
                                    placeholder: (context, url) => Image.asset(
                                      'assets/images/ic_default_profile.png',
                                      fit: BoxFit.cover,
                                    ),
                                    errorWidget: (context, url, error) => Image.asset(
                                      'assets/images/ic_default_profile.png',
                                      fit: BoxFit.cover,
                                    ),
                                    fit: BoxFit.cover,
                                    height: SV.setWidth(160),
                                    width: SV.setWidth(160),
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
                                        review[index].name,
                                        style: TextStyle(
                                          fontFamily: AppTheme.fontName,
                                          fontSize: SV.setSP(48),
                                          color: AppTheme.black,
                                        ),
                                      ),
                                      Text(
                                        review[index].date_time,
                                        style: TextStyle(
                                          fontFamily: AppTheme.fontName,
                                          fontSize: SV.setSP(40),
                                          color: AppTheme.lightGray,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Row(
                                  children: [
                                    Image.asset(
                                      'assets/images/ic_rate_fill_star.png',
                                      height: SV.setHeight(42.0),
                                      width: SV.setHeight(42.0),
                                    ),
                                    SizedBox(
                                      width: SV.setHeight(8),
                                    ),
                                    Text(
                                      review[index].rate,
                                      style: TextStyle(
                                        fontFamily: AppTheme.fontName,
                                        fontSize: SV.setSP(40),
                                        color: AppTheme.black,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(
                              height: SV.setHeight(10),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                review[index].rate_comment != ''
                                    ? Text(
                                        review[index].rate_comment,
                                        style: TextStyle(
                                          fontFamily: AppTheme.fontName,
                                          fontSize: SV.setSP(40),
                                          color: AppTheme.black,
                                        ),
                                        textAlign: TextAlign.left,
                                      )
                                    : Text(''),
                                SizedBox(
                                  height: SV.setHeight(10),
                                ),
                                review[index].user_id == userId
                                    ? PopupMenuButton(
                                        padding: EdgeInsets.zero,
                                        child: Icon(
                                          Icons.more_vert_sharp,
                                          size: SV.setSP(55),
                                        ),
                                        itemBuilder: (context) => [
                                          PopupMenuItem(
                                            child: Text("Edit"),
                                            value: 1,
                                          ),
                                          PopupMenuItem(
                                            child: Text("Delete"),
                                            value: 2,
                                          )
                                        ],
                                        onSelected: (value) {
                                          printWrapped(value);
                                          if (value == 1) {
                                            setState(() {
                                              msg.text = review[index].rate_comment;
                                              postId = review[index].id;
                                            });
                                            showDialog(
                                              context: context,
                                              builder: (BuildContext context) => agentIdDialog(identify: "EditReview"),
                                            );
                                          } else if (value == 2) {
                                            setState(() {
                                              postId = review[index].id;
                                            });
                                            _utils.isNetwotkAvailable(true).then(
                                                  (value) => checkNetworkForDeleteReview(value),
                                                );
                                          }
                                        },
                                      )
                                    : Container(),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Container(
                        height: 1.0,
                        decoration: BoxDecoration(
                          color: Colors.black26,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  //*************************************
  // Single Post :-
  //*************************************
  checkNetwork(bool value) {
    if (value) {
      _utils.showProgressDialog();
      Future<DataArrayModel> user = singlePost();
      user.then(
        (value) => responsePostList(value),
      );
    }
  }

  Future<DataArrayModel> singlePost() async {
    userId = await _sharedPref.getUserId();
    try {
      FormData formData = FormData.fromMap({
        'user_id': await _sharedPref.getUserId(),
        'post_id': widget.post,
        'current_date': formattedDate,
      });
      printWrapped('${formData.fields}---paRAM');
      Response response = await ApiClient()
          .apiClientInstance(
            context,
            await _sharedPref.getToken(),
          )
          .post('SinglePost', data: formData);
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
        postList = value.Result.cast<DataModel>();

        setState(() {
          imgCount = postList[0].post_images.length;
          profileImg = postList[0].profile_image;
          vehicleName = postList[0].post_title;
          likeCount = postList[0].total_like;
          dislikeCount = postList[0].total_dislike;
          size = postList[0].size;
          application = postList[0].application;
          finishes = postList[0].finishes;
          offsets = postList[0].offsets;
          priceStart = postList[0].starting_price;
          priceEnd = postList[0].ending_price;
          follower = postList[0].follower;
          following = postList[0].following;
          posts = postList[0].total_post;
          reviewTotal = postList[0].totle_review;
          review = postList[0].review;
          images = postList[0].post_images;
          avrageRate = postList[0].avg_review;
          isSubscribed = postList[0].is_subscribed;
          name = postList[0].name;
          profileImage = postList[0].profile_image;
          postUserId = postList[0].user_id;
        });
      } else {
        _utils.alertDialog(value.ResponseMessage);
      }
    }
  }

  //*************************************
  // Review Post :-
  //*************************************
  checkNetworkForAddReview(bool value) {
    if (value) {
      _utils.showProgressDialog();
      Future<DataObjectResponse> user = addReview();
      user.then((value) => responseLogin(value));
    }
  }

  Future<DataObjectResponse> addReview() async {
    try {
      FormData formData = FormData.fromMap({
        'user_id': await _sharedPref.getUserId(),
        'post_id': widget.post,
        'rate_comment': comment,
        'date_time': formattedDate,
        'rate': rate,
      });
      printWrapped('${formData.fields}---paRAM');
      Response response = await ApiClient()
          .apiClientInstance(
            context,
            await _sharedPref.getToken(),
          )
          .post('ReviewPost', data: formData);
      return DataObjectResponse.fromJson(response.data);
    } catch (e) {
      printWrapped(e);
      return null;
    }
  }

  responseLogin(DataObjectResponse value) {
    _utils.hideProgressDialog();
    if (value != null) {
      if (value.ResponseCode == 1) {
        _utils.isNetwotkAvailable(true).then(
              (value) => checkNetwork(value),
            );
        Navigator.of(context, rootNavigator: true).pop();
      } else {
        Navigator.of(context, rootNavigator: true).pop();
        _utils.alertDialog(value.ResponseMessage);
      }
    }
  }

  //*************************************
  // Review Update :-
  //*************************************
  checkNetworkForUpdateReview(bool value) {
    if (value) {
      _utils.showProgressDialog();
      Future<DataObjectResponse> user = updateReview();
      user.then((value) => responseUpdateReview(value));
    }
  }

  Future<DataObjectResponse> updateReview() async {
    try {
      FormData formData = FormData.fromMap({
        'user_id': await _sharedPref.getUserId(),
        'review_id': postId,
        'rate_comment': comment,
        'date_time': formattedDate,
        'rate': rate,
      });
      printWrapped('${formData.fields}---paRAM');
      Response response = await ApiClient()
          .apiClientInstance(
            context,
            await _sharedPref.getToken(),
          )
          .post('ReviewUpdate', data: formData);
      return DataObjectResponse.fromJson(response.data);
    } catch (e) {
      printWrapped(e);
      return null;
    }
  }

  responseUpdateReview(DataObjectResponse value) {
    _utils.hideProgressDialog();
    if (value != null) {
      if (value.ResponseCode == 1) {
        setState(() {
          msg.text = "";
          postId = "";
        });
        _utils.isNetwotkAvailable(true).then((value) => checkNetwork(value));
        Navigator.of(context, rootNavigator: true).pop();
      } else {
        Navigator.of(context, rootNavigator: true).pop();
        _utils.alertDialog(value.ResponseMessage);
      }
    }
  }

  //*************************************
  // Review Update :-
  //*************************************
  checkNetworkForDeleteReview(bool value) {
    if (value) {
      _utils.showProgressDialog();
      Future<DataObjectResponse> user = deleteReview();
      user.then((value) => responseDeleteReview(value));
    }
  }

  Future<DataObjectResponse> deleteReview() async {
    try {
      FormData formData = FormData.fromMap({
        'user_id': await _sharedPref.getUserId(),
        'review_id': postId,
      });
      printWrapped('${formData.fields}---paRAM');
      Response response = await ApiClient()
          .apiClientInstance(
            context,
            await _sharedPref.getToken(),
          )
          .post('ReviewDelete', data: formData);
      return DataObjectResponse.fromJson(response.data);
    } catch (e) {
      printWrapped(e);
      return null;
    }
  }

  responseDeleteReview(DataObjectResponse value) {
    _utils.hideProgressDialog();
    if (value != null) {
      if (value.ResponseCode == 1) {
        setState(() {
          msg.text = "";
          postId = "";
        });
        _utils.isNetwotkAvailable(true).then((value) => checkNetwork(value));
      } else {
        Navigator.of(context, rootNavigator: true).pop();
        _utils.alertDialog(value.ResponseMessage);
      }
    }
  }

  //*************************************
  // Add Remove Like :-
  //*************************************
  checkNetworkForLike(bool value, type) {
    if (value) {
      _utils.showProgressDialog();
      Future<DataObjectResponse> user = addRemoveLike(type);
      user.then((value) => responseAddRemoveLike(value));
    }
  }

  Future<DataObjectResponse> addRemoveLike(type) async {
    try {
      FormData formData = FormData.fromMap({
        'user_id': await _sharedPref.getUserId(),
        'post_id': widget.post,
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

  responseAddRemoveLike(DataObjectResponse value) {
    _utils.hideProgressDialog();
    if (value != null) {
      if (value.ResponseCode == 1) {
        setState(() {
          likeCount = value.like_count;
          dislikeCount = value.dislike_count;
        });

        if (value.ResponseMessage == "like successfully.") {
        } else if (value.ResponseMessage == "Removed from like list.") {
        } else if (value.ResponseMessage == "dislike successfully.") {
        } else if (value.ResponseMessage == "Removed from dislike list.") {}
      } else {
        _utils.alertDialog(value.ResponseMessage);
      }
    }
  }
}
