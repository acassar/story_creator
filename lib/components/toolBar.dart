import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:story_creator/components/conditionalActivationComponent.dart';
import 'package:story_creator/models/storyItem.dart';
import 'package:story_creator/services/nodeServiceProvider.dart';
import 'package:story_creator/services/storyServiceProvider.dart';
import 'package:story_creator/services/validationService.dart';

class Toolbar extends StatefulWidget {
  final String defaultFileName;
  static const Color inputColor = Color(0xFF6200EE);
  static const double secondaryInputWidth = 140;
  const Toolbar({super.key, required this.defaultFileName});

  static getInputDecoration(String label, IconData icon) {
    return InputDecoration(
      suffixIcon: Icon(icon),
      labelText: label,
      labelStyle: const TextStyle(
        color: inputColor,
      ),
      enabledBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)),
        borderSide: BorderSide(
          color: inputColor,
        ),
      ),
    );
  }

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
      value: "text",
      child: Text("text"),
    ),
    const DropdownMenuItem(
      value: "choice",
      child: Text("choice"),
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
  String endTypeSelected = "text";
  EdgeInsets cardPad = const EdgeInsets.all(10);
  late ValidationService validationService;

  onNodeTypeSelect(dynamic value) {
    setState(() {
      endTypeSelected = value;
    });
  }

  @override
  void initState() {
    super.initState();
    fileNameController.text = widget.defaultFileName;
    onNodeTypeSelect("text");
    WidgetsBinding.instance.addPostFrameCallback((_) => validationService =
        ValidationService(
            Provider.of<StoryServiceProvider>(context, listen: false),
            Provider.of<NodeServiceProvider>(context, listen: false)));
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
    StoryItem newItem = StoryItem.createFromForm(
      id: storyService.getNewId(),
      text: textController.text,
      nodeType: endTypeSelected,
      minutesDelay: minutesDelayController.text,
    );
    storyService.createNode(newItem, nodeService.selectedNode!);
    nodeService.selectNode(null);
    try {
      validationService.validate(newItem);
    } catch (error) {
      addError(error.toString());
      storyService.removeNode(newItem);
    }
  }

  void updateNode(
      StoryServiceProvider storyService, NodeServiceProvider nodeService) {
    StoryItem itemToUpdate = storyService.getItem(nodeService.selectedNode!.id);
    var saveText = itemToUpdate.text,
        saveEnd = itemToUpdate.nodeType,
        saveDelay = itemToUpdate.minutesToWait;

    storyService.updateNode(
      textController.text,
      endTypeSelected,
      minutesDelayController.text,
      nodeService.selectedNode!
    );

    try {
      validationService.validate(nodeService.selectedNode!);
    } catch (error) {
      addError(error.toString());
      storyService.updateNode(saveText, saveEnd.name, saveDelay.toString(),
          nodeService.selectedNode!);
    }
    nodeService.clear();
  }

  void switchLinkTo(StoryServiceProvider storyServiceProvider,
      NodeServiceProvider nodeServiceProvider) {
    if (nodeServiceProvider.isLinkingTo &&
        nodeServiceProvider.linkToSelection != null) {
      storyServiceProvider.addLink(nodeServiceProvider.selectedNode!,
          nodeServiceProvider.linkToSelection!);
      try {
        validationService.validate(nodeServiceProvider.selectedNode!);
      } catch (error) {
        addError(error.toString());
        storyServiceProvider.removeLink(nodeServiceProvider.selectedNode!,
            nodeServiceProvider.linkToSelection!);
      }
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

  void goToNode(StoryItem item, StoryServiceProvider storyServiceProvider) {
    storyServiceProvider.goToNode(
        storyServiceProvider.getNodeFromId(
          item.id,
        ),
        MediaQuery.of(context).size.width,
        MediaQuery.of(context).size.height);
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
          Consumer2<NodeServiceProvider, StoryServiceProvider>(
              builder: (context, nodeService, storyService, child) {
            return GestureDetector(
              onTap: () => nodeService.selectedNode != null
                  ? goToNode(nodeService.selectedNode!, storyService)
                  : null,
              child: Container(
                padding: const EdgeInsets.only(bottom: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("node selected: "),
                    Text(
                      nodeService.selectedNode?.text ?? "nothing",
                      style: const TextStyle(
                          color: Toolbar.inputColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 20),
                    ),
                  ],
                ),
              ),
            );
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
                              padding: cardPad,
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
                                              decoration:
                                                  Toolbar.getInputDecoration(
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
                                                width:
                                                    Toolbar.secondaryInputWidth,
                                                child: DropdownButtonFormField(
                                                    decoration: Toolbar
                                                        .getInputDecoration(
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
                                                    onChanged: onNodeTypeSelect,
                                                    value: endTypeSelected),
                                              ),
                                            ],
                                          ),
                                          Container(
                                            width: Toolbar.secondaryInputWidth,
                                            margin: const EdgeInsets.all(5),
                                            child: TextField(
                                              decoration:
                                                  Toolbar.getInputDecoration(
                                                      "Minutes delay",
                                                      Icons.timer),
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
                                                color: Toolbar.inputColor,
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
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Consumer<StoryServiceProvider>(
                              builder: (context, storyService, child) {
                            return Wrap(
                              runSpacing: 10,
                              // direction: Axis.vertical,
                              children: [
                                CustomButton(
                                  callback: () => goToNode(
                                      storyService.currentStory!.items[0],
                                      storyService),
                                  color: Colors.purple,
                                  text: "Go to first node",
                                  disabled: false,
                                ),
                                CustomButton(
                                  callback: nodeService.selectedNode != null
                                      ? () => switchLinkTo(
                                          storyService, nodeService)
                                      : null,
                                  color: nodeService.isLinkingTo
                                      ? Colors.amber
                                      : Colors.blue,
                                  text: nodeService.isLinkingTo
                                      ? "submit link"
                                      : "link to",
                                  disabled: false,
                                ),
                                CustomButton(
                                  callback: nodeService.selectedNode != null
                                      ? () => switchRemovingEdge(
                                          storyService, nodeService)
                                      : null,
                                  text: nodeService.isRemovingEdge
                                      ? "submit remove edge"
                                      : "Remove edge",
                                  color: nodeService.isRemovingEdge
                                      ? Colors.amber
                                      : Colors.blue,
                                  disabled: false,
                                ),
                                CustomButton(
                                  callback: nodeService.selectedNode != null
                                      ? () =>
                                          removeNode(storyService, nodeService)
                                      : null,
                                  text: nodeService.isRemovingEdge
                                      ? "submit remove"
                                      : "Remove (warning: no confirmation)",
                                  color: Colors.red,
                                  disabled: false,
                                ),
                              ],
                            );
                          }),
                          ConditionalActivationComponent(addError: addError),
                        ],
                      ),
                      Card(
                        child: Container(
                          padding: cardPad,
                          child: Row(
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
                                            decoration:
                                                Toolbar.getInputDecoration(
                                                    "File", Icons.file_copy),
                                            controller: fileNameController,
                                          ),
                                        ),
                                        CustomButton(
                                          callback: () =>
                                              storyService.loadStory(
                                                  fileNameController.text),
                                          text: "Load",
                                          color: Toolbar.inputColor,
                                          disabled: false,
                                        )
                                      ],
                                    ),
                                    Container(
                                      margin: const EdgeInsets.all(10),
                                      child: Row(
                                        children: [
                                          CustomButton(
                                            callback: () =>
                                                storyService.loadStory(
                                                    fileNameController.text),
                                            color: Colors.red,
                                            text: "Reset to last save",
                                            disabled: false,
                                          ),
                                          CustomButton(
                                            callback: () =>
                                                storyService.saveStory(
                                                    fileNameController.text),
                                            color: Colors.green,
                                            text: "Save",
                                            disabled: false,
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
                          ),
                        ),
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
      required this.text,
      required this.color});

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
          child: Text(
            text,
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}
