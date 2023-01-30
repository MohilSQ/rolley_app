import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:rolley_app/AppFlow/ForgotPasswordScreen.dart';
import 'package:rolley_app/AppFlow/MainTabScreen.dart';
import 'package:rolley_app/AppFlow/SignupScreen.dart';
import 'package:rolley_app/Common/ApiClient.dart';
import 'package:rolley_app/Common/CommonStrings.dart';
import 'package:rolley_app/Common/Constants.dart';
import 'package:rolley_app/Common/SharedPref.dart';
import 'package:rolley_app/Common/Utils.dart';
import 'package:rolley_app/Common/app_theme.dart';
import 'package:rolley_app/Common/screen_size_utils.dart';
import 'package:rolley_app/Model/DataObjectResponse.dart';

class LoginScreen extends StatefulWidget {
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with WidgetsBindingObserver {
  final GoogleSignIn googleSignIn = GoogleSignIn();

  String fullName = '';
  String password = '';
  String token = '';
  bool rememberVal = false;

  Utils _utils;
  SharedPref _sharedPref;
  String email = "", is_google = "0", google_id = "", is_facebook = "0", facebook_id = "", name = "", profilePic = "";

  @override
  initState() {
    super.initState();
    _utils = Utils(context: context);
    _sharedPref = SharedPref();
    successGoogle();
    getRemember();
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.instance.init(context);

    return SafeArea(
      top: false,
      bottom: false,
      child: Scaffold(
        body: Container(
          margin: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top,
          ),
          padding: EdgeInsets.symmetric(
            horizontal: SV.setWidth(50),
          ),
          child: ListView(
            children: [
              SizedBox(
                height: SV.setHeight(100),
              ),
              Center(
                child: Image.asset(
                  'assets/images/ic_appicon_blue.png',
                  height: SV.setWidth(450),
                  width: SV.setWidth(450),
                ),
              ),
              SizedBox(
                height: 16.0,
              ),
              Text(
                'Email',
                style: TextStyle(fontFamily: AppTheme.fontName, fontSize: 16, color: AppTheme.lightGray),
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
                    fontSize: 17,
                  ),
                  cursorColor: AppTheme.themeBlue,
                  keyboardType: TextInputType.emailAddress,
                  onChanged: (val) {
                    fullName = val;
                  },
                  controller: TextEditingController(text: fullName),
                  decoration: InputDecoration(
                    hintText: 'Enter email',
                    border: InputBorder.none,
                  ),
                ),
              ),
              SizedBox(
                height: 16.0,
              ),
              Text(
                'Password',
                style: TextStyle(
                  fontFamily: AppTheme.fontName,
                  fontSize: 16,
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
                    fontSize: 17,
                  ),
                  obscureText: true,
                  cursorColor: AppTheme.themeBlue,
                  onChanged: (val) {
                    password = val;
                  },
                  controller: TextEditingController(text: password),
                  decoration: InputDecoration(
                    hintText: 'Password',
                    border: InputBorder.none,
                  ),
                ),
              ),
              Row(
                children: [
                  Checkbox(
                      checkColor: AppTheme.black,
                      activeColor: AppTheme.lightGray,
                      value: rememberVal,
                      onChanged: (bool newValue) {
                        setState(() {
                          rememberVal = newValue;
                        });
                      }),
                  Expanded(
                      child: Text(
                    'Remember me',
                    style: TextStyle(
                      fontFamily: AppTheme.fontName,
                      fontSize: 16,
                      color: AppTheme.black,
                    ),
                  )),
                  GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute<dynamic>(
                            builder: (BuildContext context) => ForgotPassword(),
                          ),
                        );
                      },
                      child: Text(
                        'Forgot Password?',
                        style: TextStyle(
                          fontFamily: AppTheme.fontName,
                          fontSize: 16,
                          color: AppTheme.lightGray,
                        ),
                      )),
                ],
              ),
              SizedBox(
                height: 20.0,
              ),
              Center(
                child: FlatButton(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6.0),
                    side: BorderSide(color: AppTheme.lightGray, width: 2),
                  ),
                  onPressed: () {
                    printWrapped("fullName: --------> $fullName");
                    printWrapped("password: --------> $password");
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
                    "LOG IN".toUpperCase(),
                    style: TextStyle(fontSize: 17),
                  ),
                ),
              ),
              SizedBox(
                height: 20.0,
              ),
              Center(
                child: Text(
                  "Don't have an account?",
                  style: TextStyle(
                    fontFamily: AppTheme.fontName,
                    fontSize: 14,
                    color: AppTheme.lightGray,
                  ),
                ),
              ),
              SizedBox(
                height: 20.0,
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
                    Navigator.push(
                      context,
                      MaterialPageRoute<dynamic>(
                        builder: (BuildContext context) => Signup(
                          type: "",
                          name: "",
                          email: "",
                          profilePic: "",
                          googleId: google_id,
                          isGoogle: is_google,
                          fbId: facebook_id,
                          isFb: is_facebook,
                        ),
                      ),
                    );
                  },
                  color: Colors.white,
                  textColor: AppTheme.lightGray,
                  padding: EdgeInsets.symmetric(
                    horizontal: SV.setWidth(280),
                    vertical: SV.setHeight(32),
                  ),
                  child: Text(
                    "SIGN UP".toUpperCase(),
                    style: TextStyle(
                      fontSize: 17,
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 14.0,
              ),
              Center(
                child: Text(
                  "OR",
                  style: TextStyle(
                    fontFamily: AppTheme.fontName,
                    fontSize: 14,
                    color: AppTheme.lightGray,
                  ),
                ),
              ),
              SizedBox(
                height: 14.0,
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: SV.setSP(100)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: FlatButton(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6.0),
                          side: BorderSide(color: AppTheme.fbBlue, width: 2),
                        ),
                        onPressed: () {
                          _login();
                        },
                        color: AppTheme.fbBlue,
                        textColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          vertical: SV.setHeight(36),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              'assets/images/ic_facebook.png',
                              height: SV.setWidth(40),
                              width: SV.setWidth(40),
                            ),
                            SizedBox(
                              width: 6.0,
                            ),
                            Text(
                              "Facebook",
                              style: TextStyle(fontSize: 12, color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 12.0,
                    ),
                    Expanded(
                      child: FlatButton(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6.0),
                          side: BorderSide(
                            color: AppTheme.orange,
                            width: 2,
                          ),
                        ),
                        onPressed: () {
                          if (_googleSignIn != null) _googleSignIn.disconnect();
                          signInWithGoogle();
                        },
                        color: AppTheme.orange,
                        textColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          vertical: SV.setHeight(36),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              'assets/images/ic_google.png',
                              height: SV.setWidth(46),
                              width: SV.setWidth(46),
                            ),
                            SizedBox(
                              width: 6.0,
                            ),
                            Text(
                              "Google",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white,
                              ),
                            ),
                          ],
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
    );
  }

  //*************************************
  // Check Validation & Network :-
  //*************************************
  checkNetwork(bool value) {
    if (value) {
      _utils.showProgressDialog();
      Future<DataObjectResponse> user = login();
      user.then((value) => responseLogin(value));
    }
  }

  Future<DataObjectResponse> login() async {
    try {
      FormData formData = FormData.fromMap({
        'email': fullName,
        'password': _utils.generateMd5(password),
        'device_token': token,
        'device_type': _utils.getDeviceType(),
      });
      printWrapped('formData: --------> ${formData.fields}---paRAM');
      Response response = await ApiClient().apiClientInstance(context, '').post('Login', data: formData);
      return DataObjectResponse.fromJson(response.data);
    } catch (e) {
      printWrapped(e);
      return null;
    }
  }

  responseLogin(DataObjectResponse value) {
    _utils.hideProgressDialog();
    if (value != null) {
      if (value.ResponseCode == 1) {
        //alertDialog(value.ResponseMessage);
        storeData(value).then(
          (value) => Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => MainTab(),
            ),
            (Route<dynamic> route) => false,
          ),
        );
      } else {
        _utils.alertDialog(value.ResponseMessage);
      }
    }
  }

  bool isValid() {
    if (_utils.isValidationEmpty(fullName)) {
      _utils.alertDialog(CommonStrings.errorEmail);
      return false;
    } else if (!_utils.emailValidator(fullName)) {
      _utils.alertDialog(CommonStrings.errorValidEmail);
      return false;
    } else if (_utils.isValidationEmpty(password)) {
      _utils.alertDialog(CommonStrings.errorPassword);
      return false;
    } else if (password.length < 5) {
      _utils.alertDialog(CommonStrings.errorPasswordLength);
      return false;
    }
    return true;
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
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  //*************************************
  // Facebook Login :-
  // Setup :- kmphasistest@gmail.com
  //*************************************
  Future<Null> _login() async {
    final LoginResult result = await FacebookAuth.instance.login(permissions: ['email']);

    if (result.status == LoginStatus.success) {
      final AccessToken accessToken = result.accessToken;
      final userData = await FacebookAuth.instance.getUserData(
        fields: "name,email,picture.width(200),birthday,friends,gender,link",
      );

      printWrapped('''
         Logged in!

        Token: ${accessToken.token}
        facebook_id: ${accessToken.userId}
        email = ${userData['email']};
        name = ${userData['name']};
        profilePic = ${userData['picture']['data']['url']};
         ''');

      is_facebook = "1";
      facebook_id = accessToken.userId;
      is_google = "0";
      google_id = "";
      email = userData['email'];
      name = userData['name'];
      profilePic = userData['picture']['data']['url'];

      _utils.isNetwotkAvailable(true).then((value) => socialLogin(value, 'facebook'));
    } else if (result.status == LoginStatus.cancelled) {
      alertDialog('Login cancelled by the user.');
    } else if (result.status == LoginStatus.failed) {
      alertDialog('Something went wrong with the login process.\n'
          'Here\'s the error Facebook gave us: ${result.message}');
      debugPrint('Something went wrong with the login process.\n'
          'Here\'s the error Facebook gave us: ${result.message}');
    }
  }

  //*************************************
  // google Login :-
  // Setup :- mayank.kmphasis@gmail.com
  //*************************************
  GoogleSignInAccount _currentUser;
  GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);

  signInWithGoogle() {
    printWrapped("<<<<< _currentUser --------- >>>>> ($_currentUser)");
    _googleSignIn.signIn();
    return "";
  }

  void successGoogle() async {
    _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount account) async {
      _currentUser = account;
      if (account != null) {
        printWrapped("displayName: --------> ${account.displayName ?? ""}");
        printWrapped("email: --------------> ${account.email ?? ""}");
        printWrapped("id: -----------------> ${account.id ?? ""}");
        printWrapped("photoUrl: -----------> ${account.photoUrl ?? ""}");
        is_facebook = "0";
        facebook_id = "";
        is_google = "1";
        google_id = account.id ?? "";
        email = account.email ?? "";
        name = account.displayName ?? "";
        profilePic = account.photoUrl ?? "";
        await account.clearAuthCache();
        await _googleSignIn.disconnect();
        await _googleSignIn.signOut();
        _currentUser = null;
        _utils.isNetwotkAvailable(true).then((value) => socialLogin(value, 'google'));
      }
    });
  }

  Future<void> signOutGoogle() async {
    await googleSignIn.signOut();
    printWrapped("User Signed Out");
  }

