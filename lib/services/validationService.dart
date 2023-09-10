import 'package:flutter/material.dart';
import 'package:story_creator/models/storyEdge.dart';
import 'package:story_creator/models/storyItem.dart';
import 'package:story_creator/services/nodeServiceProvider.dart';
import 'package:story_creator/services/storyServiceProvider.dart';

class ValidationService {
  final StoryServiceProvider storyService;
  final NodeServiceProvider nodeService;

  ValidationService(this.storyService, this.nodeService);

  bool validate(StoryItem item) {
    List<StoryEdge> from = storyService.getEdgesFromSourceToOther(item);
    List<StoryEdge> to = storyService.getEdgesFromOtherToSource(item);
    List<StoryItem> childrenItems = [];
    List<StoryItem> parentItems = [];

    fillChildren(childrenItems, from);

    fillParents(parentItems, to);
    validateNoSiblingForCharacterTextAnd4UserChoiceMax(item, parentItems);
    //TODO
    return true;
  }

  fillChildren(List<StoryItem> items, List<StoryEdge> from) {
    for (StoryEdge edge in from) {
      items.add(storyService.currentStory!.items
          .firstWhere((element) => element.id == edge.to));
    }
    return items;
  }

  fillParents(List<StoryItem> items, List<StoryEdge> to) {
    for (StoryEdge edge in to) {
      items.add(storyService.currentStory!.items
          .firstWhere((element) => element.id == edge.from));
    }
    return items;
  }

  /// Ensure that two nodes representing a character chat exists at the same level (a node can't have two child of that type)
  bool validateNoSiblingForCharacterTextAnd4UserChoiceMax(
      StoryItem item, List<StoryItem> parents) {
    for (StoryItem parent in parents) {
      List<StoryItem> siblings = [];
      List<StoryEdge> from = storyService.getEdgesFromSourceToOther(parent);
      fillChildren(siblings, from);
      if (siblings.length > 1) {
        if (!item.isUser) {
          throw ErrorDescription(
              "You can't add a character text when there is other texts at the same level");
        } else {
          if (siblings.length > 4) {
            throw ErrorDescription(
                "You can't add more than 4 choices to a node");
          }
          if(siblings.any((element) => !element.isUser))
          {
            throw ErrorDescription(
                "You can't add a choice when there is already a character text at the same level");
          }
        }
      }
    }
    return true;
  }
}
