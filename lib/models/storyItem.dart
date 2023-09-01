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
