import 'dart:convert';
import 'dart:io';

import 'package:story_creator/models/story.dart';
import 'package:story_creator/models/storyItem.dart';

class StoryService {
  String folderName = "example";
  StoryItem defaultFileContent = StoryItem("start", "Story start",
      end: EndType.not, isUser: false, minutesToWait: 0);

  String getLastSave(String fileName) {
    String path = "stories/$folderName/$fileName.json";
    return File(path).lastModifiedSync().toIso8601String();
  }

  void saveStory(Story story, String fileName) {
    String path = "stories/$folderName/$fileName.json";
    writeFile(story.items.map((element) => element.toJson()).join(","),
        story.edges.map((element) => element.toJson()).join(","), path);
  }

  void writeFile(nodes, edges, path) {
    File(path).writeAsStringSync("""
{
  "nodes": [
    ${nodes}
  ],
  "edges": [
    ${edges}
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
      writeFile(defaultFileContent.toJson(), "", path);
    }
    final String response = await file.readAsString();
    return jsonDecode(response);
  }
}
