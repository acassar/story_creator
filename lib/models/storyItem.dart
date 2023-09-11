import 'dart:convert';

import 'package:flutter/material.dart';

enum NodeType { bad, good, text, choice }

class ConditionalActivation {
  final String activatedByKey;
  final String activatedByValue;
  final String activateKey;
  final String activateValue;

  ConditionalActivation(
      {required this.activatedByKey,
      required this.activatedByValue,
      required this.activateKey,
      required this.activateValue});
}

class StoryItem {
  String id;
  String text;
  NodeType nodeType;
  int minutesToWait;
  ConditionalActivation conditionalActivation;

  StoryItem(
    this.id,
    this.text, {
    required this.nodeType,
    this.minutesToWait = 0,
    required this.conditionalActivation,
  });

  static createFromForm({
    required String id,
    required String text,
    required String minutesDelay,
    required String nodeType,
  }) {
    return StoryItem(id, text,
        nodeType: stringToNodeType(nodeType),
        minutesToWait: int.parse(minutesDelay),
        conditionalActivation: ConditionalActivation(
            activateKey: "",
            activateValue: "",
            activatedByKey: "",
            activatedByValue: ""));
  }

  static stringToNodeType(String type) {
    switch (type) {
      case "bad":
        return NodeType.bad;
      case "good":
        return NodeType.good;
      case "text":
        return NodeType.text;
      case "choice":
        return NodeType.choice;
      default:
        throw ErrorDescription("Node type not recognised");
    }
  }

  nodeTypeToString() {
    switch (nodeType) {
      case NodeType.bad:
        return "bad";
      case NodeType.good:
        return "good";
      case NodeType.text:
        return "text";
      case NodeType.choice:
        return "choice";
      default:
        return "unknown";
    }
  }

  bool hasCondition() {
    return conditionalActivation?.activatedByKey != "";
  }

  bool hasActivation() {
    return conditionalActivation?.activateKey != "";
  }

  String toJson() {
    return """
  {
    "id": "$id",
    "text": "${text.replaceAll("\n", " ")}",
    "node_type": "${nodeTypeToString()}",
    "minutes_to_wait": "$minutesToWait",
    "conditional_activation": {
      "activated_by_key": "${conditionalActivation?.activatedByKey ?? ""}",
      "activated_by_value": "${conditionalActivation?.activatedByValue ?? ""}",
      "activate_key": "${conditionalActivation?.activateKey ?? ""}",
      "activate_value": "${conditionalActivation?.activateValue ?? ""}"
    }
  }
""";
  }

  @override
  String toString() {
    return """
    ⌚ Show after (minutes): $minutesToWait⌚
    🆔 Id: $id 🆔
    💭 Text: $text 💭
  """;
  }
}
