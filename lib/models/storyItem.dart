enum EndType { bad, good }

class StoryItem {
  String id;
  String? text;
  List<String>? moreText;
  String? choiceText;
  EndType? end;
  List<StoryItem>? children;
  String? teleportToId;

  StoryItem(this.id, this.text,
      {this.choiceText,
      this.children,
      this.end,
      this.moreText,
      this.teleportToId});
}
