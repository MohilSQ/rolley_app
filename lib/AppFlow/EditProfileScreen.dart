// EditProfileScreen
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:multiselect_formfield/multiselect_formfield.dart';
import 'package:rolley_app/AppFlow/getAddressScreen.dart';
import 'package:rolley_app/Common/ApiClient.dart';
import 'package:rolley_app/Common/CommonStrings.dart';
import 'package:rolley_app/Common/Constants.dart';
import 'package:rolley_app/Common/SharedPref.dart';
import 'package:rolley_app/Common/Utils.dart';
import 'package:rolley_app/Common/app_theme.dart';
import 'package:rolley_app/Common/screen_size_utils.dart';
import 'package:rolley_app/Model/DataObjectResponse.dart';

typedef StringValue = void Function(String);

class EditProfileScreen extends StatefulWidget {
  String pProfileImg, pUserID, pName, pBio, pEmail, pContactNumber, pWebsite, pAddress, pParts;
  StringValue _callback;

  EditProfileScreen(
    this.pProfileImg,
    this.pUserID,
    this.pName,
    this.pBio,
    this.pEmail,
    this.pContactNumber,
    this.pWebsite,
    this.pAddress,
    this.pParts,
    this._callback,
  );

  _EditProfileScreenState createState() => _EditProfileScreenState();
}

enum AppState {
  free,
  picked,
  cropped,
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  //*************************************
  // Properties & Variable :-
  //*************************************
  File imageFile, imageCropFile;
  AppState state;

  Utils _utils;
  SharedPref _sharedPref;

  String profileUrl = '';
  TextEditingController name = TextEditingController();
  TextEditingController description = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController contactNumber = TextEditingController();
  TextEditingController website = TextEditingController();

  MultipartFile profileImage;

  // bool _tryAgain = false;
  String oldPassword = '';
  String newPassword = '';
  String confirmNewPassword = '';

  // Position _currentPosition;
  String _currentAddress;
  var addressDetaile;

  String isUpdate = '';

  List _myActivities;

  final homeScaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    // _getCurrentLocation();
    printWrapped("imageFile: --------> $imageFile");
    printWrapped("pProfileImg: ------> ${widget.pProfileImg}");
    _myActivities = [];

    _utils = Utils(context: context);
    _sharedPref = SharedPref();

