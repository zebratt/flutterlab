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

class WordRepository extends StateNotifier<AsyncValue<List<Word>>> {
  WordRepository() : super(const AsyncValue.loading()) {
    _fetch();
  }

  _fetch() async {
    state = await AsyncValue.guard(() async {
      return await StorageManager.getWords();
    });
  }

  add(Word word) {
    state.whenData((words) async {
      state = await AsyncValue.guard(() async {
        return [...words, word];
      });
    });
  }
}

var wordsProvider = StateNotifierProvider((ref) => WordRepository());
