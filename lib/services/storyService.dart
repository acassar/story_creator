import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:story_creator/models/story.dart';

class StoryService {
  Future<Story> loadGraphStory() async {
    Map<String, dynamic> storyMap = await _readFile("example", "graphExample");
    Story example = Story("example", storyMap);
    return example;
  }

  Future<Story> loadStory() async {
    Map<String, dynamic> storyMap = await _readFile("example", "example");
    Story example = Story("example", storyMap);
    return example;
  }

  Future<Map<String, dynamic>> _readFile(String folderName, String fileName) async {
    final String response =
        await rootBundle.loadString('stories/$folderName/$fileName.json');
    return jsonDecode(response);
  }
}