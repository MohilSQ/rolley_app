import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rolley_app/Common/ApiClient.dart';
import 'package:rolley_app/Common/Constants.dart';
import 'package:rolley_app/Common/SharedPref.dart';
import 'package:rolley_app/Common/Utils.dart';
import 'package:rolley_app/Common/app_theme.dart';
import 'package:rolley_app/Common/screen_size_utils.dart';
import 'package:rolley_app/Model/DataArrayModel.dart';
import 'package:rolley_app/Model/DataModel.dart';

class PaymentHistory extends StatefulWidget {
  @override
  _PaymentHistoryState createState() => _PaymentHistoryState();
}

class _PaymentHistoryState extends State<PaymentHistory> {
  Utils _utils;
  SharedPref _sharedPref;

  static final DateTime now = DateTime.now();
  static final DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm:ss');
  final String formattedDate = formatter.format(now);

  List<DataModel> paymentList = [];

  @override
  void initState() {
    super.initState();
    _utils = Utils(context: context);
    _sharedPref = SharedPref();
    _utils.isNetwotkAvailable(true).then((value) => checkNetwork(value));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      bottom: false,
      child: Scaffold(
        backgroundColor: AppTheme.gray,
        appBar: AppBar(
          brightness: Brightness.light,
          backgroundColor: Colors.transparent,
          automaticallyImplyLeading: false,
          titleSpacing: 0.0,
          elevation: 0.0,
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
        ),
        body: Visibility(
          visible: paymentList.isNotEmpty,
          replacement: Center(
            child: Text(
              "No Payment found",
              style: TextStyle(
                fontFamily: AppTheme.fontName,
                fontSize: SV.setSP(56),
                color: AppTheme.black,
              ),
            ),
          ),
          child: ListView(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: SV.setHeight(400),
                    width: SV.setWidth(400),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      image: DecorationImage(
                        image: AssetImage('assets/images/ic_settings_04.png'),
                        alignment: Alignment.center,
                        scale: 3,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: SV.setHeight(10),
                  ),
                  Text(
                    "Payments",
                    style: TextStyle(
                      fontFamily: AppTheme.fontName,
                      fontSize: SV.setSP(80),
                      color: AppTheme.black,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(
                    height: SV.setHeight(20),
                  ),
                  Container(
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.all(SV.setWidth(50)),
                      itemCount: paymentList.length,
                      itemBuilder: (context, index) => Column(
                        children: [
                          Container(
                            height: SV.setHeight(200),
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: paymentList[index].is_payment == "1" ? Colors.orange.shade300 : Colors.green.shade300,
                              borderRadius: BorderRadius.all(
                                Radius.circular(10),
                              ),
                            ),
                            child: Container(
                              height: SV.setHeight(200),
                              margin: EdgeInsets.only(left: SV.setWidth(70)),
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.all(
                                  Radius.circular(10),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.symmetric(horizontal: SV.setWidth(50)),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          paymentList[index].post_title.isNotEmpty ? paymentList[index].post_title + " post" : "Subscription",
                                          style: TextStyle(
                                            fontFamily: AppTheme.fontName,
                                            fontSize: SV.setSP(65),
                                            color: AppTheme.lightGray,
                                          ),
                                        ),
                                        SizedBox(
                                          height: SV.setHeight(10),
                                        ),
                                        Text(
                                          paymentList[index].date != null ? paymentList[index].date : "",
                                          style: TextStyle(
                                            fontFamily: AppTheme.fontName,
                                            fontSize: SV.setSP(40),
                                            color: AppTheme.black,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    width: SV.setWidth(200),
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade300,
                                      borderRadius: BorderRadius.only(
                                        topRight: Radius.circular(10),
                                        bottomRight: Radius.circular(10),
                                      ),
                                    ),
                                    child: Text(
                                      "\$ ${paymentList[index].price}",
                                      style: TextStyle(
                                        fontFamily: AppTheme.fontName,
                                        fontSize: SV.setSP(80),
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.lightGray,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: SV.setHeight(50)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  checkNetwork(bool value) {
    if (value) {
      _utils.showProgressDialog();
      Future<DataArrayModel> user = deleatPost();
      user.then(
        (value) => responsePostList(value),
      );
    }
  }

  Future<DataArrayModel> deleatPost() async {
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
          .post('paymentHistory', data: formData);
      printWrapped("===========================${DataArrayModel?.fromJson(response.data)}");
      return DataArrayModel?.fromJson(response?.data);
    } catch (e) {
      printWrapped(e);
      return null;
    }
  }

  responsePostList(DataArrayModel value) {
    _utils.hideProgressDialog();
    if (value != null) {
      if (value.ResponseCode == 1) {
        setState(() {
          paymentList = value?.Result;
          printWrapped("========$paymentList");
        });
      } else {
        _utils.alertDialog(value.ResponseMessage);
      }
    }
  }
}
