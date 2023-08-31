import 'dart:io';

import 'package:flutter/material.dart';
import 'package:story_creator/models/edge.dart';
import 'package:story_creator/models/storyItem.dart';

class Story {
  String title;
  late StoryItem entryPoint;
  List<StoryItem> items = [];
  List<StoryEdge> edges = [];

  Story(this.title, Map<String, dynamic> _data) {
    entryPoint = StoryItem(_data["nodes"][0]["id"], _data["nodes"][0]["text"]);
    for (var item in _data["nodes"]) {
      items.add(convertToStoryItem(item));
    }
    for (var edge in _data["edges"]) {
      edges.add(StoryEdge(edge["from"], edge["to"]));
    }
  }

  List<String> addMoreText(List<dynamic> data) {
    List<String> texts = [];
    for (dynamic text in data) {
      texts.add(text.toString());
    }
    return texts;
  }

  EndType addEnd(dynamic end) {
    switch (end) {
      case "bad":
        return EndType.bad;
      case "good":
        return EndType.good;
      default:
        throw ErrorDescription("End type not recognised");
    }
  }

  StoryItem convertToStoryItem(Map<String, dynamic> data) {
    StoryItem item = StoryItem(
      data["id"],
      data["text"],
      choiceText: data["choice_text"],
    );
    if(data["end"] != null) item.end = addEnd(data["end"]);
    if (data["more_text"] != null) {
      List<dynamic> moreTextRaw = data["more_text"];
      item.moreText = addMoreText(moreTextRaw);
    }
    return item;
  }
}
