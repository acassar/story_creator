import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:story_creator/models/story.dart';

class StoryService {
  String folderName = "example";
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

  String getLastSave(String fileName) {
    String path = "stories/$folderName/$fileName.json";
    return File(path).lastModifiedSync().toIso8601String();
  }

  void saveStory(Story story, String fileName) {
    String path = "stories/$folderName/$fileName.json";
    File(path).writeAsStringSync("""
{
  "nodes": [
    ${story.items.map((element) => element.toJson()).join(",")}
  ],
  "edges": [
    ${story.edges.map((element) => element.toJson()).join(",")}
  ]
}
""");
  }

  Future<Story> loadStory(String name) async {
    Map<String, dynamic> storyMap = await _readFile(folderName, name);
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
