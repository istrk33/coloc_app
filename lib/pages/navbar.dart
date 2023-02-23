import 'package:coloc_app/pages/profile.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:flutter/cupertino.dart';
import 'home.dart';
import 'chat.dart';
import 'Maps/map.dart';
import 'profileTest.dart';

class Navbar extends StatefulWidget {
  const Navbar({Key? key}) : super(key: key);

  @override
  State<Navbar> createState() => _NavbarState();

  _NavbarState? getState() => _NavbarState._state;
}

class _NavbarState extends State<Navbar> {
  int _selectedIndex = 0;
  final List<GButton> menuItemsColoc = [
    const GButton(
      icon: Icons.home,
      text: 'Home',
    ),
    const GButton(
      icon: Icons.map,
      text: 'Carte',
    ),
    const GButton(
      icon: Icons.chat_bubble,
      text: 'Messagerie',
    ),
    const GButton(
      icon: Icons.people,
      text: 'Profile',
    ),
  ];
  final List<GButton> menuItemsProp = [
    const GButton(
      icon: Icons.other_houses,
      text: 'Propriétés',
    ),
    const GButton(
      icon: Icons.monetization_on,
      text: 'Paiements en attente',
    ),
    const GButton(
      icon: Icons.chat_bubble,
      text: 'Messagerie',
    ),
    const GButton(
      icon: Icons.people,
      text: 'Profile',
    ),
  ];
  static const TextStyle optionStyle =
      TextStyle(fontSize: 30, fontWeight: FontWeight.w600);
  static List<Widget> _widgetOptions = <Widget>[
    Home(),
    MyMap(),
    Chat(),
    ProfilePage()
  ];

  late List<GButton> _currentMenuItems;
  @override
  void initState() {
    super.initState();
    _currentMenuItems = menuItemsColoc;
    _state = this;
  }

  static _NavbarState? _state;

  void updateMenuItems() {
    setState(() {
      if (ProfilMode.getIsOwnerMode()) {
        _currentMenuItems = menuItemsProp;
      } else {
        _currentMenuItems = menuItemsColoc;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('ColocApp'),
          backgroundColor: Color.fromARGB(255, 45, 101, 144),
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                blurRadius: 20,
                color: Colors.black.withOpacity(.1),
              )
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8),
              child: GNav(
                rippleColor: Colors.grey[300]!,
                hoverColor: Colors.grey[100]!,
                gap: 8,
                activeColor: Color.fromARGB(255, 45, 101, 144),
                iconSize: 24,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                duration: Duration(milliseconds: 400),
                tabBackgroundColor: Colors.grey[100]!,
                color: Colors.black,
                tabs: _currentMenuItems,
                selectedIndex: _selectedIndex,
                onTabChange: (index) {
                  setState(() {
                    _selectedIndex = index;
                  });
                },
              ),
            ),
          ),
        ),
        body: Center(
          child: _widgetOptions.elementAt(_selectedIndex),
        ),
      ),
    );
  }
}
