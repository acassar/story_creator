import 'package:flutter/material.dart';
import 'package:story_creator/models/storyEdge.dart';
import 'package:story_creator/models/storyItem.dart';
import 'package:story_creator/services/nodeServiceProvider.dart';
import 'package:story_creator/services/storyServiceProvider.dart';
import 'package:story_creator/services/validationRules/validationRules.dart';

class ValidationService {
  final StoryServiceProvider storyService;
  final NodeServiceProvider nodeService;

  ValidationService(this.storyService, this.nodeService);

  bool validate(StoryItem item) {
    List<StoryEdge> from = storyService.getEdgesFromSourceToOther(item);
    List<StoryEdge> to = storyService.getEdgesFromOtherToSource(item);
    List<StoryItem> childrenItems = [];
    List<StoryItem> parentItems = [];
    List<ValidationRules> rules = [
      SiblingValidation(storyService, parentItems, item: item),
      NoNodeAfterEnd(storyService: storyService, item: item, parents: parentItems, children: childrenItems),
    ];

    fillChildren(childrenItems, from, storyService);

    fillParents(parentItems, to, storyService);
    for (var element in rules) {
      element.validate();
    }
    return true;
  }

  static void fillChildren(List<StoryItem> items, List<StoryEdge> from,
      StoryServiceProvider storyServiceProvider) {
    for (StoryEdge edge in from) {
      items.add(storyServiceProvider.currentStory!.items
          .firstWhere((element) => element.id == edge.to));
    }
  }

  static void fillParents(List<StoryItem> items, List<StoryEdge> to,
      StoryServiceProvider storyServiceProvider) {
    for (StoryEdge edge in to) {
      items.add(storyServiceProvider.currentStory!.items
          .firstWhere((element) => element.id == edge.from));
    }
  }
}
