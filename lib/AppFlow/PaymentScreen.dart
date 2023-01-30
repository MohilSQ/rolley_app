import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_multi_formatter/formatters/credit_card_cvc_input_formatter.dart';
import 'package:flutter_multi_formatter/formatters/credit_card_expiration_input_formatter.dart';
import 'package:flutter_multi_formatter/formatters/credit_card_number_input_formatter.dart';
import 'package:intl/intl.dart';
import 'package:rolley_app/Common/ApiClient.dart';
import 'package:rolley_app/Common/CommonStrings.dart';
import 'package:rolley_app/Common/Constants.dart';
import 'package:rolley_app/Common/SharedPref.dart';
import 'package:rolley_app/Common/Utils.dart';
import 'package:rolley_app/Common/app_theme.dart';
import 'package:rolley_app/Common/screen_size_utils.dart';
import 'package:rolley_app/Model/DataModel.dart';
import 'package:rolley_app/Model/DataObjectResponse.dart';

import 'MainTabScreen.dart';

class PaymentScreen extends StatefulWidget {
  DataModel model;

  PaymentScreen({this.model});

  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  Utils _utils;
  SharedPref _sharedPref;
  TextEditingController _cardName = new TextEditingController();
  TextEditingController _cardNumber = new TextEditingController();
  TextEditingController _cardAddress = new TextEditingController();
  TextEditingController _cardExpiry = new TextEditingController();
  TextEditingController _cardCVV = new TextEditingController();

  // Date and time
  static final DateTime now = DateTime.now();
  static final DateFormat formatter = DateFormat('yyyy-MM-dd HH:mm:ss');
  final String formattedDate = formatter.format(now);

  @override
  initState() {
    super.initState();
    _utils = Utils(context: context);
    _sharedPref = SharedPref();
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
            CommonStrings.payment,
            style: TextStyle(
              fontFamily: AppTheme.fontName,
              fontSize: SV.setSP(60),
              color: AppTheme.black,
            ),
          ),
          automaticallyImplyLeading: false,
          centerTitle: true,
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView(
                padding: EdgeInsets.only(top: SV.setWidth(50)),
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: SV.setWidth(50)),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
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
                                      if (isValidation()) {
                                        _utils.isNetwotkAvailable(true).then((value) => checkNetwork(value));
                                      }

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
                      ],
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

  bool isValidation() {
    if (_utils.isValidationEmpty(_cardName.text.trim())) {
      _utils.alertDialog(CommonStrings.error_card_name);
      return false;
    } else if (_utils.isValidationEmpty(_cardNumber.text.trim())) {
      _utils.alertDialog(CommonStrings.error_card_number);
      return false;
    } else if (_utils.isValidationEmpty(_cardAddress.text.trim())) {
      _utils.alertDialog(CommonStrings.error_billing_address);
      return false;
    } else if (_utils.isValidationEmpty(_cardExpiry.text.trim())) {
      _utils.alertDialog(CommonStrings.error_expiry);
      return false;
    } else if (_cardExpiry.text.length <= 4) {
      _utils.alertDialog(CommonStrings.error_expiry);
      return false;
    } else if (_utils.isValidationEmpty(_cardCVV.text.trim())) {
      _utils.alertDialog(CommonStrings.error_cvv);
      return false;
    } else if (_cardCVV.text.length <= 2) {
      _utils.alertDialog(CommonStrings.error_valid_cvv);
      return false;
    }
    return true;
  }

//************************************************//
// ******* purchaseSubscription ******* //
//************************************************//

  checkNetwork(bool value) {
    if (value) {
      _utils.showProgressDialog();
      Future<DataObjectResponse> user = purchaseSubscription();
      user.then((value) => responsePostList(value));
    }
  }

  Future<DataObjectResponse> purchaseSubscription() async {
    try {
      String year = _cardExpiry.text.split("/")[1].substring(_cardExpiry.text.split("/")[1].length - 2);
      FormData formData = FormData.fromMap({
        'user_id': await _sharedPref.getUserId(),
        'card_number': _cardNumber.text.trim(),
        'billing_address': _cardAddress.text.trim(),
        'cvc': _cardCVV.text.trim(),
        'exp_month': _cardExpiry.text.split("/")[0],
        'exp_year': year,
        'card_holder_name': _cardName.text.trim(),
        'package': widget.model.id,
        'amount': widget.model.price,
        'is_save': "1",
        'date_time': formattedDate,
      });
      printWrapped('${formData.fields}---paRAM');
      Response response = await ApiClient()
          .apiClientInstance(
            context,
            await _sharedPref.getToken(),
          )
          .post('subscription', data: formData);
      return DataObjectResponse.fromJson(response.data);
    } catch (e) {
      printWrapped(e);
      return null;
    }
  }

  responsePostList(DataObjectResponse value) {
    _utils.hideProgressDialog();
    if (value != null) {
      if (value.ResponseCode == 1) {
        showDialog(
          barrierDismissible: false,
          useSafeArea: false,
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
              "Your payment has been successfully processed!",
              style: TextStyle(
                fontSize: 15,
                fontFamily: 'Bahnschrift',
                fontWeight: FontWeight.w400,
              ),
            ),
            actions: [
              FlatButton(
                child: Text(
                  'OK',
                ),
                onPressed: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (context) => MainTab(),
                    ),
                    (Route<dynamic> route) => false,
                  );
                },
              ),
            ],
          ),
        );
      } else {
        _utils.alertDialog(value.ResponseMessage);
      }
    }
  }
}
