import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutterdemo/sprout_video_player/player_with_controls.dart';
import 'package:flutterdemo/sprout_video_player/sprout_video_player_controller.dart';

typedef OverlyBuilder = Widget Function(BuildContext context, bool isFullScreen);

class SproutVideoPlayer extends StatefulWidget {
  SproutVideoPlayer({
    Key key,
    @required this.controller,
    this.title,
    this.showIndicatorBuffer = false,
    this.overlyBuilder,
  })  : assert(controller != null, 'You must provide a controller'),
        super(key: key);

  final SproutVideoPlayerController controller;
  final bool showIndicatorBuffer;
  final String title;
  final OverlyBuilder overlyBuilder;

  @override
  SproutVideoPlayerState createState() {
    return SproutVideoPlayerState();
  }
}

class SproutVideoPlayerState extends State<SproutVideoPlayer> {
  @override
  Widget build(BuildContext context) {
    return SproutVideoPlayerControllerProvider(
      controller: widget.controller,
      child: PlayerWithControls(overlyBuilder: widget.overlyBuilder),
    );
  }
}
