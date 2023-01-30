import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:rolley_app/Common/ApiClient.dart';
import 'package:rolley_app/Common/CommonStrings.dart';
import 'package:rolley_app/Common/Constants.dart';
import 'package:rolley_app/Common/SharedPref.dart';
import 'package:rolley_app/Common/Utils.dart';
import 'package:rolley_app/Common/app_theme.dart';
import 'package:rolley_app/Common/screen_size_utils.dart';
import 'package:rolley_app/Model/DataArrayModel.dart';
import 'package:rolley_app/Model/DataModel.dart';

import 'PaymentScreen.dart';

class SubscriptionScreen extends StatefulWidget {
  @override
  _SubscriptionScreenState createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  Utils _utils;
  SharedPref _sharedPref;
  List<DataModel> postList = [];

  @override
  void initState() {
    super.initState();
    _utils = Utils(context: context);
    _sharedPref = SharedPref();

    _utils.isNetwotkAvailable(true).then((value) => checkNetwork(value));
  }

  checkNetwork(bool value) {
    if (value) {
      _utils.showProgressDialog();
      Future<DataArrayModel> user = subscriptionList();
      user.then((value) => responseSubscriptionList(value));
    }
  }

  Future<DataArrayModel> subscriptionList() async {
    try {
      FormData formData = FormData.fromMap({
        'user_id': await _sharedPref.getUserId(),
      });
      printWrapped('${formData.fields}---paRAM');
      Response response = await ApiClient().apiClientInstance(context, await _sharedPref.getToken()).post('subscriptionList', data: formData);
      return DataArrayModel.fromJson(response.data);
    } catch (e) {
      printWrapped(e);
      return null;
    }
  }

  responseSubscriptionList(DataArrayModel value) {
    _utils.hideProgressDialog();
    if (value != null) {
      if (value.ResponseCode == 1) {
        postList = value.Result;
        setState(() {});
      } else {
        _utils.alertDialog(value.ResponseMessage);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.instance.init(context);
    return SafeArea(
      top: false,
      bottom: false,
      child: Scaffold(
        appBar: AppBar(
          brightness: Brightness.light,
          titleSpacing: 0.0,
          backgroundColor: AppTheme.gray,
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
            CommonStrings.subscriptions,
            style: TextStyle(
              fontFamily: AppTheme.fontName,
              fontSize: SV.setSP(60),
              color: AppTheme.black,
            ),
          ),
          automaticallyImplyLeading: false,
          centerTitle: true,
        ),
        body: ListView.builder(
          itemCount: postList.length,
          padding: EdgeInsets.all(SV.setWidth(20)),
          itemBuilder: (BuildContext context, int index) {
            return Padding(
              padding: EdgeInsets.all(SV.setWidth(10)),
              child: GestureDetector(
                onTap: () {
                  Navigator.push<dynamic>(
                    context,
                    MaterialPageRoute<dynamic>(
                      builder: (BuildContext context) => PaymentScreen(model: postList[index]),
                    ),
                  );
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.all(
                    Radius.circular(
                      SV.setWidth(20),
                    ),
                  ),
                  child: Container(
                    color: AppTheme.gray,
                    child: Padding(
                      padding: EdgeInsets.all(SV.setWidth(20)),
                      child: Row(
                        children: [
                          Image.asset(
                            'assets/images/ic_logo_appbar.png',
                            height: SV.setWidth(100),
                            width: SV.setWidth(100),
                            fit: BoxFit.cover,
                          ),
                          SizedBox(width: SV.setWidth(70)),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  postList[index].name,
                                  style: TextStyle(
                                    fontFamily: AppTheme.fontName,
                                    fontSize: SV.setSP(60),
                                    color: AppTheme.black,
                                  ),
                                )
                              ],
                            ),
                          ),
                          Text(
                            "${'\$ ${postList[index].price}'}",
                            style: TextStyle(
                              fontFamily: AppTheme.fontName,
                              fontSize: SV.setSP(50),
                              color: AppTheme.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
