import 'package:flutter/material.dart';
import 'package:story_creator/models/storyEdge.dart';
import 'package:story_creator/models/storyItem.dart';
import 'package:story_creator/services/storyServiceProvider.dart';
import 'package:story_creator/services/validationService.dart';

abstract class ValidationRules {
  final StoryServiceProvider storyService;
  final StoryItem item;
  String title;
  String description;

  ValidationRules({
    required this.title,
    required this.description,
    required this.storyService,
    required this.item,
  });

  void validate();
}

class SiblingValidation extends ValidationRules {
  final List<StoryItem> parents;
  SiblingValidation(StoryServiceProvider storyService, this.parents,
      {required super.item})
      : super(
            title: "Sibling validation",
            description:
                'Make sure that only one character text exists, and less than 4 of user texts. Also make sure that none of them exists with the other one at the same level',
            storyService: storyService);

  @override
  void validate() {
    for (StoryItem parent in parents) {
      List<StoryItem> siblings = [];
      List<StoryEdge> from = storyService.getEdgesFromSourceToOther(parent);
      ValidationService.fillChildren(siblings, from, storyService);
      if (siblings.length > 1) {
        if (!item.isUser) {
          throw ErrorDescription(
              "You can't add a character text when there is other texts at the same level");
        } else {
          if (siblings.length > 4) {
            throw ErrorDescription(
                "You can't add more than 4 choices to a node");
          }
          if (siblings.any((element) => !element.isUser)) {
            throw ErrorDescription(
                "You can't add a choice when there is already a character text at the same level");
          }
        }
      }
    }
  }
}

class NoNodeAfterEnd extends ValidationRules {
  final List<StoryItem> parents;
  final List<StoryItem> children;
  NoNodeAfterEnd(
      {required super.storyService,
      required super.item,
      required this.parents,
      required this.children})
      : super(
            title: "No node after end",
            description: "Make sure that no node exists after an end");

  @override
  void validate() {
    if (parents.any((element) => element.end != EndType.not) ||
        (children.isNotEmpty && item.end != EndType.not)) {
      throw ErrorDescription("An end can't have children");
    }
  }
}
