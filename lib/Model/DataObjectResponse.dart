import 'package:json_annotation/json_annotation.dart';
import 'package:rolley_app/Model/DataModel.dart';

part 'DataObjectResponse.g.dart';

// Doing json object parsing from API response
@JsonSerializable()
class DataObjectResponse {
  DataObjectResponse();
  num ResponseCode;
  String ResponseMessage;
  DataModel Result;
  String like_count;
  String dislike_count;
  //List<DataModel> resData;

  factory DataObjectResponse.fromJson(Map<String, dynamic> json) => _$DataObjectResponseFromJson(json);
  Map<String, dynamic> toJson() => _$DataObjectResponseToJson(this);
}
