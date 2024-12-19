import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_tracker/widgets/expenses.dart';
import 'package:expense_tracker/screens/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
//import 'package:flutter/services.dart';

var kColorScheme =
    ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 96, 59, 181));
var kDarkColorScheme = ColorScheme.fromSeed(
    brightness: Brightness.dark,
    seedColor: const Color.fromARGB(255, 5, 99, 125));
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseFirestore.instance.settings =
      const Settings(persistenceEnabled: true);
  // SystemChrome.setPreferredOrientations([
  //   DeviceOrientation.portraitDown,
  // ]).then((fn) {
  runApp(
    MaterialApp(
      //setting it up at one place, and then referring and reusing it at multiple places
      darkTheme: ThemeData.dark().copyWith(
        colorScheme: kDarkColorScheme,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: kDarkColorScheme.primaryContainer,
            //foregroundColor: kDarkColorScheme.primaryContainer),
          ),
        ),
      ),
      theme: ThemeData().copyWith(
          colorScheme: kColorScheme,
          appBarTheme: const AppBarTheme().copyWith(
              backgroundColor: kColorScheme.onPrimaryContainer,
              foregroundColor: kColorScheme.primaryContainer),
          cardTheme: const CardTheme().copyWith(
            color: kColorScheme.secondaryContainer,
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
                backgroundColor: kColorScheme.primaryContainer),
          ),
          textTheme: ThemeData().textTheme.copyWith()),
      themeMode: ThemeMode.system, //system settings based on user

      home: FirebaseAuth.instance.currentUser != null
          ? const Expenses()
          : const LoginPage(),
      debugShowCheckedModeBanner: false,
    ),
  );
}//);
//}
