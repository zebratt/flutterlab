import 'package:flutter/material.dart';
import 'package:flutterdemo/sprout_video_player/sprout_video_player.dart';
import 'package:flutterdemo/sprout_video_player/sprout_video_player_controller.dart';
import 'package:flutterdemo/sprout_video_player/sprout_video_player_controls.dart';
import 'package:video_player/video_player.dart';

const TAG = 'Flutter.PlayerWithControls';

class PlayerWithControls extends StatefulWidget {
  final OverlyBuilder overlyBuilder;
  final bool isFullScreen;

  const PlayerWithControls({Key key, this.overlyBuilder, this.isFullScreen = false})
      : super(key: key);

  @override
  _PlayerWithControlsState createState() {
    return _PlayerWithControlsState();
  }
}

class _PlayerWithControlsState extends State<PlayerWithControls> {
  @override
  Widget build(BuildContext context) {
    final SproutVideoPlayerController videoPlayerController =
        SproutVideoPlayerController.of(context);

    return Container(
      alignment: Alignment.center,
      width: MediaQuery.of(context).size.width,
      child: _buildPlayerWithControls(videoPlayerController, context),
    );
  }

  Container _buildPlayerWithControls(
      SproutVideoPlayerController videoPlayerController, BuildContext context) {
    List<Widget> children = List();
    if (widget.isFullScreen) {
      children.add(
        AspectRatio(
                aspectRatio: videoPlayerController.aspectRatio ??
                    _calculateAspectRatio(context, videoPlayerController),
                child: videoPlayerController.placeholder) ??
            Container(),
      );
    } else {
      children.add(Positioned.fill(child: videoPlayerController.placeholder ?? Container()));
    }
    if (videoPlayerController.videoPlayerController == null) {
      if (videoPlayerController.lockBuilder != null) {
        children.add(videoPlayerController.lockBuilder(context, widget.isFullScreen));
      }
    } else {
      children.add(_buildVideo(context, videoPlayerController));
      children.add(_buildControls(context, videoPlayerController));
      if (widget.overlyBuilder != null) {
        children.add(widget.overlyBuilder(context, widget.isFullScreen));
      }
    }
    return Container(
      child: Stack(
        alignment: Alignment.center,
        children: children,
      ),
    );
  }

  Widget _buildControls(BuildContext context, SproutVideoPlayerController videoPlayerController) {
    return videoPlayerController.showControls ? SproutVideoPlayerControls() : Container();
  }

  double _calculateAspectRatio(
      BuildContext context, SproutVideoPlayerController videoPlayerController) {
    double aspectRatio = videoPlayerController.videoPlayerController?.value?.aspectRatio ?? 1.0;
    return aspectRatio > 1.0 ? aspectRatio : 16 / 9;
  }

  _buildVideo(BuildContext context, SproutVideoPlayerController videoPlayerController) {
    if (videoPlayerController.isFullScreen) {
      return AspectRatio(
        aspectRatio: videoPlayerController.aspectRatio ??
            _calculateAspectRatio(context, videoPlayerController),
        child: VideoPlayer(videoPlayerController.videoPlayerController),
      );
    } else {
      return Positioned.fill(bottom: -1,
        child: VideoPlayer(videoPlayerController.videoPlayerController),
      );
    }
  }
}
