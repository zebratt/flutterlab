import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_macos/pages/home_page.dart';
import 'package:flutter_macos/pages/word_maker.dart';
import 'package:hooks_riverpod/all.dart';

void main() {
  runApp(ProviderScope(child: App()));
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(backgroundColor: Colors.white, body: Main()),
    );
  }
}

class Main extends HookWidget {
  @override
  Widget build(BuildContext context) {
    var count = useState<int>(100);

    return Center(
        child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
          Text('count: ${count.value}'),
          Divider(height: 1),
          RaisedButton(
              onPressed: () {
                count.value++;
              },
              child: Text('increase'))
        ]));
  }
}
