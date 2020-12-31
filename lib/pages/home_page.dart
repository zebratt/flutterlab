import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_macos/store/store.dart';
import 'package:hooks_riverpod/all.dart';
import 'package:url_launcher/url_launcher.dart';

class HomePage extends HookWidget {
  @override
  Widget build(BuildContext context) {
    var provider = useProvider(wordsFutureProvider);

    return provider.when(
        data: (data) {
          var words = data.words;

          if (words.isEmpty) {
            return Center(child: Text('Empty'));
          }

          return ListView(children: [
            for (var word in words)
              _WordItem(
                text: word.text,
              )
          ]);
        },
        loading: () => Center(child: CircularProgressIndicator()),
        error: (_, __) => Text('error'));
  }
}

class _WordItem extends StatelessWidget {
  final String text;

  _WordItem({@required this.text});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        var url = 'https://dict.youdao.com/search?q=$text';

        if (await canLaunch(url)) {
          launch(url);
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 24),
        height: 48,
        decoration: BoxDecoration(
            border: Border(bottom: BorderSide(width: 1, color: Colors.black))),
        child: Align(
          alignment: Alignment.centerLeft,
          child:
              Text(text, style: TextStyle(color: Colors.black, fontSize: 16)),
        ),
      ),
    );
  }
}
