import 'dart:ui';

import 'package:flick_video_player/flick_video_player.dart';
import 'package:flutter/material.dart';
import 'package:rolley_app/Common/app_theme.dart';
import 'package:rolley_app/Common/video_players/play_toggle.dart';

class LandscapePlayerControls extends StatelessWidget {
  const LandscapePlayerControls({Key key, this.iconSize = 20, this.fontSize = 12}) : super(key: key);
  final double iconSize;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        FlickShowControlsAction(
          child: FlickSeekVideoAction(
            child: Center(
              child: FlickVideoBuffer(
                child: FlickAutoHideChild(
                  showIfVideoNotInitialized: false,
                  child: LandscapePlayToggle(),
                ),
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: FlickAutoHideChild(
            child: Column(
              children: <Widget>[
                Expanded(
                  child: Container(),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  color: Color.fromRGBO(0, 0, 0, 0.4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      FlickPlayToggle(size: 20),
                      SizedBox(width: 10),
                      FlickCurrentPosition(fontSize: fontSize),
                      SizedBox(width: 10),
                      Expanded(
                        child: Container(
                          child: FlickVideoProgressBar(
                            flickProgressBarSettings: FlickProgressBarSettings(
                              height: 6,
                              handleRadius: 8,
                              padding: EdgeInsets.symmetric(
                                horizontal: 8.0,
                                vertical: 8,
                              ),
                              backgroundColor: Colors.white24,
                              bufferedColor: Colors.white38,
                              getPlayedPaint: ({double handleRadius, double height, double playedPart, double width}) {
                                return Paint()
                                  ..shader = LinearGradient(colors: [AppTheme.orange, AppTheme.orange], stops: [0.0, 0.5]).createShader(
                                    Rect.fromPoints(
                                      Offset(0, 0),
                                      Offset(width, 0),
                                    ),
                                  );
                              },
                              getHandlePaint: ({double handleRadius, double height, double playedPart, double width}) {
                                return Paint()
                                  ..shader = RadialGradient(
                                    colors: [
                                      AppTheme.orange,
                                      AppTheme.orange,
                                      Colors.white,
                                    ],
                                    stops: [0.0, 0.4, 0.5],
                                    radius: 0.4,
                                  ).createShader(
                                    Rect.fromCircle(
                                      center: Offset(playedPart, height / 2),
                                      radius: handleRadius,
                                    ),
                                  );
                              },
                            ),
                          ),
                        ),
                      ),
                      FlickTotalDuration(fontSize: fontSize),
                      SizedBox(width: 10),
                      FlickSoundToggle(size: 20),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
