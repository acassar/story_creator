import 'dart:convert';

import 'package:flutter/material.dart';

enum EndType { bad, good, not }

class StoryItem {
  String id;
  String text;
  List<String> moreText;
  String choiceText;
  EndType end;
  int minutesToWait;

  StoryItem(
    this.id,
    this.text, {
    required this.choiceText,
    required this.end,
    required this.moreText,
    this.minutesToWait = 0
  });

  static createFromForm(
      {required String id,
      required String text,
      required String choiceText,
      String? end}) {
    List<String> formatedText = text.split("\n");
    List<String> moreText = formatedText.sublist(1);
    moreText.removeWhere(
      (element) => element == "",
    );
    return StoryItem(id, formatedText[0],
        choiceText: choiceText, moreText: moreText.isEmpty ? [] : moreText, end: end != null ? stringToEndType(end) : EndType.not);
  }

  _getMoreTextString() {
    String s = moreText == ""
        ? "\n -${moreText.map((e) => "$e").join("\n- ")}"
        : "none";
    return s;
  }

  String? _getMoreTextJson() {
    return moreText.isNotEmpty ? "[\n\"${moreText!.join("\",\n\"")}\"\n]" : "[]";
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
    "choice_text": "$choiceText",
    "end": "${endTypeToString(end) ?? "not"}",
    "more_text": ${_getMoreTextJson()}
  }
""";
  }

  @override
  String toString() {
    return """
    ⌚ Show after (minutes): $minutesToWait⌚
    🆔 Id: $id 🆔
    💭 Text: $text 💭
    📲 Choice text: $choiceText 📲
    📋 More Text: ${_getMoreTextString()} 📋
  """;
  }
}
