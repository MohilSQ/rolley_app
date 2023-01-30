import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rolley_app/AppFlow/EditProfileScreen.dart';
import 'package:rolley_app/AppFlow/fullScreenDetails.dart';
import 'package:rolley_app/Common/ApiClient.dart';
import 'package:rolley_app/Common/Constants.dart';
import 'package:rolley_app/Common/SharedPref.dart';
import 'package:rolley_app/Common/Utils.dart';
import 'package:rolley_app/Common/app_theme.dart';
import 'package:rolley_app/Common/screen_size_utils.dart';
import 'package:rolley_app/Model/DataArrayModel.dart';
import 'package:rolley_app/Model/DataModel.dart';

class DeleatPost extends StatefulWidget {
  String postid;
  DataModel postdata;
  StringValue callback;

  DeleatPost({
    this.postid,
    this.postdata,
    this.callback,
  });
  @override
  _DeleatPostState createState() => _DeleatPostState();
}

class _DeleatPostState extends State<DeleatPost> {
  DataModel postList;
  List<DataModel> images = [];
  int index;
  Utils _utils;
  SharedPref _sharedPref;
  String isUpdate = '';

  // Date and time
  static final DateTime now = DateTime.now();
  static final DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm:ss');
  final String formattedDate = formatter.format(now);

  @override
  void initState() {
    super.initState();
    postList = widget.postdata;
    _utils = Utils(context: context);
    _sharedPref = SharedPref();
  }

