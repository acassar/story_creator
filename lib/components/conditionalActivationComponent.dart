import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:story_creator/components/toolBar.dart';
import 'package:story_creator/models/storyItem.dart';
import 'package:story_creator/services/nodeServiceProvider.dart';
import 'package:story_creator/services/storyServiceProvider.dart';

class ConditionalActivationComponent extends StatefulWidget {
  const ConditionalActivationComponent({super.key});

  @override
  State<ConditionalActivationComponent> createState() =>
      _ConditionalActivationComponentState();
}

class _ConditionalActivationComponentState
    extends State<ConditionalActivationComponent> {
  final double inputWidth = 200;
  TextEditingController activatedByKeyController = TextEditingController();
  TextEditingController activatedByValueController = TextEditingController();
  TextEditingController activateKeyController = TextEditingController();
  TextEditingController activateValueController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  void clearForm () {
    activateKeyController.clear();
    activateValueController.clear();
    activatedByKeyController.clear();
    activatedByValueController.clear();
  }

  void setConditionalActivation(NodeServiceProvider nodeServiceProvider) {
    var activation = ConditionalActivation(
        activatedByKey: activatedByKeyController.text,
        activatedByValue: activatedByValueController.text,
        activateKey: activateKeyController.text,
        activateValue: activateValueController.text);

    StoryServiceProvider storyServiceProvider =
        Provider.of<StoryServiceProvider>(context, listen: false);
        storyServiceProvider.setConditionalActivation(nodeServiceProvider.selectedNode!, activation);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NodeServiceProvider>(
        builder: (context, nodeServiceProvider, child) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Column(
            children: [
              Container(
                width: inputWidth,
                margin: const EdgeInsets.all(5),
                child: TextField(
                  decoration:
                      Toolbar.getInputDecoration("Activated By key", Icons.key),
                  keyboardType: TextInputType.text,
                  controller: activatedByKeyController,
                  maxLines: 1,
                ),
              ),
              Container(
                width: inputWidth,
                margin: const EdgeInsets.all(5),
                child: TextField(
                  decoration: Toolbar.getInputDecoration(
                      "Activated By value", Icons.keyboard_alt_outlined),
                  keyboardType: TextInputType.text,
                  controller: activatedByValueController,
                  maxLines: 1,
                ),
              ),
            ],
          ),
          Column(
            children: [
              Container(
                width: inputWidth,
                margin: const EdgeInsets.all(5),
                child: TextField(
                  decoration:
                      Toolbar.getInputDecoration("Activate key", Icons.key),
                  keyboardType: TextInputType.text,
                  controller: activateKeyController,
                  maxLines: 1,
                ),
              ),
              Container(
                width: inputWidth,
                margin: const EdgeInsets.all(5),
                child: TextField(
                  decoration: Toolbar.getInputDecoration(
                      "Activate value", Icons.keyboard_alt_outlined),
                  keyboardType: TextInputType.text,
                  controller: activateValueController,
                  maxLines: 1,
                ),
              ),
            ],
          ),
          Column(
            children: [
              CustomButton(
                  disabled: false,
                  callback: clearForm,
                  text: "Clear form",
                  color: Colors.redAccent),
              CustomButton(
                  disabled: nodeServiceProvider.selectedNode == null,
                  callback: () => setConditionalActivation(nodeServiceProvider),
                  text: "Set",
                  color: Colors.blueAccent)
            ],
          )
        ],
      );
    });
  }
}