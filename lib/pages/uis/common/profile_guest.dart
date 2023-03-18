import 'package:coloc_app/themes/color.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfilePageGuest extends StatefulWidget {
  final String userId;
  ProfilePageGuest({Key? key, required this.userId}) : super(key: key);

  @override
  _ProfilePageGuestState createState() => _ProfilePageGuestState();
}

class _ProfilePageGuestState extends State<ProfilePageGuest> {
  String userName = "";
  String description = "";

  @override
  void initState() {
    super.initState();
    // Vous pouvez écrire votre code d'initialisation ici
    // Par exemple, vous pouvez récupérer les données de l'utilisateur à partir de Firebase Firestore
    FirebaseFirestore.instance
        .collection('Users')
        .doc(widget.userId)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      print(widget.userId);
      if (documentSnapshot.exists) {
        setState(() {
          Map<String, dynamic> data =
              documentSnapshot.data() as Map<String, dynamic>;
          userName = data['first_last_name'] as String;
          description = data['about'] as String;
          print('username' + userName);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(userName),
        backgroundColor: MyTheme.blue3,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 60,
                backgroundImage: NetworkImage(
                  'https://www.pngitem.com/pimgs/m/504-5040528_empty-profile-picture-png-transparent-png.png',
                ),
              ),
              SizedBox(height: 20),
              Text(
                userName,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  description,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
