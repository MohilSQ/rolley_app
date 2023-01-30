//CommentScreen
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rolley_app/AppFlow/PersonalProfileScreen.dart';
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

class CommentScreen extends StatefulWidget {
  String postId;
  DataModel dataModel;
  CommentScreen({this.postId, this.dataModel});

  _CommentScreenState createState() => _CommentScreenState();
}

class _CommentScreenState extends State<CommentScreen> {
  Utils _utils;
  SharedPref _sharedPref;
  List<DataModel> commentList = [];

  String userId;
  String commentId;
  bool edit = false;
  TextEditingController commentMsg = TextEditingController();

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

  getUserId() async {
    userId = await _sharedPref.getUserId();
  }

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
            'Comment',
            style: TextStyle(
              fontFamily: AppTheme.fontName,
              fontSize: SV.setSP(60),
              color: AppTheme.black,
            ),
          ),
          automaticallyImplyLeading: false,
          centerTitle: true,
        ),
        body: Padding(
          padding: EdgeInsets.all(
            SV.setWidth(30),
          ),
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: commentList.length,
                    itemBuilder: (context, index) {
                      return Container(
                        child: Column(
                          children: [
                            Container(
                              padding: EdgeInsets.fromLTRB(
                                SV.setWidth(40),
                                SV.setWidth(30),
                                SV.setWidth(40),
                                SV.setWidth(30),
                              ),
                              color: AppTheme.gray,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute<dynamic>(
                                              builder: (BuildContext context) => PersonalProfile(
                                                profileType: commentList[index].user_id == userId ? "personal" : "other",
                                                userId: commentList[index].user_id,
                                                isFrom: "otherProfile",
                                              ),
                                            ),
                                          );
                                        },
                                        child: commentList[index].profile_image != null
                                            ? ClipRRect(
                                                borderRadius: BorderRadius.circular(SV.setWidth(80.0)),
                                                child: CachedNetworkImage(
                                                  imageUrl: commentList[index].profile_image,
                                                  errorWidget: (context, url, error) => Image.asset('assets/images/ic_default_profile.png'),
                                                  progressIndicatorBuilder: (context, url, progress) => Image.asset('assets/images/ic_default_profile.png'),
                                                  height: SV.setWidth(130),
                                                  width: SV.setWidth(130),
                                                  fit: BoxFit.cover,
                                                ),
                                              )
                                            : ClipRRect(
                                                borderRadius: BorderRadius.circular(SV.setWidth(80.0)),
                                                child: FadeInImage.assetNetwork(
                                                  placeholder: 'assets/images/ic_default_profile.png',
                                                  image: '',
                                                  height: SV.setWidth(130),
                                                  width: SV.setWidth(130),
                                                  fit: BoxFit.cover,
                                                ),
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
                                              commentList[index].name,
                                              style: TextStyle(
                                                fontFamily: AppTheme.fontName,
                                                fontSize: SV.setSP(40),
                                                color: AppTheme.black,
                                              ),
                                            ),
                                            Text(
                                              commentList[index].date_time,
                                              style: TextStyle(
                                                fontFamily: AppTheme.fontName,
                                                fontSize: SV.setSP(28),
                                                color: AppTheme.lightGray,
                                              ),
                                            ),
                                            SizedBox(
                                              height: SV.setHeight(10),
                                            ),
                                            Text(
                                              commentList[index].comment,
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
                                      commentList[index].user_id == userId
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
                                                    commentMsg.text = commentList[index].comment;
                                                    commentId = commentList[index].id;
                                                    edit = true;
                                                  });
                                                } else if (value == 2) {
                                                  setState(() {
                                                    commentId = commentList[index].id;
                                                  });
                                                  _utils.isNetwotkAvailable(true).then(
                                                        (value) => checkNetworkForDeleteComment(value),
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
                            SizedBox(
                              height: SV.setHeight(10),
                            ),
                          ],
                        ),
                      );
                    }),
              ),
              Divider(height: 1, color: AppTheme.Border),
              Container(
                margin: EdgeInsets.only(
                  top: SV.setHeight(20),
                  bottom: SV.setHeight(10),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: SV.setSP(30)),
                        alignment: Alignment.center,
                        child: TextField(
                          //onChanged
                          //controller: messageController,
                          onSubmitted: (string) {
                            setState(() {});
                          },
                          maxLines: null,
                          keyboardType: TextInputType.multiline,
                          style: new TextStyle(
                            fontFamily: AppTheme.fontName,
                            fontSize: SV.setSP(50),
                            fontWeight: FontWeight.w600,
                            color: AppTheme.black,
                          ),
                          textAlign: TextAlign.left,
                          controller: commentMsg,
                          decoration: new InputDecoration(
                            contentPadding: EdgeInsets.symmetric(vertical: 10),
                            hintText: 'Comment type Here..',
                            hintStyle: new TextStyle(
                              fontFamily: AppTheme.fontName,
                              fontSize: SV.setSP(50),
                              fontWeight: FontWeight.w600,
                              color: AppTheme.lightGray,
                            ),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.transparent,
                              ),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.transparent,
                              ),
                            ),
                            border: new UnderlineInputBorder(
                              borderSide: new BorderSide(
                                color: Colors.transparent,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      height: SV.setWidth(110),
                      width: SV.setWidth(110),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppTheme.orange,
                        shape: BoxShape.circle,
                      ),
                      child: GestureDetector(
                        onTap: () {
                          if (isValid()) {
                            edit
                                ? _utils.isNetwotkAvailable(true).then(
                                      (value) => checkNetworkForUpdateComment(value),
                                    )
                                : _utils.isNetwotkAvailable(true).then(
                                      (value) => checkNetworkForAddComment(value),
                                    );
                          }
                        },
                        child: Transform.rotate(
                          angle: 180 * -0.6 / 180,
                          child: Icon(
                            Icons.send_rounded,
                            color: Colors.white,
                            size: SV.setSP(60),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Divider(height: 1, color: AppTheme.Border),
              SizedBox(
                height: SV.setHeight(40),
              ),
            ],
          ),
        ),
      ),
    );
  }

  //*************************************
  // Comment List :-
  //*************************************
  checkNetwork(bool value) {
    if (value) {
      _utils.showProgressDialog();
      Future<DataArrayModel> user = commentsList();
      user.then((value) => responsePostList(value));
    }
  }

  Future<DataArrayModel> commentsList() async {
    try {
      FormData formData = FormData.fromMap({
        'user_id': await _sharedPref.getUserId(),
        'post_id': widget.postId,
      });
      printWrapped('${formData.fields}---paRAM');
      Response response = await ApiClient()
          .apiClientInstance(
            context,
            await _sharedPref.getToken(),
          )
          .post('commentList', data: formData);
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
          commentList = value.Result;
          if (commentList != null) {
            widget.dataModel.total_comment = commentList.length.toString();
          }
        });
      } else {
        _utils.alertDialog(value.ResponseMessage);
      }
    }
  }

  bool isValid() {
    if (_utils.isValidationEmpty(commentMsg.text)) {
      _utils.alertDialog(CommonStrings.errorAddComment);
      return false;
    }
    return true;
  }

  //*************************************
  // Review Post :-
  //*************************************
  checkNetworkForAddComment(bool value) {
    if (value) {
      _utils.showProgressDialog();
      Future<DataObjectResponse> user = addComment();
      user.then((value) => responseComment(value));
    }
  }

  Future<DataObjectResponse> addComment() async {
    try {
      FormData formData = FormData.fromMap({
        'user_id': await _sharedPref.getUserId(),
        'post_id': widget.postId,
        'comment': commentMsg.text,
        'date_time': formattedDate,
      });
      printWrapped('${formData.fields}---paRAM');
      Response response = await ApiClient()
          .apiClientInstance(
            context,
            await _sharedPref.getToken(),
          )
          .post('commentPost', data: formData);
      return DataObjectResponse.fromJson(response.data);
    } catch (e) {
      printWrapped(e);
      return null;
    }
  }

  responseComment(DataObjectResponse value) {
    _utils.hideProgressDialog();
    if (value != null) {
      if (value.ResponseCode == 1) {
        setState(() {
          commentMsg.text = '';
        });
        if (value.Result != null) {
          commentList.add(value.Result);
          widget.dataModel.total_comment = commentList.length.toString();
        }
      } else {
        _utils.alertDialog(value.ResponseMessage);
      }
    }
  }

  //*************************************
  // Update Comment Post :-
  //*************************************
  checkNetworkForUpdateComment(bool value) {
    if (value) {
      _utils.showProgressDialog();
      Future<DataObjectResponse> user = updateComment();
      user.then((value) => responseUpdateComment(value));
    }
  }

  Future<DataObjectResponse> updateComment() async {
    try {
      FormData formData = FormData.fromMap({
        'user_id': await _sharedPref.getUserId(),
        'comment_id': commentId,
        'comment': commentMsg.text,
      });
      printWrapped('${formData.fields}---paRAM');
      Response response = await ApiClient()
          .apiClientInstance(
            context,
            await _sharedPref.getToken(),
          )
          .post('commentUpdate', data: formData);
      return DataObjectResponse.fromJson(response.data);
    } catch (e) {
      printWrapped(e);
      return null;
    }
  }

  responseUpdateComment(DataObjectResponse value) {
    _utils.hideProgressDialog();
    if (value != null) {
      if (value.ResponseCode == 1) {
        setState(() {
          commentMsg.text = '';
          commentId = "";
        });
        _utils.isNetwotkAvailable(true).then((value) => checkNetwork(value));
      } else {
        _utils.alertDialog(value.ResponseMessage);
      }
    }
  }

  //*************************************
  // Delete Comment Post :-
  //*************************************
  checkNetworkForDeleteComment(bool value) {
    if (value) {
      _utils.showProgressDialog();
      Future<DataObjectResponse> user = deleteComment();
      user.then((value) => responseDeleteComment(value));
    }
  }

  Future<DataObjectResponse> deleteComment() async {
    try {
      FormData formData = FormData.fromMap({
        'user_id': await _sharedPref.getUserId(),
        'comment_id': commentId,
      });
      printWrapped('${formData.fields}---paRAM');
      Response response = await ApiClient()
          .apiClientInstance(
            context,
            await _sharedPref.getToken(),
          )
          .post('commentDelete', data: formData);
      return DataObjectResponse.fromJson(response.data);
    } catch (e) {
      printWrapped(e);
      return null;
    }
  }

  responseDeleteComment(DataObjectResponse value) {
    _utils.hideProgressDialog();
    if (value != null) {
      if (value.ResponseCode == 1) {
        setState(() {
          commentId = "";
        });
        _utils.isNetwotkAvailable(true).then((value) => checkNetwork(value));
      } else {
        _utils.alertDialog(value.ResponseMessage);
      }
    }
  }
}
