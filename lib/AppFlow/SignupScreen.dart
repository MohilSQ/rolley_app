import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:multiselect_formfield/multiselect_formfield.dart';
import 'package:rolley_app/AppFlow/MainTabScreen.dart';
import 'package:rolley_app/Common/ApiClient.dart';
import 'package:rolley_app/Common/CommonStrings.dart';
import 'package:rolley_app/Common/Constants.dart';
import 'package:rolley_app/Common/SharedPref.dart';
import 'package:rolley_app/Common/Utils.dart';
import 'package:rolley_app/Common/app_theme.dart';
import 'package:rolley_app/Common/screen_size_utils.dart';
import 'package:rolley_app/Model/DataObjectResponse.dart';

class Signup extends StatefulWidget {
  String type;
  String name;
  String email;
  String profilePic;
  String googleId;
  String isGoogle;
  String fbId;
  String isFb;

  Signup({
    this.type = "",
    this.name = "",
    this.email = "",
    this.profilePic = "",
    this.googleId = "",
    this.isGoogle = "",
    this.fbId = "",
    this.isFb = "",
  });

  _SignupScreenState createState() => _SignupScreenState();
}

enum AppState {
  free,
  picked,
  cropped,
}

class _SignupScreenState extends State<Signup> {
  //*************************************
  // Properties & Variable :-
  //*************************************
  File imageFile, imageCropFile;
  AppState state;

  String strFileName = '';
  String name = '';
  String description = '';
  String email = '';
  String contactNumber = '';
  String password = '';
  String confirmPassword = '';
  String website = '';
  String token = '';
  String address = 'Address';
  String parts = 'Select parts';

  MultipartFile profileImage;

  Position _currentPosition;
  String _currentAddress;

  Utils _utils;
  SharedPref _sharedPref;

  List _myActivities;
  final homeScaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _myActivities = [];
    _utils = Utils(context: context);
    _sharedPref = SharedPref();
    _getCurrentLocation();

