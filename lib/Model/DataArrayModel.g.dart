// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'DataArrayModel.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DataArrayModel _$DataArrayModelFromJson(Map<String, dynamic> json) {
  return DataArrayModel()
    ..ResponseCode = json['ResponseCode'] as num
    ..ResponseMessage = json['ResponseMessage'] as String
    ..Result = (json['Result'] as List)
        ?.map((e) =>
            e == null ? null : DataModel.fromJson(e as Map<String, dynamic>))
        ?.toList();
}

Map<String, dynamic> _$DataArrayModelToJson(DataArrayModel instance) =>
    <String, dynamic>{
      'ResponseCode': instance.ResponseCode,
      'ResponseMessage': instance.ResponseMessage,
      'Result': instance.Result
    };
