import 'package:flutter/material.dart';
import 'package:story_creator/models/storyItem.dart';

class StoryNode extends StatelessWidget {
  final StoryItem item;
  final dynamic callack;
  final dynamic singleClick;
  final bool selected;
  final bool linkToSelected;
  const StoryNode(
      {super.key,
      required this.item,
      required this.callack,
      required this.selected,
      required this.singleClick,
      required this.linkToSelected});

  @override
  Widget build(BuildContext context) {
    Color color = selected ? Colors.green : Colors.blue;
    if (linkToSelected) {
      color = Colors.amber;
    }

    return GestureDetector(
      onDoubleTap: () => callack(item),
      onTap: () => singleClick(item),
      child: Container(
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
            color: color,
            borderRadius: const BorderRadius.all(Radius.circular(10))),
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
