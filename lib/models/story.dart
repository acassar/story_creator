import 'dart:io';

import 'package:flutter/material.dart';
import 'package:story_creator/models/storyItem.dart';

class Story {
  String title;
  late StoryItem entryPoint;

  Story(this.title, Map<String, dynamic> _data) {
    entryPoint = convertToStoryItem(_data);
  }

  StoryItem findTeleportId(String id) {
    return _findTeleportIdStep(entryPoint, id)!;
  }

  StoryItem? _findTeleportIdStep(StoryItem item, String id) {
    if(item.id == id) return item;
    else if(item.children != null) {
      StoryItem? found;
      for(var child in item.children!) {
         found = _findTeleportIdStep(child, id);
        if(found != null) {
          break;
        }
      }
      return found;
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
      teleportToId: data["teleport_to"]
    );
    if(data["end"] != null) item.end = addEnd(data["end"]);
    if (data["more_text"] != null) {
      List<dynamic> moreTextRaw = data["more_text"];
      item.moreText = addMoreText(moreTextRaw);
    }
    item.children = [];
    List<dynamic>? children = data["children"];
    if (children != null) {
      for (Map<String, dynamic> element in children) {
        StoryItem child = convertToStoryItem(element);
        item.children!.add(child);
      }
    }
    return item;
  }
}
