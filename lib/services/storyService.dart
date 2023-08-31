import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:story_creator/models/story.dart';

class StoryService {
  Future<Story> loadStory() async {
    Map<String, dynamic> storyMap = await _readFile("example");
    Story example = Story("example", storyMap);
    return example;
  }

  Future<Map<String, dynamic>> _readFile(String name) async {
    final String response =
        await rootBundle.loadString('stories/$name/$name.json');
    return jsonDecode(response);
  }
}