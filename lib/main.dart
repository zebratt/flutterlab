import 'package:flutter/material.dart';
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
      home: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: Text('Repeek'),
            actions: [
              Builder(builder: (_) {
                return IconButton(
                    icon: Icon(Icons.add, color: Colors.white),
                    onPressed: () {
                      Navigator.push(
                          _,
                          PageRouteBuilder(
                              pageBuilder: (_, __, ___) => WordMaker()));
                    });
              })
            ],
          ),
          body: HomePage()),
    );
  }
}
