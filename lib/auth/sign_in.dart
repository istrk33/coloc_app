import 'package:coloc_app/themes/color.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

FirebaseAuth auth = FirebaseAuth.instance;

class LoginPage extends StatelessWidget {
  const LoginPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            MyTheme.blue3,
            MyTheme.blue3,
            MyTheme.blue2,
          ],
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          children: [
            flutterIcon,
            titleSection,
            // textSection,
            InputSection(),
            forgetButton,
          ],
        ),
      ),
    );
  }
}

Widget flutterIcon = Container(
  margin: const EdgeInsets.only(top: 10),
  padding: const EdgeInsets.all(5),
  // decoration: BoxDecoration(
  //   borderRadius: BorderRadius.circular(60),
  //   color: const Color.fromRGBO(255, 255, 255, 0.1),
  // ),
  height: 275,
  width: 275,
  child: Container(
    // padding: const EdgeInsets.all(0),
    // decoration: BoxDecoration(
    //   borderRadius: BorderRadius.circular(40),
    //   color: Colors.white,
    //   boxShadow: [
    //     BoxShadow(
    //       color: Colors.black.withOpacity(0.1),
    //       spreadRadius: 5,
    //       blurRadius: 15,
    //       offset: const Offset(0, 3),
    //     ),
    //   ],
    // ),
    child: Image.asset('assets/images/logo.png'),
  ),
);

Widget titleSection = Container(
  margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
  child: Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Text(
        'Coloc',
        style: GoogleFonts.exo(
          fontSize: 40,
          fontWeight: FontWeight.w900,
          color: MyTheme.white,
        ),
      ),
      const SizedBox(width: 3),
      Text(
        'App',
        style: GoogleFonts.exo(
            fontSize: 40, fontWeight: FontWeight.w900, color: MyTheme.blue4),
      ),
    ],
  ),
);

// Widget textSection = Container(
//   margin: const EdgeInsets.fromLTRB(0, 5, 0, 10),
//   child: Text(
//     'Page de connexion Firebase',
//     style: GoogleFonts.comfortaa(
//       fontSize: 16,
//       fontWeight: FontWeight.bold,
//       color: Colors.red.shade700,
//     ),
//   ),
// );

class InputSection extends StatelessWidget {
  InputSection({Key? key}) : super(key: key);
  final emailField = TextEditingController();
  final passwordField = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(15),
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
                    color: Colors.white,
                  ),
                  child: const Icon(
                    Icons.people_outline,
                    size: 25,
                    color: MyTheme.blue3,
                  ),
                ),
                SizedBox(
                  height: 60,
                  width: 270,
                  child: Center(
                    child: TextField(
                      controller: emailField,
                      keyboardType: TextInputType.emailAddress,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.comfortaa(
                          fontSize: 18,
                          color: MyTheme.white,
                          fontWeight: FontWeight.bold),
                      obscureText: false,
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
          const SizedBox(height: 15),
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
                          fontSize: 18,
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
          SizedBox(
            height: 60,
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: MyTheme.white,
                padding: const EdgeInsets.fromLTRB(10, 15, 10, 15),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(30)),
                ),
              ),
              child: Text(
                "Connexion".toUpperCase(),
                style: const TextStyle(
                  color: MyTheme.blue3,
                  fontSize: 20.0,
                ),
              ),
              onPressed: () {
                loginToFirebase();
              },
            ),
          ),
        ],
      ),
    );
  }

  void loginToFirebase() {
    print(emailField.text.trim());
    print(passwordField.text.trim());
    try {
      auth
          .signInWithEmailAndPassword(
              email: emailField.text.trim(),
              password: passwordField.text.trim())
          .then((value) {
        print(value.toString());
      });
    } catch (e) {
      print(e.toString());
    }
  }
}

Widget forgetButton = TextButton(
  onPressed: () {},
  child: Text(
    'Mot de passe oublié ?',
    style: GoogleFonts.comfortaa(
      color: MyTheme.white,
      fontWeight: FontWeight.bold,
    ),
  ),
);
