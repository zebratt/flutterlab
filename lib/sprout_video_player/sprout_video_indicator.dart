import 'dart:math';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterdemo/bootstrap/life_cycle_state.dart';
import 'package:flutterdemo/sprout_video_player/lls_slider.dart';
import 'package:flutterdemo/sprout_video_player/sprout_video_player_controller.dart';
import 'package:flutterdemo/utils/time_utils.dart';
import 'package:video_player/video_player.dart';

typedef LoopModeCallBack = Function(LoopModeType modeType);

class _SproutVideoScrubber extends StatefulWidget {
  _SproutVideoScrubber(
      {@required this.child, this.controller, this.onDragStart, this.onDragEnd, this.onDragUpdate});

  final Widget child;
  final VideoPlayerController controller;
  final VoidCallback onDragStart;
  final FrameCallback onDragUpdate;
  final VoidCallback onDragEnd;

  @override
  _SproutVideoScrubberState createState() => _SproutVideoScrubberState();
}

class _SproutVideoScrubberState extends State<_SproutVideoScrubber> {
  VideoPlayerController get controller => widget.controller;

  Offset _currentPosition = Offset(0, 0);

  @override
  Widget build(BuildContext context) {
    void seekToRelativePosition(Offset globalPosition) {
      final RenderBox box = context.findRenderObject();
      final Offset tapPos = box.globalToLocal(globalPosition);
      double relative = tapPos.dx / box.size.width;
      relative = min(0.99, relative);
      relative = max(0, relative);
      final Duration position = (controller?.value?.duration ?? Duration.zero) * relative;
      controller?.seekTo(position);
    }

    void updatePositionPosition(Offset globalPosition) {
      final RenderBox box = context.findRenderObject();
      final Offset tapPos = box.globalToLocal(globalPosition);
      double relative = tapPos.dx / box.size.width;
      relative = min(0.99, relative);
      relative = max(0, relative);
      final Duration position = (controller?.value?.duration ?? Duration.zero) * relative;
      if (widget.onDragUpdate != null) {
        widget.onDragUpdate(position);
      }
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      child: widget.child,
      onHorizontalDragStart: (DragStartDetails details) {
        if (!(controller?.value?.initialized ?? false)) {
          return;
        }
        if (widget.onDragStart != null) {
          widget.onDragStart();
        }
      },
      onHorizontalDragUpdate: (DragUpdateDetails details) {
        if (!(controller?.value?.initialized ?? false)) {
          return;
        }
        _currentPosition = details.globalPosition;
        updatePositionPosition(_currentPosition);
      },
      onHorizontalDragEnd: (DragEndDetails details) {
        if (widget.onDragEnd != null) {
          widget.onDragEnd();
        }
        seekToRelativePosition(_currentPosition);
      },
      onTapDown: (TapDownDetails details) {
        if (!(controller?.value?.initialized ?? false)) {
          return;
        }
        seekToRelativePosition(details.globalPosition);
      },
    );
  }
}

enum LoopModeType {
  single,
  list,
}

class SproutVideoIndicator extends StatefulWidget {
  final bool allowScrubbing;
  final EdgeInsets padding;
  final Color indicatorColor;
  final double height;
  final bool autoPlay;
  final bool looping;
  final VoidCallback onDragStart;
  final VoidCallback onDragEnd;
  final VoidCallback onPauseCallBack;
  final VoidCallback onPlayCallBack;
  final LoopModeCallBack loopModeCallBack;
  final bool showBuffer;

  SproutVideoIndicator(
      {indicatorColor,
      this.allowScrubbing = true,
      this.height = 60,
      this.padding = const EdgeInsets.only(top: 5.0),
      this.autoPlay = false,
      this.looping = false,
      this.onDragStart,
      this.onDragEnd,
      this.onPauseCallBack,
      this.onPlayCallBack,
      this.loopModeCallBack,
      this.showBuffer = true})
      : indicatorColor = indicatorColor ?? Colors.orange;

  @override
  _SproutVideoIndicatorState createState() => _SproutVideoIndicatorState();
}

class _SproutVideoIndicatorState extends LifecycleState<SproutVideoIndicator> {
  LoopModeType _modeType;

  VideoPlayerController controller;

  SproutVideoPlayerController sproutVideoPlayerController;

  VideoPlayerValue _currentValue;

  VoidCallback get onDragStart => widget.onDragStart;

  VoidCallback get onDragEnd => widget.onDragEnd;

  VoidCallback get onPauseCallBack => widget.onPauseCallBack;

  VoidCallback get onPlayCallBack => widget.onPlayCallBack;

  Widget progressIndicator;

