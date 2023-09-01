import 'dart:convert';

enum EndType { bad, good, not }

class StoryItem {
  String id;
  String? text;
  List<String>? moreText;
  String? choiceText;
  EndType? end;

  StoryItem(
    this.id,
    this.text, {
    this.choiceText,
    this.end,
    this.moreText,
  });

  static createFromForm(
      {required String id,
      required String text,
      required String choiceText,
      String? end}) {
    List<String> formatedText = text.split("\n");
    List<String> moreText = formatedText.sublist(1);
    moreText.removeWhere(
      (element) => element == "",
    );
    return StoryItem(id, formatedText[0],
        choiceText: choiceText, moreText: moreText.isEmpty ? null : moreText);
  }

  _getMoreTextString() {
    String s = moreText != null
        ? "\n -${moreText?.map((e) => "$e").join("\n- ")}"
        : "none";
    return s;
  }

  String? _getMoreTextJson() {
    return moreText != null ? "[\n\"${moreText!.join("\",\n\"")}\"\n]" : "[]";
  }

  endTypeToString(EndType type) {
    switch (type) {
      case EndType.bad:
        return "bad";
      case EndType.good:
        return "good";
      case EndType.not:
        return "not";
      default:
        return "not";
    }
  }

  String toJson() {
    return """
  {
    "id": "$id",
    "text": "$text",
    "choice_text": "${choiceText ?? ""}",
    "end": "${endTypeToString(end ?? EndType.not) ?? "not"}",
    "more_text": ${_getMoreTextJson()}
  }
""";
  }

  @override
  String toString() {
    return """
    🆔 Id: $id 🆔
    💭 Text: $text 💭
    📲 Choice text: $choiceText 📲
    📋 More Text: ${_getMoreTextString()} 📋
  """;
  }
}
