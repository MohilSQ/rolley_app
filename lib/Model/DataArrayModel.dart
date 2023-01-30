import 'package:json_annotation/json_annotation.dart';
import 'package:rolley_app/Model/DataModel.dart';

part 'DataArrayModel.g.dart';

@JsonSerializable()
class DataArrayModel {
  DataArrayModel();

  num ResponseCode;
  String ResponseMessage;
  List<DataModel> Result;

  factory DataArrayModel.fromJson(Map<String, dynamic> json) => _$DataArrayModelFromJson(json);

  Map<String, dynamic> toJson() => _$DataArrayModelToJson(this);
}
