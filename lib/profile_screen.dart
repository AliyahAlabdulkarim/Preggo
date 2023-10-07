import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:preggo/colors.dart';
import 'package:preggo/login_screen.dart';
import 'package:awesome_notifications/awesome_notifications.dart';

class ProfileScreen extends StatelessWidget {
  ProfileScreen({super.key});

  FirebaseAuth auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backGroundPink,
      body: Column(
        children: [
          Padding(
            padding:
                const EdgeInsets.only(top: 50, left: 20, right: 20, bottom: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // InkWell(
                // onTap: ()=> Navigator.pop(context),
                //  child: Image.asset("assets/images/arrow-left.png")),
                Row(
                  children: [
                    Expanded(
                        child: Container(
                            child: const Center(
                                child: Text(
                      "Profile",
                      style: TextStyle(fontSize: 23, color: Colors.black),
                    )))),
                  ],
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
                child: const Text(
                  "N",
                  style: TextStyle(
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
                child: Column(
                  children: [
                    const SizedBox(
                      height: 10,
                    ),
                    Container(
                      padding: const EdgeInsets.only(
                          top: 10, bottom: 10, left: 20, right: 20),
                      decoration: BoxDecoration(
                          color: blackColor,
                          borderRadius: BorderRadius.circular(10)),
                      child: const Text(
                        "Edit Profile",
                        style: TextStyle(color: whiteColor),
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
                      child: const Column(
                        children: [
                          Row(
                            children: [
                              SizedBox(
                                width: 5,
                              ),
                              Icon(
                                Icons.person_outline_outlined,
                                color: grayColor,
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Text(
                                "nalhumaidani",
                                style: TextStyle(fontSize: 16),
                              )
                            ],
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Row(
                            children: [
                              SizedBox(
                                width: 5,
                              ),
                              Icon(
                                Icons.email_outlined,
                                color: grayColor,
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Text(
                                "nalhumaidani@hotmail.com",
                                style: TextStyle(fontSize: 16),
                              )
                            ],
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Row(
                            children: [
                              SizedBox(
                                width: 5,
                              ),
                              Icon(
                                Icons.phone_outlined,
                                color: grayColor,
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Text(
                                "+966 559-602-036",
                                style: TextStyle(fontSize: 16),
                              )
                            ],
                          ),
                          SizedBox(
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
                    Container(
                      padding: const EdgeInsets.all(15),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              const SizedBox(
                                width: 5,
                              ),
                              Image.asset(
                                'assets/images/person.png',
                                height: 25,
                                width: 25,
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              const Text(
                                "Ahmed",
                                style: TextStyle(fontSize: 16),
                              ),
                              const Spacer(),
                              const Icon(Icons.navigate_next_sharp)
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
                              Image.asset(
                                'assets/images/person.png',
                                height: 25,
                                width: 25,
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              const Text(
                                "Omar",
                                style: TextStyle(fontSize: 16),
                              ),
                              const Spacer(),
                              const Icon(Icons.navigate_next_sharp)
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
                        "Sign Out",
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
                          barrierDismissible: false, // user must tap button!
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
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    InkWell(
                                      child: Container(
                                        padding: const EdgeInsets.only(
                                            top: 10,
                                            bottom: 10,
                                            left: 25,
                                            right: 25),
                                        decoration: BoxDecoration(
                                            color: Colors.grey,
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                        child: const Text(
                                          "Cancel",
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                      onTap: () => Navigator.pop(context),
                                    ),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    InkWell(
                                      child: Container(
                                        padding: const EdgeInsets.only(
                                            top: 10,
                                            bottom: 10,
                                            left: 20,
                                            right: 20),
                                        decoration: BoxDecoration(
                                            color: Colors.red,
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                        child: const Text(
                                          "Sign Out",
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                      onTap: () async{
                                      await auth.signOut();
                                        await AwesomeNotifications()
                                            .cancelAll();
                                        if (context.mounted) {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    const LoginScreen(),
                                              ));
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            );
                          },
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(15),
                        child: Row(
                          children: [
                            const SizedBox(
                              width: 5,
                            ),
                            Image.asset(
                              'assets/images/logOut.png',
                              height: 25,
                              width: 25,
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            const Text(
                              "Sign Out",
                              style: TextStyle(fontSize: 16, color: Colors.red),
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
        ],
      ),
    );
  }
}
