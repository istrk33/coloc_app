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
  late List<DropDownValueModel> _optionsCity;
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
  late AnimationController controller;
  late bool _isLoading;
  late String searchCity;

  @override
  void dispose() {
    _cntCity.dispose();
    _cntPropertyType.dispose();
    _propertyNameController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    _roomNumberController.dispose();
    _surfaceController.dispose();
    controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    searchCity="";
    _loadPropertyTypeOptions();
    _loadCityOptions(searchCity);
    _cntCity = SingleValueDropDownController();
    _cntPropertyType = SingleValueDropDownController();
    controller = AnimationController(
      /// [AnimationController]s can be created with `vsync: this` because of
      /// [TickerProviderStateMixin].
      vsync: this,
      duration: const Duration(seconds: 5),
    )..addListener(() {
        setState(() {});
      });
    controller.repeat(reverse: true);
    _isLoading = false;
    super.initState();
  }

  Future<void> _loadCityOptions(cityName) async {
    final querySnapshot =
        // await FirebaseFirestore.instance.collection('ma_collection').get();
        await FirebaseFirestore.instance.collection('city').where("city_name", isEqualTo: "ville").limit(15).get();

    List<DropDownValueModel> options = querySnapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      // final cityName = data['nom_de_la_commune'] as String;
      final cityName = data['city_name'] as String;
      // final postCode = data['code_postal'] as String;
      final postCode = data['post_code'] as String;
      final id = doc.id;
      return DropDownValueModel(
        name: "${cityName}, ${postCode}",
        value: id,
        toolTipMsg: "",
      );
    }).toList();
    setState(() {
      _optionsCity = options;
    });
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
                          DropDownTextField(
                            textFieldDecoration: InputDecoration(
                              hintText: "Ville",
                            ),
                            searchDecoration: InputDecoration(
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16.0,
                                  vertical: 12.0,
                                ),
                                hintText: "Ville"),
                            clearOption: false,
                            textFieldFocusNode: textFieldFocusNode,
                            searchFocusNode: searchFocusNode,
                            // searchAutofocus: true,
                            dropDownItemCount: 8,
                            searchShowCursor: false,
                            enableSearch: true,
                            searchKeyboardType: TextInputType.text,
                            dropDownList: _optionsCity,
                            onChanged: (val) {
                              setState(() {
                                _selectedCityUid = val.value;
                              });
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Choisissez une ville";
                              } else {
                                return null;
                              }
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
                                // _images.forEach((element) async {
                                //   // final result = await _compressImage(element!);
                                //   await _uploadImage(element!);
                                // });
                                final downloadUrls = await Future.wait(
                                    _images.map((image) async {
                                  setState(() => {_isLoading = true});
                                  final compressedImage =
                                      await compressImage(image!);
                                  final imageUrl =
                                      await _uploadImage(compressedImage!);
                                  return imageUrl;
                                }));

                                final imagesUrl = downloadUrls.join('|');
                                // for (int i = 0; i < _images.length; i++) {
                                //   File? result =
                                //       await _compressImage(_images[i]);
                                //   if (result != null) {
                                //     await _uploadImage(result);
                                //   }
                                // }
                                // https://api.opencagedata.com/geocode/v1/json?q=15%20rue%20de%20naudet%2C%2033170%20Gradignan%2C%20France&key=03c48dae07364cabb7f121d8c1519492&no_annotations=1&language=fr
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
                                // await collectionRef.add({
                                //   'address': _addressController.text,
                                //   'description': _descriptionController.text,
                                //   'property_name': _propertyNameController.text,
                                //   'room_number': _roomNumberController.text,
                                //   'surface_area': _surfaceController.text,
                                //   'city_id': cityRef,
                                //   'id_owner': userRef,
                                //   'property_type_id': propertyTypeRef,
                                //   'imagesUrl': _imageUrls
                                // });
                                await collectionRef.add({
                                  'address': _addressController.text,
                                  'description': _descriptionController.text,
                                  'property_name': _propertyNameController.text,
                                  'room_number': _roomNumberController.text,
                                  'surface_area': _surfaceController.text,
                                  'city_id': cityRef,
                                  'id_owner': userRef,
                                  'property_type_id': propertyTypeRef,
                                  'imagesUrl': imagesUrl
                                });
                              }
                               setState(() => {_isLoading = false});
                              Navigator.pop(context);
                            },
                            child: (!_isLoading)
                                ? const Text('Enregistrer')
                                : CircularProgressIndicator(
                                    value: controller.value,
                                    semanticsLabel: 'Chargement',
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
}
