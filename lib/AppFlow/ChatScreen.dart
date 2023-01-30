import 'dart:async';
import 'dart:io';

import 'package:bubble/bubble.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rolley_app/Common/Constants.dart';
import 'package:rolley_app/Common/SharedPref.dart';
import 'package:rolley_app/Common/Utils.dart';
import 'package:rolley_app/Common/app_theme.dart';
import 'package:rolley_app/Common/screen_size_utils.dart';
import 'package:rolley_app/Model/DataModel.dart';

class ChatScreen extends StatefulWidget {
  DataModel userObject;
  bool isFromProfile;

  ChatScreen({
    this.userObject,
    this.isFromProfile = false,
  });

  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  Utils _utils;
  SharedPref _sharedPref;

  // Date and time
  static final DateTime now = DateTime.now();
  static final DateFormat formatter = DateFormat('yyyy-MM-dd hh:mm:ss');
  final String formattedDate = formatter.format(now);

  ScrollController _scrollController = new ScrollController();

  String autoMessage = '', presence = "offline";

  String kUpdateOnChat = "updateOnChat";
  String kGetMessageList = "getMessageList";

  String kMessageList = "message list";
  String kOnChatUpdate = "onChatUpdate";

  String kNewMessage = "new message";
  String kLivePresence = "livePresence";
  List<DataModel> massageList = [];
  String isRead = "0";

  String userId, receiverId, roomNo;

  List<String> varUpdateOnChat = [];
  List<String> varMessageList = [];
  List<String> varOffMessageList = [];

  Utils _util;

  TextEditingController messageController = new TextEditingController();

  void dispose() {
    super.dispose();

    // Update On Chat Emit
    Constants.socket.emit(kUpdateOnChat, varUpdateOnChat);

    // Get Message List Emit
    Constants.socket.emit(kGetMessageList, varOffMessageList);

    // Off Chat Update Emit
    Constants.socket.off(kOnChatUpdate);

    // Off Message List Emit
    Constants.socket.off(kMessageList);

    // Off NEW Message Emit
    Constants.socket.off(kNewMessage);

    // Off livePresence Emit
    Constants.socket.off(kLivePresence, _updatePresence);
  }

  @override
  void initState() {
    super.initState();

    _utils = Utils(context: context);
    _sharedPref = SharedPref();
    getUserId();
  }

