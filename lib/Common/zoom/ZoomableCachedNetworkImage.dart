import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:rolley_app/Common/Constants.dart';

import 'AllowMultipleHorizontalDragRecognizer.dart';
import 'AllowMultipleScaleRecognizer.dart';
import 'AllowMultipleVerticalDragRecognizer.dart';

class ZoomablePhotoViewer extends StatefulWidget {
  const ZoomablePhotoViewer({Key key, this.url}) : super(key: key);

  final String url;

  @override
  _ZoomablePhotoViewerState createState() => new _ZoomablePhotoViewerState();
}

class _ZoomablePhotoViewerState extends State<ZoomablePhotoViewer> with SingleTickerProviderStateMixin {
  AnimationController _controller;
  Animation<Offset> _flingAnimation;
  Offset _offset = Offset.zero;
  double _scale = 1.0;
  Offset _normalizedOffset;
  double _previousScale;
  HitTestBehavior behavior;

  @override
  void initState() {
    super.initState();
    _controller = new AnimationController(vsync: this)..addListener(_handleFlingAnimation);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // The maximum offset value is 0,0. If the size of this renderer's box is w,h
  // then the minimum offset value is w - _scale * w, h - _scale * h.
  Offset _clampOffset(Offset offset) {
    final Size size = context.size;
    final Offset minOffset = new Offset(size.width, size.height) * (1.0 - _scale);
    return new Offset(offset.dx.clamp(minOffset.dx, 0.0), offset.dy.clamp(minOffset.dy, 0.0));
  }

  void _handleFlingAnimation() {
    setState(() {
      _offset = _flingAnimation.value;
    });
  }

  void _handleOnScaleStart(ScaleStartDetails details) {
    setState(() {
      _previousScale = _scale;
      _normalizedOffset = (details.focalPoint - _offset) / _scale;
      // The fling animation stops if an input gesture starts.
      _controller.stop();
    });
  }

  void _handleOnScaleUpdate(ScaleUpdateDetails details) {
    setState(() {
      _scale = (_previousScale * details.scale).clamp(1.0, 4.0);
      // Ensure that image location under the focal point stays in the same place despite scaling.
      _offset = _clampOffset(details.focalPoint - _normalizedOffset * _scale);
    });
  }

  void _handleOnScaleEnd(ScaleEndDetails details) {
    const double _kMinFlingVelocity = 800.0;
    final double magnitude = details.velocity.pixelsPerSecond.distance;
    printWrapped('magnitude: ' + magnitude.toString());
    if (magnitude < _kMinFlingVelocity) return;
    final Offset direction = details.velocity.pixelsPerSecond / magnitude;
    final double distance = (Offset.zero & context.size).shortestSide;
    _flingAnimation = new Tween<Offset>(begin: _offset, end: _clampOffset(_offset + direction * distance)).animate(_controller);
    _controller
      ..value = 0.0
      ..fling(velocity: magnitude / 1000.0);
  }

  @override
  Widget build(BuildContext context) {
    MediaQueryData queryData = MediaQuery.of(context);
    double devicePixelRatio1 = queryData.devicePixelRatio;
    Image image = new Image.network(widget.url);

    Completer<ui.Image> completer = new Completer<ui.Image>();
    image.image.resolve(new ImageConfiguration(devicePixelRatio: devicePixelRatio1)).addListener(ImageStreamListener((ImageInfo info, bool _) {
      if (!completer.isCompleted) completer.complete(info.image);
    }));
    return Container(
      height: MediaQuery.of(context).size.height,
      child: RawGestureDetector(
        gestures: {
          AllowMultipleScaleRecognizer: GestureRecognizerFactoryWithHandlers<AllowMultipleScaleRecognizer>(
            () => AllowMultipleScaleRecognizer(), //constructor
            (AllowMultipleScaleRecognizer instance) {
              //initializer
              instance.onStart = (details) => this._handleOnScaleStart(details);
              instance.onEnd = (details) => this._handleOnScaleEnd(details);
              instance.onUpdate = (details) => this._handleOnScaleUpdate(details);
            },
          ),
          AllowMultipleHorizontalDragRecognizer: GestureRecognizerFactoryWithHandlers<AllowMultipleHorizontalDragRecognizer>(
            () => AllowMultipleHorizontalDragRecognizer(),
            (AllowMultipleHorizontalDragRecognizer instance) {
              instance.onStart = (details) => this._handleHorizontalDragAcceptPolicy(instance);
              instance.onUpdate = (details) => this._handleHorizontalDragAcceptPolicy(instance);
            },
          ),
          AllowMultipleVerticalDragRecognizer: GestureRecognizerFactoryWithHandlers<AllowMultipleVerticalDragRecognizer>(
            () => AllowMultipleVerticalDragRecognizer(),
            (AllowMultipleVerticalDragRecognizer instance) {
              instance.onStart = (details) => this._handleVerticalDragAcceptPolicy(instance);
              instance.onUpdate = (details) => this._handleVerticalDragAcceptPolicy(instance);
            },
          ),
        },
        //Creates the nested container within the first.
        behavior: HitTestBehavior.opaque,
        child: new ClipRect(
          child: new Transform(
            transform: new Matrix4.identity()
              ..translate(_offset.dx, _offset.dy)
              ..scale(_scale),
            child: image != null
                ? Image.network(
                    "${widget.url}",
                    loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent loadingProgress) {
                      if (loadingProgress == null) return child;

                      return Container(
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      );
                    },
                  )
                : Container(),
          ),
        ),
      ),
    );
  }

  void _handleHorizontalDragAcceptPolicy(AllowMultipleHorizontalDragRecognizer instance) {
    _scale > 1.0 ? instance.alwaysAccept = true : instance.alwaysAccept = false;
  }

  void _handleVerticalDragAcceptPolicy(AllowMultipleVerticalDragRecognizer instance) {
    _scale > 1.0 ? instance.alwaysAccept = true : instance.alwaysAccept = false;
  }
}
