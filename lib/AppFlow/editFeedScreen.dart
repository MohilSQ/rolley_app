import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as imageLib;
import 'package:image_picker/image_picker.dart';
import 'package:photofilters/filters/preset_filters.dart';
import 'package:photofilters/widgets/photo_filter.dart';
import 'package:rolley_app/Common/ApiClient.dart';
import 'package:rolley_app/Common/CommonStrings.dart';
import 'package:rolley_app/Common/Constants.dart';
import 'package:rolley_app/Common/SharedPref.dart';
import 'package:rolley_app/Common/Utils.dart';
import 'package:rolley_app/Common/app_theme.dart';
import 'package:rolley_app/Common/screen_size_utils.dart';
import 'package:rolley_app/Model/DataModel.dart';
import 'package:rolley_app/Model/DataObjectResponse.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class EditFeedScreen extends StatefulWidget {
  final String postId;
  final String type;
  final String title;
  final String caption;
  final String tag;
  final String location;
  final String size;
  final String application;
  final String finishes;
  final String offsets;
  final String priceStart;
  final String priceEnd;
  final List<DataModel> postItem;

  const EditFeedScreen({
    Key key,
    this.postId,
    this.type,
    this.title,
    this.caption,
    this.tag,
    this.location,
    this.size,
    this.application,
    this.finishes,
    this.offsets,
    this.priceStart,
    this.priceEnd,
    this.postItem,
  }) : super(key: key);

  @override
  _EditFeedScreenState createState() => _EditFeedScreenState();
}

class _EditFeedScreenState extends State<EditFeedScreen> {
  Utils _utils;
  SharedPref _sharedPref;

  MultipartFile postImage;

  String type = "Select Part";
  TextEditingController title = TextEditingController();
  TextEditingController caption = TextEditingController();
  TextEditingController tag = TextEditingController();
  TextEditingController location = TextEditingController();
  TextEditingController size = TextEditingController();
  TextEditingController application = TextEditingController();
  TextEditingController finishes = TextEditingController();
  TextEditingController offsets = TextEditingController();
  TextEditingController priceStart = TextEditingController();
  TextEditingController priceEnd = TextEditingController();
  File imageFile;

  List<DataModel> postItem = [];
  List<File> selectImage = [];
  List<String> removeImage = [];

  List<String> typeArr = ['Select parts', 'Cars', 'Trucks', 'Motorcycle', 'SpecialBus'];