    setState(() {
      name = widget.name;
      email = widget.email;

      if (widget.profilePic != "") {
        imageFile = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([]);
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
      showDialog(
        context: context,
        builder: (context) => _sb,
      );
    }

    //*************************************
    // UI :-
    //*************************************
    return SafeArea(
      top: false,
      bottom: false,
      child: Scaffold(
        key: homeScaffoldKey,
        body: Container(
          padding: EdgeInsets.all(
            SV.setWidth(50),
          ),
          child: ListView(
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
              Center(
                child: GestureDetector(
                  onTap: () {
                    chooseImageDialog();
                  },
                  child: Stack(
                    children: [
                      Container(
                        width: SV.setWidth(300),
                        height: SV.setHeight(300),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppTheme.gray,
                        ),
                        child: imageFile == null
                            ? widget.profilePic == null || widget.profilePic.isEmpty || widget.profilePic == "null" || widget.profilePic == "" || widget.profilePic == "NULL"
                                ? Image.asset('assets/images/ic_default_profile.png')
                                : Image.network(widget.profilePic)
                            : Image.file(imageFile),
                      ),
                      Positioned(
                        bottom: 10,
                        right: 0,
                        child: Image.asset(
                          'assets/images/ic_add.png',
                          width: SV.setWidth(85),
                          height: SV.setHeight(85),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: SV.setHeight(80),
              ),
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
                  onChanged: (val) {
                    name = val;
                  },
                  controller: TextEditingController(text: name),
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
                margin: EdgeInsets.only(top: SV.setHeight(12)),
                decoration: BoxDecoration(
                  color: AppTheme.gray,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                padding: EdgeInsets.symmetric(horizontal: SV.setWidth(30)),
                child: TextField(
                  keyboardType: TextInputType.multiline,
                  maxLength: null,
                  maxLines: null,
                  style: TextStyle(
                    fontFamily: AppTheme.fontName,
                    fontSize: SV.setSP(50),
                  ),
                  cursorColor: AppTheme.themeBlue,
                  onChanged: (val) {
                    description = val;
                  },
                  decoration: InputDecoration(
                    hintText: 'Enter a description',
                    border: InputBorder.none,
                  ),
                ),
              ),
              SizedBox(height: SV.setHeight(40)),
              Text(
                'Email',
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
                padding: EdgeInsets.symmetric(horizontal: SV.setWidth(30)),
                child: TextField(
                  style: TextStyle(
                    fontFamily: AppTheme.fontName,
                    fontSize: SV.setSP(50),
                  ),
                  cursorColor: AppTheme.themeBlue,
                  keyboardType: TextInputType.emailAddress,
                  onChanged: (val) {
                    email = val;
                  },
                  enabled: widget.email != "" ? false : true,
                  controller: TextEditingController(text: email),
                  decoration: InputDecoration(
                    hintText: 'abc@gmail.com',
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
                margin: EdgeInsets.only(top: SV.setHeight(12)),
                decoration: BoxDecoration(
                  color: AppTheme.gray,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                padding: EdgeInsets.symmetric(horizontal: SV.setWidth(30)),
                child: TextField(
                  style: TextStyle(
                    fontFamily: AppTheme.fontName,
                    fontSize: SV.setSP(50),
                  ),
                  cursorColor: AppTheme.themeBlue,
                  keyboardType: TextInputType.phone,
                  onChanged: (val) {
                    contactNumber = val;
                  },
                  decoration: InputDecoration(
                    hintText: 'XXX XX XXXXX',
                    border: InputBorder.none,
                  ),
                ),
              ),
              SizedBox(
                height: SV.setHeight(40),
              ),
              widget.type == ""
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Password',
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
                            obscureText: true,
                            cursorColor: AppTheme.themeBlue,
                            onChanged: (val) {
                              password = val;
                            },
                            decoration: InputDecoration(
                              hintText: 'Password',
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: SV.setHeight(40),
                        ),
                        Text(
                          'Confirm Password',
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
                            obscureText: true,
                            cursorColor: AppTheme.themeBlue,
                            onChanged: (val) {
                              confirmPassword = val;
                            },
                            decoration: InputDecoration(
                              hintText: 'Confirm password',
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: SV.setHeight(40),
                        ),
                      ],
                    )
                  : Container(),
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
                  onChanged: (val) {
                    website = val;
                  },
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
              Container(
                margin: EdgeInsets.only(top: SV.setHeight(12)),
                decoration: BoxDecoration(
                  color: AppTheme.gray,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: SV.setWidth(30),
                  vertical: SV.setWidth(50),
                ),
                child: Text(
                  _currentAddress == null ? address : _currentAddress ?? "",
                  style: TextStyle(
                    fontFamily: AppTheme.fontName,
                    fontSize: SV.setSP(50),
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
                  chipLabelStyle: TextStyle(fontWeight: FontWeight.bold),
                  dialogTextStyle: TextStyle(fontWeight: FontWeight.bold),
                  checkBoxActiveColor: AppTheme.lightGray,
                  checkBoxCheckColor: Colors.white,
                  dialogShapeBorder: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12.0)),
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
                    if (isValid()) {
                      _utils.isNetwotkAvailable(true).then(
                            (value) => checkNetwork(value),
                          );
                    }
                  },
                  color: AppTheme.lightGray,
                  textColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    horizontal: SV.setWidth(300),
                    vertical: SV.setHeight(36),
                  ),
                  child: Text(
                    "SIGN UP".toUpperCase(),
                    style: TextStyle(
                      fontSize: SV.setSP(50),
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

    String isManualEmail = '';
    if (widget.type == '') {
      isManualEmail = '1';
    } else {
      isManualEmail = '0';
    }

    try {
      FormData formData = FormData.fromMap({
        'name': name,
        'bio': description,
        'is_manual_email': isManualEmail,
        'email': email,
        'contact_number': contactNumber,
        'password': _utils.generateMd5(password),
        'website': website,
        'address': _currentAddress,
        'manufacturing_parts': selectedParts,
        'device_token': token,
        'device_type': _utils.getDeviceType(),
        'profile_image': profileImage,
        'image_url': widget.profilePic,
        'is_fb': widget.isFb,
        'fb_id': widget.fbId,
        'is_google': widget.isGoogle,
        'google_id': widget.googleId,
        'is_apple': '0',
        'apple_id': '',
      });
      printWrapped('formData: --------> ${formData.fields}---paRAM');

      Response response = await ApiClient().apiClientInstance(context, '').post('Registration', data: formData);
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
        printWrapped("ResponseCode: --------> ${value.ResponseCode}");

        storeData(value).then((value) {
          printWrapped(" <-------- storeData complete --------> ");
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => MainTab(),
            ),
            (Route<dynamic> route) => false,
          );
        });
      } else if (value.ResponseCode == 2) {
        alertDialog(value.ResponseMessage);
      } else {
        _utils.alertDialog(value.ResponseMessage);
      }
    }
  }

  Future<void> storeData(DataObjectResponse objectResponse) async {
    printWrapped("id: ------------------> ${objectResponse.Result.id}");
    printWrapped("generate_token: ------> ${objectResponse.Result.generate_token}");
    printWrapped("Result: --------------> ${objectResponse.Result}");
    _sharedPref.saveString(_sharedPref.UserId, objectResponse.Result.id);
    _sharedPref.saveString(_sharedPref.Token, objectResponse.Result.generate_token);
    _sharedPref.saveObject(_sharedPref.UserResponse, objectResponse.Result);
  }

  bool isValid() {
    if (imageFile == null && widget.profilePic == null) {
      _utils.alertDialog(CommonStrings.errorImagePick);
      return false;
    } else if (_utils.isValidationEmpty(name)) {
      _utils.alertDialog(CommonStrings.errorFullName);
      return false;
    } else if (_utils.isValidationEmpty(description)) {
      _utils.alertDialog(CommonStrings.errorDescription);
      return false;
    } else if (_utils.isValidationEmpty(email)) {
      _utils.alertDialog(CommonStrings.errorEmail);
      return false;
    } else if (!_utils.emailValidator(email)) {
      _utils.alertDialog(CommonStrings.errorValidEmail);
      return false;
    } else if (_utils.isValidationEmpty(contactNumber)) {
      _utils.alertDialog(CommonStrings.errorContactNumber);
      return false;
    } else if (widget.type == '') {
      if (password.length < 6) {
        _utils.alertDialog(CommonStrings.errorPasswordLength);
        return false;
      } else if (_utils.isValidationEmpty(confirmPassword)) {
        _utils.alertDialog(CommonStrings.errorCPassword);
        return false;
      } else if (confirmPassword.length < 6) {
        _utils.alertDialog(CommonStrings.errorCPasswordLength);
        return false;
      } else if (password != confirmPassword) {
        _utils.alertDialog(CommonStrings.errorPasswordNotMatch);
        return false;
      }
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
      setState(() {
        state = AppState.picked;
      });
      _cropImage();
    }
  }

  Future<Null> _cropImage() async {
    File croppedFile = await ImageCropper.cropImage(
      sourcePath: imageFile.path,
      aspectRatioPresets: [CropAspectRatioPreset.square],
      androidUiSettings: AndroidUiSettings(
        toolbarTitle: 'Cropper',
        toolbarColor: Colors.deepOrange,
        toolbarWidgetColor: Colors.white,
        initAspectRatio: CropAspectRatioPreset.original,
        lockAspectRatio: true,
      ),
      iosUiSettings: IOSUiSettings(),
    );
    if (croppedFile != null) {
      imageFile = croppedFile;
      _utils.getFileNameWithExtension(imageFile).then((value) => multiPartFile());
      setState(() {
        state = AppState.cropped;
      });
    }
  }

  multiPartFile() async {
    profileImage = MultipartFile.fromBytes(
      File(imageFile.path).readAsBytesSync(),
      filename: imageFile.path.split("/").last,
    );
    widget.profilePic = '';
  }

  //*************************************
  // Places API Methods:-
  //*************************************

  _getCurrentLocation() async {
    printWrapped("<<<<<-------- Get Current Location -------->>>>>");
    token = await _sharedPref.readString(_sharedPref.DeviceToken);
    await Geolocator.getCurrentPosition(
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
  }

  //*************************************
  // Alert Dialog:-
  //*************************************
  void alertDialog(String title) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Rolley',
          style: TextStyle(
            fontSize: 25,
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
          FlatButton(
            child: Text('OK'),
            onPressed: () {
              Navigator.of(context, rootNavigator: true).pop();
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
