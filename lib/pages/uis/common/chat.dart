import 'package:coloc_app/themes/color.dart';
import 'package:flutter/material.dart';

class Chat extends StatelessWidget {
  const Chat({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Material App
    return  MaterialApp(
      debugShowCheckedModeBanner: false,
      // Scaffold Widget
      home: Scaffold(
        body: DefaultTabController(
            length: 2,
            child: Column(
              children: const <Widget>[
                Material(
                    color: Color.fromARGB(255, 255, 255, 255),
                    child: TabBar(
                      tabs: [
                        Tab(icon: Icon(Icons.message,color: MyTheme.blue1)),
                        Tab(icon: Icon(Icons.notifications,color: MyTheme.blue1)),
                      ],
                    )),
                Expanded(
                  flex: 1,
                  child: TabBarView(
                    children: [
                      Icon(Icons.message),
                      Icon(Icons.notifications),
                    ],
                  ),
                )
              ],
            ))
      ),
    );
  }
}
