import 'dart:io';

import 'package:flutter/material.dart';
import 'package:story_creator/models/storyEdge.dart';
import 'package:story_creator/models/storyItem.dart';

class Story {
  String title;
  late StoryItem entryPoint;
  List<StoryItem> items = [];
  List<StoryEdge> edges = [];

  Story(this.title, Map<String, dynamic> _data) {
    var firstNode = _data["nodes"][0];
    entryPoint = convertToStoryItem(firstNode);
    for (var item in _data["nodes"]) {
      items.add(convertToStoryItem(item));
    }
    for (var edge in _data["edges"]) {
      edges.add(StoryEdge(edge["from"], edge["to"]));
    }
  }

  List<String> convertToListString(List<dynamic> data) {
    List<String> texts = [];
    for (dynamic text in data) {
      texts.add(text.toString());
    }
    return texts;
  }

  EndType addEnd(dynamic end) {
    return StoryItem.stringToEndType(end);
  }

  StoryItem convertToStoryItem(Map<String, dynamic> data) {
    StoryItem item = StoryItem(data["id"], data["text"], end: addEnd(data["end"]), isUser: data["is_user"] == "true" ? true : false, minutesToWait: int.parse(data["minutes_to_wait"]));
    return item;
  }
}
