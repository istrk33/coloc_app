import 'package:coloc_app/pages/uis/tenant/homeTenant.dart';
import 'package:coloc_app/themes/color.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
//import 'package:fluttertoast/fluttertoast.dart';

FirebaseAuth auth = FirebaseAuth.instance;
FirebaseFirestore firestore = FirebaseFirestore.instance;

class SignupPage extends StatelessWidget {
  const SignupPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            MyTheme.blue4,
            MyTheme.blue3,
          ],
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            textSection,
            InputSection(),
          ],
        ),
      ),
    );
  }
}

Widget textSection = Padding(
  padding: EdgeInsets.only(top: 10),
  child: Container(
    child: Text(
      'Créez-vous un compte',
      style: GoogleFonts.comfortaa(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: MyTheme.blue3,
      ),
    ),
  ),
);

class InputSection extends StatefulWidget {
  InputSection({Key? key}) : super(key: key);

  @override
  State<InputSection> createState() {
    return _InputSection();
  }
}

enum Sexe { homme, femme }

class _InputSection extends State<InputSection> {
  var emailField = TextEditingController();
  var mobileField = TextEditingController();
  var passwordField = TextEditingController();
  var firstLastNameField = TextEditingController();
  var birthdateField = TextEditingController();
  Sexe? _sexe = Sexe.homme;
  DateTime defaultDateTime = DateTime.now();
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(30),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white30, width: 1),
              borderRadius: BorderRadius.circular(30),
              color: const Color.fromRGBO(255, 255, 255, 0.1),
            ),
            height: 50,
            child: Row(
              children: [
                Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    color: MyTheme.white,
                  ),
                  child: const Icon(
                    Icons.people_outline,
                    size: 25,
                    color: MyTheme.blue3,
                  ),
                ),
                SizedBox(
                  height: 60,
                  width: 280,
                  child: Center(
                    child: TextField(
                      controller: firstLastNameField,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.comfortaa(
                          fontSize: 17,
                          color: MyTheme.white,
                          fontWeight: FontWeight.bold),
                      decoration: InputDecoration(
                        label: const Center(
                          child: Text("Nom Prenom"),
                        ),
                        labelStyle: GoogleFonts.comfortaa(color: MyTheme.white),
                        contentPadding: EdgeInsets.fromLTRB(10, 0, 0, 20),
                        floatingLabelBehavior: FloatingLabelBehavior.never,
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white30, width: 1),
              borderRadius: BorderRadius.circular(30),
              color: const Color.fromRGBO(255, 255, 255, 0.1),
            ),
            height: 50,
            child: Row(
              children: [
                Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    color: MyTheme.white,
                  ),
                  child: const Icon(
                    Icons.mail_outline,
                    size: 25,
                    color: MyTheme.blue3,
                  ),
                ),
                SizedBox(
                  height: 60,
                  width: 280,
                  child: Center(
                    child: TextField(
                      controller: emailField,
                      keyboardType: TextInputType.emailAddress,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.comfortaa(
                          fontSize: 17,
                          color: MyTheme.white,
                          fontWeight: FontWeight.bold),
                      decoration: InputDecoration(
                        label: const Center(
                          child: Text("Adresse email"),
                        ),
                        labelStyle: GoogleFonts.comfortaa(color: MyTheme.white),
                        contentPadding: EdgeInsets.fromLTRB(10, 0, 0, 20),
                        floatingLabelBehavior: FloatingLabelBehavior.never,
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white30, width: 1),
              borderRadius: BorderRadius.circular(30),
              color: const Color.fromRGBO(255, 255, 255, 0.1),
            ),
            height: 50,
            child: Row(
              children: [
                Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    color: MyTheme.white,
                  ),
                  child: const Icon(
                    Icons.phone_android_outlined,
                    size: 25,
                    color: MyTheme.blue3,
                  ),
                ),
                SizedBox(
                  height: 60,
                  width: 280,
                  child: Center(
                    child: TextField(
                      controller: mobileField,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.comfortaa(
                          fontSize: 17,
                          color: MyTheme.white,
                          fontWeight: FontWeight.bold),
                      decoration: InputDecoration(
                        label: const Center(
                          child: Text("Numéro téléphone"),
                        ),
                        labelStyle: GoogleFonts.comfortaa(color: MyTheme.white),
                        contentPadding: EdgeInsets.fromLTRB(10, 0, 0, 20),
                        floatingLabelBehavior: FloatingLabelBehavior.never,
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white30, width: 1),
              borderRadius: BorderRadius.circular(30),
              color: const Color.fromRGBO(255, 255, 255, 0.1),
            ),
            height: 50,
            child: Row(
              children: [
                Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    color: MyTheme.white,
                  ),
                  child: const Icon(
                    Icons.lock_outline,
                    size: 25,
                    color: MyTheme.blue3,
                  ),
                ),
                SizedBox(
                  height: 60,
                  width: 280,
                  child: Center(
                    child: TextField(
                      controller: passwordField,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.comfortaa(
                          fontSize: 17,
                          color: MyTheme.white,
                          fontWeight: FontWeight.bold),
                      obscureText: true,
                      decoration: InputDecoration(
                        label: const Center(
                          child: Text("Mot de passe"),
                        ),
                        labelStyle: GoogleFonts.comfortaa(color: MyTheme.white),
                        contentPadding: EdgeInsets.fromLTRB(10, 0, 0, 20),
                        floatingLabelBehavior: FloatingLabelBehavior.never,
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white30, width: 1),
              borderRadius: BorderRadius.circular(30),
              color: const Color.fromRGBO(255, 255, 255, 0.1),
            ),
            height: 50,
            child: Row(
              children: [
                Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    color: MyTheme.white,
                  ),
                  child: const Icon(
                    Icons.date_range,
                    size: 25,
                    color: MyTheme.blue3,
                  ),
                ),
                SizedBox(
                  height: 60,
                  width: 280,
                  child: Center(
                    child: TextField(
                      readOnly: true,
                      controller: birthdateField,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.comfortaa(
                          fontSize: 17,
                          color: MyTheme.white,
                          fontWeight: FontWeight.bold),
                      // obscureText: true,
                      decoration: InputDecoration(
                        label: const Center(
                          child: Text("Date de naissance"),
                        ),
                        labelStyle: GoogleFonts.comfortaa(color: MyTheme.white),
                        contentPadding: EdgeInsets.fromLTRB(10, 0, 0, 20),
                        floatingLabelBehavior: FloatingLabelBehavior.never,
                        border: InputBorder.none,
                      ),
                      onTap: () async {
                        DateTime? newDate = await showDatePicker(
                          context: context,
                          initialDate: defaultDateTime,
                          firstDate: DateTime(1900),
                          lastDate: DateTime(2100),
                        );

                        if (newDate == null) {
                          return;
                        } else {
                          setState(() {
                            defaultDateTime = newDate;
                          });
                          _updateDate();
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 15),
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Radio<Sexe>(
                          value: Sexe.homme,
                          groupValue: _sexe,
                          onChanged: (Sexe? value) {
                            setState(() {
                              _sexe = value;
                            });
                          }),
                      Expanded(
                        child: Text(
                          'Homme',
                          style: TextStyle(
                            color: MyTheme.white,
                          ),
                        ),
                      )
                    ],
                  ),
                  flex: 1,
                ),
                Expanded(
                  child: Row(
                    children: [
                      Radio<Sexe>(
                          value: Sexe.femme,
                          groupValue: _sexe,
                          onChanged: (Sexe? value) {
                            setState(() {
                              _sexe = value;
                            });
                          }),
                      Expanded(
                        child: Text(
                          'Femme',
                          style: TextStyle(
                            color: MyTheme.white,
                          ),
                        ),
                      )
                    ],
                  ),
                  flex: 1,
                ),
              ],
            ),
          ),
          const SizedBox(height: 15),
          SizedBox(
            height: 60,
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                try {
                  await auth
                      .createUserWithEmailAndPassword(
                    email: emailField.text.trim(),
                    password: passwordField.text.trim(),
                  )
                      .then((value) {
                    print(value.user!.uid);
                    addUser(
                      value.user!.uid,
                      firstLastNameField.text.trim(),
                      defaultDateTime.toString().trim(),
                      mobileField.text.toString().trim(),
                      (_sexe == Sexe.homme) ? true : false,
                    );

                    Fluttertoast.showToast(
                      msg: "Inscription réussie, connexion",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.BOTTOM,
                      backgroundColor: MyTheme.blue3,
                      textColor: Colors.white,
                      fontSize: 16.0,
                    );
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => HomeTenant()),
                    );
                  });
                } on FirebaseAuthException catch (e) {
                  if (e.code == 'invalid-email') {
                    Fluttertoast.showToast(
                      msg: "Email invalide.",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.BOTTOM,
                      backgroundColor: Colors.red,
                      textColor: Colors.white,
                      fontSize: 16.0,
                    );
                  } else if (e.code == 'email-already-in-use') {
                    Fluttertoast.showToast(
                      msg: "Email déja utilisé",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.BOTTOM,
                      backgroundColor: Colors.red,
                      textColor: Colors.white,
                      fontSize: 16.0,
                    );
                  } else if (e.code == 'missing-email') {
                    Fluttertoast.showToast(
                      msg: "Veuillez saisir votre adresse mail",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.BOTTOM,
                      backgroundColor: Colors.red,
                      textColor: Colors.white,
                      fontSize: 16.0,
                    );
                  } else if (e.code == 'operation-not-allowed') {
                    Fluttertoast.showToast(
                      msg: "Not allowed",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.BOTTOM,
                      backgroundColor: Colors.red,
                      textColor: Colors.white,
                      fontSize: 16.0,
                    );
                  } else if (e.code == 'weak-password') {
                    Fluttertoast.showToast(
                      msg: "Mot de passe trop faible",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.BOTTOM,
                      backgroundColor: Colors.red,
                      textColor: Colors.white,
                      fontSize: 16.0,
                    );return;
                  }
                  else {
                    Fluttertoast.showToast(
                      msg: "Error: ${e.code}",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.BOTTOM,
                      backgroundColor: Colors.red,
                      textColor: Colors.white,
                      fontSize: 16.0,
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                primary: MyTheme.white,
                elevation: 5,
              ),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 15),
                width: MediaQuery.of(context).size.width,
                child: Text(
                  'Inscription',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.comfortaa(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: MyTheme.blue3,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _updateDate() {
    setState(() {
      birthdateField.text = ((defaultDateTime.year == 0)
          ? ""
          : ((defaultDateTime.day < 10)
                  ? "0" + defaultDateTime.day.toString()
                  : defaultDateTime.day.toString()) +
              "/" +
              ((defaultDateTime.month < 10)
                  ? "0" + defaultDateTime.month.toString()
                  : defaultDateTime.month.toString()) +
              "/" +
              defaultDateTime.year.toString());
    });
  }

  Future<void> addUser(String userID, String firstLastName, String birthdate,
      String mobilePhone, bool hf) {
    return firestore
        .collection('Users')
        .doc(userID)
        .set({
          'first_last_name': firstLastName,
          'about': '',
          'birthdate': birthdate,
          'mobile_phone': mobilePhone,
          'sexe': hf,
        })
        .then((value) => print("Utilisateur ajouté"))
        .catchError(
          (error) => {print("Erreur: $error")},
        );
  }
}