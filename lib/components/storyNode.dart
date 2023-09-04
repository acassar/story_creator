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

  getColor() {
    switch (item.end) {
      case EndType.bad:
        return Colors.red.withOpacity(0.8);
      case EndType.good:
        return Colors.green.withOpacity(0.8);
      case EndType.not:
        return item.isUser ? Colors.deepOrange.withOpacity(0.5) : Colors.blue.withOpacity(0.5);
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    Color color = selected ? Colors.purple.withOpacity(0.5) : getColor();
    if (linkToSelected) {
      color = Colors.amber;
    }

    return GestureDetector(
      onDoubleTap: () => callack(item),
      onTap: () => singleClick(item),
      child: Container(
        constraints: const BoxConstraints(
          minWidth: 300,
          minHeight: 125,
          maxWidth: 500,
        ),
        decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(10))),
        child: Container(
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
              color: color,
              borderRadius: const BorderRadius.all(Radius.circular(10))),
          child: Column(
            children: [
              Text(
                item.text,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
