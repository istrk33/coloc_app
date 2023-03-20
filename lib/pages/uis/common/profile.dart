import 'package:coloc_app/pages/uis/common/navbar.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'edit_profile_page.dart';
import '/widgets/profile_button_widget.dart';
import '/widgets/profile_widget.dart';
import '/widgets/profile_numbers_widget.dart';
import 'package:provider/provider.dart';

FirebaseAuth auth = FirebaseAuth.instance;
FirebaseFirestore firestore = FirebaseFirestore.instance;
final User? currentUser = auth.currentUser;

class ProfilMode {
  static bool _isOwnerMode = false;

  static bool getIsOwnerMode() {
    return _isOwnerMode;
  }
}

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

// ignore: todo
//use the user model completely

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        physics: BouncingScrollPhysics(),
        children: [
          ProfileWidget(
            imagePath:
                'https://www.pngitem.com/pimgs/m/504-5040528_empty-profile-picture-png-transparent-png.png',
            onClicked: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => EditProfilePage()),
              );
            },
          ),
          const SizedBox(height: 24),
          Center(
            child: GetUserDataName(currentUser!.uid, 'first_last_name'),
          ),
          buildName(),
          const SizedBox(height: 24),
          Center(child: buildUpgradeButton()),
          // Center(
          //   child: Column(
          //     children: [
          //       Text("Mode Propriétaire"),
          //       Switch(
          //         value: ProfilePage._isOwnerMode,
          //         onChanged: (bool value) {
          //           setState(() {
          //             ProfilePage._isOwnerMode = value;
          //             // Ajoutez ici le code pour activer/désactiver le mode sombre
          //           });
          //         },
          //       ),
          //       SizedBox(
          //         width: 5,
          //       )
          //     ],
          //   ),
          // ),
          const SizedBox(height: 24),
          NumbersWidget(),
          const SizedBox(height: 30),
          buildAbout(),
          Center(
            child: Padding(
              padding: EdgeInsets.fromLTRB(45, 0, 30, 0),
              child: GetUserData(currentUser!.uid, 'about'),
            ),
          ),
          LogoutButton(),
        ],
      ),
    );
  }

  Widget buildName() => Column(
        children: [
          Text(
            currentUser!.email.toString(),
            style: TextStyle(color: Colors.grey),
          )
        ],
      );

  Widget buildUpgradeButton() => ButtonWidget(
        text:
            ProfilMode._isOwnerMode ? 'Mode propriétaire' : 'Mode Colocataire',
        onClicked: () {
          ProfilMode._isOwnerMode = !ProfilMode._isOwnerMode;
          Navbar().getState()!.updateMenuItems();
        },
        icon: ProfilMode._isOwnerMode
            ? Icon(Icons.apartment)
            : Icon(Icons.payment),
        bgcolor: ProfilMode._isOwnerMode ? Colors.blue : Colors.red,
      );

  Widget buildAbout() => Container(
        padding: EdgeInsets.symmetric(horizontal: 48),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'À propos',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
          ],
        ),
      );
}

class GetUserDataName extends StatelessWidget {
  final String documentId;
  final String fieldName;
  const GetUserDataName(this.documentId, this.fieldName);
  @override
  Widget build(BuildContext context) {
    CollectionReference users = firestore.collection('Users');
    return FutureBuilder<DocumentSnapshot>(
      future: users.doc(documentId).get(),
      builder:
          (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (snapshot.hasError) {
          return const ListTile(
              title: Text(
            'Un problème est survenu',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ));
        }
        if (snapshot.connectionState == ConnectionState.done) {
          Map<String, dynamic> data =
              snapshot.data!.data() as Map<String, dynamic>;
          String text = ((data[fieldName].runtimeType.toString() == 'bool')
              ? ((data[fieldName]) ? "Homme" : "Femme")
              : data[fieldName]);
          return Text(
            text,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          );
          // }
        }
        return const ListTile(
          title: Center(
            child: Text(
              'En cours de chargement',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 2),
            ),
          ),
        );
      },
    );
  }
}

class GetUserData extends StatelessWidget {
  final String documentId;
  final String fieldName;
  const GetUserData(this.documentId, this.fieldName);
  @override
  Widget build(BuildContext context) {
    CollectionReference users = firestore.collection('Users');
    return FutureBuilder<DocumentSnapshot>(
      future: users.doc(documentId).get(),
      builder:
          (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (snapshot.hasError) {
          return const ListTile(
              title: Text(
            'Un problème est survenu',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ));
        }
        if (snapshot.connectionState == ConnectionState.done) {
          Map<String, dynamic> data =
              snapshot.data!.data() as Map<String, dynamic>;
          String text = (data[fieldName].toString());
          return Text(
            text,
            style: const TextStyle(fontSize: 15),
          );
          // }
        }
        return const ListTile(
          title: Text(
            'En cours de chargement',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
        );
      },
    );
  }
}

class LogoutButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      margin: const EdgeInsets.all(30),
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          padding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(30)),
          ),
        ),
        child: Text(
          "Déconnexion".toUpperCase(),
          style: const TextStyle(
            fontSize: 20.0,
          ),
        ),
        onPressed: () {
          auth.signOut();
        },
      ),
    );
  }
}
