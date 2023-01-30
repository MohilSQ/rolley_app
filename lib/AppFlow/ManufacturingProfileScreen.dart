//ManufacturingProfileScreen
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:geocoder/geocoder.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rolley_app/AppFlow/getAddressScreen.dart';
import 'package:rolley_app/Common/ApiClient.dart';
import 'package:rolley_app/Common/Constants.dart';
import 'package:rolley_app/Common/SharedPref.dart';
import 'package:rolley_app/Common/Utils.dart';
import 'package:rolley_app/Common/app_theme.dart';
import 'package:rolley_app/Common/screen_size_utils.dart';
import 'package:rolley_app/Model/DataModel.dart';
import 'package:rolley_app/Model/DataObjectResponse.dart';

class ManufacturingProfileScreen extends StatefulWidget {
  _ManufacturingProfileScreenState createState() => _ManufacturingProfileScreenState();
}

enum AppState {
  free,
  picked,
  cropped,
}

class _ManufacturingProfileScreenState extends State<ManufacturingProfileScreen> {
  File imageFile, imageCropFile;
  AppState state;
  bool isLinkFbVal = false;

  Utils _utils;
  SharedPref _sharedPref;

  String brandImg = '', follower = '', following = '', posts = '', brandName = '', contactNumber = '', website = '', address = '', brand = '';
  List<DataModel> postList = [];

  String strFileName = '';
  String profileUrl = '';
  String profileImg = '';
  String lat = '';
  String log = '';
  int onEdit = 0;
  double review = 0.0;

  var addressDetaile;

  MultipartFile profileImage;

  @override
  void initState() {
    super.initState();

    _utils = Utils(context: context);
    _sharedPref = SharedPref();

    _utils.isNetwotkAvailable(true).then((value) => checkNetwork(value));
  }

