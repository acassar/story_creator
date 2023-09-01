import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:story_creator/models/story.dart';

class StoryService {
  String defaultFileContent = """
{
  "nodes": [
    {
      "id": "start",
      "text": "Story start"
    }
  ],
  "edges": [

  ]
}
""";

  Future<Story> loadStory(String name) async {
    Map<String, dynamic> storyMap = await _readFile("example", name);
    Story story = Story(name, storyMap);
    return story;
  }

  Future<Map<String, dynamic>> _readFile(
      String folderName, String fileName) async {
    String path = "stories/$folderName/$fileName.json";

    bool exist = await File(path).exists();
    File file = File(path);
    if (!exist) {
      await file.writeAsString(defaultFileContent);
    }
    final String response = await file.readAsString();
    return jsonDecode(response);
  }
}
