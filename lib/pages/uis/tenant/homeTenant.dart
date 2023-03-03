import 'package:coloc_app/pages/uis/common/profile.dart';
import 'package:coloc_app/pages/uis/common/announce_page.dart';
import 'package:coloc_app/themes/color.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:timeago/timeago.dart' as timeago;

class HomeTenant extends StatelessWidget {
  const HomeTenant({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    var locale = 'fr';
    timeago.setLocaleMessages('fr', timeago.FrMessages());
    return Container(
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
            stream:
                FirebaseFirestore.instance.collection("announce").snapshots(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasData) {
                final snap = snapshot.data!.docs;
                return ListView.builder(
                  shrinkWrap: true,
                  primary: false,
                  itemCount: snap.length,
                  itemBuilder: (context, index) {
                    String imgUrl = snap[index]['img_url'].toString();
                    return InkWell(
                      child: Container(
                        height: 250,
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: MyTheme.white,
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
                                snap[index]['title'],
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
                                '${'-' + snap[index]['description'].substring(0, 200)}...',
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
                                snap[index]['price'].toString() + "\u{20AC}",
                                style: TextStyle(
                                  color: Colors.green.withOpacity(0.7),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.fromLTRB(0, 0, 10, 5),
                              alignment: Alignment.bottomRight,
                              child: Text(
                                timeago
                                    .format(
                                        snap[index]['date_publication']
                                            .toDate(),
                                        locale: locale)
                                    .toString(),
                                style: const TextStyle(
                                  color: Color.fromARGB(255, 24, 1, 1),
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (context) => (AnnouncePage(
                                  announceId: snap[index].id,
                                  announceTitle:
                                      snap[index]['title'].toString()))),
                        );
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
    );
  }
}
