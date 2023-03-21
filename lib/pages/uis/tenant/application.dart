import 'package:coloc_app/pages/uis/tenant/houseShare.dart';
import 'package:coloc_app/themes/color.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

FirebaseAuth auth = FirebaseAuth.instance;
FirebaseFirestore firestore = FirebaseFirestore.instance;
final User? currentUser = auth.currentUser;

class Application extends StatefulWidget {
  Application({Key? key}) : super(key: key);

  @override
  _Application createState() => _Application();
}

class _Application extends State<Application> {
  String id = "";

  void initState() {
    id = currentUser!.uid;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // Material App
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        // Scaffold Widget
        home: Scaffold(body: Applications()));
  }

  Widget Applications() {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                'Mes candidatures',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('application')
                    .where('id_candidate',
                        isEqualTo: FirebaseFirestore.instance.doc('Users/$id'))
                    .snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (!snapshot.hasData) {
                    return CircularProgressIndicator();
                  }

                  final applications = snapshot.data!.docs;
                  final List<Map<String, dynamic>> data = [];

                  return FutureBuilder(
                    future: Future.forEach(applications, (application) async {
                      final idAnnounce =
                          application['id_announce'] as DocumentReference;
                      final announceSnapshot = await idAnnounce.get();
                      final announceData =
                          announceSnapshot.data() as Map<String, dynamic>;
                      final idProperty =
                          announceData['property_id'] as DocumentReference;
                      final propertySnapshot = await idProperty.get();
                      final propertyData =
                          propertySnapshot.data() as Map<String, dynamic>;

                      data.add({
                        'id_announce': application['id_announce'].id as String,
                        'id_property': announceData['property_id'],
                        'imageUrl1': propertyData['imageUrl1'] as String,
                        'property_name':
                            propertyData['property_name'] as String,
                        'description': propertyData['description'] as String,
                        'state': application['state'] as String,
                        'descriptionApplication':
                            application['description'] as String
                      });
                    }),
                    builder: (BuildContext context,
                        AsyncSnapshot<dynamic> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        return Text(
                            'Une erreur est survenue : ${snapshot.error}');
                      } else {
                        return ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: data.length,
                          itemBuilder: (BuildContext context, int index) {
                            final propertyData = data[index];
                            String state = propertyData['state'] as String;
                            String stateText;

                            if (state == 'pending') {
                              stateText = 'En attente';
                            } else if (state == 'accepted') {
                              stateText = 'Accepté';
                            } else if (state == 'rejected') {
                              stateText = 'Rejeté';
                            } else {
                              stateText = 'Inconnu';
                            }
                            return InkWell(
                              child: Container(
                                padding: EdgeInsets.only(
                                    left: 10, right: 5, top: 10),
                                decoration: BoxDecoration(),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      height: 150,
                                      width: 200,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        image: DecorationImage(
                                          image: NetworkImage(
                                              propertyData['imageUrl1']
                                                  as String),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            propertyData['property_name']
                                                as String,
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          SizedBox(height: 8),
                                          Text(
                                            propertyData['descriptionApplication']
                                                        .length >
                                                    100
                                                ? '${'-' + propertyData['descriptionApplication'].substring(0, 100)}...'
                                                : propertyData[
                                                    'descriptionApplication'],
                                            style: const TextStyle(
                                              color: Colors.black,
                                              fontSize: 12,
                                            ),
                                          ),
                                          Text(
                                            stateText,
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: stateText == 'En attente'
                                                  ? Color.fromARGB(
                                                      255, 19, 96, 154)
                                                  : stateText == 'Accepté'
                                                      ? Colors.green
                                                      : Colors
                                                          .red, // sinon, la couleur sera rouge
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              onTap: () {
                                if (propertyData['state'] == 'accepted') {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => HouseShare(
                                        idProperty: propertyData['id_property'],
                                        idAnnounce: propertyData['id_announce'],
                                        /* announceId: snapshot.data![index]['announceId'],*/
                                      ),
                                    ),
                                  );
                                }
                              },
                            );
                          },
                        );
                      }
                    },
                  );
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