  // Scroll To Bottom
  void bottomView() {
    Timer(
      Duration(seconds: 1),
      () => _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      ),
    );
  }

  // get UserId
  getUserId() async {
    userId = await _sharedPref.getUserId();

    receiverId = widget.userObject.id == null ? widget.userObject.user_id : widget.userObject.id;
    roomNo = widget.userObject.roomNo;
    printWrapped("roomNo --------->>> $roomNo");

    varUpdateOnChat.add(userId);
    varUpdateOnChat.add(receiverId);
    varMessageList.add(userId);
    varMessageList.add(receiverId);
    varMessageList.add(roomNo);
    varOffMessageList.add(userId);
    varOffMessageList.add("0");
    varOffMessageList.add(roomNo);

    // Update On Chat Emit
    Constants.socket.emit(kUpdateOnChat, varUpdateOnChat);

    // Get Message List Emit
    Constants.socket.emit(kGetMessageList, varMessageList);

    if (Constants.socket.connected) {
      // Set Chat list Set
      // Live Presence Set

      Constants.socket.on(kMessageList, (data) async {
        printWrapped("Response - kMessageList -------------- >>>> ${data.toString()}");

        var rId = data["receiverId"]; //9
        var rOnChatId = data["receiverOnChat_id"]; //3
//9
        if (rId == receiverId && rOnChatId == userId) {
          isRead = "1";
        }

        setState(() {
          massageList = (data["Result"] as List).map((itemWord) => DataModel.fromJson(itemWord)).toList();
          if (massageList != null && massageList.length > 0) {
            bottomView();
          }
        });
      });

      // ON Chat Update Set
      Constants.socket.on(kOnChatUpdate, (data) async {
        printWrapped("Response - kOnChatUpdate -------------- >>>> $data");

        var uId = data["userId"];
        var onChat = data["on_chat"];

        if (uId == receiverId) {
          if (onChat == userId) {
            isRead = "1";
          } else {
            isRead = "0";
          }
        } else {
          isRead = "0";
        }
        setState(() {});
      });

      // ON new massage update
      Constants.socket.on(kNewMessage, (data) async {
        printWrapped("Response - kNewMessage -------------- >>>> $data");
        // printWrapped("Response - kNewMessage -------------- >>>> ${json.decode(data)}");
        DataModel massage = DataModel.fromJson(data["Result"]);
        if (massage.receiver_id.toString() == userId && massage.sender_id.toString() == receiverId) {
          massageList.add(massage);
          setState(() {
            if (massageList != null && massageList.length > 0) bottomView();
          });
        }
      });

      Constants.socket.on(kLivePresence, _updatePresence);
    }
  }

  _updatePresence(data) async {
    printWrapped("Response live or not -------------- >>>> $data");
    presence = data["presence"];
    setState(() {});
  }

  Future<bool> _onBackPressed() {
    if (massageList != null && massageList.length != 0) {
      Navigator.pop(context, massageList[massageList.length - 1]);
    } else {
      Navigator.pop(context);
    }
    return Future.value(true);
  }

  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      bottom: false,
      child: WillPopScope(
        onWillPop: _onBackPressed,
        child: Scaffold(
          appBar: AppBar(
            brightness: Brightness.light,
            titleSpacing: 0.0,
            backgroundColor: AppTheme.gray,
            leadingWidth: SV.setWidth(200),
            leading: GestureDetector(
              onTap: _onBackPressed,
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
            title: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ClipOval(
                  child: CachedNetworkImage(
                    imageUrl: widget.userObject.profile_image,
                    placeholder: (context, url) => Image.asset('assets/images/ic_default_profile.png'),
                    errorWidget: (context, url, error) => Image.asset('assets/images/ic_default_profile.png'),
                    fit: BoxFit.cover,
                    height: SV.setWidth(120),
                    width: SV.setWidth(120),
                  ),
                ),
                SizedBox(width: SV.setWidth(30)),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.userObject.name,
                      style: TextStyle(
                        fontFamily: AppTheme.fontName,
                        fontSize: SV.setSP(50),
                        color: AppTheme.black,
                      ),
                    ),
                    Text(
                      '${presence ?? ""}',
                      style: TextStyle(
                        fontFamily: AppTheme.fontName,
                        fontSize: SV.setSP(36),
                        color: AppTheme.lightGray,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            automaticallyImplyLeading: false,
          ),
          body: Container(
            margin: EdgeInsets.only(top: SV.setHeight(30)),
            child: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: massageList.length,
                    controller: _scrollController,
                    itemBuilder: (context, index) {
                      return massageList[index].sender_id.toString() == userId ? _buildSenderRow(context, massageList[index], _utils) : _buildReceiverRow(context, massageList[index], _utils);
                    },
                  ),
                ),
                Divider(
                  height: 1,
                  color: AppTheme.Border,
                ),
                Container(
                  margin: EdgeInsets.only(
                    top: SV.setHeight(20),
                    bottom: Platform.isIOS ? SV.setHeight(60) : SV.setHeight(20),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          margin: EdgeInsets.fromLTRB(
                            SV.setWidth(60.0),
                            SV.setWidth(2.0),
                            SV.setWidth(60.0),
                            SV.setWidth(2.0),
                          ),
                          alignment: Alignment.center,
                          child: TextField(
                            controller: messageController,
                            maxLines: null,
                            keyboardType: TextInputType.multiline,
                            style: new TextStyle(
                              fontFamily: AppTheme.fontName,
                              fontSize: SV.setSP(50),
                              fontWeight: FontWeight.w600,
                              color: AppTheme.black,
                            ),
                            textAlign: TextAlign.left,
                            decoration: new InputDecoration(
                              contentPadding: EdgeInsets.symmetric(vertical: 10),
                              hintText: 'Type Here..',
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
                        height: SV.setWidth(130),
                        width: SV.setWidth(130),
                        margin: EdgeInsets.only(right: SV.setWidth(40)),
                        child: CircleAvatar(
                          backgroundColor: AppTheme.orange,
                          child: InkWell(
                            onTap: () {
                              if (messageController.text.trim().isNotEmpty) {
                                setState(
                                  () {
                                    // New Message
                                    onNewMessageEmit(
                                      messageController.text,
                                      userId,
                                      receiverId,
                                      "text",
                                      isRead,
                                      _utils.currentDate(Constants.YYYY_MM_DD_HH_MM_SS_24),
                                      roomNo,
                                    );
                                    messageController.clear();
                                  },
                                );
                              }
                            },
                            child: Transform.rotate(
                              angle: 180 * -0.6 / 180,
                              child: Icon(
                                Icons.send,
                                color: Colors.white,
                              ),
                            ),
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
      ),
    );
  }

  onNewMessageEmit(
    String msg,
    String userId,
    String receiverId,
    String msgType,
    String isRead,
    String currentDate,
    String roomNo,
  ) {
    DataModel model = new DataModel();
    model.sender_id = int.tryParse(userId);
    model.receiver_id = num.parse(receiverId);
    model.is_read = num.parse(isRead);
    model.created_date = currentDate;
    model.roomNo = roomNo.toString();
    model.msg_type = msgType.toString();
    model.msg = msg;

    var sendMsg = [msg, userId, receiverId, msgType, isRead, roomNo, currentDate];
    printWrapped("sendMsg ------------>>> $sendMsg");
    Constants.socket.emit(kNewMessage, sendMsg);
    massageList.add(model);
    setState(() {
      bottomView();
    });
  }
}

Widget _buildReceiverRow(
  BuildContext context,
  DataModel text,
  Utils _utils,
) =>
    Container(
      margin: EdgeInsets.only(
        left: SV.setWidth(40),
        right: SV.setWidth(100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Bubble(
            margin: BubbleEdges.only(top: SV.setWidth(30)),
            stick: true,
            padding: BubbleEdges.all(SV.setWidth(50)),
            color: AppTheme.gray,
            nip: BubbleNip.leftBottom,
            child: Text(
              text.msg.toString(),
              style: new TextStyle(
                fontFamily: AppTheme.fontName,
                fontSize: SV.setSP(40),
                height: 1.0,
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: SV.setWidth(20)),
            child: Text(
              "${_utils.timeAgoSinceDate(text.created_date)}",
              style: new TextStyle(
                fontFamily: AppTheme.fontName,
                fontSize: SV.setSP(30),
              ),
            ),
          ),
        ],
      ),
    );

Widget _buildSenderRow(
  BuildContext context,
  DataModel text,
  Utils _utils,
) =>
    Container(
      margin: EdgeInsets.only(
        left: SV.setWidth(100),
        right: SV.setWidth(40),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Bubble(
            margin: BubbleEdges.only(top: SV.setWidth(30)),
            padding: BubbleEdges.all(SV.setWidth(50)),
            stick: true,
            color: AppTheme.orange,
            nip: BubbleNip.rightBottom,
            alignment: Alignment.topRight,
            child: Text(
              text.msg.toString(),
              style: new TextStyle(
                fontFamily: AppTheme.fontName,
                fontSize: SV.setSP(40),
                color: Colors.white,
                height: 1.0,
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: SV.setWidth(20)),
            child: Text(
              "${_utils.timeAgoSinceDate(text.created_date)}",
              style: new TextStyle(
                fontFamily: AppTheme.fontName,
                fontSize: SV.setSP(30),
              ),
            ),
          )
        ],
      ),
    );
