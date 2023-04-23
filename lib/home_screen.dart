// ignore_for_file: unnecessary_brace_in_string_interps

import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:study_buddy_courses/firebase_services.dart';
import 'package:study_buddy_courses/images.dart';
import 'package:study_buddy_courses/provider_class.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:study_buddy_courses/splash_page.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int myCoins = 0;

  int courseValue = 300;

  bool sem1Status = false;
  bool sem2Status = false;
  _fetchCoins() async {
    final CollectionReference userCollection = FirebaseFirestore.instance.collection('Users');
    final userDoc = await userCollection.doc(Provider.of<AppProvider>(context, listen: false).getUid()).get();
    final coins = userDoc.get("coins");
    try {
      final tempSem1Status = userDoc.get("sem1");
      sem1Status = tempSem1Status;
    } catch (e) {
      sem1Status = false;

      print(e.toString());
    }

    try {
      final tempSem2Status = userDoc.get("sem2");

      sem2Status = tempSem2Status;
    } catch (e) {
      sem2Status = false;
    }

    log('$sem1Status $sem2Status');
    myCoins = coins;
    setState(() {});
  }

  @override
  void initState() {
    _fetchCoins();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var user = FirebaseAuth.instance.currentUser;

    return Consumer<AppProvider>(builder: (context, details, child) {
      return Scaffold(
        backgroundColor: Colors.blue.shade900.withOpacity(.5),
        appBar: AppBar(
          title: const Text('Earn Courses'),
          backgroundColor: Colors.blue[900],
          elevation: 0.2,
          actions: [
            IconButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Logout'),
                    content: const Text('Are you sure you want to logout?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('CANCEL'),
                      ),
                      TextButton(
                        onPressed: () {
                          FirebaseServices().signOut();
                          Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SplashPage(),
                              ),
                              (route) => false);
                        },
                        child: const Text('LOGOUT'),
                      ),
                    ],
                  ),
                );
              },
              icon: const Icon(Icons.logout),
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              details.isLoading ? LoadingDialog() : const SizedBox.shrink(),
              Card(
                elevation: 8,
                color: Colors.transparent,
                shadowColor: Colors.grey.shade100,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Container(
                  margin: const EdgeInsets.all(5),
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: const LinearGradient(
                      colors: [
                        Color.fromARGB(255, 245, 244, 159),
                        Color.fromARGB(255, 255, 185, 180),
                        Color.fromARGB(255, 255, 222, 210),
                        Color.fromARGB(255, 248, 209, 255),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Welcome back,',
                            style: TextStyle(
                              fontSize: 16.0,
                              color: Colors.grey[600],
                            ),
                          ),
                          ElevatedButton(
                              onPressed: () async {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    content: const Text(
                                      'Watch rewared ad to earn more coins',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child: const Text(
                                            'Cancel',
                                          ),
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: TextButton(
                                          onPressed: () async {
                                            await Provider.of<AppProvider>(context, listen: false).loadRewardedAd(() {
                                              final CollectionReference userCollection = FirebaseFirestore.instance.collection('Users');
                                              userCollection.doc(Provider.of<AppProvider>(context, listen: false).getUid()).update({
                                                "coins": myCoins + 10
                                              });

                                              _fetchCoins();
                                              Navigator.pop(context);

                                              log('reward is earned successfully');
                                            });
                                          },
                                          child: const Text(
                                            'Watch Now',
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                );
                              },
                              style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty.resolveWith((states) {
                                    if (states.contains(MaterialState.pressed)) {
                                      return Colors.black26;
                                    }
                                    return Colors.white60;
                                  }),
                                  foregroundColor: MaterialStateProperty.resolveWith((states) {
                                    if (states.contains(MaterialState.pressed)) {
                                      return Colors.black26;
                                    }
                                    return Colors.white;
                                  }),
                                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(borderRadius: BorderRadius.circular(13.0), side: const BorderSide(color: Colors.white)))),
                              child: Row(
                                children: const [
                                  Text(
                                    'Earn more',
                                    style: TextStyle(color: Colors.black),
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Icon(Icons.arrow_forward_ios_outlined),
                                ],
                              )),
                        ],
                      ),
                      const SizedBox(height: 8.0),
                      Text(
                        '${user!.displayName}',
                        style: const TextStyle(
                          fontSize: 24.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      Text(
                        '${user.email}',
                        style: TextStyle(
                          fontSize: 16.0,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Balance',
                            style: TextStyle(fontSize: 20.0, color: Colors.grey[600], fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '${myCoins}',
                            style: TextStyle(
                              fontSize: 24.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.green[700],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20.0),
              GestureDetector(
                onTap: sem1Status
                    ? null
                    : myCoins >= courseValue
                        ? () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Logout'),
                                content: const Text('Are you sure you want to unlock this course'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('CANCEL'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      final CollectionReference userCollection = FirebaseFirestore.instance.collection('Users');
                                      userCollection.doc(Provider.of<AppProvider>(context, listen: false).getUid()).update({
                                        "sem1": true,
                                        "coins": myCoins - courseValue
                                      }).then((value) {
                                        _fetchCoins();
                                        Navigator.pop(context);
                                      });
                                    },
                                    child: const Text('Unlock Now'),
                                  ),
                                ],
                              ),
                            );
                          }
                        : () async {
                            await Provider.of<AppProvider>(context, listen: false).loadRewardedAd(() {
                              final CollectionReference userCollection = FirebaseFirestore.instance.collection('Users');
                              userCollection.doc(Provider.of<AppProvider>(context, listen: false).getUid()).update({
                                "coins": myCoins + 10
                              });

                              _fetchCoins();

                              log('reward is earned successfully');
                            });
                          },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Stack(
                    children: [
                      Card(
                        color: Colors.grey.shade200,
                        elevation: 8,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadiusDirectional.circular(10)),
                        child: Container(
                          margin: const EdgeInsets.all(5),
                          height: 200,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'Semester I Full Course',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              sem1Status
                                  ? const Text(
                                      'This course is unlocked',
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.green,
                                      ),
                                    )
                                  : const Text(
                                      'This course is locked',
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.red,
                                      ),
                                    ),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 10,
                        left: MediaQuery.of(context).size.width * 0.4,
                        child: Image.asset(
                          sem1Status ? Images.unlockedCard : Images.lockedCard,
                          scale: 8,
                        ),
                      ),
                      Positioned(
                        top: 15,
                        right: MediaQuery.of(context).size.width * 0.1,
                        child: Row(
                          children: [
                            const Icon(
                              Icons.monetization_on,
                              color: Color.fromARGB(255, 123, 111, 0),
                            ),
                            Text(
                              courseValue.toString(),
                              style: const TextStyle(fontSize: 20, color: Color.fromARGB(255, 123, 111, 0), fontWeight: FontWeight.bold),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              GestureDetector(
                onTap: sem2Status
                    ? null
                    : myCoins >= courseValue
                        ? () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Logout'),
                                content: const Text('Are you sure you want to unlock this course'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('CANCEL'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      final CollectionReference userCollection = FirebaseFirestore.instance.collection('Users');
                                      userCollection.doc(Provider.of<AppProvider>(context, listen: false).getUid()).update({
                                        "sem2": true,
                                        "coins": myCoins - courseValue
                                      }).then((value) {
                                        _fetchCoins();
                                        Navigator.pop(context);
                                      });
                                    },
                                    child: const Text('Unlock Now'),
                                  ),
                                ],
                              ),
                            );
                          }
                        : () async {
                            await Provider.of<AppProvider>(context, listen: false).loadRewardedAd(() {
                              final CollectionReference userCollection = FirebaseFirestore.instance.collection('Users');
                              userCollection.doc(Provider.of<AppProvider>(context, listen: false).getUid()).update({
                                "coins": myCoins + 10
                              });

                              _fetchCoins();

                              log('reward is earned successfully');
                            });
                          },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Stack(
                    children: [
                      Card(
                        color: Colors.grey.shade200,
                        elevation: 8,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadiusDirectional.circular(10)),
                        child: Container(
                          margin: const EdgeInsets.all(5),
                          height: 200,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'Semester II Full Course',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              sem2Status
                                  ? const Text(
                                      'This course is unlocked',
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.green,
                                      ),
                                    )
                                  : const Text(
                                      'This course is locked',
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.red,
                                      ),
                                    ),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 10,
                        left: MediaQuery.of(context).size.width * 0.4,
                        child: Image.asset(
                          sem2Status ? Images.unlockedCard : Images.lockedCard,
                          scale: 8,
                        ),
                      ),
                      Positioned(
                        top: 15,
                        right: MediaQuery.of(context).size.width * 0.1,
                        child: Row(
                          children: [
                            const Icon(
                              Icons.monetization_on,
                              color: Color.fromARGB(255, 123, 111, 0),
                            ),
                            Text(
                              courseValue.toString(),
                              style: const TextStyle(fontSize: 20, color: Color.fromARGB(255, 123, 111, 0), fontWeight: FontWeight.bold),
                            )
                          ],
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
    });
  }
}

class LoadingDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            SizedBox(
              height: 50,
              width: 50,
              child: CircularProgressIndicator(
                strokeWidth: 5,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
              ),
            ),
            SizedBox(height: 20),
            Text(
              "Loading...",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
