import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:flutterdemo/sprout_video_player/sprout_video_player.dart';
import 'package:flutterdemo/sprout_video_player/sprout_video_player_controller.dart';
import 'package:video_player/video_player.dart';

const banners = [
  'https://sprout.llscdn.com/f911aefe5704b820aed77b02a6c4b63e.png',
  'https://sprout.llscdn.com/f14f844a65c459dc34f7331f655dd5e9.png',
  'https://cc-b.llscdn.com/ssk-prod/bb8518e9-941d-4b98-884a-498e1cb1e6de.jpg@1x'
];

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: Scaffold(body: Home()));
  }
}

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 40),
      child: Column(children: [
        Container(
          height: 200,
          child: Swiper(
            autoplay: true,
            itemBuilder: (BuildContext ctx, int idx) {
              return Container(
                padding: EdgeInsets.only(right: 10),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.network(
                    banners[idx],
                    fit: BoxFit.fill,
                  ),
                ),
              );
            },
            itemCount: 3,
            viewportFraction: 0.8,
          ),
        ),
        Preview()
        // Container(
        //     padding: EdgeInsets.only(top: 20),
        //     height: 350,
        //     child: Swiper(
        //       loop: false,
        //       viewportFraction: 0.91,
        //       itemCount: 1,
        //       itemBuilder: (BuildContext ctx, int idx) {
        //         return Preview();
        //       },
        //     ))
      ]),
    );
  }
}

SproutVideoPlayerController _controller = SproutVideoPlayerController(
  videoPlayerController: VideoPlayerController.network('https://cc-b.llscdn.com/ssk-prod/312f7759451da8a248dbdde931e2daa1.mp4'),
  autoPlay: true
);

class Preview extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(right: 20),
      child: Column(
        children: <Widget>[
          Container(
            width: 200,
            height: 200,
            child: SproutVideoPlayer(
              controller: _controller,
            ),
          ),
          Container(
            height: 93,
            width: double.infinity,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20)),
                color: Color(0xFFFFFFFF),
                border: Border.all(color: Color(0xFFFFF2D7), width: 1)),
            child: Text('text'),
          )
        ],
      ),
    );
  }
}
