// ignore_for_file: must_be_immutable, library_prefixes, avoid_unnecessary_containers, no_leading_underscores_for_local_identifiers, unnecessary_const

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:preggo/baby_information.dart';
import '../colors.dart';
import '../model/pregnancy_model.dart';
import '../model/user_model.dart';
import '../pregnancyTapped.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:preggo/colors.dart';
import 'package:preggo/login_screen.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/calendar/v3.dart' as Cal;
import 'package:awesome_notifications/awesome_notifications.dart';
// import 'package:preggo/profile/cubit/profile_cubit.dart';
import 'package:preggo/profile/edit_profile.dart';
import 'package:shared_preferences/shared_preferences.dart';

extension StringExtension on String {
  String capitalize() {
    if (int.tryParse(this[0]) == null) {
      return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
    }
    final chars = split('');
    for (int i = 0; i < chars.length; i++) {
      if (int.tryParse(chars[i]) != null) {
        continue;
      }
      return "${substring(0, i).toLowerCase()}${this[i].toUpperCase()}${substring(i + 1).toLowerCase()}";
    }
    return this;
  }
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  FirebaseAuth auth = FirebaseAuth.instance;
  UserModel? user;
  List<PregnancyInfoModel>? pregnancyInfoModel;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backGroundPink,
      body:FutureBuilder(
        future:getUserData() ,
        builder:(context, snapshot) => snapshot.hasData? Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(
                  top: 50, left: 20, right: 20, bottom: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // InkWell(
                  // onTap: ()=> Navigator.pop(context),
                  //  child: Image.asset("assets/images/arrow-left.png")),
                  Container(
                    alignment: Alignment.topCenter,
                    padding: const EdgeInsets.only(top: 40),
                    child: const Text(
                      "Profile",
                      style: TextStyle(
                        color: Color(0xFFD77D7C),
                        fontSize: 38,
                        fontFamily: 'Urbanist',
                        fontWeight: FontWeight.w700,
                        height: 1.30,
                        letterSpacing: -0.28,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Stack(
              alignment: AlignmentDirectional.bottomCenter,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10.0,
                    vertical: 20.0,
                  ),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(80.0),
                    ),
                  ),
                  width: double.infinity,
                  child: const Text(""),
                ),
                CircleAvatar(
                  backgroundColor: Colors.grey[200],
                  radius: 50,
                  child: Text(
                    user!.userName.split("")[0].toUpperCase(),
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 22,
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
              child: Container(
                width: double.infinity,
                color: Colors.white,
                child: Container(
                  padding: const EdgeInsets.symmetric(),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(80.0),
                    ),
                  ),
                  width: double.infinity,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        const SizedBox(
                          height: 10,
                        ),
                        Container(
                          height: 50,
                          padding: const EdgeInsets.only(
                              top: 10, bottom: 10, left: 20, right: 20),
                          decoration: BoxDecoration(
                              color: blackColor,
                              borderRadius: BorderRadius.circular(10)),
                          child: TextButton(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) =>
                                      const EditProfileScreen())).then(
                                      (value) => getUserData());
                            },
                            child: const Text(
                              "Edit Profile",
                              style: TextStyle(color: whiteColor),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(color: Colors.grey[200]),
                          child: const Center(
                              child: Text(
                                "Account information",
                                style: TextStyle(
                                    color: pinkColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18),
                              )),
                        ),
                        Container(
                          padding: const EdgeInsets.all(15),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  const SizedBox(
                                    width: 5,
                                  ),
                                  const Icon(
                                    Icons.person_outline_outlined,
                                    color: grayColor,
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Text(
                                    user!.userName.capitalize(),
                                    style: const TextStyle(fontSize: 16),
                                  )
                                ],
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Row(
                                children: [
                                  const SizedBox(
                                    width: 5,
                                  ),
                                  const Icon(
                                    Icons.email_outlined,
                                    color: grayColor,
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Text(
                                    user!.email,
                                    style: const TextStyle(fontSize: 16),
                                  )
                                ],
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Row(
                                children: [
                                  const SizedBox(
                                    width: 5,
                                  ),
                                  const Icon(
                                    Icons.phone_outlined,
                                    color: grayColor,
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Text(
                                    user!.phone.isEmpty ? "" : user!.phone,
                                    style: const TextStyle(fontSize: 16),
                                  )
                                ],
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(color: Colors.grey[200]),
                          child: const Center(
                              child: Text(
                                "Pregnancy history",
                                style: TextStyle(
                                    color: pinkColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18),
                              )),
                        ),
                        SizedBox(
                          // height: pregnancyInfoModel!.length <= 1 ? 40 : 65,
                          child: ListView.separated(
                            padding: const EdgeInsets.all(8),
                            itemCount: pregnancyInfoModel!.length,
                            shrinkWrap: true,
                            itemBuilder: (BuildContext context, int index) =>
                                InkWell(
                                  onTap: () {
                                    print('baby id is ${pregnancyInfoModel![index].id}');
                                    if (pregnancyInfoModel![index].ended == "true") {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => pregnancyTapped(
                                                pregnancyInfoModel![index].gender),
                                            settings: RouteSettings(
                                              arguments: pregnancyInfoModel![index].id,
                                            ),
                                          ));
                                    } else {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => BabyInformation(),
                                          settings: RouteSettings(
                                              arguments: pregnancyInfoModel![index].id),
                                        ),
                                      );
                                    }
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10.0),
                                    child: Row(
                                      children: [
                                        Image.asset(
                                          pregnancyInfoModel![index].gender == "Girl"
                                              ? 'assets/images/baby-girl.png'
                                              : pregnancyInfoModel![index].gender == "Boy"
                                              ? "assets/images/babyBoy.png"
                                              : "assets/images/baby.png",
                                          height: 25,
                                          width: 25,
                                        ),
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        Text(
                                          pregnancyInfoModel![index].babyName,
                                          style: const TextStyle(fontSize: 16),
                                        ),
                                        const Spacer(),
                                        const Icon(Icons.navigate_next_sharp),
                                      ],
                                    ),
                                  ),
                                ),
                            separatorBuilder:
                                (BuildContext context, int index) =>
                            const SizedBox(
                              height: 5,
                            ),
                          ),
                        ),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(color: Colors.grey[200]),
                          child: const Center(
                              child: Text(
                                "...",
                                style: TextStyle(
                                    color: pinkColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18),
                              )),
                        ),
                        InkWell(
                          onTap: () {
                            showDialog<void>(
                              context: context,
                              barrierDismissible: false,
                              // user must tap button!
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  // <-- SEE HERE

                                  content: const SingleChildScrollView(
                                    child: ListBody(
                                      children: <Widget>[
                                        Center(
                                          child: Text(
                                            'Are you sure you want to \nSign Out ?',
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  actions: <Widget>[
                                    Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.center,
                                      children: [
                                        ElevatedButton(
                                          onPressed: () async {
                                            Navigator.pop(context);
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: blackColor,
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                BorderRadius.circular(
                                                    40)),
                                            padding: const EdgeInsets.only(
                                                left: 30,
                                                top: 15,
                                                right: 30,
                                                bottom: 15),
                                          ),
                                          child: const Text(
                                            " Cancel  ",
                                          ),
                                        ),
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        ElevatedButton(
                                          onPressed: () async {
                                            const _scopes = const [
                                              Cal.CalendarApi.calendarScope
                                            ]; //scope to CREATE EVENT in calendar
                                            GoogleSignIn _googleSignIn =
                                            GoogleSignIn(
                                              // Optional clientId
                                              // clientId: 'your-client_id.apps.googleusercontent.com',
                                              scopes: _scopes,
                                            );

                                            _googleSignIn.disconnect();

                                            //disconnect the authorized google account on logging out
                                            await auth.signOut();
                                            await AwesomeNotifications()
                                                .cancelAll();

                                            // TODO: POST COMMUNITY - CLEAR LOCAL PREFS
                                            SharedPreferences prefs =
                                            await SharedPreferences
                                                .getInstance();
                                            prefs.clear();
                                            // End
                                            if (context.mounted) {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                  const LoginScreen(),
                                                ),
                                              );
                                            }
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Theme.of(context)
                                                .colorScheme
                                                .error,
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                BorderRadius.circular(
                                                    40)),
                                            padding: const EdgeInsets.only(
                                                left: 30,
                                                top: 15,
                                                right: 30,
                                                bottom: 15),
                                          ),
                                          child: const Text(
                                            "Sign Out",
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          child: const Padding(
                            padding: EdgeInsets.fromLTRB(
                                12, 5, 5, 5), // EdgeInsets.all(5),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 5,
                                ),
                                Icon(
                                  Icons.logout,
                                  color: Colors.red,
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  "Sign Out",
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.red),
                                ),
                              ],
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            showDialog<void>(
                              context: context,
                              barrierDismissible: false,
                              // user must tap button!
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  // <-- SEE HERE

                                  content: const SingleChildScrollView(
                                    child: ListBody(
                                      children: <Widget>[
                                        Center(
                                          child: Text(
                                            'Are you sure you want to \ndelete your account?',
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  actions: <Widget>[
                                    Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.center,
                                      children: [
                                        ElevatedButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: blackColor,
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                BorderRadius.circular(
                                                    40)),
                                            padding: const EdgeInsets.only(
                                                left: 30,
                                                top: 15,
                                                right: 30,
                                                bottom: 15),
                                          ),
                                          child: const Text(
                                            "Cancel",
                                          ),
                                        ),
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        ElevatedButton(
                                          onPressed: () async {
                                            await deleteAccount();
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Theme.of(context)
                                                .colorScheme
                                                .error,
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                BorderRadius.circular(
                                                    40)),
                                            padding: const EdgeInsets.only(
                                                left: 30,
                                                top: 15,
                                                right: 30,
                                                bottom: 15),
                                          ),
                                          child: const Text(
                                            "Delete",
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          child: const Padding(
                            padding: EdgeInsets.all(10),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 5,
                                ),
                                Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  "Delete Account",
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.red),
                                ),
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ):Center(child: CircularProgressIndicator()),
      ),

    );
  }


  Future getUserData() async {
    print("+++++++++++++++++++++++++${FirebaseAuth.instance.currentUser!.uid}");
    try {
      var response = await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get();
      user = UserModel.fromJson(response.data()!);
      var response3 = await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection("pregnancyInfo").orderBy("DueDate",descending: true)
          .get();
      pregnancyInfoModel = [];
      for (var element in response3.docs) {
        pregnancyInfoModel!
            .add(PregnancyInfoModel.fromJson(element.data(), element.id));
      }
      return pregnancyInfoModel;
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> deleteAccount() async {
    // Get the user's document reference from the `users` collection.
    final userDocRef = FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid);

    CollectionReference subCollectionRef =
    userDocRef // replace with your document ID
        .collection('pregnancyInfo');
    QuerySnapshot subCollectionQuery = await subCollectionRef.get();

    for (QueryDocumentSnapshot doc in subCollectionQuery.docs) {
      DocumentReference docRef = subCollectionRef.doc(doc.id);
      await docRef.delete();
    }
    CollectionReference subCollectionRefReminder =
    userDocRef // replace with your document ID
        .collection('reminders');
    QuerySnapshot subCollectionQueryReminder =
    await subCollectionRefReminder.get();

    for (QueryDocumentSnapshot doc in subCollectionQueryReminder.docs) {
      DocumentReference docRefReminder = subCollectionRefReminder.doc(doc.id);
      await docRefReminder.delete();
    }
    var community =
    await FirebaseFirestore.instance.collection('community').get();
    for (var element in community.docs) {
      if (element.data()["userID"] == FirebaseAuth.instance.currentUser!.uid) {
        var communityDocs = FirebaseFirestore.instance.collection('community');

        communityDocs.doc(element.id).delete();

        var replies = communityDocs.doc(element.id).collection("Replies");
        QuerySnapshot subCollectionQueryReplies = await replies.get();
        for (QueryDocumentSnapshot doc in subCollectionQueryReplies.docs) {
          DocumentReference docRef = replies.doc(doc.id);
          await docRef.delete();
        }
      }
      var repliesInUser = await FirebaseFirestore.instance
          .collection('community')
          .doc(element.id)
          .collection("Replies")
          .get();
      for (var replayData in repliesInUser.docs) {
        if (replayData.data()["userID"] ==
            FirebaseAuth.instance.currentUser!.uid) {
          await FirebaseFirestore.instance
              .collection('community')
              .doc(element.id)
              .collection("Replies")
              .doc(replayData.id)
              .delete();
        }
      }
    }

    // Delete the user's document from the `users` collection.
    await userDocRef.delete();

    // Delete the user's account from Firebase Authentication.
    await FirebaseAuth.instance.currentUser!.delete();

    await FirebaseAuth.instance.signOut();
    return showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return Center(
            child: SizedBox(
              height: MediaQuery.sizeOf(context).height * 0.40,
              width: MediaQuery.sizeOf(context).width * 0.85,
              child: Dialog(
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                    color: Color.fromRGBO(255, 255, 255, 1),
                    borderRadius: BorderRadius.all(
                      Radius.circular(20),
                    ),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.all(15),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: green,
                            //color: pinkColor,
                            // border: Border.all(
                            //   width: 1.3,
                            //   color: Colors.black,
                            // ),
                          ),
                          child: const Icon(
                            Icons.check,
                            color: Color.fromRGBO(255, 255, 255, 1),
                            size: 35,
                          ),
                        ),
                        const SizedBox(height: 25),

                        // Done
                        const Text(
                          "Profile deleted successfully!",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color.fromARGB(255, 0, 0, 0),
                            fontSize: 17,
                            fontFamily: 'Urbanist',
                            fontWeight: FontWeight.w700,
                            height: 1.30,
                            letterSpacing: -0.28,
                          ),
                        ),

                        const SizedBox(height: 20),

                        /// OK Button
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10),
                          width:
                          MediaQuery.sizeOf(context).width * 0.80,
                          height: 45.0,
                          child: Center(
                            child: ElevatedButton(
                              onPressed: () {
                                if (mounted) {
                                  Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) =>
                                        const LoginScreen()),
                                        (route) => false,
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: blackColor,
                                shape: RoundedRectangleBorder(
                                    borderRadius:
                                    BorderRadius.circular(40)),
                                padding: const EdgeInsets.only(
                                    left: 70,
                                    top: 15,
                                    right: 70,
                                    bottom: 15),
                              ),
                              child: const Text(
                                "OK",
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        });
    // Return a success message.
  }

}
