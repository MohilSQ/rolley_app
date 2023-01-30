//DirectMessageScreen
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rolley_app/AppFlow/ChatScreen.dart';
import 'package:rolley_app/Common/ApiClient.dart';
import 'package:rolley_app/Common/Constants.dart';
import 'package:rolley_app/Common/SharedPref.dart';
import 'package:rolley_app/Common/Utils.dart';
import 'package:rolley_app/Common/app_theme.dart';
import 'package:rolley_app/Common/screen_size_utils.dart';
import 'package:rolley_app/Model/DataArrayModel.dart';
import 'package:rolley_app/Model/DataModel.dart';

class DirectMessageScreen extends StatefulWidget {
  _DirectMessageScreenState createState() => _DirectMessageScreenState();
}

class _DirectMessageScreenState extends State<DirectMessageScreen> {
  SharedPref _sharedPref;
  Utils _util;

  String search = '';
  String userId = '';

  List<DataModel> userList = [];

  TextEditingController searchController = TextEditingController();

  // Socket Variable
  String kGetChatUserList = "getChatUserlist";
  String kChatList = "Chatlist";
  String kUpdateChatList = "updateChatList";

  // Date and time
  static final DateTime now = DateTime.now();
  static final DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm:ss');
  final String formattedDate = formatter.format(now);
  String updatePresence = "updatePresence";

  @override
  void dispose() {
    // Chat List Emit
    Constants.socket.off(kChatList);

    // Update Chat List Emit
    Constants.socket.off(kUpdateChatList);

    var sendMsg = ["$userId", "offline"];
    Constants.socket.emit(updatePresence, sendMsg);
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _util = Utils(context: context);
    _sharedPref = SharedPref();
    getUserId();
  }

  void printWrappedWrapped(String text) {
    final pattern = RegExp('.{1,800}'); // 800 is the size of each chunk
    pattern.allMatches(text).forEach((match) => printWrapped(match.group(0)));
  }

  // get UserId
  getUserId() async {
    userId = await _sharedPref.getUserId();

    // Socket ...
    if (Constants.socket.connected) {
      // Get Chat User List Emit
      Constants.socket.emit(kGetChatUserList, userId);

      // Set Chat list Set
      Constants.socket.on(kChatList, (data1) async {
        printWrappedWrapped("Response --------------->>>>> $data1");
        if (data1 == null) {
          return;
        }

        setState(() {
          userList = (data1["Result"] as List).map((e) => DataModel.fromJson(e)).toList();
        });
      });

      // Update Chat list Set
      Constants.socket.on(kUpdateChatList, (data) async {
        if (data == null) {
          return;
        }
        setState(() {
          var newChatObj = data["Result"];

          var isMatch = false;

          for (int i = 0; i < userList.length; i++) {
            if (userList[i].roomNo == newChatObj["roomNo"]) {
              userList[i].roomNo = newChatObj;
              isMatch = true;
              break;
            }
          }
          if (!isMatch) {
            userList.insert(0, newChatObj);
          }
          userList
            ..sort((a, b) => formatter.format(DateTime.parse(a.created_date)).compareTo(
                  formatter.format(DateTime.parse(b.created_date)),
                ));
        });
      });
      printWrapped("userId - presence update------------- >>>> $userId");
      var sendMsg = ["${userId ?? ""}", "online"];
      printWrapped("Send msg -------------- >>>> $sendMsg");
      Constants.socket.emit(updatePresence, sendMsg);
    } else {
      Constants.socket.connect();
    }
  }

