import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:connectivity/connectivity.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart' as path;
import 'package:rolley_app/AppFlow/MainTabScreen.dart';
import 'package:rolley_app/Common/Constants.dart';
import 'package:rolley_app/Common/screen_size_utils.dart';

import 'SharedPref.dart';
import 'app_theme.dart';

class Utils {
  BuildContext context;

  Utils({this.context});

  Future<bool> isNetwotkAvailable(bool showDialog) async {
    ConnectivityResult _result;
    final Connectivity _connectivity = Connectivity();
    try {
      _result = await _connectivity.checkConnectivity();
      printWrapped(_result.toString());
      switch (_result) {
        case ConnectivityResult.wifi:
          return true;
        case ConnectivityResult.mobile:
          return true;
        default:
          if (showDialog) {
            alertDialog('Your internet is not available, please try again later');
          }
          return false;
      }
    } on PlatformException catch (e) {
      printWrapped(e.toString());
      if (showDialog) {
        alertDialog('Your internet is not available, please try again later');
      }
      return false;
    }
  }

  void alertDialog(String title) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Rolley',
          style: TextStyle(
            fontSize: 18,
            fontFamily: 'Bahnschrift',
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          title,
          style: TextStyle(
            fontSize: 15,
            fontFamily: 'Bahnschrift',
            fontWeight: FontWeight.w400,
          ),
        ),
        actions: [
          GestureDetector(
            onTap: () {
              Navigator.of(context, rootNavigator: true).pop();
            },
            child: Container(
              height: 30,
              width: 50,
              child: Text('OK'),
            ),
          ),
        ],
      ),
    );
  }

  void alertDialogPostCreate(String title) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Rolley',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 18,
            fontFamily: 'Bahnschrift',
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 15,
            fontFamily: 'Bahnschrift',
            fontWeight: FontWeight.w400,
          ),
        ),
        actions: [
          GestureDetector(
            onTap: () {
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MainTab(),
                  ),
                  (route) => false);
            },
            child: Container(
              height: 30,
              width: 50,
              child: Text('OK'),
            ),
          ),
        ],
      ),
    );
  }

  void alertDialogPost({String title, BuildContext context, String identify}) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Rolley',
          style: TextStyle(
            fontSize: 18,
            fontFamily: 'Bahnschrift',
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          title,
          style: TextStyle(
            fontSize: 15,
            fontFamily: 'Bahnschrift',
            fontWeight: FontWeight.w400,
          ),
        ),
        actions: [
          GestureDetector(
            onTap: () {
              if (identify == null) {
                Navigator.of(context, rootNavigator: true).pop();
              } else {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              }
            },
            child: Container(
              height: 30,
              width: 50,
              child: Text('OK'),
            ),
          ),
        ],
      ),
    );
  }

  void alertWithAction(String title, value) async {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
                title: Text(
                  'Rolley',
                  style: TextStyle(fontSize: 25, fontFamily: 'Bahnschrift', fontWeight: FontWeight.w700),
                ),
                content: Text(title, style: TextStyle(fontSize: 15, fontFamily: 'Bahnschrift', fontWeight: FontWeight.w400)),
                actions: [
                  FlatButton(
                    child: Text('OK'),
                    onPressed: () {
                      Navigator.of(context, rootNavigator: true).pop();
                      Navigator.push(
                        context,
                        MaterialPageRoute<dynamic>(
                          builder: (BuildContext context) => value,
                        ),
                      );
                    },
                  ),
                ]));
  }

  bool isValidationEmpty(String val) {
    if (val == null || val.isEmpty || val == "null" || val == "" || val.length == 0 || val == "NULL") {
      return true;
    } else {
      return false;
    }
  }

  bool emailValidator(String email) {
    String p = r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';

    RegExp regExp = new RegExp(p);

    if (regExp.hasMatch(email)) {
      return true;
    }

    return false;
  }

  void showProgressDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => WillPopScope(
        onWillPop: () async => false,
        child: Container(
          child: Center(
            child: Container(
              width: SV.setHeight(180),
              height: SV.setHeight(180),
              decoration: BoxDecoration(
                color: AppTheme.themeBlue,
                borderRadius: BorderRadius.circular(SV.setHeight(30)),
              ),
              child: SpinKitCircle(
                color: Colors.white,
                size: SV.setHeight(90),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void hideProgressDialog() {
    Navigator.of(context, rootNavigator: true).pop();
  }

  String getDeviceType() {
    if (Platform.isAndroid) {
      return 'Android';
    } else {
      return 'iOS';
    }
  }

  Future<void> clearUserPref() async {
    SharedPref sharedPref = SharedPref();
    sharedPref.remove(sharedPref.UserId);
    sharedPref.remove(sharedPref.Token);
    sharedPref.remove(sharedPref.UserResponse);
  }

  Future<String> getFileNameWithExtension(File file) async {
    if (await file.exists()) {
      return path.basename(file.path);
    } else {
      return "";
    }
  }

  String generateMd5(String input) {
    return md5.convert(utf8.encode(input)).toString();
  }

  String timeAgoSinceDate(String dateString, {bool numericDates = true}) {
    DateTime dateUtc = DateTime.parse(dateString);
    var dateTime = DateFormat("yyyy-MM-dd HH:mm:ss").parse(dateUtc.toString(), true);
    DateTime date = dateTime.toLocal();
    final date2 = DateTime.now();
    final difference = date2.difference(date);

    if ((difference.inDays / 365).floor() >= 2) {
      return (numericDates) ? '${(difference.inDays / 365).floor()}Y' : '${(difference.inDays / 365).floor()} Years ago';
    } else if ((difference.inDays / 365).floor() >= 1) {
      return (numericDates) ? '1Y' : 'Last year';
    } else if ((difference.inDays / 30).floor() >= 2) {
      return '${(difference.inDays / 365).floor()} M';
    } else if ((difference.inDays / 30).floor() >= 1) {
      return (numericDates) ? '1M' : 'Last Month';
    } else if ((difference.inDays / 7).floor() >= 2) {
      return (numericDates) ? '${(difference.inDays / 7).floor()}w' : '${(difference.inDays / 7).floor()} Weeks ago';
    } else if ((difference.inDays / 7).floor() >= 1) {
      return (numericDates) ? '1w' : 'Last week';
    } else if (difference.inDays >= 2) {
      return (numericDates) ? '${difference.inDays}d' : '${difference.inDays} Days ago';
    } else if (difference.inDays >= 1) {
      return (numericDates) ? '1d' : 'Yesterday';
    } else if (difference.inHours >= 2) {
      return '${difference.inHours}h';
    } else if (difference.inHours >= 1) {
      return (numericDates) ? '1h' : 'An hour ago';
    } else if (difference.inMinutes >= 2) {
      return '${difference.inMinutes}m';
    } else if (difference.inMinutes >= 1) {
      return (numericDates) ? '1m' : 'A minute ago';
    } else if (difference.inSeconds >= 3) {
      return '${difference.inSeconds}s';
    } else {
      return ' now';
    }
  }

  bool isImage(String path) {
    final mimeType = lookupMimeType(path);

    return mimeType.startsWith('image/');
  }

  String currentDate(String outputFormat) {
    var now = new DateTime.now().toUtc();
    var formatter = new DateFormat(outputFormat);
    String formattedDate = formatter.format(now);

    return formattedDate;
  }

  String DateToStringDate(String date, String formatInput, String formatOutput) {
    if (date != null && date.length != 0) {
      final format = DateFormat(formatInput);
      DateTime gettingDate = format.parse(date);
      final DateFormat formatter = DateFormat(formatOutput);
      final String formatted = formatter.format(gettingDate);
      return formatted;
    }
    return '';
  }

  String utcToLocal(String date, {bool isChat}) {
    if (date != null && date.length != 0) {
      var dateTime = DateFormat(Constants.YYYY_MM_DD_HH_MM_SS_24).parse(date.toString(), true);

      DateTime dateLocal = dateTime.toLocal();
      return dateLocal.toString();
    }
    return '';
  }
}
