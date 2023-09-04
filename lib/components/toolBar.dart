import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:story_creator/services/nodeServiceProvider.dart';

class Toolbar extends StatefulWidget {
  final dynamic createNode;
  final dynamic updateNode;
  final dynamic removeNode;
  final dynamic swicthLinkTo;
  final dynamic switchRemovingEdge;
  final dynamic loadStory;
  final dynamic saveStory;
  final dynamic storyService;
  final String defaultFileName;

  const Toolbar(
      {super.key,
      required this.createNode,
      required this.updateNode,
      required this.removeNode,
      required this.swicthLinkTo,
      required this.switchRemovingEdge,
      required this.loadStory,
      required this.saveStory,
      required this.storyService,
      required this.defaultFileName});

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
                                      Container(
                                        margin:
                                            const EdgeInsets.only(bottom: 10),
                                        child: MaterialButton(
                                          onPressed: nodeService.selectedNode !=
                                                  null
                                              ? () => widget.createNode(
                                                    textController.text,
                                                    endTypeSelected,
                                                    minutesDelayController.text,
                                                    false,
                                                  )
                                              : null,
                                          child: Container(
                                              padding: const EdgeInsets.all(5),
                                              decoration: const BoxDecoration(
                                                  color: Colors.blue,
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(10))),
                                              child: const Text("new choice")),
                                        ),
                                      ),
                                      MaterialButton(
                                        onPressed:
                                            nodeService.selectedNode != null
                                                ? () => widget.updateNode(
                                                      textController.text,
                                                      endTypeSelected,
                                                      minutesDelayController.text,
                                                      false,
                                                    )
                                                : null,
                                        child: Container(
                                            padding: const EdgeInsets.all(5),
                                            decoration: const BoxDecoration(
                                                color: Colors.blue,
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(10))),
                                            child: const Text("update node")),
                                      ),
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
                          Wrap(
                            runSpacing: 10,
                            children: [
                              MaterialButton(
                                onPressed: nodeService.selectedNode != null
                                    ? widget.swicthLinkTo
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
                                    ? () => widget.switchRemovingEdge(addError)
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
                                    ? () => widget.removeNode(addError)
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
                          ),
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Column(
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
                                    onPressed: () => widget
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
                                      margin: const EdgeInsets.only(right: 10),
                                      child: MaterialButton(
                                        onPressed: () => widget
                                            .loadStory(fileNameController.text),
                                        color: Colors.red,
                                        child: const Text("Reset to last save"),
                                      ),
                                    ),
                                    MaterialButton(
                                      onPressed: () => widget
                                          .saveStory(fileNameController.text),
                                      color: Colors.green,
                                      child: const Text("Save"),
                                    )
                                  ],
                                ),
                              ),
                              if (fileNameController.text != "")
                                Text(
                                    "last save: ${widget.storyService.getLastSave(fileNameController.text)}"),
                            ],
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
