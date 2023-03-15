import 'package:coloc_app/themes/color.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'auth/sign_in.dart';
import 'auth/sign_up.dart';
import 'firebase_options.dart';
import 'pages/uis/common/navbar.dart';

FirebaseAuth auth = FirebaseAuth.instance;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  auth.authStateChanges().listen((User? user) {
    if (user == null) {
      print('Utilisateur non connecté');
      runApp(const LoginTabBar());
    } else {
      print('Utilisateur connecté: ' + user.email!);
      runApp((Navbar()));
    }
  });
}

class LoginTabBar extends StatelessWidget {
  const LoginTabBar({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: [GlobalMaterialLocalizations.delegate, GlobalWidgetsLocalizations.delegate],
      supportedLocales: [const Locale('en'), const Locale('fr')],
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        backgroundColor: MyTheme.blue3,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        /* dark theme settings */
      ),
      themeMode: ThemeMode.system,
      home: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: MyTheme.blue3,
            bottom: const TabBar(
              tabs: [Tab(text: 'Connexion'), Tab(text: 'Inscription')],
            ),
            title: const Text('ColocApp'),
          ),
          body: const TabBarView(
            children: [
              LoginPage(),
              SignupPage(),
            ],
          ),
        ),
      ),
    );
  }
}