  @override
  void initState() {
    super.initState();
    type = widget.type;
    title.text = widget.title;
    caption.text = widget.caption;
    tag.text = widget.tag;
    location.text = widget.location;
    size.text = widget.size;
    application.text = widget.application;
    finishes.text = widget.finishes;
    offsets.text = widget.offsets;
    priceStart.text = widget.priceStart;
    priceEnd.text = widget.priceEnd;
    postItem = widget.postItem;
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
            DataModel dataModel = new DataModel();
            dataModel.image = imageFile.path;
            dataModel.media_type = "video";
            postItem.add(dataModel);
            // imageFileArr.add(imageFile);
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
        if (imageFile != null) {
          DataModel dataModel = new DataModel();
          dataModel.image = imageFile.path;
          dataModel.media_type = "image";
          postItem.add(dataModel);
          // imageFileArr.add(imageFile);
        }
      });
      printWrapped(imageFile.path);
    }
  }

  @override
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
          titleSpacing: 0.0,
          automaticallyImplyLeading: false,
          centerTitle: true,
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
            'Edit Post',
            style: TextStyle(
              fontFamily: AppTheme.fontName,
              fontSize: SV.setSP(60),
              color: AppTheme.black,
            ),
          ),
          actions: [
            GestureDetector(
              onTap: () {
                if (isValid()) {
                  _utils.isNetwotkAvailable(true).then(
                        (value) => checkNetwork(value),
                      );
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
        body: ListView(
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
                      if (postItem.length != 4) {
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
                itemCount: postItem.length,
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  selectImage.clear();
                  for (int i = 0; i <= postItem.length - 1; i++) {
                    postItem[i].image.contains("http") ? null : selectImage.add(File(postItem[i].image));
                    debugPrint("selectImage ---------->> $selectImage");
                  }
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
                              child: postItem[index].media_type == "image"
                                  ? postItem[index].image.contains("http")
                                      ? Image.network(
                                          postItem[index].image,
                                          height: SV.setWidth(240),
                                          width: SV.setWidth(240),
                                          fit: BoxFit.cover,
                                        )
                                      : Image.file(
                                          File(postItem[index].image),
                                          height: SV.setWidth(240),
                                          width: SV.setWidth(240),
                                          fit: BoxFit.cover,
                                        )
                                  : postItem[index].image.contains("http")
                                      ? Stack(
                                          alignment: Alignment.center,
                                          children: [
                                            Image.network(
                                              postItem[index].video_thumb,
                                              height: SV.setWidth(240),
                                              width: SV.setWidth(240),
                                              fit: BoxFit.cover,
                                            ),
                                            Icon(Icons.play_circle_fill, color: AppTheme.orange),
                                          ],
                                        )
                                      : FutureBuilder(
                                          future: _fetchNetworkCall(File(postItem[index].image)),
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
                              removeImage.add(postItem[index].id);
                              printWrapped("removeImage ----id--->>> $removeImage");
                              postItem.removeAt(index);
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
              margin: EdgeInsets.all(
                SV.setHeight(36),
              ),
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
                  items: typeArr.map<DropdownMenuItem>((String value) {
                    return DropdownMenuItem(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ),
            ),
            Divider(height: 0.5, color: AppTheme.Border),
            Container(
              margin: EdgeInsets.all(
                SV.setHeight(10),
              ),
              padding: EdgeInsets.symmetric(
                horizontal: SV.setWidth(30),
              ),
              child: TextField(
                controller: title,
                style: TextStyle(
                  fontFamily: AppTheme.fontName,
                  fontSize: SV.setSP(50),
                ),
                cursorColor: AppTheme.themeBlue,
                keyboardType: TextInputType.multiline,
                maxLength: null,
                maxLines: null,
                decoration: InputDecoration(
                  hintText: 'Post title',
                  border: InputBorder.none,
                ),
              ),
            ),
            Divider(height: 0.5, color: AppTheme.Border),
            Container(
              margin: EdgeInsets.all(
                SV.setHeight(10),
              ),
              padding: EdgeInsets.symmetric(
                horizontal: SV.setWidth(30),
              ),
              child: TextField(
                controller: caption,
                style: TextStyle(
                  fontFamily: AppTheme.fontName,
                  fontSize: SV.setSP(50),
                ),
                cursorColor: AppTheme.themeBlue,
                keyboardType: TextInputType.multiline,
                maxLength: null,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Write a caption...',
                  border: InputBorder.none,
                ),
              ),
            ),
            Divider(height: 0.5, color: AppTheme.Border),
            Container(
              margin: EdgeInsets.all(
                SV.setHeight(10),
              ),
              padding: EdgeInsets.symmetric(
                horizontal: SV.setWidth(30),
              ),
              child: TextField(
                controller: tag,
                style: TextStyle(
                  fontFamily: AppTheme.fontName,
                  fontSize: SV.setSP(50),
                ),
                cursorColor: AppTheme.themeBlue,
                keyboardType: TextInputType.multiline,
                maxLength: null,
                maxLines: null,
                decoration: InputDecoration(
                  hintText: 'Tags',
                  border: InputBorder.none,
                ),
              ),
            ),
            Divider(height: 0.5, color: AppTheme.Border),
            Container(
              margin: EdgeInsets.all(
                SV.setHeight(10),
              ),
              padding: EdgeInsets.symmetric(
                horizontal: SV.setWidth(30),
              ),
              child: TextField(
                controller: location,
                style: TextStyle(
                  fontFamily: AppTheme.fontName,
                  fontSize: SV.setSP(50),
                ),
                cursorColor: AppTheme.themeBlue,
                keyboardType: TextInputType.streetAddress,
                maxLength: null,
                maxLines: null,
                decoration: InputDecoration(
                  hintText: 'Location ',
                  border: InputBorder.none,
                ),
              ),
            ),
            Divider(height: 0.5, color: AppTheme.Border),
            Container(
              margin: EdgeInsets.all(
                SV.setHeight(10),
              ),
              padding: EdgeInsets.symmetric(
                horizontal: SV.setWidth(30),
              ),
              child: TextField(
                controller: size,
                style: TextStyle(
                  fontFamily: AppTheme.fontName,
                  fontSize: SV.setSP(50),
                ),
                cursorColor: AppTheme.themeBlue,
                keyboardType: TextInputType.emailAddress,
                maxLength: null,
                maxLines: null,
                decoration: InputDecoration(
                  hintText: 'size',
                  border: InputBorder.none,
                ),
              ),
            ),
            Divider(height: 0.5, color: AppTheme.Border),
            Container(
              margin: EdgeInsets.all(
                SV.setHeight(10),
              ),
              padding: EdgeInsets.symmetric(
                horizontal: SV.setWidth(30),
              ),
              child: TextField(
                controller: application,
                style: TextStyle(
                  fontFamily: AppTheme.fontName,
                  fontSize: SV.setSP(50),
                ),
                cursorColor: AppTheme.themeBlue,
                keyboardType: TextInputType.multiline,
                maxLength: null,
                maxLines: null,
                decoration: InputDecoration(
                  hintText: 'Application',
                  border: InputBorder.none,
                ),
              ),
            ),
            Divider(height: 0.5, color: AppTheme.Border),
            Container(
              margin: EdgeInsets.all(
                SV.setHeight(10),
              ),
              padding: EdgeInsets.symmetric(
                horizontal: SV.setWidth(30),
              ),
              child: TextField(
                controller: finishes,
                style: TextStyle(
                  fontFamily: AppTheme.fontName,
                  fontSize: SV.setSP(50),
                ),
                cursorColor: AppTheme.themeBlue,
                keyboardType: TextInputType.multiline,
                maxLength: null,
                maxLines: null,
                decoration: InputDecoration(
                  hintText: 'finishes ',
                  border: InputBorder.none,
                ),
              ),
            ),
            Divider(height: 0.5, color: AppTheme.Border),
            Container(
              margin: EdgeInsets.all(
                SV.setHeight(10),
              ),
              padding: EdgeInsets.symmetric(
                horizontal: SV.setWidth(30),
              ),
              child: TextField(
                controller: offsets,
                style: TextStyle(
                  fontFamily: AppTheme.fontName,
                  fontSize: SV.setSP(50),
                ),
                cursorColor: AppTheme.themeBlue,
                keyboardType: TextInputType.multiline,
                maxLength: null,
                maxLines: null,
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
                      controller: priceStart,
                      style: TextStyle(
                        fontFamily: AppTheme.fontName,
                        fontSize: SV.setSP(50),
                      ),
                      cursorColor: AppTheme.themeBlue,
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      maxLength: null,
                      maxLines: 1,
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
                      controller: priceEnd,
                      style: TextStyle(
                        fontFamily: AppTheme.fontName,
                        fontSize: SV.setSP(50),
                      ),
                      cursorColor: AppTheme.themeBlue,
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      maxLength: null,
                      maxLines: 1,
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
            SizedBox(height: SV.setHeight(60)),
          ],
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
      Future<DataObjectResponse> user = createPost();
      user.then((value) => responseRegister(value));
    }
  }

  Future<DataObjectResponse> createPost() async {
    try {
      FormData formData = FormData.fromMap({
        'user_id': await _sharedPref.getUserId(),
        'post_id': widget.postId,
        'post_type': type,
        'post_title': title.text,
        'description': caption.text,
        'tag': tag.text,
        'location': location.text,
        'size': size.text,
        'application': application.text,
        'finishes': finishes.text,
        'offsets': offsets.text,
        'starting_price': priceStart.text,
        'ending_price': priceEnd.text,
        'remove_img_post_id[]': removeImage.toString().replaceAll("[", "").replaceAll("]", ""),
      });

      for (var file in selectImage) {
        printWrapped("file.path ----------->>>> ${file.path}");
        formData.files.addAll([
          MapEntry("post_images[]", await MultipartFile.fromFile(file.path)),
        ]);
      }

      printWrapped('${formData.fields}---paRAM');

      Response response = await ApiClient().apiClientInstance(context, await _sharedPref.getToken()).post('EditPost', data: formData);
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
        title.text = "";
        caption.text = "";
        size.text = "";
        application.text = "";
        finishes.text = "";
        offsets.text = "";
        priceStart.text = "";
        priceEnd.text = "";
        location.text = "";
        tag.text = "";
        imageFile = null;
        type = "Select parts";
        removeImage = [];
        selectImage = [];
        postImage = null;
        _utils.alertDialogPost(title: "Your post has been update successfully", context: context, identify: "Edit");
        setState(() {});
      } else {
        _utils.alertDialog(value.ResponseMessage);
        setState(() {});
      }
    }
  }

  multiPartFile() async {
    printWrapped('${imageFile.path.split("/").last}-----------------');
    postImage = MultipartFile.fromBytes(
      File(imageFile.path).readAsBytesSync(),
      filename: imageFile.path.split("/").last,
    );
  }

  _fetchNetworkCall(File file) async {
    printWrapped("file -------->>> ${file.path}");
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
    } else if (_utils.isValidationEmpty(title.text)) {
      _utils.alertDialog(CommonStrings.errorSelectTitle);
      return false;
    } else if (_utils.isValidationEmpty(caption.text)) {
      _utils.alertDialog(CommonStrings.errorSelectCaption);
      return false;
    } else if (_utils.isValidationEmpty(tag.text)) {
      _utils.alertDialog(CommonStrings.errorSelectTag);
      return false;
    } else if (_utils.isValidationEmpty(location.text)) {
      _utils.alertDialog(CommonStrings.errorSelectLocation);
      return false;
    } else if (_utils.isValidationEmpty(size.text)) {
      _utils.alertDialog(CommonStrings.errorSelectSize);
      return false;
    } else if (_utils.isValidationEmpty(application.text)) {
      _utils.alertDialog(CommonStrings.errorSelectApplication);
      return false;
    } else if (_utils.isValidationEmpty(finishes.text)) {
      _utils.alertDialog(CommonStrings.errorSelectFinishes);
      return false;
    } else if (_utils.isValidationEmpty(offsets.text)) {
      _utils.alertDialog(CommonStrings.errorSelectOffsets);
      return false;
    } else if (_utils.isValidationEmpty(priceStart.text)) {
      _utils.alertDialog(CommonStrings.errorSelectPriceStart);
      return false;
    } else if (_utils.isValidationEmpty(priceEnd.text)) {
      _utils.alertDialog(CommonStrings.errorSelectPriceEnd);
      return false;
    }
    return true;
  }
}
