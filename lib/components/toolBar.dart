import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:story_creator/services/nodeServiceProvider.dart';
import 'package:story_creator/services/storyServiceProvider.dart';

class Toolbar extends StatefulWidget {
  final String defaultFileName;

  const Toolbar({super.key, required this.defaultFileName});

  @override
  State<Toolbar> createState() => _ToolbarState();
}

class _ToolbarState extends State<Toolbar> {
  TextEditingController textController = TextEditingController();
  TextEditingController choiceTextController = TextEditingController();
  TextEditingController fileNameController = TextEditingController();
  TextEditingController minutesDelayController =
      TextEditingController(text: "0");
  List<String> error = [];
  List<DropdownMenuItem> dropdownItems = [
    const DropdownMenuItem(
      value: "not",
      child: Text("not"),
    ),
    const DropdownMenuItem(
      value: "good",
      child: Text("good"),
    ),
    const DropdownMenuItem(
      value: "bad",
      child: Text("bad"),
    ),
  ];
  String? endTypeSelected;

  onEndTypeSelect(dynamic value) {
    setState(() {
      endTypeSelected = value;
    });
  }

  @override
  void initState() {
    super.initState();
    fileNameController.text = widget.defaultFileName;
    onEndTypeSelect("not");
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

  void createNode(
      StoryServiceProvider storyService, NodeServiceProvider nodeService) {
    storyService.createNode(textController.text, endTypeSelected!,
        minutesDelayController.text, false, nodeService.selectedNode!);
    nodeService.selectNode(null);
  }

  void updateNode(
      StoryServiceProvider storyService, NodeServiceProvider nodeService) {
    storyService.updateNode(textController.text, endTypeSelected!,
        minutesDelayController.text, false, nodeService.selectedNode!);
    nodeService.clear();
  }

  void switchLinkTo(StoryServiceProvider storyServiceProvider,
      NodeServiceProvider nodeServiceProvider) {
    if (nodeServiceProvider.isLinkingTo &&
        nodeServiceProvider.linkToSelection != null) {
      storyServiceProvider.addLink(nodeServiceProvider.selectedNode!,
          nodeServiceProvider.linkToSelection!);
      nodeServiceProvider.clear();
    } else {
      nodeServiceProvider.activateLinkTo();
    }
  }

  void switchRemovingEdge(StoryServiceProvider storyServiceProvider,
      NodeServiceProvider nodeServiceProvider) {
    if (nodeServiceProvider.isRemovingEdge &&
        nodeServiceProvider.linkToSelection != null) {
      try {
        storyServiceProvider.removeLink(nodeServiceProvider.selectedNode!,
            nodeServiceProvider.linkToSelection!);
      } catch (error) {
        addError(error.toString());
      }
      nodeServiceProvider.clear();
    } else {
      nodeServiceProvider.activateRemoveEdge();
    }
  }

  void removeNode(StoryServiceProvider storyServiceProvider, NodeServiceProvider nodeServiceProvider) {
    storyServiceProvider.removeNode(nodeServiceProvider.selectedNode!);
      nodeServiceProvider.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // height: 100,
      decoration: const BoxDecoration(color: Colors.black12),
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          Text(
            error.join("\n"),
            style: const TextStyle(color: Colors.red),
          ),
          Consumer<NodeServiceProvider>(builder: (context, nodeService, child) {
            return Text(
                "choice to: ${nodeService.selectedNode?.id ?? "nothing"}");
          }),
          Consumer<NodeServiceProvider>(builder: (context, nodeService, child) {
            return Row(
              children: [
                Expanded(
                  child: Wrap(
                    crossAxisAlignment: WrapCrossAlignment.start,
                    alignment: WrapAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
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
                                  Column(
                                    children: [
                                      const Text("End type"),
                                      DropdownButton(
                                          items: dropdownItems,
                                          onChanged: onEndTypeSelect,
                                          value: endTypeSelected),
                                    ],
                                  ),
                                  Column(
                                    children: [
                                      Consumer<StoryServiceProvider>(builder:
                                          (context, storyService, child) {
                                        return Container(
                                          margin:
                                              const EdgeInsets.only(bottom: 10),
                                          child: MaterialButton(
                                            onPressed:
                                                nodeService.selectedNode != null
                                                    ? () => createNode(
                                                        storyService,
                                                        nodeService)
                                                    : null,
                                            child: Container(
                                                padding:
                                                    const EdgeInsets.all(5),
                                                decoration: const BoxDecoration(
                                                    color: Colors.blue,
                                                    borderRadius:
                                                        BorderRadius.all(
                                                            Radius.circular(
                                                                10))),
                                                child:
                                                    const Text("new choice")),
                                          ),
                                        );
                                      }),
                                      Consumer<StoryServiceProvider>(builder:
                                          (context, storyService, child) {
                                        return MaterialButton(
                                          onPressed:
                                              nodeService.selectedNode != null
                                                  ? () => updateNode(
                                                      storyService, nodeService)
                                                  : null,
                                          child: Container(
                                              padding: const EdgeInsets.all(5),
                                              decoration: const BoxDecoration(
                                                  color: Colors.blue,
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(10))),
                                              child: const Text("update node")),
                                        );
                                      }),
                                    ],
                                  ),
                                ],
                              ),
                              Row(
                                // mainAxisSize: MainAxisSize.min,
                                children: [
                                  Column(
                                    children: [
                                      const Text(
                                          "Minutes delay before display"),
                                      Container(
                                        width: 100,
                                        margin: const EdgeInsets.all(5),
                                        color: Colors.black26,
                                        child: TextField(
                                          inputFormatters: <TextInputFormatter>[
                                            FilteringTextInputFormatter
                                                .digitsOnly
                                          ],
                                          keyboardType: TextInputType.number,
                                          controller: minutesDelayController,
                                          maxLines: 1,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Consumer<StoryServiceProvider>(
                              builder: (context, storyService, child) {
                            return Wrap(
                              runSpacing: 10,
                              children: [
                                MaterialButton(
                                  onPressed: nodeService.selectedNode != null
                                      ? () => switchLinkTo(
                                          storyService, nodeService)
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
                                      ? () => switchRemovingEdge(storyService, nodeService)
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
                                      ? () => removeNode(storyService, nodeService)
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
                            );
                          }),
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Consumer<StoryServiceProvider>(
                                    builder: (context, storyService, child) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
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
                                        onPressed: () =>  storyService.loadStory(fileNameController.text),
                                        child: const Text("Load"),
                                      )
                                    ],
                                  ),
                                  Container(
                                    margin: const EdgeInsets.all(10),
                                    child: Row(
                                      children: [
                                        Container(
                                          margin: const EdgeInsets.only(right: 10),
                                          child: MaterialButton(
                                            onPressed: () => storyService.loadStory(fileNameController.text),
                                            color: Colors.red,
                                            child: const Text("Reset to last save"),
                                          ),
                                        ),
                                        MaterialButton(
                                          onPressed: () => storyService.saveStory(fileNameController.text),
                                          color: Colors.green,
                                          child: const Text("Save"),
                                        )
                                      ],
                                    ),
                                  ),
                                  if (fileNameController.text != "")
                                    Text(
                                        "last save: ${storyService.getLastSave(fileNameController.text)}"),
                                ],
                              );
                            }
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
    );
  }
}
