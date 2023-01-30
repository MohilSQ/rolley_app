// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'DataModel.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DataModel _$DataModelFromJson(Map<String, dynamic> json) {
  return DataModel()
    ..video_thumb = json['video_thumb'] as String
    ..is_confirm = json['is_confirm'] as String
    ..email = json['email'] as String
    ..ResponseMessage = json['ResponseMessage'] as String
    ..name = json['name'] as String
    ..profile_image = json['profile_image'] as String
    ..contact_number = json['contact_number'] as String
    ..website = json['website'] as String
    ..address = json['address'] as String
    ..bio = json['bio'] as String
    ..is_manual_email = json['is_manual_email'] as String
    ..device_token = json['device_token'] as String
    ..device_type = json['device_type'] as String
    ..updated_at = json['updated_at'] as String
    ..created_at = json['created_at'] as String
    ..id = json['id'] as String
    ..generate_token = json['generate_token'] as String
    ..manufacturing_parts = json['manufacturing_parts'] as String
    ..followers = json['followers'] as String
    ..followings = json['followings'] as String
    ..posts = json['posts'] as String
    ..user_id = json['user_id'] as String
    ..post_title = json['post_title'] as String
    ..description = json['description'] as String
    ..size = json['size'] as String
    ..application = json['application'] as String
    ..finishes = json['finishes'] as String
    ..offsets = json['offsets'] as String
    ..starting_price = json['starting_price'] as String
    ..ending_price = json['ending_price'] as String
    ..location = json['location'] as String
    ..tag = json['tag'] as String
    ..post_type = json['post_type'] as String
    ..is_payment = json['is_payment'] as String
    ..starting_date = json['starting_date'] as String
    ..is_text = json['is_text'] as String
    ..is_liked = json['is_liked'] as String
    ..is_disliked = json['is_disliked'] as String
    ..total_review = json['total_review'] as String
    ..is_reviewed = json['is_reviewed'] as String
    ..total_like = json['total_like'] as String
    ..total_dislike = json['total_dislike'] as String
    ..follower = json['follower'] as String
    ..following = json['following'] as String
    ..avg_review = json['avg_review'] as String
    ..image = json['image'] as String
    ..media_type = json['media_type'] as String
    ..rate = json['rate'] as String
    ..rate_comment = json['rate_comment'] as String
    ..date_time = json['date_time'] as String
    ..date = json['date'] as String
    ..totle_review = json['totle_review'] as String
    ..total_post = json['total_post'] as String
    ..like_count = json['like_count'] as String
    ..dislike_count = json['dislike_count'] as String
    ..total_comment = json['total_comment'] as String
    ..sender_id = json['sender_id'] as int
    ..massage = json['massage'] as String
    ..noti_type = json['noti_type'] as String
    ..common_id = json['common_id'] as String
    ..user_name = json['user_name'] as String
    ..user_image = json['user_image'] as String
    ..brand_name = json['brand_name'] as String
    ..brand_image = json['brand_image'] as String
    ..Address = json['Address'] as String
    ..comment = json['comment'] as String
    ..is_follow = json['is_follow'] as String
    ..msg_id = json['msg_id'] as num
    ..receiver_id = json['receiver_id'] as num
    ..is_read = json['is_read'] as num
    ..on_chat = json['on_chat'] as num
    ..msg = json['msg'] as String
    ..msg_type = json['msg_type'] as String
    ..roomNo = json['roomNo'] as String
    ..created_date = json['created_date'] as String
    ..presence = json['presence'] as String
    ..is_read_param = json['is_read_param'] as num
    ..profile = json['profile'] as String
    ..unread_count = json['unread_count'] as String
    ..is_subscribed = json['is_subscribed'] as String
    ..price = json['price'] as String
    ..review = (json['review'] as List)?.map((e) => e == null ? null : DataModel.fromJson(e as Map<String, dynamic>))?.toList()
    ..post_images = (json['post_images'] as List)?.map((e) => e == null ? null : DataModel.fromJson(e as Map<String, dynamic>))?.toList()
    ..post_list = (json['post_list'] as List)?.map((e) => e == null ? null : DataModel.fromJson(e as Map<String, dynamic>))?.toList()
    ..post = (json['post'] as List)?.map((e) => e == null ? null : DataModel.fromJson(e as Map<String, dynamic>))?.toList()
    ..lat = json['lat'] as String
    ..lng = json['lng'] as String
    ..main_post_id = json['main_post_id'] as String
    ..share_user_id = json['share_user_id'] as String
    ..is_share = json['is_share'] as String
    ..post_subscription_date = json['post_subscription_date'] as String
    ..subscription = json['subscription'] as String
    ..subscription_date = json['subscription_date'] as String
    ..share_details = (json['share_details'] as List)?.map((e) => e == null ? null : DataModel.fromJson(e as Map<String, dynamic>))?.toList()
    ..post_comment = (json['post_comment'] as List)?.map((e) => e == null ? null : DataModel.fromJson(e as Map<String, dynamic>))?.toList()
    ..share_starting_date = json['share_starting_date'] as String;
}

