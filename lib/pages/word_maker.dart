import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_macos/models/word.dart';
import 'package:flutter_macos/store/store.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class WordMaker extends HookWidget {
  @override
  Widget build(BuildContext context) {
    var _textController = useTextEditingController();
    var _posController = useTextEditingController();
    var _paraphraseController = useTextEditingController();

    void onSubmit() {
      var newWord = Word(
          text: _textController.value.text,
          pos: _posController.value.text,
          paraphrase: _paraphraseController.value.text);
      context.read(wordsFutureProvider).whenData((value) {
        value.add(newWord);
        context.refresh(wordsFutureProvider);
      });

      Navigator.pop(context);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Repeek'),
        leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(context).pop();
            }),
      ),
      backgroundColor: Colors.white,
      body: Container(
        padding: EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(
              controller: _textController,
              decoration: InputDecoration(
                  border: OutlineInputBorder(), labelText: 'text'),
            ),
            Divider(height: 16),
            TextField(
              controller: _posController,
              decoration: InputDecoration(
                  border: OutlineInputBorder(), labelText: 'pos'),
            ),
            Divider(
              height: 16,
            ),
            TextField(
              controller: _paraphraseController,
              decoration: InputDecoration(
                  border: OutlineInputBorder(), labelText: 'paraphrase'),
            ),
            Divider(
              height: 32,
            ),
            RaisedButton.icon(
                onPressed: onSubmit,
                icon: Icon(
                  Icons.library_add,
                  color: Colors.white,
                ),
                textColor: Colors.white,
                color: Color(0xff4697ec),
                label: Text('Submit'))
          ],
        ),
      ),
    );
  }
}
