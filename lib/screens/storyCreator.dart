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
  Story? example;
  final Graph graph = Graph()..isTree = true;
  SugiyamaConfiguration builder = SugiyamaConfiguration();
  TextEditingController textController = TextEditingController();
  TextEditingController choiceTextController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadStory();
  }

  void loadStory() async {
    Story s = await storyService.loadGraphStory();
    setState(() {
      example = s;
      s.edges.forEach((element) {
        graph.addEdge(Node.Id(element.from), Node.Id(element.to));
      });
    });
  }

  StoryItem findNode(String id) {
    return example!.items.firstWhere((element) => element.id == id);
  }

  nodeClickCallback(StoryItem item) {
    // setState(() {});
    Provider.of<NodeService>(context, listen: false).selectNode(item);
  }

  createNode() {
    String id = const Uuid().v4();
    NodeService nodeService = Provider.of<NodeService>(context, listen: false);
    setState(() {
      example!.items.add(StoryItem(id, textController.text,
          choiceText: choiceTextController.text));
      example!.edges.add(StoryEdge(nodeService.selectedNode!.id, id));
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
    return example!.edges.where((element) => element.to == linked.id).toList();
  }

  removeLink() {
    NodeService nodeService = Provider.of<NodeService>(context, listen: false);
    List<StoryEdge> edges = getLinkedNodeEdges();
    if(edges.isNotEmpty)
    {
      setState(() {
        example!.edges.remove(edges.firstWhere((element) => element.from == nodeService.selectedNode!.id)); //removing wanted edge
        Node fromNode = graph.getNodeUsingId(nodeService.selectedNode!.id);
        Node toNode = graph.getNodeUsingId(nodeService.linkToSelection!.id);
        Edge? edge = graph.getEdgeBetween(fromNode, toNode);
        graph.removeEdge(edge!);
      });
    }
    else {
      stdout.write("must have at least one active edge");
    }
  }

  addLink() {
    NodeService nodeService = Provider.of<NodeService>(context, listen: false);
    example!.edges
        .add(StoryEdge(nodeService.selectedNode!.id, nodeService.linkToSelection!.id));
    graph.addEdge(
        Node.Id(nodeService.selectedNode!.id), Node.Id(nodeService.linkToSelection!.id));
  }

  swicthLinkTo() {
    NodeService nodeService = Provider.of<NodeService>(context, listen: false);
    nodeService.linkToButtonClicked(addLink);    
  }

  switchRemovingEdge() {
    NodeService nodeService = Provider.of<NodeService>(context, listen: false);
    nodeService.removeEdgeButtonClicked(removeLink);    
  }

  @override
  Widget build(BuildContext context) {
    if (example == null) return const Placeholder();
    return Container(
      child: Column(
        children: [
          Container(
            // height: 100,
            decoration: const BoxDecoration(color: Colors.black12),
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                Consumer<NodeService>(builder: (context, nodeService, child) {
                  return Text("choice to: ${nodeService.selectedNode?.id ?? "nothing"}");
                }),
                Consumer<NodeService>(builder: (context, nodeService, child) {
                  return Row(
                    children: [
                      Column(
                        children: [
                          const Text("text"),
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
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10))),
                            child: const Text("submit")),
                      ),
                      MaterialButton(
                        onPressed: nodeService.selectedNode != null
                            ? swicthLinkTo
                            : null,
                        child: Container(
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                                color: nodeService.isLinkingTo ? Colors.amber :Colors.blue,
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(10))),
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
                                color: nodeService.isRemovingEdge ? Colors.amber :Colors.blue,
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(10))),
                            child: Text(nodeService.isRemovingEdge
                                ? "submit remove edge"
                                : "Remove edge")),
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
                              linkToSelected: nodeService.linkToSelection?.id == id,
                              singleClick: setLinkToSelection,
                            );
                          },
                        );
                      }
                    ),
                  ],
                )),
          ),
        ],
      ),
    );
  }
}
