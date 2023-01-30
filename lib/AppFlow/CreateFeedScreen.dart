//CreateFeedScreen
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_multi_formatter/formatters/credit_card_cvc_input_formatter.dart';
import 'package:flutter_multi_formatter/formatters/credit_card_expiration_input_formatter.dart';
import 'package:flutter_multi_formatter/formatters/credit_card_number_input_formatter.dart';
import 'package:image/image.dart' as imageLib;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:photofilters/photofilters.dart';
import 'package:rolley_app/Common/ApiClient.dart';
import 'package:rolley_app/Common/CommonStrings.dart';
import 'package:rolley_app/Common/Constants.dart';
import 'package:rolley_app/Common/SharedPref.dart';
import 'package:rolley_app/Common/Utils.dart';
import 'package:rolley_app/Common/app_theme.dart';
import 'package:rolley_app/Common/screen_size_utils.dart';
import 'package:rolley_app/Model/DataObjectResponse.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class CreateFeedScreen extends StatefulWidget {
  _CreateFeedScreenState createState() => _CreateFeedScreenState();
}

class _CreateFeedScreenState extends State<CreateFeedScreen> {
  Utils _utils;
  SharedPref _sharedPref;

  // Date and time
  static final DateTime now = DateTime.now();
  static final DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm:ss');
  final String formattedDate = formatter.format(now);

  MultipartFile postImage;

  String type = 'Select parts';
  String title = '';
  String caption = '';
  String tag = '';
  String location = '';
  String size = '';
  String application = '';
  String finishes = '';
  String offsets = '';
  String priceStart = '';
  String priceEnd = '';
  File imageFile;

  List<File> imageFileArr = [];

  bool isSwitched = false;
  String ispayment = "0";
  String amount = "25";

  TextEditingController _cardName = new TextEditingController();
  TextEditingController _cardNumber = new TextEditingController();
  TextEditingController _cardAddress = new TextEditingController();
  TextEditingController _cardExpiry = new TextEditingController();
  TextEditingController _cardCVV = new TextEditingController();

  List<String> typeArr = ['Select parts', 'Cars', 'Trucks', 'Motorcycle', 'Miscellaneous'];

  @override
  void initState() {
    super.initState();
    _utils = Utils(context: context);
    _sharedPref = SharedPref();
    setState(() {});
  }

  Future pickImage(context, String identify) async {
    ImagePicker _picker = new ImagePicker();
    XFile imagePickerFile;
    if (identify == "Gallery") {
      imagePickerFile = await _picker.pickImage(source: ImageSource.gallery);
    } else if (identify == "Camera") {
      imagePickerFile = await _picker.pickImage(source: ImageSource.camera);
    } else if (identify == "Video") {
      imagePickerFile = await _picker.pickVideo(source: ImageSource.camera);
    } else if (identify == "VideoGallery") {
      imagePickerFile = await _picker.pickVideo(source: ImageSource.gallery);
    }

    if (imagePickerFile != null) {
      imageFile = new File(imagePickerFile.path);
      if (identify == "Gallery" || identify == "Camera") {
        _utils.getFileNameWithExtension(imageFile).then((value) => filerImage(value));
      } else {
        setState(
          () {
            imageFileArr.add(imageFile);
            imageFile = imageFile;
            printWrapped("--path--${imageFile.path}");
            setState(() {});
            // multiPartFile();
          },
        );
      }
    }
  }

