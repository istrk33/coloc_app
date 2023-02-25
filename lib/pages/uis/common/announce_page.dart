import 'package:coloc_app/themes/color.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

FirebaseAuth auth = FirebaseAuth.instance;
FirebaseFirestore firestore = FirebaseFirestore.instance;
final User? currentUser = auth.currentUser;

class AnnouncePage extends StatelessWidget {
  final String announceId;
  final String announceTitle;

  // receive data from the FirstScreen as a parameter
  AnnouncePage(
      {Key? key, required this.announceId, required this.announceTitle})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: Text(announceTitle),
          backgroundColor: MyTheme.blue3,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back,
                color: Color.fromARGB(255, 255, 255, 255)),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: Container(
          child: ListView(
            children: [
              StreamBuilder<DocumentSnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('announce')
                      .doc(announceId)
                      .snapshots(),
                  builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                    if (!snapshot.hasData) {
                      return Text("Chargement");
                    }
                    var currentAnnounce = snapshot.data;
                    return ListView(
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      children: <Widget>[
                        Container(
                          height: 250,
                          child: ClipRRect(
                            borderRadius: const BorderRadius.only(
                                bottomLeft: Radius.circular(8),
                                bottomRight: Radius.circular(8)),
                            child: Container(
                              height: 125,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image:
                                      NetworkImage(currentAnnounce?['img_url']),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Container(
                          height: 65,
                          alignment: Alignment.center,
                          margin: const EdgeInsets.fromLTRB(0, 2, 0, 0),
                          child: Text(
                            currentAnnounce?['title'],
                            style: const TextStyle(
                                color: Color.fromARGB(255, 0, 0, 0),
                                fontWeight: FontWeight.bold,
                                fontSize: 25),
                          ),
                        ),
                        Container(
                          height: 400,
                          margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                          alignment: Alignment.center,
                          child: SingleChildScrollView(
                            child: Text(
                              currentAnnounce?['description'],
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Color.fromARGB(255, 0, 0, 0),
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  }),
            ],
          ),
        ),
      ),
    );
  }
}
