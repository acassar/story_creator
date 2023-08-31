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
}
