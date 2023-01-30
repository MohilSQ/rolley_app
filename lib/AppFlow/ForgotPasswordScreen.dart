import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rolley_app/Common/ApiClient.dart';
import 'package:rolley_app/Common/CommonStrings.dart';
import 'package:rolley_app/Common/Constants.dart';
import 'package:rolley_app/Common/Utils.dart';
import 'package:rolley_app/Common/app_theme.dart';
import 'package:rolley_app/Common/screen_size_utils.dart';
import 'package:rolley_app/Model/DataObjectResponse.dart';

class ForgotPassword extends StatefulWidget {
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPassword> {
  String email = '';
  Utils _utils;

  @override
  void initState() {
    super.initState();
    _utils = Utils(context: context);
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([]);
    ScreenUtil.instance.init(context);

    return SafeArea(
      top: false,
      bottom: false,
      child: Scaffold(
        body: Container(
            margin: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
            padding: EdgeInsets.all(SV.setWidth(50)),
            child: ListView(
                //crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Image.asset(
                          'assets/images/ic_back.png',
                          height: SV.setWidth(70),
                          width: SV.setWidth(60),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 40.0,
                  ),
                  Center(
                    child: Container(
                      width: 120,
                      height: 120,
                      padding: EdgeInsets.all(SV.setWidth(86)),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(60)),
                        color: AppTheme.gray,
                      ),
                      child: Image.asset('assets/images/ic_forgotpass_lock.png'),
                    ),
                  ),
                  SizedBox(
                    height: 30.0,
                  ),
                  Center(
                    child: Text(
                      'Forgot your password?',
                      style: TextStyle(fontFamily: AppTheme.fontName, fontSize: 28, color: AppTheme.black),
                    ),
                  ),
                  SizedBox(
                    height: 30.0,
                  ),
                  Text(
                    'Please enter the email address associated with your email. We will email you a link to reset your password.',
                    style: TextStyle(fontFamily: AppTheme.fontName, fontSize: 17, color: AppTheme.black),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(
                    height: 70.0,
                  ),
                  Text('Email', style: TextStyle(fontFamily: AppTheme.fontName, fontSize: 16, color: AppTheme.lightGray)),
                  Container(
                    margin: EdgeInsets.only(top: SV.setHeight(12)),
                    decoration: BoxDecoration(color: AppTheme.gray, borderRadius: BorderRadius.circular(8.0)),
                    padding: EdgeInsets.symmetric(horizontal: SV.setWidth(30)),
                    child: TextField(
                      style: TextStyle(fontFamily: AppTheme.fontName, fontSize: 17),
                      cursorColor: AppTheme.themeBlue,
                      keyboardType: TextInputType.emailAddress,
                      onChanged: (val) {
                        email = val;
                      },
                      decoration: InputDecoration(
                        hintText: 'abc@gmail.com',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 20.0,
                  ),
                  Center(
                    child: FlatButton(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6.0), side: BorderSide(color: AppTheme.lightGray, width: 2)),
                      onPressed: () {
                        _utils.isNetwotkAvailable(true).then((value) => checkNetwork(value));
                      },
                      color: AppTheme.lightGray,
                      textColor: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: SV.setWidth(300), vertical: SV.setHeight(36)),
                      child: Text("SEND".toUpperCase(), style: TextStyle(fontSize: 17)),
                    ),
                  ),
                ])),
      ),
    );
  }

  //*************************************
  // Check Validation & Network :-
  //*************************************
  checkNetwork(bool value) {
    if (value) {
      _utils.showProgressDialog();
      Future<DataObjectResponse> user = forgotPassword();
      user.then((value) => responseforgotPass(value));
    }
  }

  Future<DataObjectResponse> forgotPassword() async {
    try {
      FormData formData = FormData.fromMap({
        'email': email,
      });
      printWrapped('${formData.fields}---paRAM');
      Response response = await ApiClient().apiClientInstance(context, '').post('forgotPwd', data: formData);
      return DataObjectResponse.fromJson(response.data);
    } catch (e) {
      printWrapped(e);
      return null;
    }
  }

  responseforgotPass(DataObjectResponse value) {
    _utils.hideProgressDialog();
    if (value != null) {
      if (value.ResponseCode == 1) {
        _utils.alertDialog(value.ResponseMessage);
      } else {
        _utils.alertDialog(value.ResponseMessage);
      }
    }
  }

  bool isValid() {
    if (_utils.isValidationEmpty(email)) {
      _utils.alertDialog(CommonStrings.errorEmail);
      return false;
    } else if (!_utils.emailValidator(email)) {
      _utils.alertDialog(CommonStrings.errorValidEmail);
      return false;
    }
    return true;
  }
}
