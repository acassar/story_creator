import 'package:flutter/material.dart';
import 'package:story_creator/models/story.dart';
import 'package:story_creator/services/storyService.dart';

class StoryCreator extends StatefulWidget {
  const StoryCreator({super.key});

  @override
  State<StoryCreator> createState() => _StoryCreatorState();
}

class _StoryCreatorState extends State<StoryCreator> {
  StoryService storyService = StoryService();
  Story? example;

@override
  void initState() {
    super.initState();
    loadStory();
  }

  void loadStory() async {
    Story s = await storyService.loadStory();
    setState(() {
      example = s;
    });
  }

  @override
  Widget build(BuildContext context) {
    if(example == null) return const Placeholder();
    return Container(
      child: Text(example!.entryPoint.text!),
    );
  }
}