  //*************************************
  // UI :-
  //*************************************
  Widget build(BuildContext context) {
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

    return SafeArea(
      top: false,
      bottom: false,
      child: Scaffold(
        appBar: AppBar(
          brightness: Brightness.light,
          backgroundColor: AppTheme.gray,
          titleSpacing: 0,
          centerTitle: true,
          automaticallyImplyLeading: false,
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
            'Manufacturing Profile',
            style: TextStyle(
              fontFamily: AppTheme.fontName,
              fontSize: SV.setSP(60),
              color: AppTheme.black,
            ),
          ),
          actions: [
            GestureDetector(
              onTap: () {
                setState(() {
                  if (onEdit == 0) {
                    onEdit = 1;
                  } else {
                    _utils.isNetwotkAvailable(true).then((value) => checkNetworkEditProfile(value));
                  }
                });
              },
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Image.asset(
                  onEdit == 0 ? 'assets/images/ic_edit-button_black.png' : 'assets/images/ic_checked.png',
                ),
              ),
            ),
          ],
        ),
        body: ListView(
          padding: EdgeInsets.all(
            SV.setWidth(50),
          ),
          children: [
            Row(
              children: [
                Stack(
                  children: [
                    Container(
                      width: SV.setWidth(300),
                      height: SV.setWidth(300),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            offset: Offset(0.0, 2.0),
                            blurRadius: 3.0,
                          )
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: imageFile == null
                            ? brandImg == ''
                                ? Image.asset('assets/images/ic_manue_defalt.jpg')
                                : CachedNetworkImage(
                                    imageUrl: brandImg,
                                    placeholder: (context, url) => Image.asset('assets/images/ic_manue_defalt.jpg'),
                                    errorWidget: (context, url, error) => Image.asset('assets/images/ic_manue_defalt.jpg'),
                                    fit: BoxFit.cover,
                                  )
                            : Image.file(imageFile),
                      ),
                    ),
                    onEdit == 1 && imageFile == null
                        ? GestureDetector(
                            onTap: () {
                              printWrapped("Edit ------>>>> $onEdit");
                              if (onEdit == 1) {
                                chooseImageDialog();
                              }
                            },
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(24),
                              child: Container(
                                color: Colors.black26,
                                height: SV.setWidth(300),
                                width: SV.setWidth(300),
                                padding: EdgeInsets.all(40),
                                child: Image.asset(
                                  'assets/images/ic_add.png',
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          )
                        : Container(),
                  ],
                ),
                SizedBox(
                  width: SV.setWidth(40),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      onEdit == 0
                          ? Text(
                              brandName == '' ? 'Brand name' : brandName,
                              style: TextStyle(
                                fontFamily: AppTheme.fontName,
                                fontSize: SV.setSP(66),
                                color: AppTheme.black,
                              ),
                            )
                          : TextField(
                              style: TextStyle(
                                fontFamily: AppTheme.fontName,
                                fontSize: SV.setSP(50),
                              ),
                              cursorColor: AppTheme.themeBlue,
                              keyboardType: TextInputType.multiline,
                              maxLength: null,
                              maxLines: null,
                              onChanged: (val) {
                                brandName = val;
                              },
                              controller: TextEditingController(text: brandName),
                              decoration: InputDecoration(
                                hintText: brandName == '' ? 'Add brand name' : brandName,
                                border: InputBorder.none,
                              ),
                            ),
                      onEdit == 0
                          ? RatingBar(
                              itemSize: 25,
                              initialRating: review,
                              minRating: 1,
                              glow: false,
                              direction: Axis.horizontal,
                              allowHalfRating: true,
                              itemCount: 5,
                              ignoreGestures: true,
                              updateOnDrag: false,
                              itemPadding: EdgeInsets.symmetric(horizontal: 1.6),
                              onRatingUpdate: (value) {},
                              ratingWidget: RatingWidget(
                                full: Icon(
                                  Icons.star,
                                  color: Colors.amber,
                                ),
                                half: Icon(
                                  Icons.star_half,
                                  color: Colors.amber,
                                ),
                                empty: Icon(
                                  Icons.star,
                                  color: Colors.grey.shade400,
                                ),
                              ),
                            )
                          : RatingBar.builder(
                              itemSize: 25,
                              initialRating: review,
                              minRating: 1,
                              direction: Axis.horizontal,
                              allowHalfRating: true,
                              glow: false,
                              itemCount: 5,
                              itemPadding: EdgeInsets.symmetric(horizontal: 1.6),
                              itemBuilder: (context, _) => Icon(
                                Icons.star,
                                color: Colors.amber,
                              ),
                              onRatingUpdate: (value) {},
                            ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(
              height: SV.setHeight(60),
            ),
            Container(
                height: 1.0,
                decoration: BoxDecoration(
                  color: AppTheme.Border,
                )),
            SizedBox(
              height: SV.setHeight(60),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    Text(
                      'Follower',
                      style: TextStyle(
                        fontSize: SV.setSP(44),
                        color: AppTheme.lightGray,
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      follower,
                      style: TextStyle(
                        fontSize: SV.setSP(56),
                        color: AppTheme.black,
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Text(
                      "Following",
                      style: TextStyle(
                        fontSize: SV.setSP(44),
                        color: AppTheme.lightGray,
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      following,
                      style: TextStyle(
                        fontSize: SV.setSP(56),
                        color: AppTheme.black,
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Text(
                      "Posts",
                      style: TextStyle(
                        fontSize: SV.setSP(44),
                        color: AppTheme.lightGray,
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      posts,
                      style: TextStyle(
                        fontSize: SV.setSP(56),
                        color: AppTheme.black,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(
              height: SV.setHeight(60),
            ),
            Container(
              height: 1,
              decoration: BoxDecoration(
                color: AppTheme.Border,
              ),
            ),
            SizedBox(
              height: SV.setHeight(40),
            ),
            Container(
              decoration: BoxDecoration(
                color: AppTheme.gray,
                borderRadius: BorderRadius.circular(8.0),
              ),
              padding: EdgeInsets.symmetric(
                horizontal: SV.setWidth(22),
                vertical: SV.setHeight(34),
              ),
              child: Text(
                contactNumber,
                style: TextStyle(
                  fontFamily: AppTheme.fontName,
                  fontSize: SV.setSP(50),
                  color: AppTheme.black,
                ),
              ),
            ),
            SizedBox(
              height: SV.setHeight(30),
            ),
            Container(
              decoration: BoxDecoration(
                color: AppTheme.gray,
                borderRadius: BorderRadius.circular(8.0),
              ),
              padding: EdgeInsets.symmetric(
                horizontal: SV.setWidth(22),
                vertical: SV.setHeight(34),
              ),
              child: Text(
                website,
                style: TextStyle(
                  fontFamily: AppTheme.fontName,
                  fontSize: SV.setSP(50),
                  color: AppTheme.black,
                ),
              ),
            ),
            SizedBox(
              height: SV.setHeight(30),
            ),
            GestureDetector(
              onTap: () async {
                if (onEdit == 1) {
                  addressDetaile = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GetAddressScreen(),
                    ),
                  );

                  address = addressDetaile.toString();
                  var addresses = await Geocoder.local.findAddressesFromQuery(address);
                  lat = addresses.first.coordinates.latitude.toString();
                  log = addresses.first.coordinates.longitude.toString();

                  debugPrint('address: --------------->>> $address');
                  debugPrint('lat: --------------->>> $lat');
                  debugPrint('log: --------------->>> $log');
                  setState(() {});
                }
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
                  onEdit == 0 ? address ?? "Manufacturing Address" : address ?? "Select Address",
                  style: TextStyle(
                    fontFamily: AppTheme.fontName,
                    fontSize: SV.setSP(50),
                    color: AppTheme.black,
                  ),
                ),
              ),
            ),
            SizedBox(
              height: SV.setHeight(30),
            ),
            GridView.builder(
              shrinkWrap: true,
              itemCount: postList.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
              ),
              itemBuilder: (context, index) {
                return Padding(
                  padding: EdgeInsets.all(
                    SV.setHeight(10.0),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: AppTheme.lightGray,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(8),
                      image: DecorationImage(
                        image: postList[index].post_images.length > 0 ? NetworkImage(postList[index].post_images[0].image) : AssetImage('assets/images/ic_manue_defalt.jpg'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
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
      _utils.getFileNameWithExtension(imageFile).then((value) => nameOfFile(value));
      setState(() {
        state = AppState.cropped;
        printWrapped("Image: -------->>>> $state");
      });
    }
  }

  nameOfFile(String value) {
    setState(() {
      if (value.length != 0) {
        strFileName = value;
      }
      multiPartFile();
    });
  }

  multiPartFile() async {
    profileImage = MultipartFile.fromBytes(File(imageFile.path).readAsBytesSync(), filename: strFileName.split("/").last);
    printWrapped("imageFile:--------->>>> ${imageFile.path}");
    printWrapped("strFileName:--------->>>> $strFileName");
    profileImg = '';
    // await MultipartFile.fromFile(imageCropFile.path, filename: strFileName);
  }

  //*************************************
  // Load Manufacturing Profile data :-
  //*************************************
  checkNetwork(bool value) {
    if (value) {
      _utils.showProgressDialog();
      Future<DataObjectResponse> user = loadPersonalProfile();
      user.then((value) => responseLogin(value));
    }
  }

  Future<DataObjectResponse> loadPersonalProfile() async {
    try {
      FormData formData = FormData.fromMap({
        'user_id': await _sharedPref.getUserId(),
      });
      printWrapped('${formData.fields}---paRAM');
      Response response = await ApiClient()
          .apiClientInstance(
            context,
            await _sharedPref.getToken(),
          )
          .post('ManufacturingDetails', data: formData);
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
        setState(() {
          brandImg = value.Result.brand_image;
          brandName = value.Result.brand_name;
          follower = value.Result.followers;
          following = value.Result.followings;
          posts = value.Result.posts;
          contactNumber = value.Result.contact_number;
          website = value.Result.website;
          address = value.Result.address;
          postList = value.Result.post;
          log = value.Result.lng;
          lat = value.Result.lat;
          review = double.tryParse(value.Result.avg_review);
        });
      } else {
        _utils.alertDialog(value.ResponseMessage);
      }
    }
  }

  //*************************************
  // Edit Manufacturing Profile :-
  //*************************************
  checkNetworkEditProfile(bool value) {
    if (value) {
      _utils.showProgressDialog();
      Future<DataObjectResponse> user = editProfile();
      user.then((value) => responseRegister(value));
    }
  }

  Future<DataObjectResponse> editProfile() async {
    try {
      FormData formData = FormData.fromMap({
        'user_id': await _sharedPref.getUserId(),
        'brand_name': brandName ?? "",
        'address': address ?? "",
        'lat': lat ?? "",
        'lng': log ?? "",
      });

      if (imageFile != null) {
        formData.files.addAll([
          MapEntry("brand_image", await MultipartFile.fromFile(imageFile.path)),
        ]);
      }
      printWrapped('Field: ----------------->>>>>>> ${formData.fields}');
      printWrapped('Field: ----------------->>>>>>> ${formData.files}');

      Response response = await ApiClient()
          .apiClientInstance(
            context,
            await _sharedPref.getToken(),
          )
          .post(
            'UpdateBrand',
            data: formData,
          );
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
        onEdit = 0;
        _utils.isNetwotkAvailable(true).then((value) => checkNetwork(value));
      }
    }
  }
}
