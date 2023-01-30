import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:marquee/marquee.dart';
import 'package:rolley_app/AppFlow/CreateFeedScreen.dart';
import 'package:rolley_app/AppFlow/DirectMessageScreen.dart';
import 'package:rolley_app/AppFlow/FeedScreen.dart';
import 'package:rolley_app/AppFlow/HomeScreen.dart';
import 'package:rolley_app/AppFlow/PersonalProfileScreen.dart';
import 'package:rolley_app/Common/Constants.dart';
import 'package:rolley_app/Common/SharedPref.dart';
import 'package:rolley_app/Common/app_theme.dart';
import 'package:rolley_app/Common/screen_size_utils.dart';
import 'package:socket_io_client/socket_io_client.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class MainTab extends StatefulWidget {
  @override
  _MainTabScreenState createState() => _MainTabScreenState();
}

class _MainTabScreenState extends State<MainTab> with WidgetsBindingObserver {
  String _selected = "Home";
  String userId;
  SharedPref _sharedPref;

  Timer timer;

  String socketChatUrl = 'http://rolley.app:3000';

  String kOnline = "online";
  String kOffline = "offline";
  String kUpdatePresence = "updatePresence";

  List<String> online = [];
  List<String> offLine = [];

  @override
  void dispose() {
    super.dispose();
    // WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void initState() {
    super.initState();
    // WidgetsBinding.instance.addObserver(this);

    tabBody = Home();
    _sharedPref = SharedPref();
    getUserID();

    online.add(userId);
    online.add(kOnline);
    offLine.add(userId);
    offLine.add(kOffline);

    // TODO :- Socket....
    Constants.socket = IO.io(socketChatUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': true
    });

    // on Connect
    Constants.socket.onConnect((data) => checkSocket(data, "onConnect"));

    //on Connecting
    Constants.socket.onConnecting((data) => checkSocket(data, "onConnecting"));

    //on ConnectError
    Constants.socket.onConnectError((data) => checkSocket(data, "onConnectError"));

    //on Connect Timeout
    Constants.socket.onConnectTimeout((data) => checkSocket(data, "onConnectTimeout"));

    //on Disconnect
    Constants.socket.onDisconnect((data) => checkSocket(data, "onDisconnect"));
  }

  getUserID() async {
    userId = await _sharedPref.getUserId();
  }

  void checkSocket(data, String identify) {
    printWrapped("-identify-$identify-:$data");
    if (identify == 'onConnect') {
      timer = Timer.periodic(Duration(seconds: 5), (Timer t) => updatePresenceEmit());
    } else {
      if (timer != null) {
        timer.cancel();
      }
    }
  }

  // TODO :- Online & Offline Presence
  updatePresenceEmit() {
    if (userId != "") {
      if (Constants.socket.connected) {
        emitUpdatePresence();
      }
    }
  }

  emitUpdatePresence() {
    var sendMsg = ["${userId ?? ""}", "online"];

    Constants.socket.emit(kUpdatePresence, sendMsg);
  }

  emitDisconnectPresence() {
    var sendMsg = ["$userId", "offline"];
    Constants.socket.emit(kUpdatePresence, sendMsg);
  }

  // TODO :- UI
  @override
  Widget build(BuildContext context) {
    ScreenUtil.instance.init(context);
    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
    return Container(
      color: AppTheme.gray,
      child: SafeArea(
        top: false,
        bottom: true,
        child: Stack(
          children: [
            tabBody,
            bottomBar(context),
          ],
        ),
      ),
    );
  }

  Widget tabBody = Container(
    color: Colors.white,
  );

  Widget bottomBar([BuildContext context]) {
    return Column(
      children: [
        Expanded(
          child: SizedBox(),
        ),
        Container(
          height: 1.0,
          decoration: BoxDecoration(
            color: AppTheme.gray,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(6.0),
              topRight: Radius.circular(6.0),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black,
                offset: Offset(0.0, 1.0),
                blurRadius: 6.0,
              ),
            ],
          ),
        ),
        Visibility(
          visible: _selected == "Home",
          child: Container(
            height: SV.setHeight(120),
            width: double.infinity,
            color: AppTheme.themeBlue,
            alignment: Alignment.center,
            child: Material(
              color: AppTheme.themeBlue,
              child: Marquee(
                text: 'Welcome To ROLLEY Welcome To ROLLEY Welcome To ROLLEY Welcome To ROLLEY Welcome To ROLLEY Welcome To ROLLEY Welcome To ROLLEY Welcome To ROLLEY',
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
        ),
        Container(
          height: SV.setHeight(130),
          decoration: BoxDecoration(
            color: AppTheme.gray,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(6.0),
              topRight: Radius.circular(6.0),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selected = "Home";
                    });
                    tabBody = Home();
                  },
                  child: Image.asset(
                    _selected == "Home" ? 'assets/images/ic_tab_selected_01.png' : 'assets/images/ic_tab_unselected_01.png',
                    height: 25,
                    width: 25,
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selected = "Feed";
                    });
                    tabBody = FeedScreen(
                      identify: "Feed",
                    );
                  },
                  child: Image.asset(
                    _selected == "Feed" ? 'assets/images/ic_tab_selected_03.png' : 'assets/images/ic_tab_unselected_03.png',
                    height: 25,
                    width: 25,
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selected = "Direct Message";
                    });
                    tabBody = DirectMessageScreen();
                  },
                  child: Image.asset(
                    _selected == "Direct Message" ? 'assets/images/ic_tab_selected_04.png' : 'assets/images/ic_tab_unselected_04.png',
                    height: 25,
                    width: 25,
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selected = "Filter";
                    });
                    tabBody = CreateFeedScreen();
                  },
                  child: Image.asset(
                    _selected == "Filter" ? 'assets/images/ic_tab_selected_05.png' : 'assets/images/ic_tab_unselected_05.png',
                    height: 25,
                    width: 25,
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selected = "Personal Profile";
                    });
                    tabBody = PersonalProfile(
                      profileType: "personal",
                      userId: userId,
                      isFrom: "myProfile",
                    );
                  },
                  child: Image.asset(
                    _selected == "Personal Profile" ? 'assets/images/ic_tab_selected_07.png' : 'assets/images/ic_tab_unselected_07.png',
                    height: 25,
                    width: 25,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
