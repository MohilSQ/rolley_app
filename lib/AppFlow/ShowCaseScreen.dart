//ShowCaseScreen
import 'dart:ui';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rolley_app/AppFlow/DetailsScreen.dart';
import 'package:rolley_app/Common/ApiClient.dart';
import 'package:rolley_app/Common/Constants.dart';
import 'package:rolley_app/Common/SharedPref.dart';
import 'package:rolley_app/Common/Utils.dart';
import 'package:rolley_app/Common/app_theme.dart';
import 'package:rolley_app/Common/screen_size_utils.dart';
import 'package:rolley_app/Model/DataArrayModel.dart';
import 'package:rolley_app/Model/DataModel.dart';

class ShowCaseScreen extends StatefulWidget {
  String postType;

  ShowCaseScreen({this.postType});

  _ShowCaseScreenState createState() => _ShowCaseScreenState();
}

class _ShowCaseScreenState extends State<ShowCaseScreen> {
  String search = '';
  Utils _utils;
  SharedPref _sharedPref;
  List<DataModel> postList = [];
  List<DataModel> tempList = [];
  List<DataModel> listSearchAll = [];

  // Date and time
  static final DateTime now = DateTime.now();
  static final DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm:ss');
  final String formattedDate = formatter.format(now);

  @override
  void initState() {
    super.initState();
    printWrapped("<<<<<-------- ${widget.postType} -------->>>>>");
    _utils = Utils(context: context);
    _sharedPref = SharedPref();

    _utils.isNetwotkAvailable(true).then((value) => checkNetwork(value));
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
            'Show Case',
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
              Container(
                margin: EdgeInsets.only(
                  top: SV.setHeight(12),
                ),
                decoration: BoxDecoration(
                  color: AppTheme.gray,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: SV.setWidth(30),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        margin: EdgeInsets.only(
                          top: SV.setHeight(12),
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
                          cursorColor: AppTheme.themeBlue,
                          onChanged: (val) {
                            search = val;
                            filter(search);
                          },
                          decoration: InputDecoration(
                            hintText: 'Search',
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ),
                    Icon(
                      Icons.search,
                      color: AppTheme.lightGray,
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: SV.setHeight(30),
              ),
              Expanded(
                child: Visibility(
                  visible: tempList.isNotEmpty,
                  replacement: Center(
                    child: Text(
                      "No Data found",
                      style: TextStyle(
                        fontFamily: AppTheme.fontName,
                        fontSize: SV.setSP(56),
                        color: AppTheme.black,
                      ),
                    ),
                  ),
                  child: RefreshIndicator(
                    onRefresh: () {
                      return Future.delayed(
                        Duration(seconds: 1),
                        () {
                          _utils.isNetwotkAvailable(true).then((value) => checkNetwork(value));
                        },
                      );
                    },
                    child: GridView.builder(
                      physics: AlwaysScrollableScrollPhysics(),
                      // shrinkWrap: true,
                      itemCount: tempList.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                      ),
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: EdgeInsets.all(SV.setHeight(8.0)),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute<dynamic>(
                                  builder: (BuildContext context) => DetailsScreen(
                                    post: tempList[index].id,
                                    address: tempList[index].address,
                                    lat: tempList[index].lat,
                                    lon: tempList[index].lng,
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: AppTheme.lightGray,
                                  width: 1,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Stack(
                                children: [
                                  Container(
                                    height: SV.setHeight(420),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black26,
                                          offset: Offset(0.0, 2.0),
                                          blurRadius: 3.0,
                                        )
                                      ],
                                      image: DecorationImage(
                                        image: postList[index].post_images.length > 0 ? NetworkImage(postList[index].post_images[0].video_thumb == "" ? postList[index].post_images[0].image : postList[index].post_images[0].video_thumb) : AssetImage('assets/images/ic_manue_defalt.jpg'),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  Align(
                                    alignment: Alignment.bottomCenter,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.stretch,
                                      verticalDirection: VerticalDirection.up,
                                      children: [
                                        Container(
                                          // decoration: BoxDecoration(
                                          //   color: Colors.black54,
                                          //   borderRadius: BorderRadius.only(
                                          //     bottomLeft: Radius.circular(8.0),
                                          //     bottomRight: Radius.circular(
                                          //       8.0,
                                          //     ),
                                          //   ),
                                          // ),
                                          padding: EdgeInsets.all(5),
                                          child: Text(
                                            tempList[index].post_title,
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 14,
                                              fontWeight: FontWeight.normal,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
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

  void filter(String search) {
    printWrapped('${listSearchAll.length}----tempArray--');
    printWrapped(search);
    tempList.clear();
    if (search == '') {
      setState(() {
        tempList.addAll(listSearchAll);
      });
    } else {
      for (int i = 0; i < listSearchAll.length; i++) {
        if (listSearchAll[i].post_title.toLowerCase().contains(
              search.toLowerCase(),
            )) {
          setState(() {
            tempList.add(listSearchAll[i]);
          });
        }
      }
    }
    if (tempList.length == 0) {
      setState(() {});
    }
    printWrapped(tempList.length.toString() + " -- " + postList.length.toString());
  }

  //*************************************
  // Post List :-
  //*************************************
  checkNetwork(bool value) {
    if (value) {
      _utils.showProgressDialog();
      Future<DataArrayModel> user = PostList();
      user.then(
        (value) => responsePostList(value),
      );
    }
  }

  Future<DataArrayModel> PostList() async {
    printWrapped('*************************');
    printWrapped(await _sharedPref.getToken());

    try {
      FormData formData = FormData.fromMap(
        {
          'user_id': await _sharedPref.getUserId(),
          'post_type': widget.postType,
          'current_date': formattedDate,
        },
      );
      printWrapped('${formData.fields}---paRAM');
      Response response = await ApiClient()
          .apiClientInstance(
            context,
            await _sharedPref.getToken(),
          )
          .post('PostList', data: formData);
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
        listSearchAll.addAll(postList);
        setState(() {
          tempList = value.Result.cast<DataModel>();
        });
      } else {
        _utils.alertDialog(value.ResponseMessage);
      }
    }
  }
}
