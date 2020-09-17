import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: Example15());
  }
}

/*
 * 约束一：大小与屏幕一致
 */
class Example1 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(color: Colors.blue);
  }
}

/*
 * 约束一：大小与屏幕一致
 */
class Example2 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(width: 200, height: 200, color: Colors.blue);
  }
}

/*
 * 约束一：大小与屏幕一致 （Center）
 *  约束二：宽高200 （Container）
 */
class Example3 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
        child: Container(width: 200, height: 200, color: Colors.blue));
  }
}

/*
 * 约束一：大小与屏幕一致 （Center）
 *  约束二：宽高无限 （Container）
 * 
 *  由于最外层的约束影响，宽高最终只能和屏幕大小保持一致
 */
class Example4 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
        child: Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.blue));
  }
}

/*
 * 约束一：大小与屏幕一致 （Center）
 * 
 * 由于Container没有设置宽高，即自身没有约束，那么会被自动撑满屏幕 (由于LimitedBox)
 */
class Example5 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Container(color: Colors.blue));
  }
}

/*
 * 约束一：大小与屏幕一致 （Center）
 *    约束二：宽高100 （红色Container）
 */
class Example6 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
        child: Container(
      color: Colors.blue,
      child: Container(
        color: Colors.red,
        width: 100,
        height: 100,
      ),
    ));
  }
}

/*
 * 约束一：大小与屏幕一致 （Center）
 *    约束二：宽高100 （红色Container）
 */
class Example7 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
        child: Container(
      padding: EdgeInsets.all(20),
      color: Colors.blue,
      child: Container(
        color: Colors.red,
        width: 100,
        height: 100,
      ),
    ));
  }
}

/*
 * 约束一：大小与屏幕一致 
 *    附加约束二：宽高10 （Container）
 * 
 * 受到约束一的限制，附加约束不生效
 */
class Example8 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        minWidth: 70,
        minHeight: 70,
        maxWidth: 150,
        maxHeight: 150,
      ),
      child: Container(color: Colors.red, width: 10, height: 10),
    );
  }
}

/*
 * 约束一：大小和屏幕一致 （Center）
 *  约束二：最大宽高不得超过100 （Container）
 *    附加约束三：宽高不得超过10（Container）
 * 
 * 受到约束二的限制，附加约束不生效
 */
class Example9 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
        child: Container(
      constraints: BoxConstraints(maxWidth: 100, maxHeight: 100),
      width: 200,
      height: 200,
      color: Colors.red,
      child:
          Center(child: Container(width: 10, height: 10, color: Colors.blue)),
    ));
  }
}

class Example10 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return UnconstrainedBox(
      child: Container(color: Colors.red, width: 100, height: 100),
    );
  }
}

class Example11 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return UnconstrainedBox(
      child: Container(color: Colors.red, width: 1000, height: 100),
    );
  }
}

/*
 * Text具有自然宽度，由自身的大小，字体决定
 * FittedBox可以缩放子元素
 * FittedBox内如果文字超长，字体不会换行
 */
class Example12 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FittedBox(
        child: Text('hello flutter', style: TextStyle(fontSize: 12)));
  }
}

/*
 * 约束一：和屏幕大小一致 （Row）
 * 
 * 由于Row对子项没有施加任何约束，所以他们的大小完全由自己决定，会造成溢出。
 */
class Example13 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Text(
            'this is a very very very very very very very very very very long text'),
        Text('text b')
      ],
    );
  }
}

/*
 * 当我们使用Expanded组件以后，Text1的宽度便受到约束控制，不由自己决定
 */
class Example14 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
            child: Text(
                'this is a very very very very very very very very very very long text')),
        Text('text b')
      ],
    );
  }
}

class Example15 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Container(width: 100, height: 100, color: Colors.blue)
      ],
    );
  }
}
