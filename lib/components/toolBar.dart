import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:graphview/GraphView.dart';
import 'package:provider/provider.dart';
import 'package:story_creator/components/storyNode.dart';
import 'package:story_creator/models/storyEdge.dart';
import 'package:story_creator/models/storyItem.dart';
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
  bool isUserSpeaking = false;
  double secondaryInputWidth = 140;
  Color inputColor = const Color(0xFF6200EE);

  getInputDecoration(String label, IconData icon) {
    return InputDecoration(
      suffixIcon: Icon(icon),
      labelText: label,
      labelStyle: TextStyle(
        color: inputColor,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        borderSide: BorderSide(
          color: inputColor,
        ),
      ),
    );
  }

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

  bool validate(StoryServiceProvider storyService,
      NodeServiceProvider nodeService, StoryItem item) {
    List<StoryEdge> from = storyService.getEdgesFromSourceToOther(item);
    List<StoryEdge> to = storyService.getEdgesFromOtherToSource(item);
    List<StoryItem> childrenItems = [];
    List<StoryItem> parentItems = [];

    for (StoryEdge edge in from) {
      childrenItems.add(storyService.currentStory!.items
          .firstWhere((element) => element.id == edge.to));
    }
    for (StoryEdge edge in to) {
      parentItems.add(storyService.currentStory!.items
          .firstWhere((element) => element.id == edge.from));
    }
    //TODO
    return true;
  }

  void createNode(
      StoryServiceProvider storyService, NodeServiceProvider nodeService) {
    StoryItem newItem = StoryItem.createFromForm(
        id: storyService.getNewId(),
        text: textController.text,
        isUser: isUserSpeaking,
        end: endTypeSelected,
        minutesDelay: minutesDelayController.text);
    storyService.createNode(newItem, nodeService.selectedNode!);
    nodeService.selectNode(null);
    if (!validate(storyService, nodeService, newItem)) {
      storyService.removeNode(newItem);
      addError("Please provide a valid item");
    }
  }

  void updateNode(
      StoryServiceProvider storyService, NodeServiceProvider nodeService) {
    StoryItem itemToUpdate = storyService.getItem(nodeService.selectedNode!.id);
    var saveText = itemToUpdate.text,
        saveEnd = itemToUpdate.end,
        saveDelay = itemToUpdate.minutesToWait,
        saveIsUser = itemToUpdate.isUser;

    storyService.updateNode(textController.text, endTypeSelected!,
        minutesDelayController.text, isUserSpeaking, nodeService.selectedNode!);

    if (!validate(storyService, nodeService, nodeService.selectedNode!)) {
      storyService.updateNode(saveText, saveEnd.name, saveDelay.toString(),
          saveIsUser, nodeService.selectedNode!);
      addError("Please provide a valid item");
    }
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

  void removeNode(StoryServiceProvider storyServiceProvider,
      NodeServiceProvider nodeServiceProvider) {
    try {
      storyServiceProvider.removeNode(nodeServiceProvider.selectedNode!);
      nodeServiceProvider.clear();
    } catch (error) {
      addError(error.toString());
    }
  }

  void isUserSpeakingChange(bool? isSpeaking) {
    setState(() {
      isUserSpeaking = isSpeaking ?? false;
    });
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
                "node selected: ${nodeService.selectedNode?.id ?? "nothing"}");
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
                          Card(
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
                                      Column(
                                        children: [
                                          Container(
                                            width: 400,
                                            margin: const EdgeInsets.all(5),
                                            child: TextField(
                                              decoration: getInputDecoration(
                                                  "content",
                                                  Icons.textsms_rounded),
                                              controller: textController,
                                              maxLines: 5,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Column(
                                        children: [
                                          Column(
                                            children: [
                                              SizedBox(
                                                width: secondaryInputWidth,
                                                child: DropdownButtonFormField(
                                                    decoration: getInputDecoration(
                                                        "End type",
                                                        Icons
                                                            .account_tree_sharp),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                    padding:
                                                        const EdgeInsets.all(5),
                                                    items: dropdownItems,
                                                    focusColor:
                                                        Colors.transparent,
                                                    onChanged: onEndTypeSelect,
                                                    value: endTypeSelected),
                                              ),
                                            ],
                                          ),
                                          Container(
                                            width: secondaryInputWidth,
                                            margin: const EdgeInsets.all(5),
                                            child: TextField(
                                              decoration: getInputDecoration(
                                                  "Minutes delay", Icons.timer),
                                              inputFormatters: <TextInputFormatter>[
                                                FilteringTextInputFormatter
                                                    .digitsOnly
                                              ],
                                              keyboardType:
                                                  TextInputType.number,
                                              controller:
                                                  minutesDelayController,
                                              maxLines: 1,
                                            ),
                                          ),
                                          Column(
                                            children: [
                                              Container(
                                                  width: secondaryInputWidth,
                                                  margin:
                                                      const EdgeInsets.all(5),
                                                  child: CheckboxListTile(
                                                    title: Text(
                                                      "Choice",
                                                      style: TextStyle(
                                                        color: inputColor,
                                                      ),
                                                    ),
                                                    value: isUserSpeaking,
                                                    onChanged:
                                                        isUserSpeakingChange,
                                                  )),
                                            ],
                                          ),
                                        ],
                                      ),
                                      Container(
                                        padding: const EdgeInsets.all(20),
                                        child: Column(
                                          children: [
                                            Consumer<StoryServiceProvider>(
                                                builder: (context, storyService,
                                                    child) {
                                              return CustomButton(
                                                color: inputColor,
                                                text: "Create node",
                                                disabled:
                                                    nodeService.selectedNode ==
                                                        null,
                                                callback: () => createNode(
                                                    storyService, nodeService),
                                              );
                                            }),
                                            Consumer<StoryServiceProvider>(
                                                builder: (context, storyService,
                                                    child) {
                                              return CustomButton(
                                                color: const Color(0xff5DA9E9),
                                                text: "Update node",
                                                disabled:
                                                    nodeService.selectedNode ==
                                                        null,
                                                callback: () => updateNode(
                                                    storyService, nodeService),
                                              );
                                            }),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
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
                                      ? () => switchRemovingEdge(
                                          storyService, nodeService)
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
                                      ? () =>
                                          removeNode(storyService, nodeService)
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
                                      onPressed: () => storyService
                                          .loadStory(fileNameController.text),
                                      child: const Text("Load"),
                                    )
                                  ],
                                ),
                                Container(
                                  margin: const EdgeInsets.all(10),
                                  child: Row(
                                    children: [
                                      Container(
                                        margin:
                                            const EdgeInsets.only(right: 10),
                                        child: MaterialButton(
                                          onPressed: () =>
                                              storyService.loadStory(
                                                  fileNameController.text),
                                          color: Colors.red,
                                          child:
                                              const Text("Reset to last save"),
                                        ),
                                      ),
                                      MaterialButton(
                                        onPressed: () => storyService
                                            .saveStory(fileNameController.text),
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
                          }),
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

class CustomButton extends StatelessWidget {
  final bool disabled;
  final dynamic callback;
  final String text;
  final Color color;
  const CustomButton(
      {super.key,
      required this.disabled,
      required this.callback,
      required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(10),
      child: MaterialButton(
        disabledColor: Colors.grey,
        color: color,
        shape: const ContinuousRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        onPressed: !disabled ? callback : null,
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: const BoxDecoration(
              // color: Colors.blue,
              borderRadius: BorderRadius.all(Radius.circular(10))),
          child: Text(text, style: const TextStyle(color: Colors.white),),
        ),
      ),
    );
    ;
  }
}
