// ignore_for_file: use_build_context_synchronously

import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:study_buddy_courses/home_screen.dart';
import 'package:study_buddy_courses/images.dart';
import 'package:study_buddy_courses/provider_class.dart';

class SignInScreen extends StatefulWidget {
  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<void> createNewUser(uid, fullName, email, coins) async {
    final CollectionReference userCollection = FirebaseFirestore.instance.collection('Users');

    // Check if user already exists
    final existingUser = await userCollection.doc(uid).get();
    if (existingUser.exists) {
      Provider.of<AppProvider>(context, listen: false).storeUserId(uid);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const HomeScreen(),
        ),
      );
      return;
    }

    // User is new, set coins to 10
    coins = 10;

    return await userCollection.doc(uid).set({
      "uid": uid,
      "name": fullName,
      "email": email,
      "coins": coins,
    }).then((value) {
      setState(() {
        _isLoading = true;
      });
      Provider.of<AppProvider>(context, listen: false).storeUserId(uid);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const HomeScreen(),
        ),
      );
    });
  }

  bool _isLoading = false;

  Future<void> _handleSignIn() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in with Firebase Auth
      await FirebaseAuth.instance.signInWithCredential(credential);

      // Create new user or update existing user
      createNewUser(
        FirebaseAuth.instance.currentUser!.uid,
        googleUser.displayName ?? '',
        googleUser.email,
        null, // Will be set to 10 if user is new
      );
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      log(error.toString());
      Fluttertoast.showToast(msg: error.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.blueAccent,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(25.0),
                    bottomRight: Radius.circular(25.0),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  // ignore: prefer_const_literals_to_create_immutables
                  children: [
                    Image.asset(
                      Images.appLogo,
                      scale: 2,
                    ),
                    const Text(
                      'Studdy Buddy',
                      style: TextStyle(
                        fontSize: 36.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 24.0),
                    const Text(
                      'Sign in to continue',
                      style: TextStyle(
                        fontSize: 16.0,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _isLoading
                        ? Image.asset(
                            Images.googleLoading,
                            scale: 3,
                          )
                        : ElevatedButton.icon(
                            onPressed: _handleSignIn,
                            style: ElevatedButton.styleFrom(
                              primary: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30.0),
                              ),
                            ),
                            icon: const Icon(Icons.person),
                            label: const Text(
                              'Sign in with Google',
                              style: TextStyle(
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.blueAccent,
                              ),
                            ),
                          ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
