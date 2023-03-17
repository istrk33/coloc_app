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
  late TabController _tabController;
  bool _showFloatingActionButton = true;
  final _formKey = GlobalKey<FormState>();
  dynamic _selectedImage1;
  dynamic _selectedImage2;
  dynamic _selectedImage3;
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

  void _handleSubmitted(String value) {
    if (value != "") {
      fetchData(value, "searchCity");
    } else {}
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
    _tabController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    _cityOptions = [];
    _loadPropertyTypeOptions();
    _cntPropertyType = SingleValueDropDownController();
    _cntCity = SingleValueDropDownController();
    _newHouseLocation = GeoPoint(0, 0);
    super.initState();
  }

  void _onTabChanged() {
    setState(() {
      _showFloatingActionButton = _tabController.index == 0;
      print(_showFloatingActionButton);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DefaultTabController(
        length: 2,
        child: Column(
          children: <Widget>[
            Material(
              color: Color.fromARGB(255, 255, 255, 255),
              child: TabBar(
                controller: _tabController,
                tabs: [
                  Tab(
                    icon: Icon(
                      Icons.house,
                      color: MyTheme.blue1,
                    ),
                  ),
                  Tab(
                    icon: Icon(
                      Icons.list_alt,
                      color: MyTheme.blue1,
                    ),
                  ),
                ],
                onTap: (_) {
                  _onTabChanged();
                },
                
              ),
            ),
            Expanded(
              flex: 1,
              child: TabBarView(
                controller: _tabController,
              //  dragEndBehavior: DragEndBehavior.end ,
              
                children: [
                  Container(
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
                            builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
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
                                          (doc['imageUrl1'] as String),
                                          errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
                                            return Image.asset('assets/images/placeholder.jpg');
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
                                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                                                    onPressed: () async {
                                                      var ville = (doc["city"] as String).split(',')[0];
                                                      await fetchData(
                                                          "https://geo.api.gouv.fr/communes?nom=${ville}&fields=departement&limit=5", "searchCity");
                                                      final FirebaseFirestore _firestore = FirebaseFirestore.instance;
                                                      DocumentReference propertyTypeRef =
                                                          _firestore.collection('property_type').doc(doc["property_type_id"].id);
                                                      DocumentSnapshot snapshot = await propertyTypeRef.get();
                                                      var data = snapshot.data() as Map<String, dynamic>;
                                                      String? propertyTypeLabel = data['property_type_label'] as String;

                                                      var newPropertyName = doc["property_name"] as String;
                                                      var newPropertyDescription = doc["description"] as String;
                                                      var newAddress = (doc["address"] as String);
                                                      var newCity = (doc["city"] as String);
                                                      var newPropertyTypeId = doc["property_type_id"].id;
                                                      var newNumberRooms = doc["room_number"];
                                                      var newSurfaceArea = doc["surface_area"];
                                                      dynamic newImage1 = (doc['imageUrl1'] as String);
                                                      dynamic newImage2 = (doc['imageUrl2'] as String);
                                                      dynamic newImage3 = (doc['imageUrl3'] as String);
                                                      var townSearchText = "";
                                                      showModalBottomSheet(
                                                        isScrollControlled: true,
                                                        context: context,
                                                        builder: (BuildContext context) {
                                                          return SingleChildScrollView(
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
                                                                        "Editer la propriété ${doc.id}",
                                                                        style: TextStyle(
                                                                          fontSize: 20,
                                                                          fontWeight: FontWeight.bold,
                                                                        ),
                                                                      ),
                                                                      TextFormField(
                                                                        onChanged: (value) => {newPropertyName = value},
                                                                        initialValue: doc["property_name"] as String,
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
                                                                        onChanged: (value) => {newPropertyDescription = value},
                                                                        initialValue: doc["description"] as String,
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
                                                                        onChanged: (value) => {newAddress = value},
                                                                        initialValue: newAddress,
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
                                                                              decoration: InputDecoration(
                                                                                hintText: 'Recherchez une ville',
                                                                              ),
                                                                              onSubmitted: _handleSubmitted,
                                                                              onChanged: (value) => {townSearchText = value},
                                                                            ),
                                                                          ),
                                                                          SizedBox(width: 16.0),
                                                                          ElevatedButton(
                                                                            onPressed: () {
                                                                              _handleSubmitted(
                                                                                  "https://geo.api.gouv.fr/communes?nom=${townSearchText}&fields=departement&limit=5");
                                                                            },
                                                                            child: Icon(Icons.search),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                      DropDownTextField(
                                                                        initialValue: newCity,
                                                                        clearOption: false,
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
                                                                          newCity = val.value;
                                                                        },
                                                                        textFieldDecoration: InputDecoration(
                                                                          hintText: "Recherchez une ville ci-dessus",
                                                                        ),
                                                                      ),
                                                                      DropDownTextField(
                                                                        initialValue: propertyTypeLabel,
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
                                                                            newPropertyTypeId = val.value;
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
                                                                              onChanged: (value) => {newNumberRooms = value},
                                                                              initialValue: doc["room_number"],
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
                                                                              onChanged: (value) => {newSurfaceArea = value},
                                                                              initialValue: doc["surface_area"],
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
                                                                      Row(
                                                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                                        children: [
                                                                          (newImage1 == "")
                                                                              ? PropertyImagePicker(
                                                                                  onImagesSelected: (image) {
                                                                                    setState(() {
                                                                                      newImage1 = image;
                                                                                    });
                                                                                  },
                                                                                )
                                                                              : PropertyImagePicker(
                                                                                  onImagesSelected: (image) {
                                                                                    setState(() {
                                                                                      newImage1 = image;
                                                                                    });
                                                                                  },
                                                                                  defaultImage: newImage1,
                                                                                ),
                                                                          (newImage2 == "")
                                                                              ? PropertyImagePicker(
                                                                                  onImagesSelected: (image) {
                                                                                    setState(() {
                                                                                      newImage2 = image;
                                                                                    });
                                                                                  },
                                                                                )
                                                                              : PropertyImagePicker(
                                                                                  onImagesSelected: (image) {
                                                                                    setState(() {
                                                                                      newImage2 = image;
                                                                                    });
                                                                                  },
                                                                                  defaultImage: newImage2,
                                                                                ),
                                                                          (newImage3 == "")
                                                                              ? PropertyImagePicker(
                                                                                  onImagesSelected: (image) {
                                                                                    setState(() {
                                                                                      newImage3 = image;
                                                                                    });
                                                                                  },
                                                                                )
                                                                              : PropertyImagePicker(
                                                                                  onImagesSelected: (image) {
                                                                                    setState(() {
                                                                                      newImage3 = image;
                                                                                    });
                                                                                  },
                                                                                  defaultImage: newImage3,
                                                                                )
                                                                        ],
                                                                      ),
                                                                      ElevatedButton(
                                                                        onPressed: () async {
                                                                          if (_formKey.currentState!.validate()) {
                                                                            _formKey.currentState!.save();
                                                                            // send img if new image, and compare with old
                                                                            var imgUrl1 = "";
                                                                            if ((doc['imageUrl1'] as String) != "" && !(newImage1 is String)) {
                                                                              var baseUrl1 = (doc['imageUrl1'] as String);
                                                                              final ref = FirebaseStorage.instance.refFromURL(baseUrl1);
                                                                              await ref.delete();
                                                                              final compressedImage1 = await compressImage(newImage1);
                                                                              imgUrl1 = await _uploadImage(compressedImage1!);
                                                                            } else if ((doc['imageUrl1'] as String) == "" && newImage1 != "") {
                                                                              final compressedImage1 = await compressImage(newImage1);
                                                                              imgUrl1 = await _uploadImage(compressedImage1!);
                                                                            } else {
                                                                              imgUrl1 = (doc['imageUrl1'] as String);
                                                                            }
                                                                            var imgUrl2 = "";
                                                                            if ((doc['imageUrl2'] as String) != "" && !(newImage2 is String)) {
                                                                              var baseUrl2 = (doc['imageUrl2'] as String);
                                                                              final ref = FirebaseStorage.instance.refFromURL(baseUrl2);
                                                                              await ref.delete();
                                                                              final compressedImage2 = await compressImage(newImage2);
                                                                              imgUrl2 = await _uploadImage(compressedImage2!);
                                                                            } else if ((doc['imageUrl2'] as String) == "" && newImage2 != "") {
                                                                              final compressedImage2 = await compressImage(newImage2);
                                                                              imgUrl2 = await _uploadImage(compressedImage2!);
                                                                            } else {
                                                                              imgUrl2 = (doc['imageUrl2'] as String);
                                                                            }
                                                                            var imgUrl3 = "";
                                                                            if ((doc['imageUrl3'] as String) != "" && !(newImage3 is String)) {
                                                                              var baseUrl3 = (doc['imageUrl3'] as String);
                                                                              final ref = FirebaseStorage.instance.refFromURL(baseUrl3);
                                                                              await ref.delete();
                                                                              final compressedImage3 = await compressImage(newImage3);
                                                                              imgUrl3 = await _uploadImage(compressedImage3!);
                                                                            } else if ((doc['imageUrl3'] as String) == "" && newImage3 != "") {
                                                                              final compressedImage3 = await compressImage(newImage3);
                                                                              imgUrl3 = await _uploadImage(compressedImage3!);
                                                                            } else {
                                                                              imgUrl3 = (doc['imageUrl3'] as String);
                                                                            }

                                                                            // Submit form
                                                                            final CollectionReference<Map<String, dynamic>> propertyTypes =
                                                                                FirebaseFirestore.instance.collection('property_type');

                                                                            final DocumentReference<Map<String, dynamic>> propertyTypeRef =
                                                                                propertyTypes.doc(newPropertyTypeId);
                                                                            FirebaseFirestore.instance
                                                                                .collection('property')
                                                                                .doc(doc.id)
                                                                                .update({
                                                                                  'address': newAddress,
                                                                                  'city': newCity,
                                                                                  'description': newPropertyDescription,
                                                                                  'property_name': newPropertyName,
                                                                                  'room_number': newNumberRooms,
                                                                                  'surface_area': newSurfaceArea,
                                                                                  'property_type_id': propertyTypeRef,
                                                                                  'position': _newHouseLocation,
                                                                                  'imageUrl1': imgUrl1,
                                                                                  'imageUrl2': imgUrl2,
                                                                                  'imageUrl3': imgUrl3,
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
                                                                  backgroundColor: MaterialStateProperty.all<Color>(
                                                                    Colors.red,
                                                                  ),
                                                                ),
                                                                child: Text('Oui'),
                                                                onPressed: () async {
                                                                  var toDeleteId = doc.id;
                                                                  final FirebaseFirestore firestore = FirebaseFirestore.instance;
                                                                  final DocumentReference propertyToDelete =
                                                                      firestore.collection('property').doc(toDeleteId);
                                                                  await propertyToDelete.delete();
                                                                  Navigator.of(context).pop();

                                                                  if ((doc['imageUrl1'] as String) != "") {
                                                                    final ref = FirebaseStorage.instance.refFromURL((doc['imageUrl1'] as String));
                                                                    await ref.delete();
                                                                  }
                                                                  if ((doc['imageUrl2'] as String) != "") {
                                                                    final ref = FirebaseStorage.instance.refFromURL((doc['imageUrl2'] as String));
                                                                    await ref.delete();
                                                                  }
                                                                  if ((doc['imageUrl3'] as String) != "") {
                                                                    final ref = FirebaseStorage.instance.refFromURL((doc['imageUrl3'] as String));
                                                                    await ref.delete();
                                                                  }
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
                  Icon(Icons.notifications),
                ],
              ),
            )
          ],
        ),
      ),
      floatingActionButton: _showFloatingActionButton
          ? FloatingActionButton(
              onPressed: () {
                print("===================================================================================");
                print(_showFloatingActionButton);
                print("===================================================================================");
                showModalBottomSheet(
                  isScrollControlled: true,
                  context: context,
                  builder: (BuildContext context) {
                    return SingleChildScrollView(
                      child: Padding(
                        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
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
                                  controller: _cntCity,
                                  clearOption: false,
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
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    PropertyImagePicker(
                                      onImagesSelected: (image) {
                                        setState(() {
                                          _selectedImage1 = image;
                                        });
                                      },
                                    ),
                                    PropertyImagePicker(
                                      onImagesSelected: (image) {
                                        setState(() {
                                          _selectedImage2 = image;
                                        });
                                      },
                                    ),
                                    PropertyImagePicker(
                                      onImagesSelected: (image) {
                                        setState(() {
                                          _selectedImage3 = image;
                                        });
                                      },
                                    )
                                  ],
                                ),
                                ElevatedButton(
                                  onPressed: () async {
                                    if (_formKey.currentState!.validate()) {
                                      _formKey.currentState!.save();
                                      String address = _addressController.text + " " + _selectedCity!;
                                      String url =
                                          "https://api-adresse.data.gouv.fr/search/?q=${address.replaceAll(" ", "+").replaceAll(",", "")}&limit=1";
                                      await fetchData(url, "requestType");

                                      // send img
                                      var imgUrl1 = "";
                                      if (_selectedImage1 != null) {
                                        final compressedImage1 = await compressImage(_selectedImage1);
                                        imgUrl1 = await _uploadImage(compressedImage1!);
                                      }
                                      var imgUrl2 = "";
                                      if (_selectedImage2 != null) {
                                        final compressedImage2 = await compressImage(_selectedImage2);
                                        imgUrl2 = await _uploadImage(compressedImage2!);
                                      }
                                      var imgUrl3 = "";
                                      if (_selectedImage3 != null) {
                                        final compressedImage3 = await compressImage(_selectedImage3);
                                        imgUrl3 = await _uploadImage(compressedImage3!);
                                      }

                                      // Submit form
                                      final CollectionReference<Map<String, dynamic>> users = FirebaseFirestore.instance.collection('Users');
                                      final CollectionReference<Map<String, dynamic>> propertyTypes =
                                          FirebaseFirestore.instance.collection('property_type');

                                      final DocumentReference<Map<String, dynamic>> userRef = users.doc(auth.currentUser!.uid.toString());
                                      final DocumentReference<Map<String, dynamic>> propertyTypeRef = propertyTypes.doc(_selectedPropertyTypeUid);
                                      final collectionRef = FirebaseFirestore.instance.collection('property');
                                      await collectionRef.add({
                                        'address': _addressController.text,
                                        'city': _selectedCity,
                                        'description': _descriptionController.text,
                                        'property_name': _propertyNameController.text,
                                        'room_number': _roomNumberController.text,
                                        'surface_area': _surfaceController.text,
                                        'id_owner': userRef,
                                        'property_type_id': propertyTypeRef,
                                        'position': _newHouseLocation,
                                        'imageUrl1': imgUrl1,
                                        'imageUrl2': imgUrl2,
                                        'imageUrl3': imgUrl3,
                                      });
                                      Navigator.pop(context);
                                    }
                                    _propertyNameController.clear();
                                    _descriptionController.clear();
                                    _addressController.clear();
                                    _roomNumberController.clear();
                                    _surfaceController.clear();
                                    _cityTextEditingController.clear();
                                    _cntCity.clearDropDown();
                                    _cntPropertyType.clearDropDown();
                                    _selectedImage1 = null;
                                    _selectedImage2 = null;
                                    _selectedImage3 = null;
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
            )
          : null,
    );
  }

  Future<void> _loadPropertyTypeOptions() async {
    final querySnapshot = await FirebaseFirestore.instance.collection('property_type').get();

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

  Future<File?> compressImage(File file) async {
    File compressedFile = await FlutterNativeImage.compressImage(
      file.path,
      quality: 50,
      percentage: 50,
    );
    return compressedFile;
  }

  Future<String> _uploadImage(File image) async {
    final storageRef = FirebaseStorage.instance.ref();
    final imageRef = storageRef.child('images/${DateTime.now().millisecondsSinceEpoch}.jpg');
    final uploadTask = imageRef.putFile(image);
    final snapshot = await uploadTask;
    final downloadUrl = await snapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  Future<void> fetchData(String url, String requestType) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (requestType == "searchCity") {
          final cityOptions = List<DropDownValueModel>.from(data.map((option) {
            return DropDownValueModel(
              name: "${option['nom']}, ${option['departement']['nom']} ${option['departement']['code']}",
              value: "${option['nom']}, ${option['departement']['nom']} ${option['departement']['code']}",
            );
          }));
          setState(() {
            _cityOptions = cityOptions;
          });
        } else {
          setState(
            () {
              _newHouseLocation = GeoPoint(data['features'][0]['geometry']['coordinates'][1], data['features'][0]['geometry']['coordinates'][0]);
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
            content: Text('Problème avec la récupération des données, signalez cette erreur si elle persiste !'),
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
