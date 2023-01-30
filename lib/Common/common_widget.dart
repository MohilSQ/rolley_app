import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:rolley_app/Common/screen_size_utils.dart';
import 'package:rolley_app/Model/video_list_data.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

class CommonVideoPlayer extends StatefulWidget {
  final VideoListData images;
  final bool isVideo;

  const CommonVideoPlayer({Key key, this.images, this.isVideo}) : super(key: key);

  @override
  _CommonVideoPlayerState createState() => _CommonVideoPlayerState();
}

class _CommonVideoPlayerState extends State<CommonVideoPlayer> {
  VideoPlayerController _videoPlayerController;
  // FlickManager flickManager;
  // BetterPlayerController betterPlayerController;
  @override
  void initState() {
    // TODO: implement initState
    videoController();
    super.initState();
  }

  videoController() async {
    if (widget.isVideo) {
      _videoPlayerController = VideoPlayerController.network(widget.images.videoUrl);
      _videoPlayerController.initialize().then((_) {
        _videoPlayerController.play();
        _videoPlayerController.setLooping(true);
        if (mounted) setState(() {});
      });

      // flickManager = FlickManager(
      //   videoPlayerController: VideoPlayerController.network(widget.images.videoUrl),
      //   autoPlay: true,
      //   autoInitialize: true,
      //   onVideoEnd: (value) {
      //     flickManager.flickControlManager.replay();
      //   },
      // );

      // BetterPlayerConfiguration betterPlayerConfiguration = BetterPlayerConfiguration(
      //   fit: BoxFit.cover,
      //   autoPlay: true,
      //   looping: true,
      //   autoDispose: true,
      //   placeholder: Container(
      //     height: double.infinity,
      //     color: Colors.transparent,
      //     alignment: Alignment.center,
      //     child: Image.asset(
      //       "assets/images/ic_manue_defalt.jpg",
      //       height: SV.setHeight(700),
      //       width: double.infinity,
      //       fit: BoxFit.cover,
      //     ),
      //   ),
      // );
      // BetterPlayerDataSource dataSource = BetterPlayerDataSource(BetterPlayerDataSourceType.network, widget.images.videoUrl);
      // betterPlayerController = BetterPlayerController(betterPlayerConfiguration);
      // betterPlayerController.setupDataSource(dataSource);
      // betterPlayerController.setControlsEnabled(false);
    } else {
      if (_videoPlayerController != null) {
        _videoPlayerController.pause();
        _videoPlayerController.dispose();
      }

      // if (flickManager != null) {
      //   flickManager.flickControlManager.pause();
      //   flickManager.dispose();
      // }

      // if (betterPlayerController != null) {
      //   betterPlayerController.pause();
      // betterPlayerController.dispose(forceDispose: true);
      // }
    }
    setState(() {});
  }

  @override
  void dispose() {
    if (_videoPlayerController != null) {
      _videoPlayerController.dispose();
    }

    // if (flickManager != null) {
    //   flickManager.dispose();
    // }

    // if (betterPlayerController != null) {
    //   betterPlayerController.pause();
    //   betterPlayerController.dispose(forceDispose: true);
    // }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: SV.setWidth(700),
      width: MediaQuery.of(context).size.width,
      child: widget.isVideo
          ? VisibilityDetector(
              key: Key("unique key"),
              onVisibilityChanged: (VisibilityInfo info) {
                debugPrint(" <<<------------ ${info.visibleFraction} of my widget is visible ------------------------->>>");
                if (info.visibleFraction == 0.0) {
                  if (mounted) {
                    if (_videoPlayerController != null) {
                      _videoPlayerController.pause();
                    }
                    // flickManager.flickControlManager.pause();
                    // betterPlayerController.pause();
                    setState(() {});
                  }
                } else {
                  if (mounted) {
                    if (_videoPlayerController = null) {
                      _videoPlayerController = VideoPlayerController.network(widget.images.videoUrl);
                      _videoPlayerController.initialize().then((_) {
                        _videoPlayerController.play();
                        _videoPlayerController.setLooping(true);
                        if (mounted) setState(() {});
                      });
                    }

                    // if (flickManager == null) {
                    //   flickManager = FlickManager(
                    //     videoPlayerController: VideoPlayerController.network(widget.images.videoUrl),
                    //     autoPlay: true,
                    //     autoInitialize: true,
                    //     onVideoEnd: (value) {
                    //       flickManager.flickControlManager.replay();
                    //     },
                    //   );
                    // } else {
                    //   flickManager.flickControlManager.play();
                    // }

                    // if (betterPlayerController == null) {
                    //   BetterPlayerConfiguration betterPlayerConfiguration = BetterPlayerConfiguration(
                    //     fit: BoxFit.cover,
                    //     autoPlay: true,
                    //     looping: true,
                    //     autoDispose: true,
                    //     placeholder: Container(
                    //       height: double.infinity,
                    //       color: Colors.transparent,
                    //       alignment: Alignment.center,
                    //       child: Image.asset(
                    //         "assets/images/ic_manue_defalt.jpg",
                    //         height: SV.setHeight(700),
                    //         width: double.infinity,
                    //         fit: BoxFit.cover,
                    //       ),
                    //     ),
                    //   );
                    //   BetterPlayerDataSource dataSource = BetterPlayerDataSource(BetterPlayerDataSourceType.network, widget.images.videoUrl);
                    //   betterPlayerController = BetterPlayerController(betterPlayerConfiguration);
                    //   betterPlayerController.setupDataSource(dataSource);
                    //   betterPlayerController.setControlsEnabled(false);
                    // } else {
                    //   betterPlayerController.play();
                    // }
                    setState(() {});
                  }
                }
              },
              child: VideoPlayer(_videoPlayerController),
              // child: betterPlayerController.isBuffering()
              //     ? Container(
              //         height: double.infinity,
              //         color: Colors.transparent,
              //         alignment: Alignment.center,
              //         child: Image.asset(
              //           "assets/images/ic_manue_defalt.jpg",
              //           height: SV.setHeight(700),
              //           width: double.infinity,
              //           fit: BoxFit.cover,
              //         ),
              //       )

              //     : VideoPlayer(_videoPlayerController),

              // : FlickVideoPlayer(
              //     flickManager: flickManager,
              //     preferredDeviceOrientation: [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown],
              //     systemUIOverlay: [SystemUiOverlay.top, SystemUiOverlay.bottom],
              //     flickVideoWithControls: FlickVideoWithControls(
              //       videoFit: BoxFit.cover,
              //     ),
              //   ),
              // : BetterPlayer(controller: betterPlayerController),
            )
          : PhotoView(
              imageProvider: NetworkImage(widget.images.videoUrl),
              initialScale: PhotoViewComputedScale.covered,
              minScale: PhotoViewComputedScale.covered,
            ),
    );
  }
}
