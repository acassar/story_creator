import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:graphview/GraphView.dart';
import 'package:story_creator/components/storyNodeComponent.dart';
import 'package:story_creator/models/story.dart';
import 'package:story_creator/models/storyEdge.dart';
import 'package:story_creator/models/storyItem.dart';
import 'package:uuid/uuid.dart';

class StoryServiceProvider extends ChangeNotifier {
  String folderName = "example";
  StoryItem defaultFileContent = StoryItem("start", "Story start",
      end: EndType.not, isUser: false, minutesToWait: 0);
  Graph graph = Graph()..isTree = true;
  TransformationController? _transformationController;
  late Matrix4 transformationControllerDefaultValue;

  Node getNodeFromId(String id) {
    return graph.getNodeUsingId(id);
  }

  TransformationController initTransformationController() {
    _transformationController ??= TransformationController();
    transformationControllerDefaultValue = _transformationController!.value;
    return _transformationController!;
  }

  goToNode(Node node, double screenWidth, double screenHeight) {
    const zoomFactor = 0.5;
    final xTranslate = (-node.position.dx + screenWidth - 300) * zoomFactor;
    final yTranslate = (-node.position.dy + screenHeight / 2) * zoomFactor;

    _transformationController!.value.setEntry(0, 0, zoomFactor);
    _transformationController!.value.setEntry(1, 1, zoomFactor);
    _transformationController!.value.setEntry(2, 2, zoomFactor);
    _transformationController!.value.setEntry(0, 3, xTranslate);
    _transformationController!.value.setEntry(1, 3, yTranslate);
    notifyListeners();
    _transformationController!.notifyListeners();
  }

  Story? currentStory;

  String getLastSave(String fileName) {
    String path = "stories/$folderName/$fileName.json";
    return File(path).lastModifiedSync().toIso8601String();
  }

  void saveStory(String fileName) {
    String path = "stories/$folderName/$fileName.json";
    writeFile(currentStory!.items.map((element) => element.toJson()).join(","),
        currentStory!.edges.map((element) => element.toJson()).join(","), path);
    notifyListeners();
  }

  void writeFile(nodes, edges, path) {
    File(path).writeAsStringSync("""
{
  "nodes": [
    ${nodes}
  ],
  "edges": [
    ${edges}
  ]
}
""");
  }

  void loadStory(String name) async {
    Map<String, dynamic> storyMap = await _readFile(folderName, name);
    Story story = Story(name, storyMap);
    currentStory = story;
    graph = Graph()..isTree = true;
    graph.addNode(Node.Id(story.items[0].id));
    for (var element in story.edges) {
      graph.addEdge(Node.Id(element.from), Node.Id(element.to));
    }
    notifyListeners();
  }

  Future<Map<String, dynamic>> _readFile(
      String folderName, String fileName) async {
    String path = "stories/$folderName/$fileName.json";

    bool exist = await File(path).exists();
    File file = File(path);
    if (!exist) {
      writeFile(defaultFileContent.toJson(), "", path);
    }
    final String response = await file.readAsString();
    return jsonDecode(response);
  }

  bool isIdExist(String id) {
    return currentStory!.items.any((element) => element.id == id);
  }

  String getNewId() {
    String id = const Uuid().v4();
    while (isIdExist(id)) {
      id = const Uuid().v4();
    }
    return id;
  }

  StoryItem getItem(String id) {
    return currentStory!.items.firstWhere((element) => element.id == id);
  }

  createNode(StoryItem item, StoryItem selectedItem) {
    currentStory!.items.add(item);
    currentStory!.edges.add(StoryEdge(selectedItem.id, item.id));
    graph.addEdge(Node.Id(selectedItem.id), Node.Id(item.id));
    notifyListeners();
  }

  updateNode(String text, String endTypeSelected, String minutesDelay,
      bool isUser, StoryItem selectedItem) {
    StoryItem item = currentStory!.items
        .firstWhere((element) => element.id == selectedItem.id);
    item.text = text;
    item.end = StoryItem.stringToEndType(endTypeSelected);
    item.isUser = isUser;
    item.minutesToWait = int.parse(minutesDelay);
    notifyListeners();
  }

  void setConditionalActivation(StoryItem item, ConditionalActivation conditionalActivation) {
    item.conditionalActivation = conditionalActivation;
    notifyListeners();
  }

  addLink(StoryItem selectedItem, StoryItem toSelectedItem) {
    currentStory!.edges.add(StoryEdge(selectedItem.id, toSelectedItem.id));
    graph.addEdge(Node.Id(selectedItem.id), Node.Id(toSelectedItem.id));
    notifyListeners();
  }

  List<StoryEdge> getEdgesFromSourceToOther(StoryItem item) {
    return currentStory!.edges
        .where((element) => element.from == item.id)
        .toList();
  }

  List<StoryEdge> getEdgesFromOtherToSource(StoryItem item) {
    return currentStory!.edges
        .where((element) => element.to == item.id)
        .toList();
  }

  removeLink(StoryItem selectedItem, StoryItem toSelectedItem) {
    List<StoryEdge> edges = getEdgesFromOtherToSource(toSelectedItem);
    if (edges.isNotEmpty) {
      Node fromNode = graph.getNodeUsingId(selectedItem.id);
      Node toNode = graph.getNodeUsingId(toSelectedItem.id);
      Edge? edge = graph.getEdgeBetween(fromNode, toNode);
      if (edge == null) {
        throw ErrorDescription(
            "Select a correct edge (select first the parent, then the child. Make sure that there also is an active edge)");
      } else {
        currentStory!.edges.remove(edges.firstWhere((element) =>
            element.from ==
            selectedItem.id)); //removing wanted edge in the story
        graph.removeEdge(edge); //removing it from the graph
        notifyListeners();
      }
    } else {
      throw ErrorDescription(
          "Select a correct edge (select first the parent, then the child. Make sure that there also is an active edge)");
    }
  }

  removeNode(StoryItem selectedItem) {
    String selectedNodeID = selectedItem.id;
    if (currentStory!.edges.any(
      (element) => element.from == selectedNodeID,
    )) {
      throw ErrorDescription(
          "Make sure there is no child to that node before removing it");
    } else {
      graph.removeNode(graph.getNodeUsingId(selectedNodeID));
      currentStory!.items.removeWhere(
          (element) => element.id == selectedNodeID); // removing this node
      currentStory!.edges.removeWhere((element) =>
          element.to ==
          selectedNodeID); //removing all edges that have this node as destination
      notifyListeners();
    }
  }
}
