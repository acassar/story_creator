import 'package:flutter/material.dart';
import 'package:story_creator/models/storyItem.dart';

class NodeService extends ChangeNotifier {
  StoryItem? selectedNode;
  StoryItem? linkToSelection;
  bool isLinkingTo = false;

  selectNode(StoryItem? item) {
    if(item == selectedNode) {
      item = null;
    }
    clear();
    selectedNode = item;
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
    }
    if (isLinkingTo && item != selectedNode) {
      linkToSelection = item;
      activateLinkTo();
    }
  }

  clear() {
    linkToSelection = null;
    selectedNode = null;
    isLinkingTo = false;
    notifyListeners();
  }

  void linkToButtonClicked(callBack) {
    if (isLinkingTo && linkToSelection != null) {
      callBack();
      clear();
    } else {
      activateLinkTo();
    }
  }
}
