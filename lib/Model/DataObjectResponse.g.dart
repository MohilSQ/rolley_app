// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'DataObjectResponse.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DataObjectResponse _$DataObjectResponseFromJson(Map<String, dynamic> json) {
  return DataObjectResponse()
    ..ResponseCode = json['ResponseCode'] as num
    ..ResponseMessage = json['ResponseMessage'] as String
    ..Result = json['Result'] == null
        ? null
        : DataModel.fromJson(json['Result'] as Map<String, dynamic>)
    ..like_count = json['like_count'] as String
    ..dislike_count = json['dislike_count'] as String;
}

Map<String, dynamic> _$DataObjectResponseToJson(DataObjectResponse instance) =>
    <String, dynamic>{
      'ResponseCode': instance.ResponseCode,
      'ResponseMessage': instance.ResponseMessage,
      'Result': instance.Result,
      'like_count': instance.like_count,
      'dislike_count': instance.dislike_count
    };
