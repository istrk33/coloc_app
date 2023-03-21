import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coloc_app/themes/color.dart';
import 'package:flutter/material.dart';

class PropertyApplicationPage extends StatefulWidget {
  final QueryDocumentSnapshot<Object?> announceData;

  PropertyApplicationPage({required this.announceData});
  @override
  _PropertyApplicationPageState createState() => _PropertyApplicationPageState();
}

class _PropertyApplicationPageState extends State<PropertyApplicationPage> {
  late DocumentSnapshot<Object?> propertyData;
  late List<DocumentSnapshot<Object?>> applications;
  late List<DocumentSnapshot<Object?>> users;

  @override
  void initState() {
    super.initState();
    initPropertyData();
    initApplications();
    applications = [];
    users = [];
  }

  Future<void> initPropertyData() async {
    propertyData = await widget.announceData["property_id"].get();
  }

  Future<void> initApplications() async {
    QuerySnapshot<Object?> applicationsSnapshot = await FirebaseFirestore.instance
        .collection("application")
        .where("id_announce", isEqualTo: FirebaseFirestore.instance.collection('announce').doc(widget.announceData.id))
        .get();
    setState(() {
      applications = applicationsSnapshot.docs;
    });
  }

  Future<void> getUsersData() async {
    QuerySnapshot<Object?> usersSnapshot = await FirebaseFirestore.instance
        .collection("Users")
        .where("id", isEqualTo: FirebaseFirestore.instance.collection('announce').doc(widget.announceData.id))
        .get();
    setState(() {
      applications = usersSnapshot.docs;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: MyTheme.blue1,
        title: const Text('Candidatures pour l\'annonce '),
      ),
      body: ListView.builder(
        shrinkWrap: true,
        itemCount: applications.length,
        itemBuilder: (BuildContext context, int index) {
          return FutureBuilder(
            future: applications[index]["id_candidate"].get(),
            builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot<Object?>> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else if (!snapshot.hasData) {
                return const Text('Aucune donnée');
              } else {
                DocumentSnapshot<Object?> user = snapshot.data!;
                return Container(
                  margin: EdgeInsets.all(5),
                  child: applications[index]['state'] == "pending"
                      ? ListTile(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: BorderSide(color: Colors.grey),
                          ),
                          contentPadding: EdgeInsets.all(0),
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(50),
                            child: Image.network(
                              (user["avatar_url"]),
                              errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
                                return Image.asset('assets/images/placeholder.jpg');
                              },
                              width: 50,
                              height: 50,
                            ),
                          ),
                          title: Text(user['first_last_name']),
                          subtitle: Container(
                            child: Column(
                              children: [
                                Text(
                                  applications[index]['description'].length > 125
                                      ? '${applications[index]['description'].substring(0, 125)}...'
                                      : applications[index]['description'],
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    IconButton(
                                      icon: Icon(
                                        Icons.person,
                                        color: MyTheme.blue1,
                                      ),
                                      onPressed: () {
                                        showModalBottomSheet(
                                          isScrollControlled: true,
                                          context: context,
                                          builder: (BuildContext context) {
                                            // si annonce déja existante, afficher dialog pour dire que annonce deja existante pour la propriete
                                            return StatefulBuilder(
                                              builder: (BuildContext context, StateSetter setState) {
                                                return Stack(
                                                  children: [
                                                    SingleChildScrollView(
                                                      child: Padding(
                                                        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                                                        child: Container(
                                                          padding: const EdgeInsets.all(20),
                                                          child: Column(
                                                            children: [
                                                              SizedBox(height: 20.0),
                                                              ClipRRect(
                                                                borderRadius: BorderRadius.circular(50),
                                                                child: Image.network(
                                                                  ("user['imageUrl'] as String"),
                                                                  errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
                                                                    return Image.asset('assets/images/placeholder.jpg');
                                                                  },
                                                                  width: 75,
                                                                  height: 75,
                                                                ),
                                                              ),
                                                              SizedBox(height: 10.0),
                                                              Text(
                                                                user['first_last_name'],
                                                                style: TextStyle(
                                                                  fontSize: 22.0,
                                                                  fontWeight: FontWeight.bold,
                                                                ),
                                                              ),
                                                              SizedBox(height: 20.0),
                                                              Divider(),
                                                              ListTile(
                                                                leading: Icon(Icons.call),
                                                                title: Text('Appeler au ${user['mobile_phone']}'),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                );
                                              },
                                            );
                                          },
                                        );
                                      },
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        Icons.close_sharp,
                                        color: Colors.red,
                                      ),
                                      onPressed: () async {
                                        FirebaseFirestore.instance
                                            .collection('application')
                                            .doc(applications[index].id)
                                            .update({
                                              'state': "refused",
                                            })
                                            .then((_) => print('Mise à jour réussie'))
                                            .catchError((error) => print('Erreur de mise à jour: $error'));
                                      },
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.check),
                                      color: Colors.green,
                                      onPressed: () async {
                                        if (widget.announceData["roomate_number"] as int < int.parse(widget.announceData["max_roomates"])) {
                                          FirebaseFirestore.instance
                                              .collection('application')
                                              .doc(applications[index].id)
                                              .update({
                                                'state': "accepted",
                                              })
                                              .then((_) => print('Mise à jour réussie'))
                                              .catchError((error) => print('Erreur de mise à jour: $error'));
                                          FirebaseFirestore.instance
                                              .collection('announce')
                                              .doc(widget.announceData.id)
                                              .update({
                                                'roomate_number': int.parse(widget.announceData["roomate_number"]) + 1,
                                              })
                                              .then((_) => print('Mise à jour réussie'))
                                              .catchError((error) => print('Erreur de mise à jour: $error'));
                                        } else {
                                          showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                title: Text('Attention !'),
                                                content: Text(
                                                  "Vous ne pouvez plus accepter de colocataire dans cette propriété, vous n'avez plus de place !",
                                                ),
                                                actions: [
                                                  ElevatedButton(
                                                    child: Text('Lu'),
                                                    style: ButtonStyle(
                                                      backgroundColor: MaterialStateProperty.all<Color>(Color.fromARGB(255, 222, 218, 218)),
                                                      foregroundColor: MaterialStateProperty.all<Color>(Colors.black),
                                                    ),
                                                    onPressed: () {
                                                      Navigator.of(context).pop();
                                                    },
                                                  ),
                                                ],
                                              );
                                            },
                                          );
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text('Message de ${user['first_last_name']}'),
                                  content: Text(
                                    applications[index]['description'],
                                  ),
                                  actions: [
                                    ElevatedButton(
                                      child: Text('Lu'),
                                      style: ButtonStyle(
                                        backgroundColor: MaterialStateProperty.all<Color>(Color.fromARGB(255, 222, 218, 218)),
                                        foregroundColor: MaterialStateProperty.all<Color>(Colors.black),
                                      ),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        )
                      : ((applications[index]['state'] == "accepted")
                          ? Container(
                              // color: Colors.green[200],
                              decoration: BoxDecoration(
                                color: Colors.green[200],
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: ListTile(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  side: BorderSide(color: Colors.grey),
                                ),
                                contentPadding: EdgeInsets.all(0),
                                leading: ClipRRect(
                                  borderRadius: BorderRadius.circular(50),
                                  child: Image.network(
                                    ("user['imageUrl'] as String"),
                                    errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
                                      return Image.asset('assets/images/placeholder.jpg');
                                    },
                                    width: 50,
                                    height: 50,
                                  ),
                                ),
                                title: Text(user['first_last_name']),
                                subtitle: Container(
                                  child: Column(
                                    children: [
                                      Text(
                                        applications[index]['description'].length > 125
                                            ? '${applications[index]['description'].substring(0, 125)}...'
                                            : applications[index]['description'],
                                      ),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        children: [
                                          IconButton(
                                            icon: Icon(
                                              Icons.person,
                                              color: MyTheme.blue1,
                                            ),
                                            onPressed: () {
                                              showModalBottomSheet(
                                                isScrollControlled: true,
                                                context: context,
                                                builder: (BuildContext context) {
                                                  return StatefulBuilder(
                                                    builder: (BuildContext context, StateSetter setState) {
                                                      return Stack(
                                                        children: [
                                                          SingleChildScrollView(
                                                            child: Padding(
                                                              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                                                              child: Container(
                                                                padding: const EdgeInsets.all(20),
                                                                child: Column(
                                                                  children: [
                                                                    SizedBox(height: 20.0),
                                                                    ClipRRect(
                                                                      borderRadius: BorderRadius.circular(50),
                                                                      child: Image.network(
                                                                        ("user['imageUrl'] as String"),
                                                                        errorBuilder:
                                                                            (BuildContext context, Object exception, StackTrace? stackTrace) {
                                                                          return Image.asset('assets/images/placeholder.jpg');
                                                                        },
                                                                        width: 75,
                                                                        height: 75,
                                                                      ),
                                                                    ),
                                                                    SizedBox(height: 10.0),
                                                                    Text(
                                                                      user['first_last_name'],
                                                                      style: TextStyle(
                                                                        fontSize: 22.0,
                                                                        fontWeight: FontWeight.bold,
                                                                      ),
                                                                    ),
                                                                    SizedBox(height: 20.0),
                                                                    Divider(),
                                                                    ListTile(
                                                                      leading: Icon(Icons.call),
                                                                      title: Text('Appeler au ${user['mobile_phone']}'),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      );
                                                    },
                                                  );
                                                },
                                              );
                                            },
                                          ),
                                          IconButton(
                                            icon: Icon(
                                              Icons.close_sharp,
                                              color: Colors.red,
                                            ),
                                            onPressed: () async {
                                              FirebaseFirestore.instance
                                                  .collection('application')
                                                  .doc(applications[index].id)
                                                  .update({
                                                    'state': "refused",
                                                  })
                                                  .then((_) => print('Mise à jour réussie'))
                                                  .catchError((error) => print('Erreur de mise à jour: $error'));
                                              FirebaseFirestore.instance
                                                  .collection('announce')
                                                  .doc(widget.announceData.id)
                                                  .update({
                                                    'roomate_number': int.parse(widget.announceData["roomate_number"]) - 1,
                                                  })
                                                  .then((_) => print('Mise à jour réussie'))
                                                  .catchError((error) => print('Erreur de mise à jour: $error'));
                                            },
                                          )
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: Text('Message de ${user['first_last_name']}'),
                                        content: Text(
                                          applications[index]['description'],
                                        ),
                                        actions: [
                                          ElevatedButton(
                                            child: Text('Lu'),
                                            style: ButtonStyle(
                                              backgroundColor: MaterialStateProperty.all<Color>(Color.fromARGB(255, 222, 218, 218)),
                                              foregroundColor: MaterialStateProperty.all<Color>(Colors.black),
                                            ),
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                              ),
                            )
                          : SizedBox(
                              height: 0,
                            )),
                );
              }
            },
          );
        },
      ),
    );
  }
}
