import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_place/google_place.dart';
import 'package:rolley_app/Common/Constants.dart';
import 'package:rolley_app/Common/app_theme.dart';
import 'package:rolley_app/Common/screen_size_utils.dart';

class GetAddressScreen extends StatefulWidget {
  const GetAddressScreen({Key key}) : super(key: key);

  @override
  State<GetAddressScreen> createState() => _GetAddressScreenState();
}

class _GetAddressScreenState extends State<GetAddressScreen> {
  GooglePlace googlePlace;
  List<AutocompletePrediction> predictions = [];
  TextEditingController address = new TextEditingController();

  String city;
  String addressFull;

  @override
  void initState() {
    String apiKey = Platform.isAndroid ? Constants.androidPlacesApi : Constants.iosPlacesApi;
    printWrapped("apiKey ------->>> $apiKey");
    googlePlace = GooglePlace(apiKey);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        brightness: Brightness.light,
        backgroundColor: AppTheme.gray,
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
          'Search your address',
          style: TextStyle(
            fontFamily: AppTheme.fontName,
            fontSize: SV.setSP(60),
            color: AppTheme.black,
          ),
        ),
      ),
      body: SafeArea(
        child: Container(
          color: Colors.white,
          padding: EdgeInsets.all(SV.setSP(20)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(top: SV.setHeight(50)),
                decoration: BoxDecoration(
                  color: AppTheme.gray,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: SV.setWidth(30),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
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
                          onChanged: (value) {
                            if (value.isNotEmpty) {
                              autoCompleteSearch(value);
                            } else if (value.isEmpty) {
                              if (predictions.length > 0 && mounted) {
                                predictions = [];
                                setState(() {});
                              }
                            }
                          },
                          decoration: InputDecoration(
                            hintText: 'Search Address',
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ),
                    Icon(
                      Icons.search,
                      color: AppTheme.lightGray,
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: SV.setHeight(20),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: predictions.length,
                  padding: EdgeInsets.zero,
                  itemBuilder: (context, index) {
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        backgroundColor: AppTheme.orange,
                        child: Icon(
                          Icons.pin_drop,
                          color: Colors.white,
                        ),
                      ),
                      title: Text(predictions[index].description),
                      onTap: () {
                        Navigator.pop(context, predictions[index].description);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void autoCompleteSearch(String value) async {
    var result = await googlePlace.autocomplete.get(value);
    debugPrint("result ------------>>> ${result.status}");
    if (result != null && result.predictions != null && mounted) {
      setState(() {
        predictions = result.predictions;
      });
    }
  }
}
