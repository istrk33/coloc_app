import 'package:coloc_app/pages/uis/common/profile.dart';
import 'package:coloc_app/themes/color.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:flutter/cupertino.dart';

class HomeOwner extends StatefulWidget {
  const HomeOwner({Key? key}) : super(key: key);

  @override
  _HomeOwnerState createState() => _HomeOwnerState();
}

class _HomeOwnerState extends State<HomeOwner> {
  final _formKey = GlobalKey<FormState>();
  late QuerySnapshot _snapshot;
  String _searchText = '';

  final _propertyNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _roomNumberController = TextEditingController();

  @override
  void dispose() {
    _propertyNameController.dispose();
    _descriptionController.dispose();
    _roomNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
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
              stream: FirebaseFirestore.instance
                  .collection('property')
                  .where('id_owner',
                      isEqualTo: FirebaseFirestore.instance
                          .collection('Users')
                          .doc(auth.currentUser!.uid))
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
                                snap[index]['property_name'],
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
                                '-' + snap[index]['description'],
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
                                snap[index]['room_number'].toString() +
                                    "\u{20AC}",
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            isScrollControlled: true,
            context: context,
            builder: (BuildContext context) {
              return SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Ajouter une nouvelle propriété',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 20),
                          TextFormField(
                            controller: _propertyNameController,
                            decoration: const InputDecoration(
                              labelText: 'Nom de la propriété',
                            ),
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Le nom ne peux pas être vide';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 10),
                          TextFormField(
                            controller: _descriptionController,
                            decoration: const InputDecoration(
                              labelText: 'Description',
                            ),
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'La description ne peux pas être vide';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 10),
                          TextFormField(
                            controller: _descriptionController,
                            decoration: const InputDecoration(
                              labelText: 'Adresse',
                            ),
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'L\'adresse ne peux pas être vide';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 10),
                          TextFormField(
                            controller: _roomNumberController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Nombre de chambre',
                            ),
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Le nombre de chambre est incorrect';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 10),
                          TextFormField(
                            controller: _roomNumberController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Type de logement',
                            ),
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Le type de logement est incorrect';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 10),
                          Column(
                            children: [
                              TextField(
                                onChanged: (value) {
                                  setState(() {
                                    _searchText = value;
                                  });
                                },
                              ),
                              StreamBuilder<QuerySnapshot>(
                                stream: FirebaseFirestore.instance
                                    .collection('city')
                                    .snapshots(),
                                builder: (BuildContext context,
                                    AsyncSnapshot<QuerySnapshot> snapshot) {
                                  if (snapshot.hasData) {
                                    _snapshot = snapshot.data!;
                                    final filteredData = _snapshot.docs.where(
                                        (doc) => doc['city_name']
                                            .toString()
                                            .toLowerCase()
                                            .contains(
                                                _searchText.toLowerCase()));
                                    final dropdownItems = filteredData
                                        .map((doc) =>
                                            doc['city_name'].toString())
                                        .toList();
                                    // "${doc['city_name']}, ${doc['post_code']}"
                                    return DropdownButton<String>(
                                      value: dropdownItems.isEmpty
                                          ? null
                                          : dropdownItems.first,
                                      onChanged: (String? value) {},
                                      items: dropdownItems
                                          .map((item) =>
                                              DropdownMenuItem<String>(
                                                value: item,
                                                child: Text(item),
                                              ))
                                          .toList(),
                                    );
                                  } else {
                                    return const CircularProgressIndicator();
                                  }
                                },
                              ),
                            ],
                          ),
                          // StreamBuilder<List<String>>(
                          //   stream: FirebaseFirestore.instance
                          //       .collection('city')
                          //       .snapshots(), // Récupère la liste de données depuis une source de données
                          //   builder: (BuildContext context,
                          //       AsyncSnapshot<List<String>> snapshot) {
                          //     if (snapshot.hasData) {
                          //       // Crée une variable pour stocker la valeur sélectionnée de la DropdownButton
                          //       String selectedValue = snapshot.data![0];
                          //       // Crée une variable pour stocker une liste filtrée de données
                          //       List<String> filteredList = snapshot.data!;
                          //       // Crée une TextField pour saisir du texte à filtrer
                          //       return Column(
                          //         children: [
                          //           TextField(
                          //             onChanged: (text) {
                          //               // Met à jour la liste filtrée en fonction de la valeur du champ texte
                          //               setState(() {
                          //                 filteredList = snapshot.data!
                          //                     .where((item) => item
                          //                         .toLowerCase()
                          //                         .contains(text.toLowerCase()))
                          //                     .toList();
                          //               });
                          //             },
                          //           ),
                          //           DropdownButton<String>(
                          //             value: selectedValue,
                          //             items: filteredList.map((value) {
                          //               // Utilise la liste filtrée pour créer les éléments de la DropdownButton
                          //               return DropdownMenuItem<String>(
                          //                 value: value,
                          //                 child: Text(value),
                          //               );
                          //             }).toList(),
                          //             onChanged: (newValue) {
                          //               setState(() {
                          //                 selectedValue = newValue!;
                          //               });
                          //             },
                          //           ),
                          //         ],
                          //       );
                          //     } else if (snapshot.hasError) {
                          //       return Text("Error: ${snapshot.error}");
                          //     } else {
                          //       return Text("Loading...");
                          //     }
                          //   },
                          // ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                // Submit form
                              }
                            },
                            child: const Text('Enregistrer'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
