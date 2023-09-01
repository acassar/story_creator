enum EndType { bad, good }

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

  static createFromForm({required String id, required String text, required String choiceText, String? end}) {
    List<String> moreText = text.split("\n");
    return StoryItem(id, moreText[0], choiceText: choiceText, moreText: moreText.sublist(1));
  }

  _getMoreTextString() {
    String s = moreText != null ? "\n -${moreText?.map((e) => "$e").join("\n- ")}" : "none";
    return s;
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
