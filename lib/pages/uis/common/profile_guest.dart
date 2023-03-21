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
  String id = "";

  @override
  void initState() {
    id = widget.userId;
    super.initState();
    FirebaseFirestore.instance
        .collection('Users')
        .doc(widget.userId)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        setState(() {
          Map<String, dynamic> data =
              documentSnapshot.data() as Map<String, dynamic>;
          userName = data['first_last_name'] as String;
          description = data['about'] as String;
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
            mainAxisAlignment: MainAxisAlignment.start,
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
              Text(
                "à propos",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left:20, right: 20,bottom: 20, top: 5),
                child: Text(
                  description,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14),
                ),
              ),
              SizedBox(height: 20),
              Divider(
                indent: 24,
                endIndent: 24,
              ),
              Text(
                'Propriétés de ' + userName,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('property')
                    .where('id_owner',
                        isEqualTo: FirebaseFirestore.instance.doc('Users/$id'))
                    .snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (!snapshot.hasData) {
                    return CircularProgressIndicator();
                  }
                  final announces = snapshot.data!.docs;
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: announces.length,
                    itemBuilder: (BuildContext context, int index) {
                      final announce = announces[index];
                      return Container(
                        padding: EdgeInsets.only(left: 50, right: 50, top: 20),
                        decoration: BoxDecoration(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: 200,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                image: DecorationImage(
                                  image: NetworkImage(
                                      announce['imageUrl1'] as String),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              announce['property_name'] as String,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              announce['description'].length > 300
                                  ? '${'-' + announce['description'].substring(0, 300)}...'
                                  : announce['description'],
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
