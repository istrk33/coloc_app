import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'platformMap.dart';
import 'navigatorMap.dart';

class MyMap extends StatefulWidget {
  @override
  _MyMapState createState() => _MyMapState();
}

class _MyMapState extends State<MyMap> {
  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return Scaffold(body: MyNavigatorMap());
    } else {
      return Scaffold(body: MyPlatformMap());
    }
  }
}
