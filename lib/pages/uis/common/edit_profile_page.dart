import 'package:coloc_app/themes/color.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';

import '/widgets/profile_widget.dart';

FirebaseAuth auth = FirebaseAuth.instance;
FirebaseFirestore firestore = FirebaseFirestore.instance;
final User? currentUser = auth.currentUser;

class EditProfilePage extends StatefulWidget {
  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  //UserModel user = UserPreferences.myUser;
  var _descriptionController = TextEditingController();
  final _emailController = TextEditingController();
  final _nameController = TextEditingController();

  void initState() {
    super.initState();
  }

  void pickUploadProfilePic() async {
    final image = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxHeight: 512,
      maxWidth: 512,
      imageQuality: 90,
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('Users').doc(currentUser!.uid).snapshots(),
      builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Une erreur est survenue.'));
        }

        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }
        // DocumentSnapshot doc = snapshot.data!.docs[index];
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        } else {
          final userData = snapshot.data!.data() as Map<String, dynamic>?;
          final String? name = userData?['first_last_name'];
          final String? about = userData?['about'];
          print(userData);
          print(name);
          print(about);
          // final String? photoUrl = userData?['photo'];

          // Use the data to build your UI
          // ...
          var newName = name;
          var newDescription = "";
          return Scaffold(
            appBar: AppBar(
              title: const Text('Éditer profil'),
              backgroundColor: MyTheme.blue3,
            ),
            body: ListView(
              padding: EdgeInsets.symmetric(horizontal: 32),
              physics: BouncingScrollPhysics(),
              children: [
                ProfileWidget(
                  imagePath: 'https://www.pngitem.com/pimgs/m/504-5040528_empty-profile-picture-png-transparent-png.png',
                  //isEdit: true,
                  onClicked: () async {
                    pickUploadProfilePic();
                  },
                ),
                const SizedBox(height: 24),
                (name == "")
                    ? TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: 'Nom Prénom',
                          hintMaxLines: null,
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black),
                          ),
                        ),
                      )
                    : TextFormField(
                        initialValue: name,
                        onChanged: (value) {
                          newName = value;
                        },
                        decoration: InputDecoration(
                          labelText: 'Nom Prénom',
                          hintMaxLines: null,
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black),
                          ),
                        ),
                      ),
                const SizedBox(height: 24),
                (about == "")
                    ? TextFormField(
                        controller: _descriptionController,
                        maxLines: 10,
                        decoration: const InputDecoration(
                          labelText: 'Description',
                          hintMaxLines: 10,
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black),
                          ),
                        ),
                      )
                    : TextFormField(
                        initialValue: about,
                        maxLines: 10,
                        decoration: const InputDecoration(
                          labelText: 'Description',
                          hintMaxLines: 10,
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black),
                          ),
                        ),
                        onChanged: (value) {
                          newDescription = value;
                        },
                      ),
                Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      fixedSize: const Size(180, 40),
                      backgroundColor: MyTheme.blue3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.0),
                      ),
                    ),
                    child: Text(
                      'Enregistrer',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.0,
                      ),
                    ),
                    onPressed: () async {
                      var newDescInsert = (_descriptionController.text.isNotEmpty) ? _descriptionController.text : newDescription;
                      if (_nameController.text.isNotEmpty || newName != "") {
                        var newNameInsert = (_nameController.text.isNotEmpty) ? _nameController.text : newName;
                        FirebaseFirestore.instance.collection('Users').doc(currentUser!.uid).update(
                          {
                            'about': newDescInsert,
                            'first_last_name': newNameInsert,
                          },
                        );
                         Navigator.of(context).pop();
                      } else {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('Impossible d\'enregistrer'),
                              content: Text('Le nom ne peut pas être vide !'),
                              actions: <Widget>[
                                TextButton(
                                  child: Text('Fermer'),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      }

                      //   if (_descriptionController.text.isNotEmpty) {
                      //     // Submit form
                      //     FirebaseFirestore.instance.collection('Users').doc(currentUser!.uid).update({'about': _descriptionController.text});
                      //     showDialog(
                      //         context: context,
                      //         builder: (context) {
                      //           return GestureDetector(
                      //             onTap: () {
                      //               Navigator.pop(context);
                      //             },
                      //             child: Lottie.network(
                      //               'https://assets1.lottiefiles.com/packages/lf20_Nd1IlGbdnB.json',
                      //               repeat: false,
                      //             ),
                      //           );
                      //         });
                      //   }
                      //   if (_nameController.text.isNotEmpty || newName != "") {
                      //     // Submit form
                      //     FirebaseFirestore.instance.collection('Users').doc(currentUser!.uid).update({'first_last_name': _nameController.text});
                      //     showDialog(
                      //         context: context,
                      //         builder: (context) {
                      //           return GestureDetector(
                      //             onTap: () {
                      //               Navigator.pop(context);
                      //             },
                      //             child: Lottie.network(
                      //               'https://assets1.lottiefiles.com/packages/lf20_Nd1IlGbdnB.json',
                      //               repeat: false,
                      //             ),
                      //           );
                      //         });
                      //   } else {
                      //     if (_descriptionController.text.isEmpty || newDescription == "") {
                      //       showDialog(
                      //         context: context,
                      //         builder: (BuildContext context) {
                      //           return AlertDialog(
                      //             title: Text('Impossible d\'enregistrer'),
                      //             content: Text('La description ne peut pas être vide, présentez vous brievement.'),
                      //             actions: <Widget>[
                      //               TextButton(
                      //                 child: Text('Fermer'),
                      //                 onPressed: () {
                      //                   Navigator.of(context).pop();
                      //                 },
                      //               ),
                      //             ],
                      //           );
                      //         },
                      //       );
                      //     } else {
                      //       var value = (_descriptionController.text.isEmpty) ? newDescription : _descriptionController.text;

                      //     }
                      // }
                    },
                  ),
                )
              ],
            ),
          );
        }
      },
    );
  }
}
