import 'package:json_annotation/json_annotation.dart';

part 'DataModel.g.dart';

@JsonSerializable()
class DataModel {
  DataModel();

  String is_confirm = "";
  String email = "";
  String ResponseMessage = "";
  String name = "";
  String profile_image = "";
  String contact_number = "";
  String website = "";
  String address = "";
  String bio = "";
  String is_manual_email = "";
  String device_token = "";
  String device_type = "";
  String updated_at = "";
  String created_at = "";
  String id = "";
  String generate_token = "";
  String manufacturing_parts = "";
  String followers = "";
  String followings = "";
  String posts = "";

  String user_id = "";
  String post_title = "";
  String description = "";
  String size = "";
  String application = "";
  String finishes = "";
  String offsets = "";
  String starting_price = "";
  String ending_price = "";
  String location = "";
  String tag = "";
  String post_type = "";
  String is_payment = "";
  String starting_date = "";
  String is_text = "";
  String is_liked = "";
  String is_disliked = "";
  String total_review = "";
  String is_reviewed = "";
  String total_like = "";
  String total_dislike = "";
  String follower = "";
  String following = "";
  String avg_review = "";

  String image = "";
  String media_type = "";

  String rate = "";
  String rate_comment = "";
  String date_time = "";
  String date = "";

  String totle_review = "";
  String total_post = "";

  String like_count = "";
  String dislike_count = "";

  String total_comment = "";

  int sender_id = 0;
  String massage = "";
  String noti_type = "";
  String common_id = "";
  String user_name = "";
  String user_image = "";

  String brand_name = "";
  String brand_image = "";
  String Address = "";
  String comment = "";

  String is_follow = "";

  List<DataModel> review = [];
  List<DataModel> post_images = [];
  List<DataModel> post_list = [];
  List<DataModel> post = [];

  num msg_id = 0;
  num receiver_id = 0;
  num is_read = 0;
  num on_chat = 0;
  String msg = "";
  String msg_type = "";
  String roomNo = "";
  String created_date = "";
  String presence = "";
  num is_read_param = 0;
  String profile = "";
  String unread_count = "";
  String is_subscribed = "";
  String price = "";
  String video_thumb = "";
  String lat = "";
  String lng = "";

  String main_post_id = "";
  String share_user_id = "";
  String is_share = "";
  String post_subscription_date = "";
  String subscription = "";
  String subscription_date = "";
  List<DataModel> share_details = [];
  List<DataModel> post_comment = [];
  String share_starting_date = "";

  factory DataModel.fromJson(Map<String, dynamic> json) => _$DataModelFromJson(json);

  Map<String, dynamic> toJson() => _$DataModelToJson(this);
}
