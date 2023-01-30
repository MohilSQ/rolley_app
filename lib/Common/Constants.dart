import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class Constants {
  static void ScreenPortrait() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
  }

  static IO.Socket socket;

  static const String YYYY_MM_DD_HH_MM_SS = 'yyyy-MM-dd hh:mm:ss';
  static const String YYYY_MM_DD_HH_MM_SS_24 = 'yyyy-MM-dd HH:mm:ss';
  static const String HH_MM_A = 'hh:mm a';
  static String androidPlacesApi = "AIzaSyATozybKhREUYW__VLBEuS07ZCmWan536A";
  static String iosPlacesApi = "AIzaSyCJvX4hrShpN6N3QYTAzVyJBqSjC1WxbnE";
}

void printWrapped(String text) {
  final pattern = RegExp('.{1,8000}'); // 800 is the size of each chunk
  pattern.allMatches(text).forEach((match) => debugPrint(match.group(0)));
}
