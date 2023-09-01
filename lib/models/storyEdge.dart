class StoryEdge {
  String from;
  String to;

  StoryEdge(this.from, this.to);

  String toJson() {
    return """
  {
    "from": "$from",
    "to": "$to"
  }
""";
  }
}
