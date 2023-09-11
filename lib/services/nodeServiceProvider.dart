import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:story_creator/components/storyNodeComponent.dart';
import 'package:story_creator/models/storyItem.dart';

class NodeServiceProvider extends ChangeNotifier {
  StoryItem? selectedNode;
  StoryItem? linkToSelection;
  bool isLinkingTo = false;
  bool isRemovingEdge = false;
  StoryItem? longClickedNode;

  void setLongClickedNode(StoryItem item) {
    longClickedNode = item;
    notifyListeners();
  }
  
  selectNode(StoryItem? item) {
    if (item == selectedNode) {
      item = null;
    }
    clear();
    selectedNode = item;
    notifyListeners();
  }

  activateRemoveEdge() {
    isRemovingEdge = true;
    notifyListeners();
  }

  deactivateRemoveEdge() {
    isRemovingEdge = false;
    notifyListeners();
  }

  activateLinkTo() {
    isLinkingTo = true;
    notifyListeners();
  }

  deactivateLinkTo() {
    isLinkingTo = false;
    notifyListeners();
  }

  selectLinkTo(StoryItem? item) {
    if (item == linkToSelection) {
      linkToSelection = null;
      deactivateLinkTo();
      deactivateRemoveEdge();
    }
    if ((isLinkingTo || isRemovingEdge) && item != selectedNode) {
      linkToSelection = item;
      notifyListeners();
    }
  }

  void clear() {
    linkToSelection = null;
    selectedNode = null;
    longClickedNode = null;
    deactivateLinkTo();
    deactivateRemoveEdge();
  }
}
