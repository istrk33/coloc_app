import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';


import '/widgets/profile_widget.dart';
import '/widgets/profile_textfield_widget.dart';

FirebaseAuth auth = FirebaseAuth.instance;
FirebaseFirestore firestore = FirebaseFirestore.instance;
final User? currentUser = auth.currentUser;

class EditProfilePage extends StatefulWidget {
  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  //UserModel user = UserPreferences.myUser;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Éditer profil'),
          backgroundColor: Color.fromARGB(255, 45, 101, 144),
        ),
        body: ListView(
          padding: EdgeInsets.symmetric(horizontal: 32),
          physics: BouncingScrollPhysics(),
          children: [
            ProfileWidget(
              imagePath: 'https://www.pngitem.com/pimgs/m/504-5040528_empty-profile-picture-png-transparent-png.png',
              //isEdit: true,
              onClicked: () async {pickUploadProfilePic();},
            ),
            const SizedBox(height: 24),
            TextFieldWidget(
              label: 'Nom Prénom',
              text: '',
              onChanged: (name) {},
            ),
            const SizedBox(height: 24),
            TextFieldWidget(
              label: 'Email',
              text: currentUser!.email.toString(),
              onChanged: (email) {},
            ),
            const SizedBox(height: 24),
            TextFieldWidget(
              label: 'À propos',
              text: '',
              maxLines: 5,
              onChanged: (about) {},
            ),
          ],
        ),
      );

  void pickUploadProfilePic() async {
    final image = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxHeight: 512,
      maxWidth: 512,
      imageQuality: 90,
    );
  }
}
