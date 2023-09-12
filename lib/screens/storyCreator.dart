import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:story_creator/components/storyNodeComponent.dart';
import 'package:story_creator/components/toolBar.dart';
import 'package:story_creator/models/storyEdge.dart';
import 'package:story_creator/models/story.dart';
import 'package:story_creator/models/storyItem.dart';
import 'package:story_creator/services/nodeServiceProvider.dart';
import 'package:story_creator/services/storyServiceProvider.dart';
import 'package:story_creator/services/validationService.dart';
import 'package:uuid/uuid.dart';

import 'package:graphview/GraphView.dart';

class StoryCreator extends StatefulWidget {
  const StoryCreator({super.key});

  @override
  State<StoryCreator> createState() => _StoryCreatorState();
}

class _StoryCreatorState extends State<StoryCreator> {
  SugiyamaConfiguration builder = SugiyamaConfiguration();
  String defaultFileName = "example";

  @override
  void initState() {
    super.initState();
  }

  void loadStory(StoryServiceProvider storyService) async {
    storyService.loadStory(defaultFileName);
  }

  StoryItem findNode(String id, StoryServiceProvider storyServiceProvider) {
    return storyServiceProvider.currentStory!.items
        .firstWhere((element) => element.id == id);
  }

  nodeClickCallback(StoryItem item) {
    Provider.of<NodeServiceProvider>(context, listen: false).selectNode(item);
  }

  setLinkToSelection(StoryItem item) {
    Provider.of<NodeServiceProvider>(context, listen: false).selectLinkTo(item);
  }

  longClickedNode(StoryItem item) {
    Provider.of<NodeServiceProvider>(context, listen: false)
        .setLongClickedNode(item);
  }

  updateNodeErrors() {
    StoryServiceProvider storyServiceProvider =
        Provider.of<StoryServiceProvider>(context);
    NodeServiceProvider nodeServiceProvider =
        Provider.of<NodeServiceProvider>(context, listen: false);
    ValidationService validationService =
        ValidationService(storyServiceProvider, nodeServiceProvider);

    for (var item in storyServiceProvider.currentStory!.items) {
      try {
        validationService.validate(item);
      } catch (error) {
        item.nodeInError = error.toString();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<StoryServiceProvider>(
        builder: (context, storyService, child) {
      if (storyService.currentStory == null) {
        storyService.loadStory(defaultFileName);
        return const LinearProgressIndicator();
      }
      return Column(
        children: [
          Toolbar(
            defaultFileName: defaultFileName,
          ),
          Flexible(
            child: InteractiveViewer(
                transformationController:
                    storyService.initTransformationController(),
                constrained: false,
                boundaryMargin: const EdgeInsets.all(double.infinity),
                minScale: 0.01,
                maxScale: 5.6,
                child: Column(
                  children: [
                    Consumer<NodeServiceProvider>(
                        builder: (context, nodeService, child) {
                      updateNodeErrors();
                      return GraphView(
                        animated: true,
                        graph: storyService.graph,
                        algorithm: SugiyamaAlgorithm(builder),
                        paint: Paint()
                          ..color = Colors.green
                          ..strokeWidth = 1
                          ..style = PaintingStyle.stroke,
                        builder: (Node node) {
                          // I can decide what widget should be shown here based on the id
                          var id = node.key!.value;
                          return StoryNodeComponent(
                            item: findNode(id, storyService),
                            callack: nodeClickCallback,
                            longClickedNodeCallback: longClickedNode,
                            key: Key(id),
                            selected: nodeService.selectedNode?.id == id,
                            linkToSelected:
                                nodeService.linkToSelection?.id == id,
                            singleClick: setLinkToSelection,
                          );
                        },
                      );
                    }),
                  ],
                )),
          ),
        ],
      );
    });
  }
}
