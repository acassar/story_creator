import 'package:flutter/material.dart';
import 'package:story_creator/models/storyItem.dart';

class StoryNode extends StatelessWidget {
  final StoryItem item;
  final dynamic callack;
  final dynamic singleClick;
  final bool selected;
  const StoryNode({super.key, required this.item, required this.callack, required this.selected, required this.singleClick});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTap: () => callack(item),
      onTap: () => singleClick(item),
      child: Container(
        padding: const EdgeInsets.all(5),
        decoration:  BoxDecoration(
          color: selected ? Colors.green : Colors.blue,
          borderRadius: const BorderRadius.all(Radius.circular(10))
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