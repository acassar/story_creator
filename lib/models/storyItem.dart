import 'dart:convert';

import 'package:flutter/material.dart';

enum EndType { bad, good, not }

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
  EndType end;
  int minutesToWait;
  bool isUser;
  ConditionalActivation conditionalActivation;

  StoryItem(
    this.id,
    this.text, {
    required this.end,
    this.isUser = false,
    this.minutesToWait = 0,
    required this.conditionalActivation,
  });

  static createFromForm({
    required String id,
    required String text,
    required String minutesDelay,
    required bool isUser,
    String? end,
  }) {
    return StoryItem(
      id,
      text,
      isUser: isUser,
      end: end != null ? stringToEndType(end) : EndType.not,
      minutesToWait: int.parse(minutesDelay),
      conditionalActivation: ConditionalActivation(activateKey: "", activateValue: "", activatedByKey: "", activatedByValue: "")
    );
  }

  static stringToEndType(String end) {
    switch (end) {
      case "bad":
        return EndType.bad;
      case "good":
        return EndType.good;
      case "not":
        return EndType.not;
      default:
        throw ErrorDescription("End type not recognised");
    }
  }

  endTypeToString(EndType type) {
    switch (type) {
      case EndType.bad:
        return "bad";
      case EndType.good:
        return "good";
      case EndType.not:
        return "not";
      default:
        return "not";
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
    "text": "$text",
    "end": "${endTypeToString(end) ?? "not"}",
    "minutes_to_wait": "$minutesToWait",
    "is_user": "$isUser",
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
