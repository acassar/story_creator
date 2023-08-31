import 'package:flutter/material.dart';
import 'package:story_creator/models/storyItem.dart';

class StoryNode extends StatelessWidget {
  final StoryItem item;
  final dynamic callack;
  const StoryNode({super.key, required this.item, required this.callack});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTap: () => callack(item),
      child: Container(
        padding: const EdgeInsets.all(5),
        decoration: const BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.all(Radius.circular(10))
        ),
        child: Column(
          children: [
            Text("id: ${item.id}"),
            Text("choice: ${item.choiceText}"),
            Text("text: ${item.text}"),
          ],
        ),
      ),
    );
  }
}