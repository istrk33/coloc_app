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
import 'dart:convert';
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
  late SingleValueDropDownController _cntPropertyType;
  late SingleValueDropDownController _cntCity;
  late List<DropDownValueModel> _optionsPropertyType;
  late List<DropDownValueModel> _cityOptions;
  String? _selectedPropertyTypeUid;
  String? _selectedCity;
  FocusNode searchFocusNode = FocusNode();
  FocusNode textFieldFocusNode = FocusNode();
  final _propertyNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _addressController = TextEditingController();
  final _roomNumberController = TextEditingController();
  final _surfaceController = TextEditingController();
  final _cityTextEditingController = TextEditingController();
  late GeoPoint _newHouseLocation;
  bool _isLoading = false;

  void _handleSubmitted(String value) {
    if (value != "") {
      fetchData(value, "searchCity");
    } else {}
    // _cityTextEditingController.clear();
    // print('You entered: $value');
  }

  @override
  void dispose() {
    _cntPropertyType.dispose();
    _cntCity.dispose();
    _propertyNameController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    _roomNumberController.dispose();
    _surfaceController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _cityOptions = [];
    _loadPropertyTypeOptions();
    _cntPropertyType = SingleValueDropDownController();
    _cntCity = SingleValueDropDownController();
    _newHouseLocation = GeoPoint(0, 0);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
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
                    .where('id_owner',
                        isEqualTo: FirebaseFirestore.instance
                            .collection('Users')
                            .doc(auth.currentUser!.uid))
                    .snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text('Une erreur est survenue.'));
                  }

                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (BuildContext context, int index) {
                      DocumentSnapshot doc = snapshot.data!.docs[index];

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          ListTile(
                            contentPadding: EdgeInsets.all(0),
                            leading: Image.network(
                              (doc['imagesUrl'] as String).split('|')[0],
                              errorBuilder: (BuildContext context,
                                  Object exception, StackTrace? stackTrace) {
                                return Image.asset(
                                    'assets/images/placeholder.jpg'); // L'image par défaut
                              },
                              width: 50,
                              height: 50,
                            ),
                            title: Text(doc['property_name']),
                            subtitle: Container(
                              child: Column(
                                children: [
                                  Text(
                                    doc['description'],
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      IconButton(
                                        icon: Icon(Icons.publish),
                                        color: Colors.green,
                                        onPressed: () {},
                                      ),
                                      IconButton(
                                        icon: Icon(
                                          Icons.edit,
                                          color: MyTheme.blue3,
                                        ),
                                        onPressed: () {
                                          // showModalBottomSheet(
                                          //   isScrollControlled: true,
                                          //   context: context,
                                          //   builder: (BuildContext context) {
                                          //     return SingleChildScrollView(
                                          //       child: Padding(
                                          //         padding: EdgeInsets.only(
                                          //             bottom:
                                          //                 MediaQuery.of(context)
                                          //                     .viewInsets
                                          //                     .bottom),
                                          //         child: Container(
                                          //           padding:
                                          //               const EdgeInsets.all(
                                          //                   20),
                                          //           child: Form(
                                          //             key: _formKey,
                                          //             child: Column(
                                          //               mainAxisSize:
                                          //                   MainAxisSize.min,
                                          //               children: [
                                          //                 Text(
                                          //                   "Editer la propriété ${doc.id}",
                                          //                   style: TextStyle(
                                          //                     fontSize: 20,
                                          //                     fontWeight:
                                          //                         FontWeight
                                          //                             .bold,
                                          //                   ),
                                          //                 ),
                                          //                 TextFormField(
                                          //                   initialValue: doc[
                                          //                       "property_name"],
                                          //                   controller:
                                          //                       _propertyNameController,
                                          //                   decoration:
                                          //                       const InputDecoration(
                                          //                     labelText:
                                          //                         'Nom de la propriété',
                                          //                   ),
                                          //                   validator: (value) {
                                          //                     if (value!
                                          //                         .isEmpty) {
                                          //                       return 'Le nom ne peux pas être vide';
                                          //                     }
                                          //                     return null;
                                          //                   },
                                          //                 ),
                                          //                 TextFormField(
                                          //                   initialValue: doc[
                                          //                       "description"],
                                          //                   controller:
                                          //                       _descriptionController,
                                          //                   minLines: 2,
                                          //                   maxLines: 3,
                                          //                   decoration:
                                          //                       const InputDecoration(
                                          //                     labelText:
                                          //                         'Description',
                                          //                   ),
                                          //                   validator: (value) {
                                          //                     if (value!
                                          //                         .isEmpty) {
                                          //                       return 'La description ne peux pas être vide';
                                          //                     }
                                          //                     return null;
                                          //                   },
                                          //                 ),
                                          //                 TextFormField(
                                          //                   initialValue:
                                          //                       doc["address"],
                                          //                   controller:
                                          //                       _addressController,
                                          //                   decoration:
                                          //                       const InputDecoration(
                                          //                     labelText:
                                          //                         'Adresse',
                                          //                   ),
                                          //                   validator: (value) {
                                          //                     if (value!
                                          //                         .isEmpty) {
                                          //                       return 'L\'adresse ne peux pas être vide';
                                          //                     }
                                          //                     return null;
                                          //                   },
                                          //                 ),
                                          //                 Row(
                                          //                   children: [
                                          //                     Expanded(
                                          //                       child:
                                          //                           TextField(
                                          //                         controller:
                                          //                             _cityTextEditingController,
                                          //                         decoration:
                                          //                             InputDecoration(
                                          //                           hintText:
                                          //                               'Recherchez une ville',
                                          //                         ),
                                          //                         onSubmitted:
                                          //                             _handleSubmitted,
                                          //                       ),
                                          //                     ),
                                          //                     SizedBox(
                                          //                         width: 16.0),
                                          //                     ElevatedButton(
                                          //                       onPressed: () {
                                          //                         _handleSubmitted(
                                          //                             "https://geo.api.gouv.fr/communes?nom=${_cityTextEditingController.text}&fields=departement&limit=5");
                                          //                       },
                                          //                       child: Icon(Icons
                                          //                           .search),
                                          //                     ),
                                          //                   ],
                                          //                 ),
                                          //                 DropDownTextField(
                                          //                   // initialValue: "name4",
                                          //                   controller:
                                          //                       _cntCity,
                                          //                   clearOption: false,
                                          //                   // enableSearch: true,
                                          //                   // dropdownColor: Colors.green,
                                          //                   searchDecoration:
                                          //                       InputDecoration(
                                          //                     contentPadding:
                                          //                         EdgeInsets
                                          //                             .symmetric(
                                          //                       horizontal:
                                          //                           16.0,
                                          //                       vertical: 12.0,
                                          //                     ),
                                          //                     hintText: "Ville",
                                          //                   ),
                                          //                   validator: (value) {
                                          //                     if (value ==
                                          //                             null ||
                                          //                         value
                                          //                             .isEmpty) {
                                          //                       return "Choisissez une ville";
                                          //                     } else {
                                          //                       return null;
                                          //                     }
                                          //                   },
                                          //                   dropDownItemCount:
                                          //                       6,
                                          //                   dropDownList:
                                          //                       _cityOptions,
                                          //                   onChanged: (val) {
                                          //                     setState(() {
                                          //                       _selectedCity =
                                          //                           val.value;
                                          //                     });
                                          //                   },
                                          //                   textFieldDecoration:
                                          //                       InputDecoration(
                                          //                     hintText:
                                          //                         "Recherchez une ville ci-dessus",
                                          //                   ),
                                          //                 ),
                                          //                 DropDownTextField(
                                          //                   controller:
                                          //                       _cntPropertyType,
                                          //                   clearOption: false,
                                          //                   searchDecoration:
                                          //                       InputDecoration(
                                          //                     contentPadding:
                                          //                         EdgeInsets
                                          //                             .symmetric(
                                          //                       horizontal:
                                          //                           16.0,
                                          //                       vertical: 12.0,
                                          //                     ),
                                          //                     hintText:
                                          //                         "Type de propriété",
                                          //                   ),
                                          //                   validator: (value) {
                                          //                     if (value ==
                                          //                             null ||
                                          //                         value
                                          //                             .isEmpty) {
                                          //                       return "Choisissez le type de votre propriété";
                                          //                     } else {
                                          //                       return null;
                                          //                     }
                                          //                   },
                                          //                   dropDownItemCount:
                                          //                       6,
                                          //                   dropDownList:
                                          //                       _optionsPropertyType,
                                          //                   onChanged: (val) {
                                          //                     setState(() {
                                          //                       _selectedPropertyTypeUid =
                                          //                           val.value;
                                          //                     });
                                          //                   },
                                          //                   textFieldDecoration:
                                          //                       InputDecoration(
                                          //                     hintText:
                                          //                         "Type de propriété",
                                          //                   ),
                                          //                 ),
                                          //                 Row(
                                          //                   children: [
                                          //                     Expanded(
                                          //                       child:
                                          //                           TextFormField(
                                          //                         controller:
                                          //                             _roomNumberController,
                                          //                         keyboardType:
                                          //                             TextInputType
                                          //                                 .number,
                                          //                         decoration:
                                          //                             const InputDecoration(
                                          //                           labelText:
                                          //                               'Nombre de chambre',
                                          //                         ),
                                          //                         validator:
                                          //                             (value) {
                                          //                           if (value!
                                          //                               .isEmpty) {
                                          //                             return 'Nombre de chambre incorrect';
                                          //                           }
                                          //                           return null;
                                          //                         },
                                          //                       ),
                                          //                     ),
                                          //                     SizedBox(
                                          //                         width: 16),
                                          //                     Expanded(
                                          //                       child:
                                          //                           TextFormField(
                                          //                         controller:
                                          //                             _surfaceController,
                                          //                         keyboardType:
                                          //                             TextInputType
                                          //                                 .number,
                                          //                         decoration:
                                          //                             const InputDecoration(
                                          //                           labelText:
                                          //                               'Surface en m²',
                                          //                         ),
                                          //                         validator:
                                          //                             (value) {
                                          //                           if (value!
                                          //                               .isEmpty) {
                                          //                             return 'Valeur incorrecte';
                                          //                           }
                                          //                           return null;
                                          //                         },
                                          //                       ),
                                          //                     ),
                                          //                   ],
                                          //                 ),
                                          //                 const SizedBox(
                                          //                     height: 10),
                                          //                 PropertyImagePicker(
                                          //                     onImagesSelected:
                                          //                         _handleImagesSelected),
                                          //                 // const SizedBox(height: 20),
                                          //                 ElevatedButton(
                                          //                   onPressed:
                                          //                       () async {
                                          //                     setState(() {
                                          //                       _isLoading =
                                          //                           true;
                                          //                     });
                                          //                     // String url="https://api-adresse.data.gouv.fr/search/?q=7+rue+de+guyenne+Pessac+Gironde+33&limit=1";
                                          //                     if (_formKey
                                          //                         .currentState!
                                          //                         .validate()) {
                                          //                       String address =
                                          //                           _addressController
                                          //                                   .text +
                                          //                               " " +
                                          //                               _selectedCity!;
                                          //                       String url =
                                          //                           "https://api-adresse.data.gouv.fr/search/?q=${address.replaceAll(" ", "+").replaceAll(",", "")}&limit=1";
                                          //                       await fetchData(
                                          //                           url,
                                          //                           "requestType");
                                          //                       // Rue%20de%20Guyenne%2C%2033600%20Pessac%2C%20France
                                          //                       // https://api.opencagedata.com/geocode/v1/json?q=15%20rue%20de%20naudet%2C%2033170%20Gradignan%2C%20France&key=03c48dae07364cabb7f121d8c1519492&no_annotations=1&language=fr
                                          //                       // String url =
                                          //                       //     "https://api.opencagedata.com/geocode/v1/json?q=" +
                                          //                       //         Uri.encodeFull(
                                          //                       //             _addressController.text) +
                                          //                       //         "&key=03c48dae07364cabb7f121d8c1519492&no_annotations=1&language=fr";

                                          //                       // send img
                                          //                       await Future.wait(
                                          //                           _images.map(
                                          //                               (image) async {
                                          //                         final compressedImage =
                                          //                             await compressImage(
                                          //                                 image!);
                                          //                         final imageUrl =
                                          //                             await _uploadImage(
                                          //                                 compressedImage!);
                                          //                         return imageUrl;
                                          //                       }));
                                          //                       // Submit form
                                          //                       final CollectionReference<
                                          //                               Map<String,
                                          //                                   dynamic>>
                                          //                           users =
                                          //                           FirebaseFirestore
                                          //                               .instance
                                          //                               .collection(
                                          //                                   'Users');
                                          //                       final CollectionReference<
                                          //                               Map<String,
                                          //                                   dynamic>>
                                          //                           propertyTypes =
                                          //                           FirebaseFirestore
                                          //                               .instance
                                          //                               .collection(
                                          //                                   'property_type');

                                          //                       final DocumentReference<
                                          //                               Map<String,
                                          //                                   dynamic>>
                                          //                           userRef =
                                          //                           users.doc(auth
                                          //                               .currentUser!
                                          //                               .uid
                                          //                               .toString());
                                          //                       final DocumentReference<
                                          //                               Map<String,
                                          //                                   dynamic>>
                                          //                           propertyTypeRef =
                                          //                           propertyTypes
                                          //                               .doc(
                                          //                                   _selectedPropertyTypeUid);

                                          //                       final collectionRef =
                                          //                           FirebaseFirestore
                                          //                               .instance
                                          //                               .collection(
                                          //                                   'property');
                                          //                       await collectionRef
                                          //                           .add({
                                          //                         'address':
                                          //                             address,
                                          //                         'description':
                                          //                             _descriptionController
                                          //                                 .text,
                                          //                         'property_name':
                                          //                             _propertyNameController
                                          //                                 .text,
                                          //                         'room_number':
                                          //                             _roomNumberController
                                          //                                 .text,
                                          //                         'surface_area':
                                          //                             _surfaceController
                                          //                                 .text,
                                          //                         'id_owner':
                                          //                             userRef,
                                          //                         'property_type_id':
                                          //                             propertyTypeRef,
                                          //                         'position':
                                          //                             _newHouseLocation,
                                          //                         'imagesUrl':
                                          //                             _imageUrls,
                                          //                       });
                                          //                       Navigator.pop(
                                          //                           context);
                                          //                     }
                                          //                     setState(() {
                                          //                       _isLoading =
                                          //                           false;
                                          //                     });
                                          //                     _formKey
                                          //                         .currentState
                                          //                         ?.reset();
                                          //                     _propertyNameController
                                          //                         .clear();
                                          //                     _descriptionController
                                          //                         .clear();
                                          //                     _addressController
                                          //                         .clear();
                                          //                     _roomNumberController
                                          //                         .clear();
                                          //                     _surfaceController
                                          //                         .clear();
                                          //                     _cityTextEditingController
                                          //                         .clear();
                                          //                     _cntCity
                                          //                         .clearDropDown();
                                          //                     _cntPropertyType
                                          //                         .clearDropDown();
                                          //                   },
                                          //                   child: _isLoading
                                          //                       ? Center(
                                          //                           child:
                                          //                               CircularProgressIndicator())
                                          //                       : const Text(
                                          //                           'Enregistrer',
                                          //                         ),
                                          //                 ),
                                          //               ],
                                          //             ),
                                          //           ),
                                          //         ),
                                          //       ),
                                          //     );
                                          //   },
                                          // );
                                        },
                                      ),
                                      IconButton(
                                        icon: Icon(
                                          Icons.delete,
                                          color: Colors.red,
                                        ),
                                        onPressed: () {
                                          showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                title: Text('Attention'),
                                                content: Text(
                                                  'Voulez vous supprimer cette propriété ?',
                                                ),
                                                actions: [
                                                  ElevatedButton(
                                                    style: ButtonStyle(
                                                      backgroundColor:
                                                          MaterialStateProperty
                                                              .all<Color>(
                                                        Colors.red,
                                                      ),
                                                    ),
                                                    child: Text('Oui'),
                                                    onPressed: () async {
                                                      var toDeleteId = doc.id;
                                                      final FirebaseFirestore
                                                          firestore =
                                                          FirebaseFirestore
                                                              .instance;
                                                      final DocumentReference
                                                          propertyToDelete =
                                                          firestore
                                                              .collection(
                                                                  'property')
                                                              .doc(toDeleteId);
                                                      await propertyToDelete
                                                          .delete();
                                                      Navigator.of(context)
                                                          .pop();

                                                      for (var url
                                                          in (doc['imagesUrl']
                                                                  as String)
                                                              .split('|')) {
                                                        final ref =
                                                            FirebaseStorage
                                                                .instance
                                                                .refFromURL(
                                                                    url);
                                                        await ref.delete();
                                                      }
                                                    },
                                                  ),
                                                  ElevatedButton(
                                                    child: Text('Non'),
                                                    style: ButtonStyle(
                                                      backgroundColor:
                                                          MaterialStateProperty
                                                              .all<Color>(
                                                                  Colors.white),
                                                      foregroundColor:
                                                          MaterialStateProperty
                                                              .all<Color>(
                                                                  Colors.black),
                                                    ),
                                                    onPressed: () {
                                                      Navigator.of(context)
                                                          .pop();
                                                    },
                                                  ),
                                                ],
                                              );
                                            },
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            onTap: () {},
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
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
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _cityTextEditingController,
                                  decoration: InputDecoration(
                                    hintText: 'Recherchez une ville',
                                  ),
                                  onSubmitted: _handleSubmitted,
                                ),
                              ),
                              SizedBox(width: 16.0),
                              ElevatedButton(
                                onPressed: () {
                                  _handleSubmitted(
                                      "https://geo.api.gouv.fr/communes?nom=${_cityTextEditingController.text}&fields=departement&limit=5");
                                },
                                child: Icon(Icons.search),
                              ),
                            ],
                          ),
                          DropDownTextField(
                            // initialValue: "name4",
                            controller: _cntCity,
                            clearOption: false,
                            // enableSearch: true,
                            // dropdownColor: Colors.green,
                            searchDecoration: InputDecoration(
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 16.0,
                                vertical: 12.0,
                              ),
                              hintText: "Ville",
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Choisissez une ville";
                              } else {
                                return null;
                              }
                            },
                            dropDownItemCount: 6,
                            dropDownList: _cityOptions,
                            onChanged: (val) {
                              setState(() {
                                _selectedCity = val.value;
                              });
                            },
                            textFieldDecoration: InputDecoration(
                              hintText: "Recherchez une ville ci-dessus",
                            ),
                          ),
                          DropDownTextField(
                            controller: _cntPropertyType,
                            clearOption: false,
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
                          // const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: () async {
                              setState(() {
                                _isLoading = true;
                              });
                              // String url="https://api-adresse.data.gouv.fr/search/?q=7+rue+de+guyenne+Pessac+Gironde+33&limit=1";
                              if (_formKey.currentState!.validate()) {
                                String address = _addressController.text +
                                    " " +
                                    _selectedCity!;
                                String url =
                                    "https://api-adresse.data.gouv.fr/search/?q=${address.replaceAll(" ", "+").replaceAll(",", "")}&limit=1";
                                await fetchData(url, "requestType");
                                // Rue%20de%20Guyenne%2C%2033600%20Pessac%2C%20France
                                // https://api.opencagedata.com/geocode/v1/json?q=15%20rue%20de%20naudet%2C%2033170%20Gradignan%2C%20France&key=03c48dae07364cabb7f121d8c1519492&no_annotations=1&language=fr
                                // String url =
                                //     "https://api.opencagedata.com/geocode/v1/json?q=" +
                                //         Uri.encodeFull(
                                //             _addressController.text) +
                                //         "&key=03c48dae07364cabb7f121d8c1519492&no_annotations=1&language=fr";

                                // send img
                                await Future.wait(_images.map((image) async {
                                  final compressedImage =
                                      await compressImage(image!);
                                  final imageUrl =
                                      await _uploadImage(compressedImage!);
                                  return imageUrl;
                                }));
                                // Submit form
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
                                    propertyTypeRef =
                                    propertyTypes.doc(_selectedPropertyTypeUid);

                                final collectionRef = FirebaseFirestore.instance
                                    .collection('property');
                                await collectionRef.add({
                                  'address': address,
                                  'description': _descriptionController.text,
                                  'property_name': _propertyNameController.text,
                                  'room_number': _roomNumberController.text,
                                  'surface_area': _surfaceController.text,
                                  'id_owner': userRef,
                                  'property_type_id': propertyTypeRef,
                                  'position': _newHouseLocation,
                                  'imagesUrl': _imageUrls,
                                });
                                Navigator.pop(context);
                              }
                              setState(() {
                                _isLoading = false;
                              });
                              _formKey.currentState?.reset();
                              _propertyNameController.clear();
                              _descriptionController.clear();
                              _addressController.clear();
                              _roomNumberController.clear();
                              _surfaceController.clear();
                              _cityTextEditingController.clear();
                              _cntCity.clearDropDown();
                              _cntPropertyType.clearDropDown();
                            },
                            child: _isLoading
                                ? Center(child: CircularProgressIndicator())
                                : const Text(
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

  Future<void> fetchData(String url, String requestType) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (requestType == "searchCity") {
          final cityOptions = List<DropDownValueModel>.from(data.map((option) {
            return DropDownValueModel(
              name:
                  "${option['nom']}, ${option['departement']['nom']} ${option['departement']['code']}",
              value:
                  "${option['nom']}, ${option['departement']['nom']} ${option['departement']['code']}",
            );
          }));
          setState(() {
            _cityOptions = cityOptions;
          });
        } else {
          setState(
            () {
              _newHouseLocation = GeoPoint(
                  data['features'][0]['geometry']['coordinates'][1],
                  data['features'][0]['geometry']['coordinates'][0]);
            },
          );
        }
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Erreur'),
            content: Text(
                'Problème avec la récupération des données, signalez cette erreur si elle persiste !'),
            actions: [
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }
}