Map<String, dynamic> _$DataModelToJson(DataModel instance) => <String, dynamic>{
      'video_thumb': instance.video_thumb,
      'is_confirm': instance.is_confirm,
      'email': instance.email,
      'ResponseMessage': instance.ResponseMessage,
      'name': instance.name,
      'profile_image': instance.profile_image,
      'contact_number': instance.contact_number,
      'website': instance.website,
      'address': instance.address,
      'bio': instance.bio,
      'is_manual_email': instance.is_manual_email,
      'device_token': instance.device_token,
      'device_type': instance.device_type,
      'updated_at': instance.updated_at,
      'created_at': instance.created_at,
      'id': instance.id,
      'generate_token': instance.generate_token,
      'manufacturing_parts': instance.manufacturing_parts,
      'followers': instance.followers,
      'followings': instance.followings,
      'posts': instance.posts,
      'user_id': instance.user_id,
      'post_title': instance.post_title,
      'description': instance.description,
      'size': instance.size,
      'application': instance.application,
      'finishes': instance.finishes,
      'offsets': instance.offsets,
      'starting_price': instance.starting_price,
      'ending_price': instance.ending_price,
      'location': instance.location,
      'tag': instance.tag,
      'post_type': instance.post_type,
      'is_payment': instance.is_payment,
      'starting_date': instance.starting_date,
      'is_text': instance.is_text,
      'is_liked': instance.is_liked,
      'is_disliked': instance.is_disliked,
      'total_review': instance.total_review,
      'is_reviewed': instance.is_reviewed,
      'total_like': instance.total_like,
      'total_dislike': instance.total_dislike,
      'follower': instance.follower,
      'following': instance.following,
      'avg_review': instance.avg_review,
      'image': instance.image,
      'media_type': instance.media_type,
      'rate': instance.rate,
      'rate_comment': instance.rate_comment,
      'date_time': instance.date_time,
      'date': instance.date,
      'totle_review': instance.totle_review,
      'total_post': instance.total_post,
      'like_count': instance.like_count,
      'dislike_count': instance.dislike_count,
      'total_comment': instance.total_comment,
      'sender_id': instance.sender_id,
      'massage': instance.massage,
      'noti_type': instance.noti_type,
      'common_id': instance.common_id,
      'user_name': instance.user_name,
      'user_image': instance.user_image,
      'brand_name': instance.brand_name,
      'brand_image': instance.brand_image,
      'Address': instance.Address,
      'comment': instance.comment,
      'is_follow': instance.is_follow,
      'review': instance.review,
      'post_images': instance.post_images,
      'post_list': instance.post_list,
      'post': instance.post,
      'msg_id': instance.msg_id,
      'receiver_id': instance.receiver_id,
      'is_read': instance.is_read,
      'on_chat': instance.on_chat,
      'msg': instance.msg,
      'msg_type': instance.msg_type,
      'roomNo': instance.roomNo,
      'created_date': instance.created_date,
      'presence': instance.presence,
      'is_read_param': instance.is_read_param,
      'profile': instance.profile,
      'unread_count': instance.unread_count,
      'is_subscribed': instance.is_subscribed,
      'price': instance.price,
      'lat': instance.lat,
      'lng': instance.lng,
      'main_post_id': instance.main_post_id,
      'share_user_id': instance.share_user_id,
      'is_share': instance.is_share,
      'post_subscription_date': instance.post_subscription_date,
      'subscription': instance.subscription,
      'subscription_date': instance.subscription_date,
      'share_details': instance.share_details,
      'post_comment': instance.post_comment,
      'share_starting_date': instance.share_starting_date,
    };
