import 'package:coloc_app/pages/uis/tenant/application.dart';
import 'package:coloc_app/pages/uis/owner/MyAnnounce.dart';
import 'package:coloc_app/pages/uis/owner/homeOwner.dart';
import 'package:coloc_app/pages/uis/common/profile.dart';
import 'package:coloc_app/themes/color.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import '../tenant/homeTenant.dart';
import '../../maps/map.dart';

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
      icon: Icons.search,
      text: 'Home',
    ),
    const GButton(
      icon: Icons.map,
      text: 'Carte',
    ),
    const GButton(
      icon: Icons.home,
      text: 'Logement',
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
      icon: Icons.list_alt,
      text: 'Mes Annonces',
    ),
    const GButton(
      icon: Icons.people,
      text: 'Profile',
    ),
  ];
  static List<Widget> _widgetOptionsForColoc = <Widget>[HomeTenant(), MyMap(), Application(), ProfilePage()];
  static List<Widget> _widgetOptionsForProp = <Widget>[HomeOwner(), MyAnnounce(), ProfilePage()];

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
        setState(() {
          _selectedIndex = _selectedIndex - 1;
        });
      } else {
        _currentMenuItems = menuItemsColoc;
        setState(() {
          _selectedIndex = _selectedIndex + 1;
        });
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
          backgroundColor: MyTheme.blue3,
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: MyTheme.white,
            boxShadow: [
              BoxShadow(
                blurRadius: 20,
                color: Colors.black.withOpacity(.1),
              )
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8),
              child: GNav(
                rippleColor: Colors.grey[300]!,
                hoverColor: Colors.grey[100]!,
                gap: 8,
                activeColor: MyTheme.blue3,
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
          child: ProfilMode.getIsOwnerMode() ? _widgetOptionsForProp.elementAt(_selectedIndex) : _widgetOptionsForColoc.elementAt(_selectedIndex),
        ),
      ),
    );
  }
}
