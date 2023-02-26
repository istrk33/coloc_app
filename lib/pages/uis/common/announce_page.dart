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
                                bottomLeft: Radius.circular(2),
                                bottomRight: Radius.circular(2)),
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
                        /*Container(
                          height: 30,
                          alignment: Alignment.topLeft,
                          margin: const EdgeInsets.fromLTRB(5, 2, 0, 0),
                          child: Text(
                            currentAnnounce?['title'],
                            style: const TextStyle(
                                color: Color.fromARGB(255, 0, 0, 0),
                                fontWeight: FontWeight.bold,
                                fontSize: 24),
                          ),
                        ),*/
                        Container(
                          height: 75,
                          alignment: Alignment.center,
                          margin: const EdgeInsets.fromLTRB(5, 5, 0, 0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                currentAnnounce?['title'],
                                style: const TextStyle(
                                    color: Color.fromARGB(255, 0, 0, 0),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 24),
                              ),
                              Padding(
                                padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                                child: Text(
                                  "${currentAnnounce!['price']}\u{20AC}",
                                  style: const TextStyle(
                                    color: MyTheme.blue3,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          height: 50,
                          alignment: Alignment.centerLeft,
                          margin: const EdgeInsets.fromLTRB(5, 10, 0, 0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              buildButton(context, currentAnnounce['max_roomates'].toString(), 'Colocataires'),
                              buildDivider(),
                              buildButton(context, "${currentAnnounce['deposit_amount']}\u{20AC}", 'Caution'),
                              buildDivider(),
                              buildButton(context, '3', 'Chambres'),
                            ],
                          ),
                        ),
                        Divider(color: Colors.black),
                        Container(
                          height: 25,
                          margin: const EdgeInsets.fromLTRB(0, 0, 0, 5),
                          alignment: Alignment.center,
                          child: const SingleChildScrollView(
                            child: Text(
                              "Description",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                    color: Color.fromARGB(255, 0, 0, 0),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 24),
                            ),
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

  Widget buildDivider() => Container(
        height: 24,
        child: VerticalDivider(),
      );

  Widget buildButton(BuildContext context, String value, String text) =>
      MaterialButton(
        padding: EdgeInsets.symmetric(vertical: 4),
        onPressed: () {},
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Text(
              value,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: MyTheme.blue3),
            ),
            SizedBox(height: 2),
            Text(
              text,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      );
}