  double sliderValue = 0;

  bool isDragStart = false;
  
  @override
  void dispose() {
    _dispose();
    super.dispose();
  }

  void _dispose() {
    controller?.removeListener(_indicatorStateListener);
  }

  Future<Null> _initialize() async {
    _currentValue = controller?.value;
    controller?.addListener(_indicatorStateListener);
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

  _indicatorStateListener() {
    if (controller?.isDisposed ?? true) {
      return;
    }
    setState(() {
      _currentValue = controller?.value;
    });
  }

  void _playOrPause() {
    bool isFinished = false;
    if (_currentValue?.duration != null && _currentValue?.position != null) {
      isFinished = _currentValue.position >= _currentValue.duration;
    }
    setState(() {
      if (_currentValue?.isPlaying ?? false) {
        if (onPauseCallBack != null) {
          onPauseCallBack();
        }
        sproutVideoPlayerController.pause();
      } else {
        if (onPlayCallBack != null) {
          onPlayCallBack();
        }
        if (isFinished) {
          sproutVideoPlayerController.replay();
        } else {
          sproutVideoPlayerController.play();
        }
      }
    });
  }

  void _singleOrListLoop() {
    setState(() {
      if (sproutVideoPlayerController.isLoop) {
        _modeType = LoopModeType.list;
      } else {
        _modeType = LoopModeType.single;
      }
      sproutVideoPlayerController.setLooping(!sproutVideoPlayerController.isLoop);
      if (widget.loopModeCallBack != null) {
        widget.loopModeCallBack(_modeType);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_currentValue?.initialized ?? false) {
      final int duration = _currentValue.duration.inMilliseconds;
      final int positionMilliseconds = _currentValue.position.inMilliseconds;
      int maxBuffering = 0;
      for (DurationRange range in _currentValue.buffered) {
        final int end = range.end.inMilliseconds;
        if (end > maxBuffering) {
          maxBuffering = end;
        }
      }
      progressIndicator = _createProgressIndicator(
        positionMilliseconds,
        duration,
        maxBuffering,
        TimeUtils.durationToTime(_currentValue.position,
            showHour: _currentValue.duration.inHours > 0),
        TimeUtils.durationToTime(_currentValue.duration),
      );
    } else if (_currentValue?.hasError ?? false) {
      if (progressIndicator == null) {
        progressIndicator = _createProgressIndicator(0, 0, 0, "00:00", "00:00");
      }
    } else {
      progressIndicator = _createProgressIndicator(0, 0, 0, "00:00", "00:00");
    }
    final Widget paddedProgressIndicator = Padding(
      padding: widget.padding,
      child: progressIndicator,
    );
    return paddedProgressIndicator;
  }

  _createProgressIndicator(
      int position, int duration, int maxBuffering, String posTime, String time) {
    Widget child = Row(
      children: <Widget>[
        Container(
          child: GestureDetector(
              onTap: _playOrPause,
              child: _currentValue?.isPlaying ?? false
                  ? Text('play')
                  : Text('pause')),
          width: widget.height * 0.75,
          height: widget.height * 0.75,
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            posTime,
            style: TextStyle(color: Colors.white),
          ),
        ),
        Expanded(
          flex: 1,
          child: _buildLlsSlider(position, maxBuffering, duration),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            time,
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
    return Container(
        padding: EdgeInsets.symmetric(horizontal: (12)),
        height: widget.height,
        margin: sproutVideoPlayerController.isFullScreen ? EdgeInsets.all(12) : EdgeInsets.all(0),
        child: child);
  }

  Widget _buildLlsSlider(int position, int maxBuffering, int duration) {
    double value = min(max(0, position.toDouble()), duration.toDouble());
    if (isDragStart) {
      value = sliderValue;
    }
    Widget slider = LlsSlider(
        value: value,
        canSlider: false,
        min: 0,
        max: duration.toDouble(),
        onChanged: (value) {},
        showBufferSlider: widget.showBuffer,
        bufferValue: min(maxBuffering.toDouble(), duration.toDouble()),
        sliderColor: widget.indicatorColor);
    if (widget.allowScrubbing) {
      return _SproutVideoScrubber(
        child: slider,
        controller: controller,
        onDragEnd: () {
          isDragStart = false;
          if (onDragEnd != null) {
            onDragEnd();
          }
        },
        onDragUpdate: (position) {
          setState(() {
            sliderValue = position.inMilliseconds.toDouble();
          });
        },
        onDragStart: () {
          isDragStart = true;
          if (onDragStart != null) {
            onDragStart();
          }
        },
      );
    } else {
      return slider;
    }
  }
}
