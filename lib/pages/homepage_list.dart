import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:flutter/cupertino.dart';

class HomagePageList extends StatefulWidget {
  const HomagePageList({Key? key}) : super(key: key);

  @override
  State<HomagePageList> createState() => _HomagePageListState();
}

class _HomagePageListState extends State<HomagePageList> {
  int _selectedIndex = 0;
  /*
  static const TextStyle optionStyle =
      TextStyle(fontSize: 30, fontWeight: FontWeight.w600);
  static const List<Widget> _widgetOptions = <Widget>[
    Text(
      'Home',
      style: optionStyle,
    ),
    Text(
      'Likes',
      style: optionStyle,
    ),
    Text(
      'Search',
      style: optionStyle,
    ),
    Text(
      'Profile',
      style: optionStyle,
    ),
  ];*/
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('CollocApp'),
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
                tabs: [
                  GButton(
                    icon: Icons.home,
                    text: 'Home',
                  ),
                  GButton(
                    icon: Icons.map,
                    text: 'Carte',
                  ),
                  GButton(
                    icon: Icons.chat_bubble,
                    text: 'Messagerie',
                  ),
                  GButton(
                    icon: Icons.people,
                    text: 'Profile',
                  ),
                ],
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
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(15.0),
                child: CupertinoSearchTextField(
                  placeholder: 'Rechercher',
                ),
              ),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection("Announce")
                    .snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasData) {
                    final snap = snapshot.data!.docs;
                    return ListView.builder(
                      shrinkWrap: true,
                      primary: false,
                      itemCount: snap.length,
                      itemBuilder: (context, index) {
                        return Container(
                          height: 100,
                          width: double.infinity,
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black26,
                                offset: Offset(2, 2),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          child: Stack(
                            children: [
                              Container(
                                margin: const EdgeInsets.only(left: 20),
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  snap[index]['Title'],
                                  style: const TextStyle(
                                    color: Colors.black54,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Container(
                                margin: const EdgeInsets.only(right: 20),
                                alignment: Alignment.centerRight,
                                child: Text(
                                  snap[index]['Price'].toString() + "\u{20AC}",
                                  style: TextStyle(
                                    color: Colors.green.withOpacity(0.7),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  } else {
                    return const SizedBox();
                  }
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