  filerImage(value) async {
    var image = imageLib.decodeImage(imageFile.readAsBytesSync());
    image = imageLib.copyResize(image, width: 600);
    Map imagefile = await Navigator.push(
      context,
      new MaterialPageRoute(
        builder: (context) => SafeArea(
          bottom: false,
          top: false,
          child: Scaffold(
            body: PhotoFilterSelector(
              appBarColor: Colors.black54,
              title: Text(
                "Photo Filter",
                style: TextStyle(color: Colors.white),
              ),
              image: image,
              filters: presetFiltersList,
              filename: value,
              circleShape: false,
              fit: BoxFit.contain,
              loader: Center(
                child: CircularProgressIndicator(
                  color: AppTheme.orange,
                ),
              ),
            ),
          ),
        ),
      ),
    );
    if (imagefile != null && imagefile.containsKey('image_filtered')) {
      setState(() {
        imageFile = imagefile['image_filtered'];
        imageFileArr.add(imageFile);
        imageFile = imageFile;
        // multiPartFile();
      });
      printWrapped(imageFile.path);
    }
  }

  Widget build(BuildContext context) {
    ScreenUtil.instance.init(context);
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
                fontSize: SV.setSP(45),
                color: AppTheme.black,
              ),
            ),
            onPressed: () {
              Navigator.of(context, rootNavigator: true).pop();
              pickImage(context, 'Camera');
            },
          ),
          SimpleDialogOption(
            child: Text(
              'Image choose from Gallery',
              style: new TextStyle(
                fontFamily: AppTheme.fontName,
                fontSize: SV.setSP(45),
                color: AppTheme.black,
              ),
            ),
            onPressed: () {
              Navigator.of(context, rootNavigator: true).pop();
              pickImage(context, 'Gallery');
            },
          ),
          SimpleDialogOption(
            child: Text(
              'Take Video',
              style: new TextStyle(
                fontFamily: AppTheme.fontName,
                fontSize: SV.setSP(45),
                color: AppTheme.black,
              ),
            ),
            onPressed: () {
              Navigator.of(context, rootNavigator: true).pop();
              pickImage(context, 'Video');
            },
          ),
          SimpleDialogOption(
            child: Text(
              'Video choose from Gallery',
              style: new TextStyle(
                fontFamily: AppTheme.fontName,
                fontSize: SV.setSP(45),
                color: AppTheme.black,
              ),
            ),
            onPressed: () {
              Navigator.of(context, rootNavigator: true).pop();
              pickImage(context, 'VideoGallery');
            },
          ),
          SimpleDialogOption(
            child: Text(
              'Cancel',
              style: new TextStyle(
                fontFamily: AppTheme.fontName,
                fontSize: SV.setSP(45),
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
          title: Text(
            'New Post',
            style: TextStyle(
              fontFamily: AppTheme.fontName,
              fontSize: SV.setSP(60),
              color: AppTheme.black,
            ),
          ),
          leading: Padding(
            padding: EdgeInsets.all(14.0),
            child: Image.asset(
              'assets/images/ic_logo_appbar.png',
            ),
          ),
          actions: [
            GestureDetector(
              onTap: () {
                if (isValid()) {
                  _utils.isNetwotkAvailable(true).then((value) => checkNetwork(value));
                }
              },
              child: Padding(
                padding: EdgeInsets.all(10.0),
                child: Image.asset(
                  'assets/images/ic_create_feed.png',
                ),
              ),
            ),
          ],
        ), //
        body: Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                      left: SV.setWidth(40),
                      top: SV.setWidth(40),
                      bottom: SV.setWidth(10),
                    ),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            if (imageFileArr.length != 4) {
                              chooseImageDialog();
                            } else {
                              _utils.alertDialog("You already select 4 item for your post.");
                            }
                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.asset(
                              'assets/images/ic_add.png',
                              height: SV.setWidth(100),
                              width: SV.setWidth(100),
                            ),
                          ),
                        ),
                        SizedBox(width: SV.setWidth(20)),
                        Text(
                          'Add Images Or Video',
                          style: TextStyle(
                            fontFamily: AppTheme.fontName,
                            fontSize: SV.setSP(50),
                            color: AppTheme.lightGray,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: SV.setWidth(310),
                    child: ListView.builder(
                      padding: EdgeInsets.only(
                        left: SV.setWidth(30),
                        right: SV.setWidth(20),
                        bottom: SV.setWidth(30),
                      ),
                      itemCount: imageFileArr.length,
                      shrinkWrap: true,
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, index) {
                        return Row(
                          children: [
                            Stack(
                              alignment: Alignment.topRight,
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(
                                    right: SV.setWidth(20),
                                    top: SV.setWidth(30),
                                    left: SV.setWidth(10),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: _utils.isImage(imageFileArr[index].path)
                                        ? Image.file(
                                            imageFileArr[index],
                                            height: SV.setWidth(240),
                                            width: SV.setWidth(240),
                                            fit: BoxFit.cover,
                                          )
                                        : FutureBuilder(
                                            future: _fetchNetworkCall(imageFileArr[index]),
                                            builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                                              switch (snapshot.connectionState) {
                                                case ConnectionState.waiting:
                                                  return Center(
                                                    child: CircularProgressIndicator(),
                                                  );
                                                default:
                                                  if (snapshot.hasError)
                                                    return Text('Error: ${snapshot.error}');
                                                  else
                                                    return Stack(
                                                      alignment: Alignment.center,
                                                      children: [
                                                        Image.memory(
                                                          snapshot.data,
                                                          fit: BoxFit.cover,
                                                          height: SV.setWidth(240),
                                                          width: SV.setWidth(240),
                                                        ),
                                                        Icon(Icons.play_circle_fill, color: AppTheme.orange),
                                                      ],
                                                    );
                                              }
                                            },
                                          ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    printWrapped("imageFileArr ------->>> $imageFileArr");
                                    imageFileArr.removeAt(index);
                                    printWrapped("imageFileArr ------->>> $imageFileArr");
                                    setState(() {});
                                  },
                                  child: Container(
                                    height: SV.setWidth(65),
                                    width: SV.setWidth(65),
                                    decoration: BoxDecoration(
                                      color: AppTheme.orange,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.clear_rounded,
                                      color: Colors.white,
                                      size: SV.setWidth(40),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  Divider(
                    height: 0.5,
                    color: AppTheme.Border,
                  ),
                  Container(
                    margin: EdgeInsets.all(SV.setHeight(36)),
                    child: ButtonTheme(
                      alignedDropdown: false,
                      child: DropdownButton(
                        underline: Container(),
                        isExpanded: true,
                        value: type,
                        icon: Icon(
                          Icons.arrow_drop_down,
                          color: AppTheme.lightGray,
                        ),
                        iconSize: 24,
                        elevation: 10,
                        isDense: true,
                        selectedItemBuilder: (context) {
                          return typeArr.map((String value) {
                            return Text(value);
                          }).toList();
                        },
                        onChanged: (data) {
                          setState(() {
                            type = data;
                          });
                        },
                        items: typeArr.map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  Divider(
                    height: 0.5,
                    color: AppTheme.Border,
                  ),
                  Container(
                    margin: EdgeInsets.all(
                      SV.setHeight(10),
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
                      keyboardType: TextInputType.multiline,
                      maxLength: null,
                      maxLines: null,
                      onChanged: (val) {
                        title = val;
                      },
                      decoration: InputDecoration(
                        hintText: 'Post title',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  Divider(
                    height: 0.5,
                    color: AppTheme.Border,
                  ),
                  Container(
                    margin: EdgeInsets.all(
                      SV.setHeight(10),
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
                      keyboardType: TextInputType.multiline,
                      maxLength: null,
                      maxLines: 3,
                      onChanged: (val) {
                        caption = val;
                      },
                      decoration: InputDecoration(
                        hintText: 'Write a caption...',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  Divider(
                    height: 0.5,
                    color: AppTheme.Border,
                  ),
                  Container(
                    margin: EdgeInsets.all(
                      SV.setHeight(10),
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
                      keyboardType: TextInputType.multiline,
                      maxLength: null,
                      maxLines: null,
                      onChanged: (val) {
                        tag = val;
                      },
                      decoration: InputDecoration(
                        hintText: 'Tags',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  Divider(
                    height: 0.5,
                    color: AppTheme.Border,
                  ),
                  Container(
                    margin: EdgeInsets.all(
                      SV.setHeight(10),
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
                      keyboardType: TextInputType.streetAddress,
                      maxLength: null,
                      maxLines: null,
                      onChanged: (val) {
                        setState(() {
                          location = val;
                        });
                      },
                      decoration: InputDecoration(
                        hintText: 'Location ',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  Divider(
                    height: 0.5,
                    color: AppTheme.Border,
                  ),
                  Container(
                    margin: EdgeInsets.all(
                      SV.setHeight(10),
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
                      keyboardType: TextInputType.emailAddress,
                      maxLength: null,
                      maxLines: null,
                      onChanged: (val) {
                        size = val;
                      },
                      decoration: InputDecoration(
                        hintText: 'size',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  Divider(
                    height: 0.5,
                    color: AppTheme.Border,
                  ),
                  Container(
                    margin: EdgeInsets.all(
                      SV.setHeight(10),
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
                      keyboardType: TextInputType.multiline,
                      maxLength: null,
                      maxLines: null,
                      onChanged: (val) {
                        application = val;
                      },
                      decoration: InputDecoration(
                        hintText: 'Application',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  Divider(
                    height: 0.5,
                    color: AppTheme.Border,
                  ),
                  Container(
                    margin: EdgeInsets.all(
                      SV.setHeight(10),
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
                      keyboardType: TextInputType.multiline,
                      maxLength: null,
                      maxLines: null,
                      onChanged: (val) {
                        finishes = val;
                      },
                      decoration: InputDecoration(
                        hintText: 'finishes ',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  Divider(
                    height: 0.5,
                    color: AppTheme.Border,
                  ),
                  Container(
                    margin: EdgeInsets.all(
                      SV.setHeight(10),
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
                      keyboardType: TextInputType.multiline,
                      maxLength: null,
                      maxLines: null,
                      onChanged: (val) {
                        offsets = val;
                      },
                      decoration: InputDecoration(
                        hintText: 'offsets ',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  Divider(height: 0.5, color: AppTheme.Border),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          margin: EdgeInsets.all(
                            SV.setHeight(10),
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
                            keyboardType: TextInputType.numberWithOptions(decimal: true),
                            maxLength: null,
                            maxLines: 1,
                            onChanged: (val) {
                              priceStart = val;
                            },
                            decoration: InputDecoration(
                              hintText: 'Start price range(\$)',
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          margin: EdgeInsets.all(
                            SV.setHeight(10),
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
                            keyboardType: TextInputType.numberWithOptions(decimal: true),
                            maxLength: null,
                            maxLines: 1,
                            onChanged: (val) {
                              priceEnd = val;
                            },
                            decoration: InputDecoration(
                              hintText: 'End price range(\$)',
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Divider(height: 0.5, color: AppTheme.Border),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: SV.setWidth(50),
                      vertical: SV.setHeight(25),
                    ),
                    child: Row(
                      children: [
                        Text(
                          "For ads monetization, you have \nto pay \$25 a week! ",
                          overflow: TextOverflow.clip,
                          style: TextStyle(
                            fontFamily: AppTheme.fontName,
                            fontSize: SV.setSP(50),
                            color: AppTheme.black,
                          ),
                        ),
                        Spacer(),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: SV.setWidth(10)),
                          child: Switch(
                            onChanged: toggleSwitch,
                            value: isSwitched,
                            activeColor: AppTheme.orange,
                            activeTrackColor: Colors.grey.shade400,
                            inactiveThumbColor: Colors.white,
                            inactiveTrackColor: Colors.grey.shade400,
                          ),
                        )
                      ],
                    ),
                  ),
                  SizedBox(height: 62),
                ],
              ),
            ),
            SizedBox(height: SV.setHeight(130)),
          ],
        ),
      ),
    );
  }

  void toggleSwitch(bool value) {
    if (isSwitched == false) {
      setState(() {
        isSwitched = true;
        ispayment = "1";
        isValid()
            ? showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) {
                  return WillPopScope(
                    onWillPop: () {
                      return showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text(
                            'Rolley',
                            style: TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          content: Text(
                            "Are You Sure To Exit?",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          actions: [
                            FlatButton(
                              child: Text('Yes'),
                              onPressed: () {
                                Navigator.of(context).pop(true);
                                isSwitched = false;
                              },
                            ),
                            FlatButton(
                              child: Text('No'),
                              onPressed: () {
                                Navigator.of(context).pop(false);
                              },
                            ),
                          ],
                        ),
                      );
                    },
                    child: Scaffold(
                      body: Container(
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: SV.setWidth(60),
                                  vertical: SV.setHeight(30),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    SizedBox(width: SV.setWidth(30)),
                                    Text(
                                      "For ads monetization, you have \nto pay \$25 a week! ",
                                      overflow: TextOverflow.clip,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontFamily: AppTheme.fontName,
                                        fontSize: SV.setSP(50),
                                        color: AppTheme.black,
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          isSwitched = false;
                                          ispayment = "0";
                                        });
                                        Navigator.pop(context);
                                      },
                                      child: Icon(
                                        Icons.cancel_rounded,
                                        color: AppTheme.orange,
                                        size: SV.setSP(90),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.all(15),
                                child: Container(
                                  width: MediaQuery.of(context).size.width,
                                  padding: EdgeInsets.all(SV.setHeight(50)),
                                  decoration: BoxDecoration(
                                    color: AppTheme.gray,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Form(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(height: SV.setHeight(45)),
                                        Text(
                                          CommonStrings.card_holder_name,
                                          style: TextStyle(
                                            fontSize: SV.setSP(42),
                                            color: AppTheme.lightGray,
                                            fontWeight: FontWeight.w500,
                                            fontFamily: AppTheme.fontName,
                                          ),
                                        ),
                                        Container(
                                          margin: EdgeInsets.only(top: SV.setHeight(20)),
                                          padding: EdgeInsets.symmetric(horizontal: SV.setHeight(45)),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(10),
                                            border: Border.all(
                                              color: AppTheme.lightGray,
                                              width: 1,
                                            ),
                                          ),
                                          child: TextField(
                                            controller: _cardName,
                                            style: TextStyle(
                                              letterSpacing: 1,
                                              fontSize: SV.setSP(40),
                                              color: AppTheme.black,
                                              fontWeight: FontWeight.w400,
                                              fontFamily: AppTheme.fontName,
                                            ),
                                            cursorColor: AppTheme.black,
                                            onChanged: (val) {},
                                            decoration: InputDecoration(
                                              border: InputBorder.none,
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: SV.setHeight(55)),
                                        Text(
                                          CommonStrings.card_number,
                                          style: TextStyle(
                                            fontSize: SV.setSP(42),
                                            color: AppTheme.lightGray,
                                            fontWeight: FontWeight.w500,
                                            fontFamily: AppTheme.fontName,
                                          ),
                                        ),
                                        Container(
                                          margin: EdgeInsets.only(top: SV.setHeight(20)),
                                          padding: EdgeInsets.symmetric(horizontal: SV.setHeight(45)),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(10),
                                            border: Border.all(
                                              color: AppTheme.lightGray,
                                              width: 1,
                                            ),
                                          ),
                                          child: TextField(
                                            controller: _cardNumber,
                                            style: TextStyle(
                                              letterSpacing: 1,
                                              fontSize: SV.setSP(40),
                                              color: AppTheme.black,
                                              fontWeight: FontWeight.w400,
                                              fontFamily: AppTheme.fontName,
                                            ),
                                            cursorColor: AppTheme.black,
                                            keyboardType: TextInputType.number,
                                            inputFormatters: [CreditCardNumberInputFormatter()],
                                            onChanged: (val) {},
                                            decoration: InputDecoration(
                                              border: InputBorder.none,
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: SV.setHeight(55)),
                                        Text(
                                          CommonStrings.billing_address,
                                          style: TextStyle(
                                            fontSize: SV.setSP(42),
                                            color: AppTheme.lightGray,
                                            fontWeight: FontWeight.w500,
                                            fontFamily: AppTheme.fontName,
                                          ),
                                        ),
                                        Container(
                                          margin: EdgeInsets.only(top: SV.setHeight(20)),
                                          padding: EdgeInsets.symmetric(horizontal: SV.setHeight(45)),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(10),
                                            border: Border.all(
                                              color: AppTheme.lightGray,
                                              width: 1,
                                            ),
                                          ),
                                          child: TextField(
                                            controller: _cardAddress,
                                            style: TextStyle(
                                              letterSpacing: 1,
                                              fontSize: SV.setSP(40),
                                              color: AppTheme.black,
                                              fontWeight: FontWeight.w400,
                                              fontFamily: AppTheme.fontName,
                                            ),
                                            cursorColor: AppTheme.black,
                                            onChanged: (val) {},
                                            maxLines: 3,
                                            decoration: InputDecoration(
                                              border: InputBorder.none,
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: SV.setHeight(55)),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    CommonStrings.exp_date,
                                                    style: TextStyle(
                                                      fontSize: SV.setSP(42),
                                                      color: AppTheme.lightGray,
                                                      fontWeight: FontWeight.w500,
                                                      fontFamily: AppTheme.fontName,
                                                    ),
                                                  ),
                                                  Container(
                                                    margin: EdgeInsets.only(top: SV.setHeight(20)),
                                                    padding: EdgeInsets.symmetric(horizontal: SV.setHeight(45)),
                                                    decoration: BoxDecoration(
                                                      borderRadius: BorderRadius.circular(10),
                                                      border: Border.all(
                                                        color: AppTheme.lightGray,
                                                        width: 1,
                                                      ),
                                                    ),
                                                    child: TextField(
                                                      controller: _cardExpiry,
                                                      style: TextStyle(
                                                        letterSpacing: 1,
                                                        fontSize: SV.setSP(40),
                                                        color: AppTheme.black,
                                                        fontWeight: FontWeight.w400,
                                                        fontFamily: AppTheme.fontName,
                                                      ),
                                                      cursorColor: AppTheme.black,
                                                      keyboardType: TextInputType.number,
                                                      inputFormatters: [
                                                        CreditCardExpirationDateFormatter(),
                                                      ],
                                                      onChanged: (val) {},
                                                      decoration: InputDecoration(
                                                        border: InputBorder.none,
                                                        hintText: "MM/YY",
                                                        hintStyle: TextStyle(
                                                          fontSize: SV.setSP(40),
                                                          color: AppTheme.black,
                                                          fontWeight: FontWeight.w400,
                                                          fontFamily: AppTheme.fontName,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            SizedBox(width: SV.setHeight(45)),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    CommonStrings.cvv,
                                                    style: TextStyle(
                                                      fontSize: SV.setSP(42),
                                                      color: AppTheme.lightGray,
                                                      fontWeight: FontWeight.w500,
                                                      fontFamily: AppTheme.fontName,
                                                    ),
                                                  ),
                                                  Container(
                                                    margin: EdgeInsets.only(top: SV.setHeight(20)),
                                                    padding: EdgeInsets.symmetric(horizontal: SV.setHeight(45)),
                                                    decoration: BoxDecoration(
                                                      borderRadius: BorderRadius.circular(10),
                                                      border: Border.all(
                                                        color: AppTheme.lightGray,
                                                        width: 1,
                                                      ),
                                                    ),
                                                    child: TextField(
                                                      controller: _cardCVV,
                                                      style: TextStyle(
                                                        letterSpacing: 1,
                                                        fontSize: SV.setSP(40),
                                                        color: AppTheme.black,
                                                        fontWeight: FontWeight.w400,
                                                        fontFamily: AppTheme.fontName,
                                                      ),
                                                      cursorColor: AppTheme.black,
                                                      keyboardType: TextInputType.number,
                                                      inputFormatters: [
                                                        CreditCardCvcInputFormatter(),
                                                      ],
                                                      onChanged: (val) {},
                                                      obscureText: true,
                                                      decoration: InputDecoration(border: InputBorder.none),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: SV.setHeight(100)),
                                        Center(
                                          child: GestureDetector(
                                            onTap: () {
                                              if (isValidation(context)) {
                                                _utils.isNetwotkAvailable(true).then((value) => checkNetwork(value));
                                                isSwitched = true;
                                              }
                                              Navigator.pop(context);
                                              FocusScope.of(context).unfocus();
                                            },
                                            child: ClipRRect(
                                              borderRadius: BorderRadius.all(Radius.circular(10)),
                                              child: Container(
                                                height: SV.setHeight(100),
                                                width: SV.setWidth(500),
                                                color: AppTheme.orange,
                                                child: Center(
                                                  child: Text(
                                                    CommonStrings.pay.toUpperCase(),
                                                    style: TextStyle(
                                                      fontSize: SV.setSP(45),
                                                      color: Colors.white,
                                                      fontWeight: FontWeight.w600,
                                                      fontFamily: AppTheme.fontName,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: SV.setHeight(50)),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              )
            : setState(() {
                isSwitched = false;
                ispayment = "0";
              });
      });
      printWrapped('Switch Button is ON');
    } else {
      setState(() {
        isSwitched = false;
        ispayment = "0";
      });
      printWrapped('Switch Button is OFF');
    }
  }

  //*************************************
  // Check Validation & Network :-
  //*************************************
  checkNetwork(bool value) {
    if (value) {
      _utils.showProgressDialog();
      Future<DataObjectResponse> user = createPost();
      user.then((value) => responseRegister(value));
    }
  }

  Future<DataObjectResponse> createPost() async {
    try {
      String year = isSwitched ? _cardExpiry.text.split("/")[1].substring(_cardExpiry.text.split("/")[1].length - 2) : "";
      printWrapped("isSwitched ------>> $isSwitched");
      printWrapped("year ------>> $year");
      FormData formData = FormData.fromMap({
        'user_id': await _sharedPref.getUserId(),
        'post_title': title,
        'description': caption,
        'size': size,
        'application': application,
        'finishes': finishes,
        'offsets': offsets,
        'starting_price': priceStart,
        'ending_price': priceEnd,
        'location': location,
        'tag': tag,
        'post_type': type,
        'starting_date': formattedDate,
        'is_payment': ispayment,
        'card_number': _cardNumber.text.trim(),
        'exp_month': _cardExpiry.text.split("/")[0],
        'exp_year': year,
        "card_holder_name": _cardName.text.trim(),
        'cvc': _cardCVV.text.trim(),
        'amount': amount,
        'billing_address': _cardAddress.text.trim(),
      });

      for (var file in imageFileArr) {
        formData.files.addAll([
          MapEntry("images[]", await MultipartFile.fromFile(file.path)),
        ]);
      }

      printWrapped("--imageFileArr-->${imageFileArr.length}-");
      printWrapped('${formData.fields}---paRAM');

      Response response = await ApiClient().apiClientInstance(context, await _sharedPref.getToken()).post('createPost', data: formData);
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
        setState(() {
          title = "";
          caption = "";
          size = "";
          application = "";
          finishes = "";
          offsets = "";
          priceStart = "";
          priceEnd = "";
          location = "";
          tag = "";
          imageFile = null;
          imageFileArr = [];
          type = "Select parts";
          ispayment = "0";
          _cardNumber.text = "";
          _cardName.text = "";
          _cardExpiry.text = "";
          _cardCVV.text = "";
          _cardAddress.text = "";
        });
        _utils.alertDialogPostCreate("Your post has been posted successfully");
      } else {
        _utils.alertDialog(value.ResponseMessage);
        setState(() {
          isSwitched = false;
          ispayment = "0";
        });
      }
    }
  }

  multiPartFile() async {
    printWrapped('${imageFile.path.split("/").last}-----------------');
    postImage = MultipartFile.fromBytes(
      File(imageFile.path).readAsBytesSync(),
      filename: imageFile.path.split("/").last,
    );
    // await MultipartFile.fromFile(imageCropFile.path, filename: strFileName);
  }

  _fetchNetworkCall(File file) async {
    return await VideoThumbnail.thumbnailData(
      video: file.path,
      imageFormat: ImageFormat.PNG,
      maxWidth: 512,
      maxHeight: 512,
      quality: 25,
    );
  }

  bool isValid() {
    if (type == 'Select parts') {
      _utils.alertDialog(CommonStrings.errorSelectType);
      return false;
    } else if (_utils.isValidationEmpty(title)) {
      _utils.alertDialog(CommonStrings.errorSelectTitle);
      return false;
    }
    /*else if (_utils.isValidationEmpty(caption)) {
      _utils.alertDialog(CommonStrings.errorSelectCaption);
      return false;
    } else if (_utils.isValidationEmpty(tag)) {
      _utils.alertDialog(CommonStrings.errorSelectTag);
      return false;
    } else if (_utils.isValidationEmpty(location)) {
      _utils.alertDialog(CommonStrings.errorSelectLocation);
      return false;
    } else if (_utils.isValidationEmpty(size)) {
      _utils.alertDialog(CommonStrings.errorSelectSize);
      return false;
    } else if (_utils.isValidationEmpty(application)) {
      _utils.alertDialog(CommonStrings.errorSelectApplication);
      return false;
    } else if (_utils.isValidationEmpty(finishes)) {
      _utils.alertDialog(CommonStrings.errorSelectFinishes);
      return false;
    } else if (_utils.isValidationEmpty(offsets)) {
      _utils.alertDialog(CommonStrings.errorSelectOffsets);
      return false;
    } else if (_utils.isValidationEmpty(priceStart)) {
      _utils.alertDialog(CommonStrings.errorSelectPriceStart);
      return false;
    } else if (_utils.isValidationEmpty(priceEnd)) {
      _utils.alertDialog(CommonStrings.errorSelectPriceEnd);
      return false;
    }*/
    return true;
  }

  bool isValidation(BuildContext context) {
    Utils _utils = Utils(context: context);
    if (_utils.isValidationEmpty(_cardName.text.trim())) {
      printWrapped("<<<< -------- ValidationEmpty -------- >>>>");
      _utils.alertDialogPost(title: CommonStrings.error_card_name, context: context);
      return false;
    } else if (_utils.isValidationEmpty(_cardNumber.text.trim())) {
      _utils.alertDialogPost(title: CommonStrings.error_card_number, context: context);
      return false;
    } else if (_utils.isValidationEmpty(_cardAddress.text.trim())) {
      _utils.alertDialogPost(title: CommonStrings.error_billing_address, context: context);
      return false;
    } else if (_utils.isValidationEmpty(_cardExpiry.text.trim())) {
      _utils.alertDialogPost(title: CommonStrings.error_expiry, context: context);
      return false;
    } else if (_cardExpiry.text.length <= 4) {
      _utils.alertDialogPost(title: CommonStrings.error_expiry, context: context);
      return false;
    } else if (_utils.isValidationEmpty(_cardCVV.text.trim())) {
      _utils.alertDialogPost(title: CommonStrings.error_cvv, context: context);
      return false;
    } else if (_cardCVV.text.length <= 2) {
      _utils.alertDialogPost(title: CommonStrings.error_valid_cvv, context: context);
      return false;
    }
    return true;
  }
}
