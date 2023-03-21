import 'package:coloc_app/pages/uis/tenant/task.dart';
import 'package:coloc_app/themes/color.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

FirebaseAuth auth = FirebaseAuth.instance;
FirebaseFirestore firestore = FirebaseFirestore.instance;
final User? currentUser = auth.currentUser;

class HouseShare extends StatefulWidget {
  final DocumentReference idProperty;
  final String idAnnounce;

  HouseShare({Key? key, required this.idProperty, required this.idAnnounce})
      : super(key: key);

  @override
  _HouseShare createState() => _HouseShare();
}

class _HouseShare extends State<HouseShare> {
  Future<void>? imgUrlFuture;
  String imgUrl = "";
  String title = "";
  String id = "";
  void initState() {
    imgUrlFuture = _loadPropertyData();
    id = currentUser!.uid;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // Material App
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      // Scaffold Widget
      home: Scaffold(
        body: FutureBuilder(
          future: imgUrlFuture,
          builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              // Afficher une barre de progression pendant que la page se charge
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              // Afficher un message d'erreur s'il y a une erreur
              return Center(
                  child: Text('Une erreur est survenue : ${snapshot.error}'));
            } else {
              // Afficher la page si tout va bien
              return DefaultTabController(
                length: 2,
                child: Column(
                  children: <Widget>[
                    Material(
                      color: Color.fromARGB(255, 255, 255, 255),
                      child: TabBar(
                        tabs: [
                          Tab(
                              icon: Icon(Icons.home_filled,
                                  color: MyTheme.blue1)),
                          Tab(icon: Icon(Icons.task, color: MyTheme.blue1)),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: TabBarView(
                        children: [
                          HouseShare(),
                          TaskList(),
                        ],
                      ),
                    )
                  ],
                ),
              );
            }
          },
        ),
      ),
    );
  }

  Widget HouseShare() {
    return Scaffold(
        body: SingleChildScrollView(
            child:
                Column(mainAxisAlignment: MainAxisAlignment.start, children: [
      Container(
        height: 300,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: NetworkImage(
              imgUrl,
            ),
            fit: BoxFit.cover,
          ),
        ),
      ),
      Center(
        child: Text(
          title,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      Divider(
        indent: 24,
        endIndent: 24,
      ),
      Center(
        child: Text(
          'Les colocataires',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('application')
            .where('id_announce',
                isEqualTo: FirebaseFirestore.instance
                    .doc('/announce/' + widget.idAnnounce))
            .snapshots(),
        builder:
            (BuildContext context, AsyncSnapshot<QuerySnapshot> taskSnapshot) {
          if (!taskSnapshot.hasData) {
            return CircularProgressIndicator();
          }
          final List<Map<String, dynamic>> data = [];

          return FutureBuilder(
            future: Future.forEach(taskSnapshot.data!.docs, (taskDoc) async {
              final idCandidate = taskDoc['id_candidate'] as DocumentReference;
              final candidateSnapshot = await idCandidate.get();
              final candidateData =
                  candidateSnapshot.data() as Map<String, dynamic>;

              if (taskDoc['state'] == "accepted") {
                data.add({
                  'state': taskDoc['state'] as String,
                  'candidate_name': candidateData['first_last_name'] as String,
                });
              }
            }),
            builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Text('Une erreur est survenue : ${snapshot.error}');
              } else {
                return ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: data.length,
                  itemBuilder: (BuildContext context, int index) {
                    final itemData = data[index];
                    return Container(
                      padding: EdgeInsets.only(left: 10, right: 5, top: 10),
                      decoration: BoxDecoration(),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 25,
                            backgroundImage: NetworkImage(
                              'https://www.pngitem.com/pimgs/m/504-5040528_empty-profile-picture-png-transparent-png.png',
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  itemData['candidate_name'] as String,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              }
            },
          );
        },
      )
    ])));
  }

  Widget TaskList() {
    final DateFormat formatter = DateFormat('dd/MM/yyyy');
    return Scaffold(
      body: SingleChildScrollView(
          child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('task')
            .where('id_announce',
                isEqualTo: FirebaseFirestore.instance
                    .doc('/announce/' + widget.idAnnounce))
            .snapshots(),
        builder:
            (BuildContext context, AsyncSnapshot<QuerySnapshot> taskSnapshot) {
          if (!taskSnapshot.hasData) {
            return CircularProgressIndicator();
          }
          final List<Map<String, dynamic>> data = [];

          return FutureBuilder(
            future: Future.forEach(taskSnapshot.data!.docs, (taskDoc) async {
              data.add({
                'title': taskDoc['task_name'] as String,
                'description': taskDoc['task_description'] as String,
                'end_date': taskDoc['task_end_date']
              });
            }),
            builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Text('Une erreur est survenue : ${snapshot.error}');
              } else {
                return ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: data.length,
                  itemBuilder: (BuildContext context, int index) {
                    final itemData = data[index];
                    Timestamp date = itemData['end_date'];

                    return Column(
  children: [
    ListTile(
      contentPadding: EdgeInsets.fromLTRB(5, 5, 5, 5),
      tileColor: Color.fromARGB(255, 39, 105, 191),
      title: Text(
        itemData['title'],
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 18,
          color: Colors.white,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            itemData['description'],
            style: TextStyle(fontSize: 12, color: Colors.white),
          ),
          SizedBox(height: 5),
          Text(
            formatter.format(date.toDate()),
            style: TextStyle(fontWeight: FontWeight.bold),
            textAlign: TextAlign.right,
          ),
        ],
      ),
    ),
   const SizedBox(height: 5,)
  ],
);

                  },
                );
              }
            },
          );
        },
      )),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    TaskManagement(idAnnounce: widget.idAnnounce)),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _loadPropertyData() async {
    DocumentSnapshot documentSnapshot = await widget.idProperty.get();
    if (documentSnapshot.exists) {
      Map<String, dynamic>? data =
          documentSnapshot.data() as Map<String, dynamic>?;
      imgUrl = data!['imageUrl1'];
      title = data['property_name'];
    }
  }
}
