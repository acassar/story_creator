import 'dart:convert';

import 'package:flutter/material.dart';

enum EndType { bad, good, not }

class StoryItem {
  String id;
  String text;
  EndType end;
  int minutesToWait;
  bool isUser;

  StoryItem(
    this.id,
    this.text, {
    required this.end,
    this.isUser = false,
    this.minutesToWait = 0
  });

  static createFromForm(
      {required String id,
      required String text,
      required String minutesDelay,
      required bool isUser,
      String? end}) {
    return StoryItem(id, text,
        isUser: isUser, end: end != null ? stringToEndType(end) : EndType.not, minutesToWait: int.parse(minutesDelay));
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

  String toJson() {
    return """
  {
    "id": "$id",
    "text": "$text",
    "end": "${endTypeToString(end) ?? "not"}",
    "minutes_to_wait": "$minutesToWait",
    "is_user": "$isUser"
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
