import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutterdemo/sprout_video_player/sprout_video_indicator.dart';
import 'package:flutterdemo/sprout_video_player/sprout_video_player_controller.dart';
import 'package:video_player/video_player.dart';

const Duration _bufferingToleranceDuration = Duration(milliseconds: 500);

const TAG = 'Flutter.SproutVideoPlayerControls';

class SproutVideoPlayerControls extends StatefulWidget {
  final bool showIndicatorBuffer;

  SproutVideoPlayerControls({this.showIndicatorBuffer});

  @override
  State<StatefulWidget> createState() {
    return _SproutVideoPlayerControlsState();
  }
}

class _SproutVideoPlayerControlsState extends State<SproutVideoPlayerControls> {
  VideoPlayerValue _currentValue;
  bool _hideControls = true;
  Timer _hideTimer;
  Timer _initTimer;
  Timer _trySeeTimer;
  bool _displayTapped = false;
  VideoPlayerController controller;
  SproutVideoPlayerController sproutVideoPlayerController;

  @override
  Widget build(BuildContext context) {
    if ((_currentValue?.hasError ?? false) && sproutVideoPlayerController.errorBuilder != null) {
      return sproutVideoPlayerController.errorBuilder(
          context,
          sproutVideoPlayerController.isFullScreen,
          _currentValue?.position ?? Duration.zero,
          _currentValue?.errorDescription ?? '');
    }
    if (_currentValue?.isCompleted ?? false) {
      if (sproutVideoPlayerController.onFinishCallBack != null) {
        sproutVideoPlayerController.onFinishCallBack();
      }
      if (sproutVideoPlayerController.completedBuilder != null) {
        return sproutVideoPlayerController.completedBuilder(
            context, sproutVideoPlayerController.isFullScreen);
      }
    }
    if (sproutVideoPlayerController?.trySeeDuration != null ) {
      var position = _currentValue?.position ?? Duration.zero;
      if (position >= sproutVideoPlayerController.trySeeDuration){
        sproutVideoPlayerController?.pause();
        if (sproutVideoPlayerController?.trySeeFinishCallBack != null) {
          sproutVideoPlayerController.trySeeFinishCallBack();
        }
        if (sproutVideoPlayerController.trySeeCompletedBuilder != null) {
          return sproutVideoPlayerController.trySeeCompletedBuilder(
              context, sproutVideoPlayerController.isFullScreen);
        }
      }
    }
    List<Widget> children = List();
    children.add(_createTitleBar(context));
    children.add(_createCenterView());
    children.add(_createIndicator());
    return MouseRegion(
      onHover: (_) {
        _cancelAndRestartTimer();
      },
      child: GestureDetector(
        onTap: () => _cancelAndRestartTimer(),
        child: AbsorbPointer(
          absorbing: _hideControls,
          child: Column(
            children: children,
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _trySeeTimer = Timer(const Duration(seconds: 5), () {
      setState(() {
        sproutVideoPlayerController?.showTrySeeView = false;
      });
    });
  }

  @override
  void dispose() {
    _dispose();
    _trySeeTimer?.cancel();
    super.dispose();
  }

  void _dispose() {
    controller?.removeListener(_videoStateListener);
    _hideTimer?.cancel();
    _initTimer?.cancel();
  }

  @override
  void didChangeDependencies() {
    final _oldController = sproutVideoPlayerController;
    sproutVideoPlayerController = SproutVideoPlayerController.of(context);
    controller = sproutVideoPlayerController.videoPlayerController;
    if (_oldController != sproutVideoPlayerController) {
      _dispose();
      _initialize();
    }
    super.didChangeDependencies();
  }

  Widget _createTitleBar(BuildContext context) {
    Widget child;
    if (sproutVideoPlayerController.isFullScreen &&
        sproutVideoPlayerController.titleBarBuilder != null) {
      child = sproutVideoPlayerController.titleBarBuilder(
          context, sproutVideoPlayerController.isFullScreen);
    } else {
      child = SizedBox(height: 60);
    }
    return AnimatedOpacity(
      opacity: _hideControls ? 0.0 : 1.0,
      duration: Duration(milliseconds: 300),
      child: child,
    );
  }

  Widget _createCenterView() {
    return _isBufferingState()
        ? const Expanded(
            child: const Center(
                child: const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
          )))
        : _buildHitArea();
  }

  AnimatedOpacity _createIndicator() {
    return AnimatedOpacity(
      opacity: _hideControls ? 0.0 : 1.0,
      duration: Duration(milliseconds: 300),
      child: SproutVideoIndicator(
          onDragEnd: () {
            if (sproutVideoPlayerController.onDragEnd != null) {
              sproutVideoPlayerController.onDragEnd();
            }
            sproutVideoPlayerController?.showTrySeeView = false;
            _trySeeTimer?.cancel();
            _cancelAndRestartTimer();
          },
          onDragStart: () {
            if (sproutVideoPlayerController.onDragStart != null) {
              sproutVideoPlayerController.onDragStart();
            }
            _hideTimer.cancel();
          },
          onPauseCallBack: () {
            if (sproutVideoPlayerController.onPauseCallBack != null) {
              sproutVideoPlayerController.onPauseCallBack();
            }
            _cancelAndRestartTimer();
          },
          onPlayCallBack: () {
            if (sproutVideoPlayerController.onPlayCallBack != null) {
              sproutVideoPlayerController.onPlayCallBack();
            }
            _cancelAndRestartTimer();
          },
          showBuffer: widget.showIndicatorBuffer,
          loopModeCallBack: (loopType) {
            if (sproutVideoPlayerController.loopModeCallBack != null) {
              sproutVideoPlayerController.loopModeCallBack(loopType);
            }
            _cancelAndRestartTimer();
          }),
    );
  }

  bool _isBufferingState() {
    if (_currentValue == null || !_currentValue.initialized) {
      return true;
    } else {
      int maxBuffering = 0;
      for (DurationRange range in _currentValue.buffered) {
        final int end = range.end.inMilliseconds;
        if (end > maxBuffering) {
          maxBuffering = end;
        }
      }
      if (_currentValue.isPlaying) {
        if (maxBuffering < _bufferingToleranceDuration.inMilliseconds) {
          return true;
        } else {
          /// 缓存完成
          // 预留 buffer 缓冲时间
          if (_currentValue.position.inMilliseconds >=
                  (maxBuffering - _bufferingToleranceDuration.inMilliseconds) &&
              (_currentValue.duration - _bufferingToleranceDuration) >= _currentValue.position) {
            return true;
          } else {
            return false;
          }
        }
      }
      return _currentValue.isBuffering;
    }
  }

  Expanded _buildHitArea() {
    return Expanded(
        child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () {
              if (_currentValue?.isPlaying ?? false) {
                if (_displayTapped) {
                  setState(() {
                    _hideControls = true;
                  });
                } else {
                  _cancelAndRestartTimer();
                }
              } else {
                setState(() {
                  _hideControls = true;
                });
              }
            },
            child: Container(
              child: _createTrySeeView(),
            )));
  }

  Widget _createTrySeeView() {
    if (sproutVideoPlayerController?.trySeeDuration != null &&
        sproutVideoPlayerController?.trySeeBuilder != null) {
      double left = 12;
      left = (sproutVideoPlayerController?.isFullScreen ?? false) ? left + 12 : left;
      return Container(
        alignment: Alignment.bottomLeft,
        margin: EdgeInsets.only(left: left, bottom: 10),
        child: Visibility(
            visible: sproutVideoPlayerController?.showTrySeeView ?? false,
            child: sproutVideoPlayerController?.trySeeBuilder(
                context, sproutVideoPlayerController?.isFullScreen ?? false)),
      );
    } else {
      return Container();
    }
  }

  void _cancelAndRestartTimer() {
    _hideTimer?.cancel();
    _startHideTimer();
    setState(() {
      _hideControls = false;
      _displayTapped = true;
    });
  }

  Future<Null> _initialize() async {
    _currentValue = controller?.value;
    controller?.addListener(_videoStateListener);
    if ((controller?.value?.isPlaying ?? false) || sproutVideoPlayerController.autoPlay) {
      _startHideTimer();
    }
    if (sproutVideoPlayerController.showControlsOnInitialize) {
      _initTimer = Timer(Duration(milliseconds: 200), () {
        setState(() {
          _hideControls = false;
        });
      });
    }
  }

  _videoStateListener() {
    if (controller?.isDisposed ?? true) {
      return;
    }
    setState(() {
      _currentValue = controller?.value;
    });
  }

  void _startHideTimer() {
    _hideTimer = Timer(const Duration(seconds: 3), () {
      setState(() {
        _hideControls = true;
      });
    });
  }
}
