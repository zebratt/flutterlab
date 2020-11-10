import 'package:flutter/material.dart';
import 'package:flutterdemo/sprout_video_player/sprout_video_indicator.dart';
import 'package:video_player/video_player.dart';

const TAG = 'Flutter.SproutVideoPlayerController';

class SproutVideoPlayerController extends ChangeNotifier {
  SproutVideoPlayerController(
      {this.onDragStart,
      this.onDragEnd,
      this.onPauseCallBack,
      this.onPlayCallBack,
      this.onFinishCallBack,
      this.loopModeCallBack,
      this.enterFullScreenCallBack,
      this.exitFullScreenCallBack,
      this.videoPlayerController,
      this.aspectRatio,
      this.autoInitialize = true,
      this.autoPlay = false,
      this.startAt,
      this.looping = false,
      this.placeholder,
      this.overlay,
      this.showControlsOnInitialize = false,
      this.showControls = true,
      this.customControls,
      this.errorBuilder,
      this.lockBuilder,
      this.completedBuilder,
      this.titleBarBuilder,
      this.allowFullScreen = true,
      this.allowMuting = true,
      this.trySeeDuration,
      this.trySeeBuilder,
      this.trySeeFinishCallBack,
      this.trySeeCompletedBuilder}) {
    _initialize();
  }

  /// The controller for the video you want to play
  final VideoPlayerController videoPlayerController;

  /// Initialize the Video on Startup. This will prep the video for playback.
  final bool autoInitialize;

  /// Play the video as soon as it's displayed
  final bool autoPlay;

  /// Start video at a certain position
  final Duration startAt;

  /// Whether or not the video should loop
  final bool looping;

  /// Weather or not to show the controls when initializing the widget.
  final bool showControlsOnInitialize;

  /// Whether or not to show the controls at all
  final bool showControls;

  final Widget customControls;

  /// When the video playback runs  into an error, you can build a custom
  /// error message.
  final Widget Function(BuildContext context, bool isFullScreen,
      Duration position, String errorMessage) errorBuilder;

  final Widget Function(BuildContext context, bool isFullScreen) lockBuilder;

  final Widget Function(BuildContext context, bool isFullScreen)
      titleBarBuilder;

  final Widget Function(BuildContext context, bool isFullScreen)
      completedBuilder;

  final Widget Function(BuildContext context, bool isFullScreen)
      trySeeCompletedBuilder;

  final Widget Function(BuildContext context, bool isFullScreen) trySeeBuilder;

  /// how long you can watch the video
  final Duration trySeeDuration;

  /// The Aspect Ratio of the Video. Important to get the correct size of the
  /// video!
  ///
  /// Will fallback to fitting within the space allowed.
  final double aspectRatio;

  /// The placeholder is displayed underneath the Video before it is initialized
  /// or played.
  final Widget placeholder;

  /// A widget which is placed between the video and the controls
  final Widget overlay;

  /// Defines if the fullscreen control should be shown
  final bool allowFullScreen;

  /// Defines if the mute control should be shown
  final bool allowMuting;

  final VoidCallback onDragStart;

  final VoidCallback onDragEnd;

  final VoidCallback onPauseCallBack;

  final VoidCallback onPlayCallBack;

  final VoidCallback onFinishCallBack;

  final VoidCallback trySeeFinishCallBack;

  final VoidCallback enterFullScreenCallBack;

  final VoidCallback exitFullScreenCallBack;

  final LoopModeCallBack loopModeCallBack;

  static SproutVideoPlayerController of(BuildContext context) {
    final sproutVideoPlayerControllerProvider =
        context.dependOnInheritedWidgetOfExactType<
            SproutVideoPlayerControllerProvider>();
    return sproutVideoPlayerControllerProvider.controller;
  }

  bool _isFullScreen = false;

  bool get isFullScreen => _isFullScreen;

  set isFullScreen(bool value) {
    _isFullScreen = value;
  }

  bool _isLoop = false;

  bool get isLoop => _isLoop;

  bool _showTrySeeView = false;

  bool get showTrySeeView => _showTrySeeView;

  set showTrySeeView(bool value) {
    _showTrySeeView = value;
  }

  Future _initialize() async {
    if ((autoInitialize || autoPlay) && !hasInitialized()) {
      await videoPlayerController?.initialize();
    }

    await videoPlayerController?.setLooping(looping);

    if (autoPlay) {
      await videoPlayerController?.play();
    }

    if (startAt != null) {
      await videoPlayerController?.seekTo(startAt);
    }

    showTrySeeView = trySeeDuration != null && trySeeDuration > Duration.zero;
  }

  void enterFullScreen() {
    _isFullScreen = true;
    notifyListeners();
    if (enterFullScreenCallBack != null) {
      enterFullScreenCallBack();
    }
  }

  void exitFullScreen() {
    _isFullScreen = false;
    notifyListeners();
    if (exitFullScreenCallBack != null) {
      exitFullScreenCallBack();
    }
  }

  void toggleFullScreen() {
    _isFullScreen = !_isFullScreen;
    notifyListeners();
  }

  Future<void> play() async {
    if (isPlaying()) {
      return;
    }
    await videoPlayerController?.play();
  }

  Future<void> setLooping(bool looping) async {
    _isLoop = looping;
    await videoPlayerController?.setLooping(looping);
  }

  Future<void> pause() async {
    await videoPlayerController?.pause();
  }

  Future<void> seekTo(Duration moment) async {
    if (hasInitialized()) {
      await videoPlayerController?.seekTo(moment);
    }
  }

  Future<void> setVolume(double volume) async {
    await videoPlayerController?.setVolume(volume);
  }

  bool hasInitialized() {
    return videoPlayerController?.value?.initialized ?? false;
  }

  bool hasError() {
    return videoPlayerController?.value?.hasError ?? false;
  }

  bool isCompleted() {
    return videoPlayerController?.value?.isCompleted ?? false;
  }

  bool isPlaying() {
    return videoPlayerController?.value?.isPlaying ?? false;
  }

  Future<void> initializeToPlay() async {
    if (hasInitialized()) {
      await videoPlayerController?.play();
    } else {
      await videoPlayerController?.initialize();
      await videoPlayerController?.play();
    }
  }

  Future<void> replay({Duration position}) async {
    await resetVideo(position: position);
    await play();
  }

  Future<void> resetVideo({Duration position}) async {
    if (!hasInitialized()) {
      await videoPlayerController?.initialize();
    }
    await seekTo(position ?? Duration.zero);
  }

  Duration getPosition() {
    return videoPlayerController?.value?.position ?? Duration.zero;
  }
}

class SproutVideoPlayerControllerProvider extends InheritedWidget {
  const SproutVideoPlayerControllerProvider({
    Key key,
    @required this.controller,
    @required Widget child,
  })  : assert(controller != null),
        assert(child != null),
        super(key: key, child: child);

  final SproutVideoPlayerController controller;

  @override
  bool updateShouldNotify(SproutVideoPlayerControllerProvider old) =>
      controller != old.controller;
}

class DefaultSproutVideoTitle extends StatelessWidget {
  final VoidCallback onBackClicked;
  final String title;

  DefaultSproutVideoTitle({this.onBackClicked, this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16),
        child: Row(
          children: <Widget>[
            GestureDetector(
                onTap: () {
                  if (onBackClicked != null) {
                    onBackClicked();
                  }
                },
                child: Text('back')),
            Padding(
              padding: const EdgeInsets.only(left: 14.0),
              child: Text(
                title ?? '',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            )
          ],
        ));
  }
}
