import 'dart:io';
import 'package:flutter/material.dart';
import 'package:coloc_app/pages/uis/common/profile.dart';
import 'package:coloc_app/themes/color.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:dropdown_textfield/dropdown_textfield.dart';
import 'propertyImagePicker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:http/http.dart' as http;

class HomeOwner extends StatefulWidget {
  const HomeOwner({Key? key}) : super(key: key);

  @override
  _HomeOwnerState createState() => _HomeOwnerState();
}

class _HomeOwnerState extends State<HomeOwner> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  List<File?> _images = [];
  String _imageUrls = "";
  late SingleValueDropDownController _cntCity;
  late SingleValueDropDownController _cntPropertyType;
  late List<DropDownValueModel> _optionsPropertyType;
  String? _selectedCityUid;
  String? _selectedPropertyTypeUid;
  FocusNode searchFocusNode = FocusNode();
  FocusNode textFieldFocusNode = FocusNode();
  final _propertyNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _addressController = TextEditingController();
  final _roomNumberController = TextEditingController();
  final _surfaceController = TextEditingController();
  GlobalKey<AutoCompleteTextFieldState<String>> _autoCompleteKey = GlobalKey();
  List<String> _optionsCity = [];
  var _selectedCityId;
  late CollectionReference _cityCollectionRef;
  final TextEditingController _typeAheadController = TextEditingController();

  List<String> _suggestions = [];

  @override
  void dispose() {
    _cntCity.dispose();
    _cntPropertyType.dispose();
    _propertyNameController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    _roomNumberController.dispose();
    _surfaceController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _loadPropertyTypeOptions();
    _cntCity = SingleValueDropDownController();
    _cntPropertyType = SingleValueDropDownController();
    _cityCollectionRef = FirebaseFirestore.instance.collection('city');
    _loadData();
    super.initState();
  }

  Future<void> _loadData() async {
    // Récupération des données de Firestore
    QuerySnapshot querySnapshot = await _cityCollectionRef.limit(5).get();
    List<DocumentSnapshot> documents = querySnapshot.docs;
    documents.forEach((document) {
      _optionsCity
          .add("${document['nom_de_la_commune']}, ${document['code_postal']}");
    });
    setState(() {});
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
                      String imgUrl = snap[index]['imagesUrl'].toString().split('|')[0];
                    return InkWell(
                      child: Container(
                        height: 250,
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color:  Color(0x80ffffff),
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: Stack(
                          children: [
                            Container(
                              margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                              alignment: Alignment.topCenter,
                              child: ClipRRect(
                                borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(8),
                                    topRight: Radius.circular(8)),
                                child: Container(
                                  height: 125,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                      image: NetworkImage(imgUrl),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                              alignment: Alignment.center,
                              child: Text(
                                snap[index]['property_name'],
                                style: const TextStyle(
                                  color: Colors.black54,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.fromLTRB(0, 100, 0, 0),
                              alignment: Alignment.center,
                              child: Text(
                                '${snap[index]['description']}',
                                style: const TextStyle(
                                  color: Colors.black54,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.only(bottom: 5),
                              alignment: Alignment.bottomCenter,
                              child: Text(
                                snap[index]['room_number'].toString(),
                                style: TextStyle(
                                  color: Colors.green.withOpacity(0.7),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            // Container(
                            //   margin: const EdgeInsets.fromLTRB(0, 0, 10, 5),
                            //   alignment: Alignment.bottomRight,
                            //   child: Text(
                            //     timeago
                            //         .format(
                            //             snap[index]['date_publication']
                            //                 .toDate(),
                            //             locale: locale)
                            //         .toString(),
                            //     style: const TextStyle(
                            //       color: Color.fromARGB(255, 24, 1, 1),
                            //       fontSize: 12,
                            //     ),
                            //   ),
                            // ),
                          ],
                        ),
                      ),
                      onTap: () {
                        // Navigator.of(context).push(
                        //   MaterialPageRoute(
                        //       builder: (context) => (AnnouncePage(
                        //           announceId: snap[index].id,
                        //           announceTitle:
                        //               snap[index]['title'].toString()))),
                        // );
                      },
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
                          const SizedBox(height: 10),
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
                            minLines: 2,
                            maxLines: 3,
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
                            controller: _addressController,
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
                          // DropDownTextField(
                          //   textFieldDecoration: InputDecoration(
                          //     hintText: "Ville",
                          //   ),
                          //   searchDecoration: InputDecoration(
                          //     contentPadding: EdgeInsets.symmetric(
                          //       horizontal: 16.0,
                          //       vertical: 12.0,
                          //     ),
                          //     hintText: "Ville",
                          //   ),
                          //   clearOption: false,
                          //   textFieldFocusNode: textFieldFocusNode,
                          //   searchFocusNode: searchFocusNode,
                          //   // searchAutofocus: true,
                          //   dropDownItemCount: 3,
                          //   searchShowCursor: false,
                          //   enableSearch: true,
                          //   searchKeyboardType: TextInputType.text,
                          //   dropDownList: _optionsCity,
                          //   onChanged: (val) {
                          //     setState(() {
                          //       print("iussssss");
                          //       _selectedCityUid = val.value;
                          //     });
                          //   },

                          //   validator: (value) {
                          //     if (value == null || value.isEmpty) {
                          //       return "Choisissez une ville";
                          //     } else {
                          //       return null;
                          //     }
                          //   },
                          // ),

                          // TypeAheadFormField(
                          //   textFieldConfiguration: TextFieldConfiguration(
                          //     controller: _typeAheadController,
                          //     decoration: const InputDecoration(
                          //       labelText: 'Ville',
                          //       border: OutlineInputBorder(),
                          //     ),
                          //   ),
                          //   suggestionsCallback: (pattern) async {
                          //     final query = FirebaseFirestore.instance
                          //         .collection('city')
                          //         .where('nom_de_la_commune',
                          //             isGreaterThanOrEqualTo: pattern)
                          //         .where('nom_de_la_commune',
                          //             isLessThanOrEqualTo: pattern + '\uf8ff')
                          //         .limit(5);
                          //     final snapshot = await query.get();
                          //     final suggestions = snapshot.docs
                          //         .map((doc) => "${doc['nom_de_la_commune']}, ${doc['code_postal']}")
                          //         .toList();
                          //     return suggestions;
                          //   },
                          //   itemBuilder: (context, suggestion) {
                          //     return ListTile(
                          //       title: Text(suggestion),
                          //     );
                          //   },
                          //   onSuggestionSelected: (suggestion) {
                          //     _typeAheadController.text = suggestion;
                          //   },
                          // ),
                          
                          AutoCompleteTextField(
                            key: _autoCompleteKey,
                            clearOnSubmit: false,
                            suggestions: _optionsCity,
                            decoration: InputDecoration(
                              hintText: 'Ville',
                              // border: OutlineInputBorder(),
                            ),
                            itemBuilder: (BuildContext context, String option) {
                              return ListTile(
                                title: Text(option),
                              );
                            },
                            itemFilter: (String option, String input) => option
                                .toLowerCase()
                                .startsWith(input.toLowerCase()),
                            itemSorter: (String a, String b) => a.compareTo(b),
                            itemSubmitted: (String value) {
                              setState(() {
                                _selectedCityId = _optionsCity
                                    .indexWhere((element) => element == value);
                              });
                            },
                            textChanged: (String value) {
                              // Rafraîchir la liste des options à chaque fois que le texte est modifié
                              _cityCollectionRef
                                  .where("nom_de_la_commune",
                                      isGreaterThanOrEqualTo: value)
                                  .where('nom_de_la_commune',
                                      isLessThan: value + 'z')
                                  .orderBy('nom_de_la_commune')
                                  .limit(5)
                                  .get()
                                  .then((querySnapshot) {
                                List<DocumentSnapshot> documents =
                                    querySnapshot.docs;
                                setState(() {
                                  _optionsCity.clear();
                                  documents.forEach((document) {
                                    _optionsCity.add(
                                        "${document['nom_de_la_commune']}, ${document['code_postal']}");
                                  });
                                });
                              });
                            },
                          ),
                          const SizedBox(height: 10),
                          DropDownTextField(
                            // initialValue: "name4",
                            controller: _cntPropertyType,
                            clearOption: false,
                            // enableSearch: true,
                            // dropdownColor: Colors.green,
                            searchDecoration: InputDecoration(
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 16.0,
                                vertical: 12.0,
                              ),
                              hintText: "Type de propriété",
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Choisissez le type de votre propriété";
                              } else {
                                return null;
                              }
                            },
                            dropDownItemCount: 6,
                            dropDownList: _optionsPropertyType,
                            onChanged: (val) {
                              setState(() {
                                _selectedPropertyTypeUid = val.value;
                              });
                            },
                            textFieldDecoration: InputDecoration(
                              hintText: "Type de propriété",
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _roomNumberController,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    labelText: 'Nombre de chambre',
                                  ),
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return 'Nombre de chambre incorrect';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                child: TextFormField(
                                  controller: _surfaceController,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    labelText: 'Surface en m²',
                                  ),
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return 'Valeur incorrecte';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          PropertyImagePicker(
                              onImagesSelected: _handleImagesSelected),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                // Rue%20de%20Guyenne%2C%2033600%20Pessac%2C%20France
                                // https://api.opencagedata.com/geocode/v1/json?q=15%20rue%20de%20naudet%2C%2033170%20Gradignan%2C%20France&key=03c48dae07364cabb7f121d8c1519492&no_annotations=1&language=fr
                                // String url =
                                //     "https://api.opencagedata.com/geocode/v1/json?q=" +
                                //         Uri.encodeFull(
                                //             _addressController.text) +
                                //         "&key=03c48dae07364cabb7f121d8c1519492&no_annotations=1&language=fr";
                                // var json=jsonDecode(getJsonData(url) as String);
                                // print(json.result);

                                await Future.wait(_images.map((image) async {
                                  final compressedImage =
                                      await compressImage(image!);
                                  final imageUrl =
                                      await _uploadImage(compressedImage!);
                                  return imageUrl;
                                }));
                                // Submit form
                                final CollectionReference<Map<String, dynamic>>
                                    city = FirebaseFirestore.instance
                                        .collection('city');
                                final CollectionReference<Map<String, dynamic>>
                                    users = FirebaseFirestore.instance
                                        .collection('Users');
                                final CollectionReference<Map<String, dynamic>>
                                    propertyTypes = FirebaseFirestore.instance
                                        .collection('property_type');

                                final DocumentReference<Map<String, dynamic>>
                                    userRef =
                                    users.doc(auth.currentUser!.uid.toString());
                                final DocumentReference<Map<String, dynamic>>
                                    cityRef = city.doc(_selectedCityUid);
                                final DocumentReference<Map<String, dynamic>>
                                    propertyTypeRef =
                                    propertyTypes.doc(_selectedPropertyTypeUid);

                                final collectionRef = FirebaseFirestore.instance
                                    .collection('property');
                                await collectionRef.add({
                                  'address': _addressController.text,
                                  'description': _descriptionController.text,
                                  'property_name': _propertyNameController.text,
                                  'room_number': _roomNumberController.text,
                                  'surface_area': _surfaceController.text,
                                  'city_id': cityRef,
                                  'id_owner': userRef,
                                  'property_type_id': propertyTypeRef,
                                  'imagesUrl': _imageUrls
                                });
                              }
                              Navigator.pop(context);
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
              );
            },
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<String> getJsonData(String url) async {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      print(response.body);
    } else {
      print('Request failed with status: ${response.statusCode}');
    }
    return response.body;
  }

  Future<void> _loadPropertyTypeOptions() async {
    final querySnapshot =
        await FirebaseFirestore.instance.collection('property_type').get();

    List<DropDownValueModel> options = querySnapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      final propertyTypeLabel = data['property_type_label'] as String;
      final id = doc.id;
      return DropDownValueModel(
        name: propertyTypeLabel,
        value: id,
        toolTipMsg: "",
      );
    }).toList();
    setState(() {
      _optionsPropertyType = options;
    });
  }

  Future<void> _handleImagesSelected(List<File> images) async {
    _images = images;
  }

  Future<File?> compressImage(File file) async {
    File compressedFile = await FlutterNativeImage.compressImage(
      file.path,
      quality: 50,
      percentage: 50,
    );
    return compressedFile;
  }

  Future<void> _uploadImage(File image) async {
    final storageRef = FirebaseStorage.instance.ref();
    final imageRef =
        storageRef.child('images/${DateTime.now().millisecondsSinceEpoch}.jpg');
    final uploadTask = imageRef.putFile(image);
    final snapshot = await uploadTask;
    final downloadUrl = await snapshot.ref.getDownloadURL();
    setState(() {
      if (_imageUrls.isNotEmpty) {
        _imageUrls += '|$downloadUrl';
      } else {
        _imageUrls = downloadUrl;
      }
    });
  }
}
