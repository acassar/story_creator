import 'package:flutter/material.dart';
import 'package:story_creator/components/storyNode.dart';
import 'package:story_creator/models/edge.dart';
import 'package:story_creator/models/story.dart';
import 'package:story_creator/models/storyItem.dart';
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
  StoryItem? selectedNode;
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
    setState(() {
      selectedNode = item;
    });
  }

  createNode() {
    String id = Uuid().v4();
    setState(() {
      example!.items.add(StoryItem(id, textController.text, choiceText: choiceTextController.text));
      example!.edges.add(StoryEdge(selectedNode!.id, id));
      graph.addEdge(Node.Id(selectedNode!.id), Node.Id(id));
      selectedNode = null;
    });
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
                Text("choice to: ${selectedNode?.id}"),
                Row(
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
                         onPressed: selectedNode != null ? createNode : null,
                          child: Container(
                            padding: const EdgeInsets.all(5),
                            decoration: const BoxDecoration(
                                color: Colors.blue,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10))),
                            child: const Text("submit")
                          ),
                        )
                  ],
                )
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
                    GraphView(
                      graph: graph,
                      algorithm: SugiyamaAlgorithm(
                          builder),
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
                        );
                      },
                    ),
                  ],
                )),
          ),
        ],
      ),
    );
  }
}
