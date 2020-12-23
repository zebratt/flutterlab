import 'dart:convert';

class Word {
  String text;
  String pos;
  String paraphrase;

  Word({this.text, this.pos, this.paraphrase});

  Word.fromJson(json) {
    if (json != null) {
      this.text = json['text'];
      this.pos = json['pos'];
      this.paraphrase = json['paraphrase'];
    }
  }

  String toJson() {
    return json.encode(
        {'text': this.text, 'pos': this.pos, 'paraphrase': this.paraphrase});
  }
}
