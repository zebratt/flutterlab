import 'package:flutter_macos/config.dart';
import 'package:flutter_macos/models/word.dart';
import 'package:hooks_riverpod/all.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageManager {
  static Future<List<Word>> getWords() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    List<String> words = pref.getStringList(STORAGE_KEY);

    if (words == null || words.isEmpty) {
      return [];
    }

    return words.map((json) => Word.fromJson(json)).toList();
  }

  static save(List<Word> words) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setStringList(
        STORAGE_KEY, words.map((word) => word.toJson()).toList());
  }
}

class WordRepository extends StateNotifier<List<Word>> {
  WordRepository(List<Word> words) : super(words);

  List<Word> get words => state;

  add(Word word) {
    state = [...state, word];
    // StorageManager.save(words);
  }
}

var wordsFutureProvider =
    FutureProvider.autoDispose<WordRepository>((ref) async {
  var words = await StorageManager.getWords();

  return WordRepository(words);
});

var wordsProvider = Provider.autoDispose<AsyncValue<List<Word>>>((ref) {
  return ref.watch(wordsFutureProvider).whenData((value) => value.words);
});
