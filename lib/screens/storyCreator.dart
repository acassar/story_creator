import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:story_creator/components/storyNode.dart';
import 'package:story_creator/components/toolBar.dart';
import 'package:story_creator/models/storyEdge.dart';
import 'package:story_creator/models/story.dart';
import 'package:story_creator/models/storyItem.dart';
import 'package:story_creator/services/nodeService.dart';
import 'package:story_creator/services/storyService.dart';
import 'package:uuid/uuid.dart';

import 'package:graphview/GraphView.dart';

class StoryCreator extends StatefulWidget {
  const StoryCreator({super.key});

  @override
  State<StoryCreator> createState() => _StoryCreatorState();
}

class _StoryCreatorState extends State<StoryCreator> {
  StoryService storyService = StoryService();
  Story? story;
  Graph graph = Graph()..isTree = true;
  SugiyamaConfiguration builder = SugiyamaConfiguration();
  String defaultFileName = "example";

  @override
  void initState() {
    super.initState();
    loadStory(defaultFileName);
  }

  void loadStory(String fileName) async {
    Story s = await storyService.loadStory(fileName);
    story = s;
    graph = Graph()..isTree = true;
    graph.addNode(Node.Id(s.items[0].id));
    for (var element in s.edges) {
      graph.addEdge(Node.Id(element.from), Node.Id(element.to));
    }
    setState(() {});
  }

  void saveStory(String fileName) {
    storyService.saveStory(story!, fileName);
    setState(() {});
  }

  StoryItem findNode(String id) {
    return story!.items.firstWhere((element) => element.id == id);
  }

  nodeClickCallback(StoryItem item) {
    // setState(() {});
    Provider.of<NodeService>(context, listen: false).selectNode(item);
  }

  bool isIdExist(String id) {
    return story!.items.any((element) => element.id == id);
  }

  createNode(String text, String choiceText, String endTypeSelected, String minutesDelay) {
    String id = const Uuid().v4();
    while (isIdExist(id)) {
      id = const Uuid().v4();
    }
    NodeService nodeService = Provider.of<NodeService>(context, listen: false);
    StoryItem newItem = StoryItem.createFromForm(
        id: id, text: text, choiceText: choiceText, end: endTypeSelected, minutesDelay: minutesDelay);
    setState(() {
      story!.items.add(newItem);
      story!.edges.add(StoryEdge(nodeService.selectedNode!.id, id));
      graph.addEdge(Node.Id(nodeService.selectedNode!.id), Node.Id(id));
      nodeService.selectNode(null);
    });
  }

  setLinkToSelection(StoryItem item) {
    NodeService nodeService = Provider.of<NodeService>(context, listen: false);
    nodeService.selectLinkTo(item);
  }

  List<StoryEdge> getLinkedNodeEdges() {
    NodeService nodeService = Provider.of<NodeService>(context, listen: false);
    StoryItem linked = nodeService.linkToSelection!;
    return story!.edges.where((element) => element.to == linked.id).toList();
  }

  removeLink(dynamic errorCallback) {
    NodeService nodeService = Provider.of<NodeService>(context, listen: false);
    List<StoryEdge> edges = getLinkedNodeEdges();
    if (edges.isNotEmpty) {
      Node fromNode = graph.getNodeUsingId(nodeService.selectedNode!.id);
      Node toNode = graph.getNodeUsingId(nodeService.linkToSelection!.id);
      Edge? edge = graph.getEdgeBetween(fromNode, toNode);
      setState(() {
        if (edge == null) {
          errorCallback(
              "Select a correct edge (select first the parent, then the child. Make sure that there also is an active edge)");
        } else {
          story!.edges.remove(edges.firstWhere((element) =>
              element.from ==
              nodeService
                  .selectedNode!.id)); //removing wanted edge in the story
          graph.removeEdge(edge); //removing it from the graph
        }
      });
    } else {
      errorCallback(
              "Select a correct edge (select first the parent, then the child. Make sure that there also is an active edge)");
    }
  }

  addLink() {
    NodeService nodeService = Provider.of<NodeService>(context, listen: false);
    story!.edges.add(StoryEdge(
        nodeService.selectedNode!.id, nodeService.linkToSelection!.id));
    graph.addEdge(Node.Id(nodeService.selectedNode!.id),
        Node.Id(nodeService.linkToSelection!.id));
  }

  swicthLinkTo() {
    NodeService nodeService = Provider.of<NodeService>(context, listen: false);
    nodeService.linkToButtonClicked(addLink);
  }

  switchRemovingEdge(dynamic errorCallback) {
    NodeService nodeService = Provider.of<NodeService>(context, listen: false);
    nodeService.removeEdgeButtonClicked(removeLink, errorCallback);
  }

  removeNode(dynamic errorCallback) {
    NodeService nodeService = Provider.of<NodeService>(context, listen: false);
    String selectedNodeID = nodeService.selectedNode!.id;
    if (story!.edges.any(
      (element) => element.from == selectedNodeID,
    )) {
      errorCallback(
          "Make sure there is no child to that node before removing it");
    } else {
      graph.removeNode(graph.getNodeUsingId(selectedNodeID));
      story!.items.removeWhere(
          (element) => element.id == selectedNodeID); // removing this node
      story!.edges.removeWhere((element) =>
          element.to ==
          selectedNodeID); //removing all edges that have this node as destination
      nodeService.clear();
    }
  }

  updateNode(String text, String choiceText, String endTypeSelected, String minutesDelay) {
    NodeService nodeService = Provider.of<NodeService>(context, listen: false);
    StoryItem item = story!.items
        .firstWhere((element) => element.id == nodeService.selectedNode!.id);
    item.text = text;
    item.choiceText = choiceText;
    item.end = StoryItem.stringToEndType(endTypeSelected);
    item.minutesToWait = int.parse(minutesDelay);
    nodeService.clear();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (story == null) return const Placeholder();
    return Column(
      children: [
        Toolbar(
          createNode: createNode,
          defaultFileName: defaultFileName,
          loadStory: loadStory,
          removeNode: removeNode,
          saveStory: saveStory,
          storyService: storyService,
          swicthLinkTo: swicthLinkTo,
          switchRemovingEdge: switchRemovingEdge,
          updateNode: updateNode,
        ),
        Flexible(
          child: InteractiveViewer(
              constrained: false,
              boundaryMargin: const EdgeInsets.all(double.infinity),
              minScale: 0.01,
              maxScale: 5.6,
              child: Column(
                children: [
                  Consumer<NodeService>(
                      builder: (context, nodeService, child) {
                    return GraphView(
                      graph: graph,
                      algorithm: SugiyamaAlgorithm(builder),
                      paint: Paint()
                        ..color = Colors.green
                        ..strokeWidth = 1
                        ..style = PaintingStyle.stroke,
                      builder: (Node node) {
                        // I can decide what widget should be shown here based on the id
                        var id = node.key!.value;
                        return StoryNode(
                          item: findNode(id),
                          callack: nodeClickCallback,
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
  }
}
