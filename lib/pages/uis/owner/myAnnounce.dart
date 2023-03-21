import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coloc_app/auth/sign_in.dart';
import 'package:coloc_app/pages/uis/owner/propertyApplicationList.dart';
import 'package:coloc_app/themes/color.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MyAnnounce extends StatefulWidget {
  @override
  _MyAnnounce createState() => _MyAnnounce();
}

class _MyAnnounce extends State<MyAnnounce> {
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Padding(
            padding: EdgeInsets.all(15.0),
            child: CupertinoSearchTextField(
              placeholder: 'Rechercher',
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('property')
                  .where('id_owner', isEqualTo: FirebaseFirestore.instance.collection('Users').doc(auth.currentUser!.uid))
                  .snapshots(),
              builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> propertiesSnapshot) {
                if (propertiesSnapshot.hasError) {
                  return Text('Une erreur est survenue : ${propertiesSnapshot.error}');
                }

                if (!propertiesSnapshot.hasData) {
                  return Text('Aucune donnée trouvée !');
                }

                // récupère les données du snapshot
                final data = propertiesSnapshot.data!.docs;
                final propertyIds = data.map((doc) => FirebaseFirestore.instance.collection('property').doc(doc.id)).toList();
                if (propertyIds.length > 0) {
                  return StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance.collection('announce').where('property_id', whereIn: propertyIds).snapshots(),
                    builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> announceSnapshot) {
                      if (announceSnapshot.hasError) {
                        return Text('Une erreur est survenue : ${announceSnapshot.error}');
                      }

                      if (!announceSnapshot.hasData) {
                        return Text('Aucune annonce trouvée !');
                      }

                      // récupère les données du snapshot d'annonce
                      final announceData = announceSnapshot.data!.docs;

                      return ListView.builder(
                        itemCount: announceData.length,
                        itemBuilder: (BuildContext context, int index) {
                          final announceDocument = announceData[index];
                          final propertyDocument = announceDocument['property_id'].get();
                          return FutureBuilder<DocumentSnapshot>(
                            future: propertyDocument,
                            builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                              if (snapshot.connectionState == ConnectionState.done) {
                                final correspondingProperty = snapshot.data!;
                                return Column(
                                  children: [
                                    SizedBox(
                                      height: 10,
                                    ),
                                    ListTile(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        side: BorderSide(color: Colors.grey),
                                      ),
                                      contentPadding: EdgeInsets.all(0),
                                      leading: Image.network(
                                        (correspondingProperty['imageUrl1'] as String),
                                        errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
                                          return Image.asset('assets/images/placeholder.jpg');
                                        },
                                        width: 50,
                                        height: 50,
                                      ),
                                      title: Text.rich(
                                        TextSpan(
                                          children: [
                                            WidgetSpan(
                                              alignment: PlaceholderAlignment.middle,
                                              baseline: TextBaseline.alphabetic,
                                              child: Icon(Icons.house),
                                            ),
                                            TextSpan(
                                              text: correspondingProperty['property_name'],
                                            ),
                                          ],
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      subtitle: Container(
                                        child: Column(
                                          children: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                              children: [
                                                Column(
                                                  children: [
                                                    Icon(Icons.credit_card),
                                                    Text("${announceData[index]['price']}€"),
                                                  ],
                                                ),
                                                Column(
                                                  children: [
                                                    Icon(Icons.credit_score_sharp),
                                                    Text("${announceData[index]['deposit_amount']}€"),
                                                  ],
                                                ),
                                              ],
                                            ),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                              children: [
                                                Switch(
                                                  value: announceData[index]['is_active'],
                                                  onChanged: (value) {
                                                    setState(
                                                      () {
                                                        FirebaseFirestore.instance
                                                            .collection('announce')
                                                            .doc(announceData[index].id)
                                                            .update({
                                                              'is_active': !announceData[index]['is_active'],
                                                            })
                                                            .then((_) => print('Mise à jour réussie'))
                                                            .catchError((error) => print('Erreur de mise à jour: $error'));
                                                      },
                                                    );
                                                  },
                                                  activeColor: MyTheme.blue1,
                                                  inactiveThumbColor: Colors.grey,
                                                  inactiveTrackColor: Colors.grey[300],
                                                  activeTrackColor: MyTheme.blue4,
                                                ),
                                                IconButton(
                                                  icon: Icon(
                                                    Icons.edit,
                                                    color: MyTheme.blue3,
                                                  ),
                                                  onPressed: () async {
                                                    // update
                                                    var newMaxRoomates = announceData[index]['max_roomates'];
                                                    var newDepositAmount = announceData[index]['deposit_amount'];
                                                    var newPrice = announceData[index]['price'];
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
                                                                      child: Form(
                                                                        key: _formKey,
                                                                        child: Column(
                                                                          mainAxisSize: MainAxisSize.min,
                                                                          children: [
                                                                            Text(
                                                                              "Modifier l'annonce de ${correspondingProperty['property_name']}",
                                                                              style: TextStyle(
                                                                                fontSize: 20,
                                                                                fontWeight: FontWeight.bold,
                                                                              ),
                                                                            ),
                                                                            TextFormField(
                                                                              initialValue: newDepositAmount,
                                                                              keyboardType: TextInputType.number,
                                                                              decoration: const InputDecoration(
                                                                                  labelText: 'Caution',
                                                                                  suffixIcon: Icon(
                                                                                    Icons.euro_sharp,
                                                                                  )),
                                                                              validator: (value) {
                                                                                if (value!.isEmpty) {
                                                                                  return 'Montant incorrect';
                                                                                }
                                                                                return null;
                                                                              },
                                                                              onChanged: (value) {
                                                                                newDepositAmount = value;
                                                                              },
                                                                            ),
                                                                            TextFormField(
                                                                              initialValue: newMaxRoomates,
                                                                              keyboardType: TextInputType.number,
                                                                              decoration: const InputDecoration(
                                                                                  labelText: 'Nombre de colocataire',
                                                                                  suffixIcon: Icon(
                                                                                    Icons.groups_sharp,
                                                                                  )),
                                                                              validator: (value) {
                                                                                if (value!.isEmpty ||
                                                                                    int.parse(value) < announceData[index]['roomate_number'] ||
                                                                                    int.parse(value) <= 1) {
                                                                                  return 'Valeur incorrecte';
                                                                                }
                                                                                return null;
                                                                              },
                                                                              onChanged: (value) {
                                                                                newMaxRoomates = value;
                                                                              },
                                                                            ),
                                                                            TextFormField(
                                                                              initialValue: newPrice,
                                                                              keyboardType: TextInputType.number,
                                                                              decoration: const InputDecoration(
                                                                                suffixIcon: Icon(
                                                                                  Icons.euro_sharp,
                                                                                ),
                                                                                labelText: 'Loyer',
                                                                              ),
                                                                              validator: (value) {
                                                                                if (value!.isEmpty) {
                                                                                  return 'Montant incorrect';
                                                                                }
                                                                                return null;
                                                                              },
                                                                              onChanged: (value) {
                                                                                newPrice = value;
                                                                              },
                                                                            ),
                                                                            ElevatedButton(
                                                                              onPressed: () async {
                                                                                setState(() {
                                                                                  _isLoading = true;
                                                                                });
                                                                                if (_formKey.currentState!.validate()) {
                                                                                  _formKey.currentState!.save();
                                                                                  FirebaseFirestore.instance
                                                                                      .collection('announce')
                                                                                      .doc(announceData[index].id)
                                                                                      .update({
                                                                                        'max_roomates': newMaxRoomates,
                                                                                        'price': newPrice,
                                                                                        'deposit_amount': newDepositAmount,
                                                                                      })
                                                                                      .then((_) => print('Mise à jour réussie'))
                                                                                      .catchError((error) => print('Erreur de mise à jour: $error'));
                                                                                  Navigator.pop(context);
                                                                                }
                                                                              },
                                                                              child: const Text(
                                                                                'Enregistrer',
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
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
                                                    Icons.delete,
                                                    color: Colors.red,
                                                  ),
                                                  onPressed: () {
                                                    if (announceData[index]['roomate_number'] > 0) {
                                                      showDialog(
                                                        context: context,
                                                        builder: (BuildContext context) {
                                                          return AlertDialog(
                                                            title: Text('Attention'),
                                                            content: Text(
                                                              'Voulez ne pouvez pas supprimer cette annonce !',
                                                            ),
                                                            actions: [
                                                              ElevatedButton(
                                                                child: Text('Compris'),
                                                                style: ButtonStyle(
                                                                  backgroundColor: MaterialStateProperty.all<Color>(Colors.white),
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
                                                    } else {
                                                      showDialog(
                                                        context: context,
                                                        builder: (BuildContext context) {
                                                          return AlertDialog(
                                                            title: Text('Attention'),
                                                            content: Text(
                                                              'Voulez vous supprimer cette annonce ?',
                                                            ),
                                                            actions: [
                                                              ElevatedButton(
                                                                style: ButtonStyle(
                                                                  backgroundColor: MaterialStateProperty.all<Color>(
                                                                    Colors.red,
                                                                  ),
                                                                ),
                                                                child: Text('Oui'),
                                                                onPressed: () async {
                                                                  var toDeleteId = announceData[index].id;
                                                                  final FirebaseFirestore firestore = FirebaseFirestore.instance;
                                                                  final DocumentReference propertyToDelete =
                                                                      firestore.collection('announce').doc(toDeleteId);
                                                                  await propertyToDelete.delete();
                                                                  Navigator.of(context).pop();
                                                                },
                                                              ),
                                                              ElevatedButton(
                                                                child: Text('Non'),
                                                                style: ButtonStyle(
                                                                  backgroundColor: MaterialStateProperty.all<Color>(Colors.white),
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
                                      onTap: () async {
                                        // afficher liste de colocataire
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => PropertyApplicationPage(announceData: announceDocument),
                                          ),
                                        );
                                      },
                                      trailing: Column(
                                        children: [
                                          Icon(Icons.groups),
                                          Container(
                                            padding: EdgeInsets.all(5),
                                            child: Text(
                                              "${announceData[index]['roomate_number']}/${announceData[index]['max_roomates']}",
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                );
                              } else {
                                return SizedBox.shrink();
                              }
                            },
                          );
                        },
                      );
                    },
                  );
                } else {
                  return Text("Aucune donnée");
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
