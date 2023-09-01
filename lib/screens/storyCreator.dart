import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:story_creator/components/storyNode.dart';
import 'package:story_creator/models/edge.dart';
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
  //TODO: keep only the graph as truth source and remove any modification on the story at every step, but at the end
  Story? story;
  Graph graph = Graph()..isTree = true;
  SugiyamaConfiguration builder = SugiyamaConfiguration();
  TextEditingController textController = TextEditingController();
  TextEditingController choiceTextController = TextEditingController();
  TextEditingController fileNameController =
      TextEditingController(text: "example");
  List<String> error = [];

  @override
  void initState() {
    super.initState();
    loadStory();
  }

  void loadStory() async {
    Story s = await storyService.loadStory(fileNameController.text);
    story = s;
    graph = Graph()..isTree = true;
    graph.addNode(Node.Id(s.items[0].id));
    s.edges.forEach((element) {
      graph.addEdge(Node.Id(element.from), Node.Id(element.to));
    });
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

  createNode() {
    String id = const Uuid().v4();
    while (isIdExist(id)) {
      id = const Uuid().v4();
    }
    NodeService nodeService = Provider.of<NodeService>(context, listen: false);
    StoryItem newItem = StoryItem.createFromForm(
        id: id,
        text: textController.text,
        choiceText: choiceTextController.text);
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

  addError(String error) async {
    setState(() {
      this.error.add(error);
    });
    await Future.delayed(const Duration(seconds: 10));
    setState(() {
      if (this.error.length == 1) {
        this.error.clear();
      } else {
        this.error = this.error.sublist(1);
      }
    });
  }

  removeLink() {
    NodeService nodeService = Provider.of<NodeService>(context, listen: false);
    List<StoryEdge> edges = getLinkedNodeEdges();
    if (edges.isNotEmpty) {
      Node fromNode = graph.getNodeUsingId(nodeService.selectedNode!.id);
      Node toNode = graph.getNodeUsingId(nodeService.linkToSelection!.id);
      Edge? edge = graph.getEdgeBetween(fromNode, toNode);
      setState(() {
        if (edge == null) {
          addError(
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
      stdout.write("must have at least one active edge");
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

  switchRemovingEdge() {
    NodeService nodeService = Provider.of<NodeService>(context, listen: false);
    nodeService.removeEdgeButtonClicked(removeLink);
  }

  removeNode() {
    NodeService nodeService = Provider.of<NodeService>(context, listen: false);
    String selectedNodeID = nodeService.selectedNode!.id;
    if (story!.edges.any(
      (element) => element.from == selectedNodeID,
    )) {
      addError("Make sure there is no child to that node before removing it");
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

  @override
  Widget build(BuildContext context) {
    if (story == null) return const Placeholder();
    return Container(
      child: Column(
        children: [
          Container(
            // height: 100,
            decoration: const BoxDecoration(color: Colors.black12),
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                Text(
                  error.join("\n"),
                  style: const TextStyle(color: Colors.red),
                ),
                Consumer<NodeService>(builder: (context, nodeService, child) {
                  return Text(
                      "choice to: ${nodeService.selectedNode?.id ?? "nothing"}");
                }),
                Consumer<NodeService>(builder: (context, nodeService, child) {
                  return Row(
                    children: [
                      Expanded(
                        child: Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          alignment: WrapAlignment.spaceBetween,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Column(
                                  children: [
                                    const Text(
                                        "text (press enter to add new text chunks => will be inserted in \"more text\")"),
                                    Container(
                                      width: 400,
                                      margin: const EdgeInsets.all(5),
                                      color: Colors.black26,
                                      child: TextField(
                                        controller: textController,
                                        maxLines: 3,
                                      ),
                                    ),
                                  ],
                                ),
                                Column(
                                  children: [
                                    const Text("choice text"),
                                    Container(
                                      width: 400,
                                      margin: const EdgeInsets.all(5),
                                      color: Colors.black26,
                                      child: TextField(
                                        controller: choiceTextController,
                                        maxLines: 3,
                                      ),
                                    ),
                                  ],
                                ),
                                MaterialButton(
                                  onPressed: nodeService.selectedNode != null
                                      ? createNode
                                      : null,
                                  child: Container(
                                      padding: const EdgeInsets.all(5),
                                      decoration: const BoxDecoration(
                                          color: Colors.blue,
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(10))),
                                      child: const Text("submit")),
                                ),
                              ],
                            ),
                            Wrap(
                              runSpacing: 10,
                              children: [
                                MaterialButton(
                                  onPressed: nodeService.selectedNode != null
                                      ? swicthLinkTo
                                      : null,
                                  child: Container(
                                      padding: const EdgeInsets.all(5),
                                      decoration: BoxDecoration(
                                          color: nodeService.isLinkingTo
                                              ? Colors.amber
                                              : Colors.blue,
                                          borderRadius: const BorderRadius.all(
                                              Radius.circular(10))),
                                      child: Text(nodeService.isLinkingTo
                                          ? "submit link"
                                          : "link to")),
                                ),
                                MaterialButton(
                                  onPressed: nodeService.selectedNode != null
                                      ? switchRemovingEdge
                                      : null,
                                  child: Container(
                                      padding: const EdgeInsets.all(5),
                                      decoration: BoxDecoration(
                                          color: nodeService.isRemovingEdge
                                              ? Colors.amber
                                              : Colors.blue,
                                          borderRadius: const BorderRadius.all(
                                              Radius.circular(10))),
                                      child: Text(nodeService.isRemovingEdge
                                          ? "submit remove edge"
                                          : "Remove edge")),
                                ),
                                MaterialButton(
                                  onPressed: nodeService.selectedNode != null
                                      ? removeNode
                                      : null,
                                  child: Container(
                                      padding: const EdgeInsets.all(5),
                                      decoration: const BoxDecoration(
                                          color: Colors.red,
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(10))),
                                      child: Text(nodeService.isRemovingEdge
                                          ? "submit remove"
                                          : "Remove (warning: no confirmation)")),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Column(
                                  children: [
                                    const Text("File"),
                                    Row(
                                      children: [
                                        SizedBox(
                                          width: 200,
                                          child: TextField(
                                            controller: fileNameController,
                                          ),
                                        ),
                                        MaterialButton(
                                          onPressed: loadStory,
                                          child: const Text("✔️"),
                                        )
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ],
                  );
                })
              ],
            ),
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
      ),
    );
  }
}