  Widget build(BuildContext context) {
    ScreenUtil.instance.init(context);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        brightness: Brightness.light,
        backgroundColor: AppTheme.gray,
        title: Text(
          'Direct Message ',
          style: TextStyle(
            fontFamily: AppTheme.fontName,
            fontSize: SV.setSP(60),
            color: AppTheme.black,
          ),
        ),
        leading: Padding(
          padding: EdgeInsets.all(14.0),
          child: Image(
            image: AssetImage('assets/images/ic_logo_appbar.png'),
          ),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.all(14.0),
            child: Container(),
          ),
        ],
      ),
      body: Container(
        padding: EdgeInsets.all(SV.setWidth(30)),
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
                        controller: searchController,
                        onChanged: (val) {
                          search = val;
                          if (search.length >= 2) {
                            printWrapped("<<<< --------------- Search -------------- >>>>");
                            _util.isNetwotkAvailable(true).then((value) => checkNetwork(value));
                          }
                        },
                        decoration: InputDecoration(
                          hintText: 'Search',
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                  search == null
                      ? Icon(
                          Icons.search,
                          color: AppTheme.lightGray,
                        )
                      : GestureDetector(
                          onTap: () {
                            getUserId();
                            setState(() {
                              searchController.clear();
                            });
                            FocusScope.of(context).requestFocus(new FocusNode());
                          },
                          child: Icon(
                            Icons.clear,
                            color: AppTheme.lightGray,
                          ),
                        ),
                ],
              ),
            ),
            SizedBox(
              height: SV.setHeight(30),
            ),
            Expanded(
              child: Visibility(
                visible: userList.isNotEmpty,
                replacement: Center(
                  child: Text(
                    "No Chat found",
                    style: TextStyle(
                      fontFamily: AppTheme.fontName,
                      fontSize: SV.setSP(56),
                      color: AppTheme.black,
                    ),
                  ),
                ),
                child: ListView.builder(
                  padding: EdgeInsets.all(0),
                  itemCount: userList.length,
                  shrinkWrap: true,
                  
                  itemBuilder: (context, index) {
                    return Container(
                      child: Column(
                        children: [
                          GestureDetector(
                            onTap: () {
                              printWrapped("Device -------------- >>>> ${userList[index]}");
                              Navigator.push(
                                  context,
                                  MaterialPageRoute<dynamic>(
                                    builder: (BuildContext context) => ChatScreen(
                                      userObject: userList[index] ?? "",
                                    ),
                                  )).then(
                                (value) => backWithData(value, index),
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
                                      height: SV.setWidth(200),
                                      width: SV.setWidth(200),
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
                                          userList[index].name,
                                          style: TextStyle(
                                            fontFamily: AppTheme.fontName,
                                            fontSize: SV.setSP(56),
                                            color: AppTheme.black,
                                          ),
                                        ),
                                        Text(
                                          userList[index].msg != null ? userList[index].msg : " ",
                                          maxLines: 1,
                                          style: TextStyle(
                                            fontFamily: AppTheme.fontName,
                                            fontSize: SV.setSP(44),
                                            color: AppTheme.lightGray,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      SizedBox(width: SV.setHeight(8)),
                                      Text(
                                        _util.DateToStringDate(
                                          _util.utcToLocal(userList[index].created_date),
                                          Constants.YYYY_MM_DD_HH_MM_SS_24,
                                          Constants.HH_MM_A,
                                        ),
                                        style: TextStyle(
                                          fontFamily: AppTheme.fontName,
                                          fontSize: SV.setSP(32),
                                          color: AppTheme.lightGray,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(
                            height: SV.setHeight(30),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
            SizedBox(height: SV.setHeight(130)),
          ],
        ),
      ),
    );
  }

  backWithData(value, int position) {
    printWrapped("""
    
       Value -------------->>>> $value,
       position -------------->>>> $position,
       msg -------------->>>> ${value != null && value.msg != null ? value.msg : ""},
       created_date -------------->>>> ${value != null && value.created_date != null ? value.created_date : ""},
    
    """);

    if (value != null) {
      userList[position].msg = '${value.msg ?? " "}';
      userList[position].created_date = '${value.created_date ?? ""}';

      userList.sort(
        (a, b) {
          debugPrint("b.created_date ----->>> ${b.created_date}");
          debugPrint("a.created_date ----->>> ${a.created_date}");
          debugPrint("a.created_date ----->>> ${a.name}");
          if (b.created_date != null) {
            return b.created_date.compareTo(a.created_date);
          }
          return null;
        },
      );
      setState(() {});
    }
  }

  //*************************************
  // Users List :-
  //*************************************
  checkNetwork(bool value) {
    if (value) {
      Future<DataArrayModel> user = usersList();
      user.then((value) => responsePostList(value));
    }
  }

  Future<DataArrayModel> usersList() async {
    try {
      FormData formData = FormData.fromMap({
        'user_id': await _sharedPref.getUserId(),
        'serach_name': search,
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
    if (value != null) {
      if (value.ResponseCode == 1) {
        setState(() {
          userList = value.Result;
        });
      } else {
        _util.alertDialog(value.ResponseMessage);
      }
    }
  }
}
