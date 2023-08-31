import 'package:flutter/material.dart';
import 'package:story_creator/components/storyNode.dart';
import 'package:story_creator/models/story.dart';
import 'package:story_creator/models/storyItem.dart';
import 'package:story_creator/services/storyService.dart';


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
  BuchheimWalkerConfiguration builder = BuchheimWalkerConfiguration();

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


  @override
  Widget build(BuildContext context) {
    if(example == null) return const Placeholder();
    return Column(
      children: [
        Expanded(
              child: InteractiveViewer(
                  constrained: false,
                  boundaryMargin: const EdgeInsets.all(100),
                  minScale: 0.01,
                  maxScale: 5.6,
                  child: GraphView(
                    graph: graph,
                    algorithm: BuchheimWalkerAlgorithm(builder, TreeEdgeRenderer(builder)),
                    paint: Paint()
                      ..color = Colors.green
                      ..strokeWidth = 1
                      ..style = PaintingStyle.stroke,
                    builder: (Node node) {
                      // I can decide what widget should be shown here based on the id
                      var a = node.key!.value;
                      return StoryNode(item: findNode(a),);
                    },
                  )),
            ),
      ],
    );
  }
}