  @override
  Widget build(BuildContext context) {
    Future<bool> _goToBack() async {
      Navigator.pop(context);
      widget.callback(isUpdate);
      return Future.value(true);
    }

    ScreenUtil.instance.init(context);
    return WillPopScope(
      onWillPop: _goToBack,
      child: SafeArea(
        top: false,
        bottom: false,
        child: Scaffold(
          appBar: AppBar(
            brightness: Brightness.light,
            backgroundColor: AppTheme.gray,
            leadingWidth: SV.setWidth(200),
            title: Text(
              'Delete Post',
              style: TextStyle(
                fontFamily: AppTheme.fontName,
                fontSize: SV.setSP(60),
                color: AppTheme.black,
              ),
            ),
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
            actions: [
              GestureDetector(
                onTap: () {
                  _utils.isNetwotkAvailable(true).then(
                        (value) => checkNetwork(value),
                      );
                },
                child: Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Image.asset(
                    'assets/images/ic_create_feed.png',
                  ),
                ),
              ),
            ],
          ), //
          body: ListView(
            children: [
              postList.post_images.isNotEmpty
                  ? Container(
                      child: Container(
                        padding: EdgeInsets.all(SV.setWidth(50)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: SV.setWidth(260),
                              child: ListView.builder(
                                padding: EdgeInsets.all(0),
                                itemCount: postList.post_images.length,
                                shrinkWrap: true,
                                scrollDirection: Axis.horizontal,
                                itemBuilder: (context, index) {
                                  return Container(
                                    child: Column(
                                      children: [
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: SV.setWidth(20),
                                          ),
                                          child: Row(
                                            children: [
                                              GestureDetector(
                                                onTap: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) => FullScreenDetails(
                                                        images: postList.post_images,
                                                        index: index,
                                                        is_subscribed: "1",
                                                      ),
                                                    ),
                                                  );
                                                },
                                                child: ClipRRect(
                                                  borderRadius: BorderRadius.circular(12),
                                                  child: postList.post_images[index].video_thumb == ""
                                                      ? Image.network(
                                                          postList.post_images[index].image,
                                                          fit: BoxFit.cover,
                                                          height: SV.setWidth(240),
                                                          width: SV.setWidth(240),
                                                        )
                                                      : Stack(
                                                          alignment: Alignment.center,
                                                          children: [
                                                            Image.network(
                                                              postList.post_images[index].video_thumb,
                                                              fit: BoxFit.cover,
                                                              height: SV.setWidth(240),
                                                              width: SV.setWidth(240),
                                                            ),
                                                            Icon(
                                                              Icons.play_circle_fill,
                                                              color: AppTheme.orange,
                                                            ),
                                                          ],
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
                          ],
                        ),
                      ),
                    )
                  : Container(),
              Divider(
                height: 0.5,
                color: AppTheme.Border,
              ),
              Container(
                margin: EdgeInsets.all(
                  SV.setHeight(10),
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: SV.setWidth(30),
                  vertical: SV.setHeight(30),
                ),
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'Post Type: ',
                        style: TextStyle(
                          fontFamily: AppTheme.fontName,
                          fontSize: SV.setSP(50),
                          color: AppTheme.lightGray,
                        ),
                      ),
                      TextSpan(
                        text: postList.post_type,
                        style: TextStyle(
                          fontFamily: AppTheme.fontName,
                          fontSize: SV.setSP(50),
                          color: AppTheme.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Divider(
                height: 0.5,
                color: AppTheme.Border,
              ),
              Container(
                margin: EdgeInsets.all(
                  SV.setHeight(10),
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: SV.setWidth(30),
                  vertical: SV.setHeight(30),
                ),
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'Post Title: ',
                        style: TextStyle(
                          fontFamily: AppTheme.fontName,
                          fontSize: SV.setSP(50),
                          color: AppTheme.lightGray,
                        ),
                      ),
                      TextSpan(
                        text: postList.post_title,
                        style: TextStyle(
                          fontFamily: AppTheme.fontName,
                          fontSize: SV.setSP(50),
                          color: AppTheme.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Divider(
                height: 0.5,
                color: AppTheme.Border,
              ),
              Container(
                margin: EdgeInsets.all(
                  SV.setHeight(10),
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: SV.setWidth(30),
                  vertical: SV.setHeight(30),
                ),
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'Caption: ',
                        style: TextStyle(
                          fontFamily: AppTheme.fontName,
                          fontSize: SV.setSP(50),
                          color: AppTheme.lightGray,
                        ),
                      ),
                      TextSpan(
                        text: postList.description,
                        style: TextStyle(
                          fontFamily: AppTheme.fontName,
                          fontSize: SV.setSP(50),
                          color: AppTheme.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Divider(
                height: 0.5,
                color: AppTheme.Border,
              ),
              Container(
                margin: EdgeInsets.all(
                  SV.setHeight(10),
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: SV.setWidth(30),
                  vertical: SV.setHeight(30),
                ),
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'Tags: ',
                        style: TextStyle(
                          fontFamily: AppTheme.fontName,
                          fontSize: SV.setSP(50),
                          color: AppTheme.lightGray,
                        ),
                      ),
                      TextSpan(
                        text: postList.tag,
                        style: TextStyle(
                          fontFamily: AppTheme.fontName,
                          fontSize: SV.setSP(50),
                          color: AppTheme.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Divider(
                height: 0.5,
                color: AppTheme.Border,
              ),
              Container(
                margin: EdgeInsets.all(
                  SV.setHeight(10),
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: SV.setWidth(30),
                  vertical: SV.setHeight(30),
                ),
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'Location: ',
                        style: TextStyle(
                          fontFamily: AppTheme.fontName,
                          fontSize: SV.setSP(50),
                          color: AppTheme.lightGray,
                        ),
                      ),
                      TextSpan(
                        text: postList.location,
                        style: TextStyle(
                          fontFamily: AppTheme.fontName,
                          fontSize: SV.setSP(50),
                          color: AppTheme.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Divider(
                height: 0.5,
                color: AppTheme.Border,
              ),
              Container(
                margin: EdgeInsets.all(
                  SV.setHeight(10),
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: SV.setWidth(30),
                  vertical: SV.setHeight(30),
                ),
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'Size: ',
                        style: TextStyle(
                          fontFamily: AppTheme.fontName,
                          fontSize: SV.setSP(50),
                          color: AppTheme.lightGray,
                        ),
                      ),
                      TextSpan(
                        text: postList.size,
                        style: TextStyle(
                          fontFamily: AppTheme.fontName,
                          fontSize: SV.setSP(50),
                          color: AppTheme.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Divider(
                height: 0.5,
                color: AppTheme.Border,
              ),
              Container(
                margin: EdgeInsets.all(
                  SV.setHeight(10),
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: SV.setWidth(30),
                  vertical: SV.setHeight(30),
                ),
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'Application: ',
                        style: TextStyle(
                          fontFamily: AppTheme.fontName,
                          fontSize: SV.setSP(50),
                          color: AppTheme.lightGray,
                        ),
                      ),
                      TextSpan(
                        text: postList.application,
                        style: TextStyle(
                          fontFamily: AppTheme.fontName,
                          fontSize: SV.setSP(50),
                          color: AppTheme.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Divider(
                height: 0.5,
                color: AppTheme.Border,
              ),
              Container(
                margin: EdgeInsets.all(
                  SV.setHeight(10),
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: SV.setWidth(30),
                  vertical: SV.setHeight(30),
                ),
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'Finishes: ',
                        style: TextStyle(
                          fontFamily: AppTheme.fontName,
                          fontSize: SV.setSP(50),
                          color: AppTheme.lightGray,
                        ),
                      ),
                      TextSpan(
                        text: postList.finishes,
                        style: TextStyle(
                          fontFamily: AppTheme.fontName,
                          fontSize: SV.setSP(50),
                          color: AppTheme.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Divider(
                height: 0.5,
                color: AppTheme.Border,
              ),
              Container(
                margin: EdgeInsets.all(
                  SV.setHeight(10),
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: SV.setWidth(30),
                  vertical: SV.setHeight(30),
                ),
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'Offsets: ',
                        style: TextStyle(
                          fontFamily: AppTheme.fontName,
                          fontSize: SV.setSP(50),
                          color: AppTheme.lightGray,
                        ),
                      ),
                      TextSpan(
                        text: postList.offsets,
                        style: TextStyle(
                          fontFamily: AppTheme.fontName,
                          fontSize: SV.setSP(50),
                          color: AppTheme.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Divider(
                height: 0.5,
                color: AppTheme.Border,
              ),
              Container(
                margin: EdgeInsets.all(
                  SV.setHeight(10),
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: SV.setWidth(30),
                  vertical: SV.setHeight(30),
                ),
                child: RichText(
                  overflow: TextOverflow.clip,
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'Start price range(\$): ',
                        style: TextStyle(
                          fontFamily: AppTheme.fontName,
                          fontSize: SV.setSP(50),
                          color: AppTheme.lightGray,
                        ),
                      ),
                      TextSpan(
                        text: postList.starting_price,
                        style: TextStyle(
                          fontFamily: AppTheme.fontName,
                          fontSize: SV.setSP(50),
                          color: AppTheme.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Divider(
                height: 0.5,
                color: AppTheme.Border,
              ),
              Container(
                margin: EdgeInsets.all(
                  SV.setHeight(10),
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: SV.setWidth(30),
                  vertical: SV.setHeight(30),
                ),
                child: RichText(
                  overflow: TextOverflow.clip,
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'Ending price range(\$): ',
                        style: TextStyle(
                          fontFamily: AppTheme.fontName,
                          fontSize: SV.setSP(50),
                          color: AppTheme.lightGray,
                        ),
                      ),
                      TextSpan(
                        text: postList.ending_price,
                        style: TextStyle(
                          fontFamily: AppTheme.fontName,
                          fontSize: SV.setSP(50),
                          color: AppTheme.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Divider(
                height: 0.5,
                color: AppTheme.Border,
              ),
              SizedBox(height: 20),
            ],
          ),
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
      Future<DataArrayModel> user = deleatePost();
      user.then(
        (value) => responsePostList(value),
      );
    }
  }

  Future<DataArrayModel> deleatePost() async {
    try {
      FormData formData = FormData.fromMap({
        'user_id': await _sharedPref.getUserId(),
        'post_id': widget.postid,
        'current_date': formattedDate,
      });
      printWrapped('${formData.fields}---paRAM');
      Response response = await ApiClient()
          .apiClientInstance(
            context,
            await _sharedPref.getToken(),
          )
          .post('DeletePost', data: formData);
      return DataArrayModel.fromJson(response.data);
    } catch (e) {
      printWrapped(e);
      return null;
    }
  }

  responsePostList(DataArrayModel value) {
    printWrapped("<-------- Deleat Response -------->");
    _utils.hideProgressDialog();
    printWrapped("<-------- hideProgressDialog -------->");
    if (value != null) {
      if (value.ResponseCode == 1) {
        setState(() {
          postList = postList;
          images = postList.post_images;
        });
        Navigator.pop(context);
        widget.callback(isUpdate);
      } else {
        _utils.alertDialog(value.ResponseMessage);
      }
    }
  }
}
