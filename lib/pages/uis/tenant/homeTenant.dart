import 'package:coloc_app/pages/uis/common/profile.dart';
import 'package:coloc_app/themes/color.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:flutter/cupertino.dart';

class HomeTenant extends StatelessWidget {
  const HomeTenant({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.all(15.0),
            child: CupertinoSearchTextField(
              placeholder: 'Rechercher',
            ),
          ),
          StreamBuilder<QuerySnapshot>(
            stream:
                FirebaseFirestore.instance.collection("announce").snapshots(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
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
                        color: MyTheme.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 0.5,
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          Container(
                            margin: const EdgeInsets.fromLTRB(20, 10, 0, 0),
                            alignment: Alignment.topLeft,
                            child: Text(
                              snap[index]['__title'],
                              style: const TextStyle(
                                color: Colors.black54,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.fromLTRB(20, 30, 50, 0),
                            alignment: Alignment.topLeft,
                            child: Text(
                              '-'+snap[index]['description'].substring(0,150)+'...',
                              style: const TextStyle(
                                color: Colors.black54,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.only(right: 15),
                            alignment: Alignment.centerRight,
                            child: Text(
                              snap[index]['price'].toString() + "\u{20AC}",
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
    );
  }
}