//*************************************
// Social Login :-
//*************************************

  void socialLogin(isNetwork, type) {
    if (isNetwork) {
      _utils.showProgressDialog();
      Future<DataObjectResponse> userData = isRegister();
      userData.then(
        (value) => manageResponse(value, type),
      );
    }
  }

  Future<DataObjectResponse> isRegister() async {
    try {
      Map<String, dynamic> body = new Map();
      body['email'] = email;
      body['is_google'] = is_google;
      body['google_id'] = google_id;
      body['is_fb'] = is_facebook;
      body['fb_id'] = facebook_id;
      body['device_token'] = token;
      body['device_type'] = _utils.getDeviceType();
      Response response = await ApiClient().apiClientInstance(context, '').post('is_Registration', data: new FormData.fromMap(body));
      return DataObjectResponse.fromJson(response.data);
    } catch (e) {
      printWrapped(e);
      return null;
    }
  }

  void manageResponse(DataObjectResponse objectResponse, type) {
    if (objectResponse.ResponseCode != null) {
      _utils.hideProgressDialog();
      if (objectResponse.ResponseCode == 1) {
        storeData(objectResponse).then(
          (value) => Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => MainTab(),
            ),
            (Route<dynamic> route) => false,
          ),
        );
      } else if (objectResponse.ResponseCode == 2) {
        _utils.alertDialog(objectResponse.ResponseMessage);
      } else if (objectResponse.ResponseCode == 3) {
        Navigator.push(
          context,
          MaterialPageRoute<dynamic>(
            builder: (BuildContext context) => Signup(
              type: type,
              name: name,
              email: email,
              profilePic: profilePic,
              googleId: google_id,
              isGoogle: is_google,
              fbId: facebook_id,
              isFb: is_facebook,
            ),
          ),
        );
      } else if (objectResponse.ResponseCode == 4) {
      } else {
        _utils.alertDialog(objectResponse.ResponseMessage);
      }
    }
  }

  Future<void> storeData(DataObjectResponse objectResponse) async {
    printWrapped(' <-------- storeData --------> ');
    printWrapped("id: ------------------> ${objectResponse.Result.id}");
    printWrapped("generate_token: ------> ${objectResponse.Result.generate_token}");
    printWrapped("email: ---------------> $email");
    printWrapped("password: ------------> $password");
    printWrapped("rememberVal: ---------> $rememberVal");
    printWrapped("Result: --------------> ${objectResponse.Result}");
    _sharedPref.saveString(_sharedPref.UserId, objectResponse.Result.id);
    _sharedPref.saveString(_sharedPref.Token, objectResponse.Result.generate_token);
    _sharedPref.saveObject(_sharedPref.UserResponse, objectResponse.Result);

    if (rememberVal) {
      _sharedPref.saveString(_sharedPref.Email, fullName);
      _sharedPref.saveString(_sharedPref.Password, password);
      _sharedPref.saveString(_sharedPref.Remember, rememberVal.toString());
    }
  }

  Future<void> getRemember() async {
    token = await _sharedPref.readString(_sharedPref.DeviceToken);
    fullName = await _sharedPref.readString(_sharedPref.Email);
    password = await _sharedPref.readString(_sharedPref.Password);
    String remember = await _sharedPref.readString(_sharedPref.Remember);
    if (remember != null && remember == 'true') {
      rememberVal = true;
    }

    setState(() {});
    printWrapped(' <-------- getRemember --------> ');
    printWrapped("fullName: --------> $fullName");
    printWrapped("password: --------> $password");
    printWrapped("remember: --------> $remember");
  }
}
