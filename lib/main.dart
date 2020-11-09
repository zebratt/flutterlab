import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';

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
        )
      ]),
    );
  }
}
