// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:preggo/colors.dart';
import 'package:preggo/viewAppointment.dart';
import 'package:preggo/view_reminders.dart';
import 'package:preggo/weightFeature/view_delete_Weight.dart';

class ToolsPage extends StatefulWidget {
  const ToolsPage({super.key});

  @override
  _ToolsPage createState() => _ToolsPage();
}

class _ToolsPage extends State<ToolsPage> {
  @override
  initState() {
    super.initState();
  }

  Future<bool> isPregnant() async {
    var subCollectionRef = await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('pregnancyInfo')
        .where("ended", isEqualTo: 'false') //get current pregnancy
        .get();

    return subCollectionRef.docs
        .isEmpty; //true: not currently pregnant || false: currently pregnant => access tools
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: isPregnant(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasData) {
              if (snapshot.data == false) {
                return Tools(context);
              } else {
                return Container(
                  child: Text('not pregnant!'),
                );
              }
            }
            return Text('no data');
          }
          return Center(child: CircularProgressIndicator(color: pinkColor));
        },
      ),
    );
  }
}

Widget Tools(BuildContext context) {
  return Stack(
    children: [
      Container(
          margin: EdgeInsets.only(left: 20, top: 45),
          child: RichText(
            text: const TextSpan(
                style: TextStyle(
                  fontFamily: 'Urbanist',
                ),
                children: <TextSpan>[
                  TextSpan(
                      text: 'Tools\n',
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 35,
                          fontWeight: FontWeight.w400)),
                  TextSpan(
                      text: ' Use our tools to make your journey easier',
                      style:
                          TextStyle(color: Color.fromARGB(255, 121, 119, 119))),
                ]),
          )),
      Container(
        // the boxes
        margin: EdgeInsets.only(top: 85),
        padding: EdgeInsets.all(17), // the spaces between the boxes
        child: GridView(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 20,
              crossAxisSpacing: 10,
              childAspectRatio: 0.60),
          children: [
            InkWell(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            viewAppointment())); // Appointment page
              },
              child: Container(
                  //1-Appointments
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color.fromARGB(255, 236, 194, 193),
                          const Color.fromARGB(255, 251, 233, 234),
                        ],
                        begin: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20)),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    //crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Image.asset(
                        "assets/images/schedule.png",
                        height: 150,
                      ),
                      RichText(
                        text: const TextSpan(
                            style: TextStyle(
                              fontFamily: 'Urbanist',
                            ),
                            children: <TextSpan>[
                              TextSpan(
                                  text: ' Appointments\n',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700)),
                              TextSpan(
                                  text:
                                      '    Add new dates \n         and times ',
                                  style: TextStyle(
                                      color: Color.fromARGB(255, 96, 95, 95))),
                            ]),
                      )
                    ],
                  )),
            ),
            InkWell(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            view_delete_Weight())); // Track Weight page
              },
              child: Container(
                  //2- weight
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color.fromARGB(255, 236, 194, 193),
                          const Color.fromARGB(255, 251, 233, 234),
                        ],
                        begin: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20)),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    //crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Image.asset(
                        "assets/images/weight-scale.png",
                      ),
                      RichText(
                        text: const TextSpan(
                            style: TextStyle(
                              fontFamily: 'Urbanist',
                            ),
                            children: <TextSpan>[
                              TextSpan(
                                  text: '    My Weight\n',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700)),
                              TextSpan(
                                  text:
                                      '  Track your weekly  \n          weight ',
                                  style: TextStyle(
                                      color: Color.fromARGB(255, 96, 95, 95))),
                            ]),
                      )
                    ],
                  )),
            ),
            InkWell(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            viewReminders())); // Reminders page
              },
              child: Container(
                  //3-reminders
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color.fromARGB(255, 236, 194, 193),
                          const Color.fromARGB(255, 251, 233, 234),
                        ],
                        begin: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20)),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    //crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Image.asset(
                        "assets/images/reminders.png",
                        height: 120,
                      ),
                      RichText(
                        text: const TextSpan(
                            style: TextStyle(
                              fontFamily: 'Urbanist',
                            ),
                            children: <TextSpan>[
                              TextSpan(
                                  text: '   \n    Reminders\n',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700)),
                              TextSpan(
                                  text:
                                      '  Set reminders and \n       stay notified ',
                                  style: TextStyle(
                                      color: Color.fromARGB(255, 96, 95, 95))),
                            ]),
                      )
                    ],
                  )),
            ),
            InkWell(
              onTap: () {
                // Navigator.push(
                //     context,
                //     MaterialPageRoute(
                //         builder: (context) =>
                //             CommunityPage())); // Contraction timer page
              },
              child: Container(
                  //4-contaraction timer
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color.fromARGB(255, 236, 194, 193),
                          const Color.fromARGB(255, 251, 233, 234),
                        ],
                        begin: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20)),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    //crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Image.asset(
                        "assets/images/timer.png",
                        height: 140,
                      ),
                      RichText(
                        text: const TextSpan(
                            style: TextStyle(
                              fontFamily: 'Urbanist',
                            ),
                            children: <TextSpan>[
                              TextSpan(
                                  text: '     Contraction timer\n',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700)),
                              TextSpan(
                                  text:
                                      '  Tell difference between  \n     true and false labor',
                                  style: TextStyle(
                                      color: Color.fromARGB(255, 96, 95, 95))),
                            ]),
                      )
                    ],
                  )),
            ),
          ],
        ),
      )
    ],
  );
}
