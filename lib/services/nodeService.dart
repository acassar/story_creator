import 'package:story_creator/models/storyItem.dart';

class NodeService {
  StoryItem? selectedNode;
  StoryItem? linkToSelection;
  bool isLinkingTo = false;

  selectNode(StoryItem item) {
    item == selectedNode ? selectedNode = null : selectedNode = item;
  }
}
