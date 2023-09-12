import 'package:flutter/material.dart';
import 'package:graphview/GraphView.dart';
import 'package:story_creator/models/storyItem.dart';

class StoryNodeComponent extends StatelessWidget {
  final StoryItem item;
  final dynamic callack;
  final dynamic singleClick;
  final bool selected;
  final bool linkToSelected;
  final dynamic longClickedNodeCallback;
  const StoryNodeComponent({
    super.key,
    required this.item,
    required this.callack,
    required this.selected,
    required this.singleClick,
    required this.linkToSelected,
    required this.longClickedNodeCallback,
  });

  getColor() {
    switch (item.nodeType) {
      case NodeType.bad:
        return Colors.red.withOpacity(0.8);
      case NodeType.good:
        return Colors.green.withOpacity(0.8);
      case NodeType.text:
        return Colors.blue.withOpacity(0.5);
      case NodeType.choice:
        return Colors.deepOrange.withOpacity(0.5);
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
      onLongPress: () => longClickedNodeCallback(item),
      child: Container(
        constraints: const BoxConstraints(
          minWidth: 300,
          minHeight: 125,
          maxWidth: 500,
        ),
        child: Stack(
          children: [
            Container(
              constraints: const BoxConstraints(
                minWidth: 300,
                minHeight: 125,
                maxWidth: 500,
              ),
              clipBehavior: Clip.antiAlias,
              decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.all(Radius.circular(10))),
              child: Container(
                decoration: BoxDecoration(
                    color: color,
                    borderRadius: const BorderRadius.all(Radius.circular(10))),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(5),
                      child: Text(
                        item.text,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            color: Colors.black,
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    if (item.minutesToWait > 0)
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(5),
                              color: Colors.black.withOpacity(0.4),
                              child: Wrap(
                                crossAxisAlignment: WrapCrossAlignment.center,
                                alignment: WrapAlignment.center,
                                spacing: 10,
                                children: [
                                  const Icon(
                                    Icons.access_time_rounded,
                                    color: Colors.white,
                                  ),
                                  Text(
                                    "Delay: ${item.minutesToWait}",
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 25),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    if (item.hasCondition())
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(5),
                              color: Colors.pink,
                              child: Wrap(
                                crossAxisAlignment: WrapCrossAlignment.center,
                                alignment: WrapAlignment.center,
                                spacing: 10,
                                children: [
                                  const Icon(
                                    Icons.auto_awesome_sharp,
                                    color: Colors.white,
                                  ),
                                  Text(
                                    "Can be chosen if : ${item.conditionalActivation.activatedByKey} = ${item.conditionalActivation.activatedByValue}",
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 25),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    if (item.hasActivation())
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(5),
                              color: Colors.purple,
                              child: Wrap(
                                crossAxisAlignment: WrapCrossAlignment.center,
                                alignment: WrapAlignment.center,
                                spacing: 10,
                                children: [
                                  const Icon(
                                    Icons.auto_awesome_sharp,
                                    color: Colors.white,
                                  ),
                                  Text(
                                    "${item.conditionalActivation.activateKey} = ${item.conditionalActivation.activateValue}",
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 25),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      )
                  ],
                ),
              ),
            ),
            if (item.nodeInError != null)
              Positioned.fill(
                child: Column(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: const BoxDecoration(
                            color: Colors.transparent,
                            borderRadius:
                                BorderRadius.all(Radius.circular(10))),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                children: [
                                  const Icon(
                                    Icons.error_outline,
                                    color: Colors.white,
                                  ),
                                  Text(
                                    "${item.nodeInError}",
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 25),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