    setState(() {
      name.text = widget.pName;
      email.text = widget.pEmail;
      description.text = widget.pBio;
      contactNumber.text = widget.pContactNumber;
      website.text = widget.pWebsite;

      if (widget.pParts == "") {
        _myActivities = [];
      } else {
        _myActivities = widget.pParts
            .split(",")
            .map(
              (String text) => (text.trim()),
            )
            .toList();
      }

      if (widget.pProfileImg != "") {
        imageFile = null;
      }
    });
  }

  Dialog agentIdDialog() {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      //this right here
      child: Container(
        width: double.infinity,
        height: SV.setHeight(1000),
        child: Column(
          children: [
            Container(
              height: SV.setHeight(120),
              width: double.infinity,
              color: AppTheme.lightGray,
              child: Center(
                child: Text(
                  'Change Password',
                  style: TextStyle(
                    fontFamily: AppTheme.fontName,
                    fontSize: SV.setSP(70),
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  SizedBox(
                    height: SV.setHeight(40),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: SV.setHeight(12)),
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
                      obscureText: true,
                      cursorColor: AppTheme.themeBlue,
                      onChanged: (val) {
                        setState(() {
                          oldPassword = val;
                        });
                      },
                      decoration: InputDecoration(
                        hintText: 'Old password',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: SV.setHeight(40),
                  ),
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
                    child: TextField(
                      style: TextStyle(
                        fontFamily: AppTheme.fontName,
                        fontSize: SV.setSP(50),
                      ),
                      obscureText: true,
                      cursorColor: AppTheme.themeBlue,
                      onChanged: (val) {
                        newPassword = val;
                      },
                      decoration: InputDecoration(
                        hintText: 'New password',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: SV.setHeight(40),
                  ),
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
                    child: TextField(
                      style: TextStyle(
                        fontFamily: AppTheme.fontName,
                        fontSize: SV.setSP(50),
                      ),
                      obscureText: true,
                      cursorColor: AppTheme.themeBlue,
                      onChanged: (val) {
                        setState(() {
                          confirmNewPassword = val;
                        });
                      },
                      decoration: InputDecoration(
                        hintText: 'Confirm new password',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: SV.setHeight(80),
                  ),
                  FlatButton(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6.0),
                      side: BorderSide(
                        color: AppTheme.lightGray,
                        width: 2,
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context, rootNavigator: true).pop();
                    },
                    color: AppTheme.lightGray,
                    textColor: Colors.white,
                    padding: EdgeInsets.symmetric(
                      horizontal: SV.setWidth(200),
                      vertical: SV.setHeight(32),
                    ),
                    child: Text(
                      "CHANGE".toUpperCase(),
                      style: TextStyle(
                        fontSize: SV.setSP(50),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget build(BuildContext context) {
    Future<bool> _goToBack() async {
      Navigator.pop(context);
      widget._callback(isUpdate);
      return Future.value(true);
    }

    ScreenUtil.instance.init(context);

    //*************************************
    // Image Dialog  :-
    //*************************************
    void chooseImageDialog() {
      SimpleDialog _sb = new SimpleDialog(
        title: Text(
          'Select Option',
          style: new TextStyle(
            fontFamily: AppTheme.fontName,
            fontSize: SV.setSP(60),
            color: AppTheme.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        children: [
          SimpleDialogOption(
              child: Text(
                'Take Photo',
                style: new TextStyle(
                  fontFamily: AppTheme.fontName,
                  fontSize: SV.setSP(40),
                  color: AppTheme.black,
                ),
              ),
              onPressed: () {
                Navigator.of(context, rootNavigator: true).pop();
                pickImage(context, 'Camera');
              }),
          SimpleDialogOption(
              child: Text(
                'Choose from Gallery',
                style: new TextStyle(
                  fontFamily: AppTheme.fontName,
                  fontSize: SV.setSP(40),
                  color: AppTheme.black,
                ),
              ),
              onPressed: () {
                Navigator.of(context, rootNavigator: true).pop();
                pickImage(context, 'Gallery');
              }),
          SimpleDialogOption(
            child: Text(
              'Cancel',
              style: new TextStyle(
                fontFamily: AppTheme.fontName,
                fontSize: SV.setSP(40),
                color: AppTheme.black,
              ),
            ),
            onPressed: () {
              Navigator.of(context, rootNavigator: true).pop();
            },
          )
        ],
      );
      showDialog(context: context, builder: (context) => _sb);
    }

    //*************************************
    // UI :-
    //*************************************
    return MaterialApp(
      home: SafeArea(
        top: false,
        bottom: false,
        child: WillPopScope(
          onWillPop: _goToBack,
          child: Scaffold(
            key: homeScaffoldKey,
            appBar: AppBar(
              brightness: Brightness.light,
              titleSpacing: 0.0,
              backgroundColor: AppTheme.gray,
              leadingWidth: SV.setWidth(200),
              leading: GestureDetector(
                onTap: _goToBack,
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
                'Edit Profile',
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
                SizedBox(
                  height: SV.setHeight(50),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () {
                        chooseImageDialog();
                      },
                      child: Container(
                        width: SV.setHeight(360),
                        height: SV.setWidth(500),
                        child: Stack(
                          children: [
                            Center(
                              child: Container(
                                width: SV.setWidth(360),
                                height: SV.setHeight(360),
                                decoration: BoxDecoration(
                                  color: Colors.white60,
                                  borderRadius: BorderRadius.circular(14),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black26,
                                      offset: Offset(0.0, 2.0),
                                      blurRadius: 7.0,
                                      spreadRadius: 3,
                                    ),
                                  ],
                                ),
                                child: imageFile == null
                                    ? _utils.isValidationEmpty(widget.pProfileImg)
                                        ? Image.asset('assets/images/ic_default_profile.png')
                                        : ClipRRect(
                                            borderRadius: BorderRadius.circular(14),
                                            child: CachedNetworkImage(
                                              imageUrl: widget.pProfileImg,
                                              placeholder: (context, url) => Image.asset('assets/images/ic_default_profile.png'),
                                              errorWidget: (context, url, error) => Image.asset('assets/images/ic_default_profile.png'),
                                              fit: BoxFit.cover,
                                            ),
                                          )
                                    : Image.file(imageFile),
                              ),
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: SV.setWidth(180),
                                      height: SV.setHeight(60),
                                      padding: EdgeInsets.all(SV.setHeight(16.0)),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(14),
                                        boxShadow: [
                                          BoxShadow(
                                            color: AppTheme.lightGray,
                                            offset: Offset(0.0, 1.0),
                                            blurRadius: 1.0,
                                          )
                                        ],
                                      ),
                                      child: Image.asset('assets/images/ic_camera.png'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                Container(
                  margin: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top,
                  ),
                  padding: EdgeInsets.all(
                    SV.setWidth(50),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Name',
                        style: TextStyle(
                          fontFamily: AppTheme.fontName,
                          fontSize: SV.setSP(50),
                          color: AppTheme.lightGray,
                        ),
                      ),
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
                        child: TextField(
                          style: TextStyle(
                            fontFamily: AppTheme.fontName,
                            fontSize: SV.setSP(50),
                          ),
                          cursorColor: AppTheme.themeBlue,
                          controller: name,
                          decoration: InputDecoration(
                            hintText: 'Enter a name',
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: SV.setHeight(40),
                      ),
                      Text(
                        'Short Description',
                        style: TextStyle(
                          fontFamily: AppTheme.fontName,
                          fontSize: SV.setSP(50),
                          color: AppTheme.lightGray,
                        ),
                      ),
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
                        child: TextField(
                          keyboardType: TextInputType.multiline,
                          maxLength: null,
                          maxLines: null,
                          style: TextStyle(
                            fontFamily: AppTheme.fontName,
                            fontSize: SV.setSP(50),
                          ),
                          cursorColor: AppTheme.themeBlue,
                          controller: description,
                          decoration: InputDecoration(
                            hintText: 'Enter a description',
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: SV.setHeight(40),
                      ),
                      Text(
                        'Contact Number',
                        style: TextStyle(
                          fontFamily: AppTheme.fontName,
                          fontSize: SV.setSP(50),
                          color: AppTheme.lightGray,
                        ),
                      ),
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
                        child: TextField(
                          style: TextStyle(
                            fontFamily: AppTheme.fontName,
                            fontSize: SV.setSP(50),
                          ),
                          cursorColor: AppTheme.themeBlue,
                          keyboardType: TextInputType.phone,
                          controller: contactNumber,
                          decoration: InputDecoration(
                            hintText: 'XXX XX XXXXX',
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: SV.setHeight(40),
                      ),
                      Text(
                        'Website',
                        style: TextStyle(
                          fontFamily: AppTheme.fontName,
                          fontSize: SV.setSP(50),
                          color: AppTheme.lightGray,
                        ),
                      ),
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
                        child: TextField(
                          style: TextStyle(
                            fontFamily: AppTheme.fontName,
                            fontSize: SV.setSP(50),
                          ),
                          cursorColor: AppTheme.themeBlue,
                          keyboardType: TextInputType.url,
                          controller: website,
                          decoration: InputDecoration(
                            hintText: 'https://google.com',
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: SV.setHeight(40),
                      ),
                      Text(
                        'Address',
                        style: TextStyle(
                          fontFamily: AppTheme.fontName,
                          fontSize: SV.setSP(50),
                          color: AppTheme.lightGray,
                        ),
                      ),
                      GestureDetector(
                        onTap: () async {
                          addressDetaile = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => GetAddressScreen(),
                            ),
                          );

                          if (addressDetaile != null) {
                            _currentAddress = addressDetaile.toString();
                          }
                          setState(() {});
                        },
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: AppTheme.gray,
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: SV.setWidth(22),
                            vertical: SV.setHeight(34),
                          ),
                          child: Text(
                            _currentAddress ?? "Select Address",
                            style: TextStyle(
                              fontFamily: AppTheme.fontName,
                              fontSize: SV.setSP(50),
                              color: AppTheme.black,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: SV.setHeight(40),
                      ),
                      Text(
                        'Manufacturing Parts',
                        style: TextStyle(
                          fontFamily: AppTheme.fontName,
                          fontSize: SV.setSP(50),
                          color: AppTheme.lightGray,
                        ),
                      ),
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
                        child: MultiSelectFormField(
                          fillColor: AppTheme.gray,
                          chipBackGroundColor: AppTheme.lightGray.withOpacity(0.5),
                          chipLabelStyle: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                          dialogTextStyle: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                          checkBoxActiveColor: AppTheme.lightGray,
                          checkBoxCheckColor: Colors.white,
                          dialogShapeBorder: RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(12.0),
                            ),
                          ),
                          title: Text(
                            "Select parts",
                            style: TextStyle(fontSize: 16),
                          ),
                          dataSource: [
                            {"display": "Cars", "value": "Cars"},
                            {"display": "Trucks", "value": "Trucks"},
                            {"display": "Motorcycle", "value": "Motorcycle"},
                            {"display": "Miscellaneous", "value": "Miscellaneous"},
                          ],
                          textField: 'display',
                          valueField: 'value',
                          okButtonLabel: 'OK',
                          cancelButtonLabel: 'CANCEL',
                          hintWidget: Text('Please choose one or more'),
                          initialValue: _myActivities,
                          onSaved: (value) {
                            if (value == null) return;
                            setState(() {
                              _myActivities = value;
                            });
                          },
                        ),
                      ),
                      SizedBox(
                        height: SV.setHeight(60),
                      ),
                      Center(
                        child: FlatButton(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6.0),
                            side: BorderSide(
                              color: AppTheme.lightGray,
                              width: 2,
                            ),
                          ),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) => agentIdDialog(),
                            );
                          },
                          color: Colors.white,
                          textColor: AppTheme.lightGray,
                          padding: EdgeInsets.symmetric(
                            horizontal: SV.setWidth(140),
                            vertical: SV.setHeight(32),
                          ),
                          child: Text(
                            "CHANGE PASSWORD".toUpperCase(),
                            style: TextStyle(
                              fontSize: SV.setSP(50),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: SV.setHeight(60),
                      ),
                      Center(
                        child: FlatButton(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6.0),
                            side: BorderSide(
                              color: AppTheme.lightGray,
                              width: 2,
                            ),
                          ),
                          onPressed: () {
                            if (isValid()) {
                              _utils.isNetwotkAvailable(true).then((value) => checkNetwork(value));
                            }
                          },
                          color: AppTheme.lightGray,
                          textColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                            horizontal: SV.setWidth(300),
                            vertical: SV.setHeight(36),
                          ),
                          child: Text(
                            "Update".toUpperCase(),
                            style: TextStyle(
                              fontSize: SV.setSP(50),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  //*************************************
  // Check Validation & Network :-
  //*************************************
  checkNetwork(bool value) {
    if (value) {
      _utils.showProgressDialog();
      Future<DataObjectResponse> user = register();
      user.then((value) => responseRegister(value));
    }
  }

  Future<DataObjectResponse> register() async {
    String selectedParts = _myActivities.toString().replaceAll('[', '').toString().replaceAll(']', '');
    try {
      FormData formData = FormData.fromMap({
        'user_id': await _sharedPref.getUserId(),
        'name': name.text,
        'bio': description.text,
        'contact_number': contactNumber.text,
        'website': website.text,
        'address': _currentAddress,
        'manufacturing_parts': selectedParts,
        'device_type': _utils.getDeviceType(),
        'profile_image': profileImage,
      });
      printWrapped('${formData.fields}---paRAM');
      Response response = await ApiClient().apiClientInstance(context, await _sharedPref.getToken()).post('UpdateProfile', data: formData);
      return DataObjectResponse.fromJson(response.data);
    } catch (e) {
      printWrapped(e);
      return null;
    }
  }

  responseRegister(DataObjectResponse value) {
    _utils.hideProgressDialog();
    if (value != null) {
      if (value.ResponseCode == 1) {
        _utils.alertDialog(value.ResponseMessage);
        isUpdate = '1';
        storeData(value);
      } else if (value.ResponseCode == 2) {
        _utils.alertDialog(value.ResponseMessage);
      } else {
        _utils.alertDialog(value.ResponseMessage);
      }
    }
  }

  Future<void> storeData(DataObjectResponse objectResponse) async {
    _sharedPref.saveString(_sharedPref.UserId, objectResponse.Result.id);
    _sharedPref.saveString(_sharedPref.Token, objectResponse.Result.generate_token);
    _sharedPref.saveObject(_sharedPref.UserResponse, objectResponse.Result);
  }

  bool isValid() {
    if (imageFile == null && widget.pProfileImg == null) {
      _utils.alertDialog(CommonStrings.errorImagePick);
      return false;
    } else if (_utils.isValidationEmpty(name.text)) {
      _utils.alertDialog(CommonStrings.errorFullName);
      return false;
    } else if (_utils.isValidationEmpty(description.text)) {
      _utils.alertDialog(CommonStrings.errorDescription);
      return false;
    } else if (_utils.isValidationEmpty(contactNumber.text)) {
      _utils.alertDialog(CommonStrings.errorContactNumber);
      return false;
    }
    return true;
  }

  //*************************************
  // Forgot Password Validation & API :-
  //*************************************
  checkNetworkForgot(bool value) {
    if (value) {
      _utils.showProgressDialog();
      Future<DataObjectResponse> user = changePassword();
      user.then((value) => resChangePassword(value));
    }
  }

  Future<DataObjectResponse> changePassword() async {
    try {
      FormData formData = FormData.fromMap({
        'user_id': await _sharedPref.getUserId(),
        'old_pwd': _utils.generateMd5(oldPassword),
        'new_pwd': _utils.generateMd5(newPassword),
      });
      printWrapped('${formData.fields}---paRAM');
      Response response = await ApiClient().apiClientInstance(context, '').post('ChangePassword', data: formData);
      return DataObjectResponse.fromJson(response.data);
    } catch (e) {
      printWrapped(e);
      return null;
    }
  }

  resChangePassword(DataObjectResponse value) {
    _utils.hideProgressDialog();
    if (value != null) {
      if (value.ResponseCode == 1) {
        _utils.alertDialog(value.ResponseMessage);
      }
    }
  }

  bool isForgotValid() {
    if (_utils.isValidationEmpty(oldPassword)) {
      _utils.alertDialog(CommonStrings.errorOldPassword);
      return false;
    } else if (oldPassword.length < 6) {
      _utils.alertDialog(CommonStrings.errorOldPasswordLength);
      return false;
    } else if (_utils.isValidationEmpty(newPassword)) {
      _utils.alertDialog(CommonStrings.errorNewPassword);
      return false;
    } else if (newPassword.length < 6) {
      _utils.alertDialog(CommonStrings.errorNewPasswordLength);
      return false;
    } else if (_utils.isValidationEmpty(confirmNewPassword)) {
      _utils.alertDialog(CommonStrings.errorConNewPassword);
      return false;
    } else if (confirmNewPassword.length < 6) {
      _utils.alertDialog(CommonStrings.errorConNewPasswordLength);
      return false;
    } else if (newPassword != confirmNewPassword) {
      _utils.alertDialog(CommonStrings.errorPasswordNotMatch);
      return false;
    }
    return true;
  }

  //*************************************
  // Image Selection & Crop :-
  //*************************************
  Future pickImage(context, String identify) async {
    ImagePicker _picker = new ImagePicker();
    XFile imagePickerFile;
    if (identify == "Gallery") {
      imagePickerFile = await _picker.pickImage(source: ImageSource.gallery);
    } else if (identify == "Camera") {
      imagePickerFile = await _picker.pickImage(source: ImageSource.camera);
    }

    if (imagePickerFile != null) {
      imageFile = new File(imagePickerFile.path);
      state = AppState.picked;
      _cropImage();
      setState(() {});
    }
  }

  Future<Null> _cropImage() async {
    File croppedFile = (await ImageCropper.cropImage(
      sourcePath: imageFile.path,
      aspectRatioPresets: Platform.isAndroid ? [CropAspectRatioPreset.square] : [CropAspectRatioPreset.square],
      androidUiSettings: AndroidUiSettings(
        toolbarTitle: 'Cropper',
        toolbarColor: Colors.deepOrange,
        toolbarWidgetColor: Colors.white,
        initAspectRatio: CropAspectRatioPreset.original,
        lockAspectRatio: true,
      ),
      iosUiSettings: IOSUiSettings(),
    ));
    if (croppedFile != null) {
      imageFile = croppedFile;
      printWrapped("cropImage ----------->>> $imageFile");
      multiPartFile();
      state = AppState.cropped;
      setState(() {});
    }
  }

  multiPartFile() async {
    profileImage = MultipartFile.fromBytes(File(imageFile.path).readAsBytesSync(), filename: imageFile.path.split("/").last);
    widget.pProfileImg = '';
    setState(() {});
  }

  //*************************************
  // Google Places API Methods:-
  //*************************************

/*  _getCurrentLocation() {
    printWrapped("<<<<<-------- Get Current Location -------->>>>>");
    Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.bestForNavigation,
      // forceAndroidLocationManager: true,
    ).then((Position position) {
      setState(() {
        _currentPosition = position;
        printWrapped("<<<<<-------- position: -------->>>>> $position");
        _getAddressFromLatLng();
      });
    }).catchError((e) {
      printWrapped(e);
    });
  }

  _getAddressFromLatLng() async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(_currentPosition.latitude, _currentPosition.longitude);

      Placemark place = placemarks[0];

      setState(() {
        _currentAddress = "${place.thoroughfare.isEmpty ? "" : place.thoroughfare + ", "}${place.subLocality.isEmpty ? "" : place.subLocality + ", "}${place.subAdministrativeArea.isEmpty ? "" : place.subAdministrativeArea + ", "}${place.postalCode.isEmpty ? "" : place.postalCode}, ${place.administrativeArea}, ${place.country}";
        printWrapped("<<<<<-------- Current Address: -------->>>>> $_currentAddress");
      });
    } catch (e) {
      printWrapped(e);
    }
  }*/
}
