import 'package:flutter/material.dart';

class Chat extends StatelessWidget {
  const Chat({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Material App
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      // Scaffold Widget
      home: Scaffold(
        body: Center(child: Text('Chat')),
      ),
    );
  }
}
