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
