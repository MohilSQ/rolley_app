import 'package:carousel_slider/carousel_slider.dart';
import 'package:flick_video_player/flick_video_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rolley_app/Common/Utils.dart';
import 'package:rolley_app/Common/app_theme.dart';
import 'package:rolley_app/Common/screen_size_utils.dart';
import 'package:rolley_app/Common/video_players/landscape_player_controls.dart';
import 'package:rolley_app/Common/zoom/ZoomableCachedNetworkImage.dart';
import 'package:rolley_app/Model/DataModel.dart';
import 'package:video_player/video_player.dart';

class FullScreenDetails extends StatefulWidget {
  final List<DataModel> images;
  final int index;
  final String is_subscribed;

  const FullScreenDetails({
    Key key,
    this.images,
    this.index,
    this.is_subscribed,
  }) : super(key: key);

  @override
  _FullScreenDetailsState createState() => _FullScreenDetailsState();
}

class _FullScreenDetailsState extends State<FullScreenDetails> {
  List<DataModel> imagesLenth = [];
  int setIndex = 0;
  Utils utils = Utils();

  @override
  void initState() {
    setIndex = widget.index;
    imagesLenth = widget.images;
    super.initState();
  }

  FlickManager flickManager;

  @override
  void dispose() {
    if (flickManager != null) {
      flickManager.dispose();
    }
    super.dispose();
  }

  Widget waterMark() {
    return Opacity(
      opacity: 0.9,
      child: Image.asset(
        "assets/images/logo_transparent.png",
        height: SV.setHeight(85),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      bottom: false,
      child: Scaffold(
        backgroundColor: AppTheme.black,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          titleSpacing: 0.0,
          brightness: Brightness.light,
          backgroundColor: Colors.transparent,
          elevation: 0.0,
          leadingWidth: SV.setWidth(130),
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
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ),
        ),
        body: Container(
          height: double.infinity,
          width: double.infinity,
          child: CarouselSlider.builder(
            itemCount: imagesLenth.length,
            options: CarouselOptions(
              autoPlay: false,
              enableInfiniteScroll: false,
              viewportFraction: 1,
              height: SV.setHeight(750),
              enlargeCenterPage: true,
              scrollDirection: Axis.horizontal,
              scrollPhysics: widget.is_subscribed == "0" ? NeverScrollableScrollPhysics() : null,
              initialPage: widget.index,
              onPageChanged: (index, reason) {
                setIndex = index;
              },
            ),
            itemBuilder: (context, index, realIndex) {
              // FlickManager flickManager;
              if (imagesLenth[index].video_thumb != "") {
                flickManager = FlickManager(
                  videoPlayerController: VideoPlayerController.network(imagesLenth[realIndex].image),
                );
              } else {
                if (flickManager != null) {
                  flickManager.dispose();
                }
              }
              return Stack(
                alignment: Alignment.topRight,
                children: [
                  imagesLenth[index].video_thumb == ""
                      ? Container(
                          width: MediaQuery.of(context).size.width,
                          child: imagesLenth[index].image != null
                              ? ZoomablePhotoViewer(
                                  url: imagesLenth[index].image,
                                )
                              : Image.asset(
                                  'assets/images/ic_manue_defalt.jpg',
                                  fit: BoxFit.cover,
                                ),
                        )
                      : FlickVideoPlayer(
                          flickManager: flickManager,
                          preferredDeviceOrientation: [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown],
                          systemUIOverlay: [
                            SystemUiOverlay.top,
                            SystemUiOverlay.bottom,
                          ],
                          flickVideoWithControls: FlickVideoWithControls(
                            controls: LandscapePlayerControls(),
                            videoFit: BoxFit.fitHeight,
                          ),
                        ),
                  waterMark(),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
