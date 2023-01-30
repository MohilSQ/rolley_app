import 'package:dio/dio.dart';
import 'package:rolley_app/Common/Constants.dart';

import 'Utils.dart';

//1st time--> flutter packages pub run build_runner build
//2nd time--> flutter packages pub run build_runner watch
class ApiClient {
  Dio dio;
  String baseUrl = 'https://rolley.app/Rolley/api/';

  Dio apiClientInstance(context, token) {
    Utils utils = Utils(context: context);

    BaseOptions options = new BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: 300000,
      receiveTimeout: 60000,
    );

    dio = new Dio(options);

    printWrapped("Token : " + token);

    dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      error: true,
      requestHeader: true,
      responseHeader: true,
    ));
    dio.interceptors.add(InterceptorsWrapper(onRequest: (RequestOptions option, RequestInterceptorHandler handler) async {
      var header = {
        'key': 'abc67fdrfg596e164cd97415c8b7z2a47zz',
        'token': token,
      };
      option.headers.addAll(header);
      return handler.next(option);
    }, onResponse: (Response response, ResponseInterceptorHandler handler) async {
      return handler.next(response);
    }, onError: (DioError e, ErrorInterceptorHandler handler) {
      utils.hideProgressDialog();
      utils.alertDialog("Something went wrong, Please try again...");
      return handler.next(e);
    }));
    return dio;
  }
}
