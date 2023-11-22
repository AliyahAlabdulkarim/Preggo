// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, avoid_print, camel_case_types

import 'package:flutter/material.dart';
import 'package:preggo/weight_history.dart';

import 'appointmentHistory.dart';
import 'colors.dart';

class pregnancyTapped extends StatefulWidget {
  const pregnancyTapped({super.key});

  @override
  _pregnancyTapped createState() => _pregnancyTapped();
}

class _pregnancyTapped extends State<pregnancyTapped> {
  @override
  initState() {
    super.initState();
    print("in pregnancy tapped");
  }

  @override
  Widget build(BuildContext context) {
    var babyID = ModalRoute.of(context)?.settings.arguments as String;
    return Scaffold(
      backgroundColor: backGroundPink,
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          Column(
            children: [
              SizedBox(
                height: 40,
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Text(
                    "Pregnancy History",
                    style: TextStyle(
                      color: Color(0xFFD77D7C),
                      fontSize: 32,
                      fontFamily: 'Urbanist',
                      fontWeight: FontWeight.w600,
                      height: 1.30,
                      letterSpacing: -0.28,
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18.0,
                    vertical: 0.0,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(45.0),
                    ),
                  ),

                  //padding: EdgeInsets.only(top: 0),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () {
                            print("BABY ID IS $babyID");
                          },
                          child: Container(
                            margin: EdgeInsets.only(bottom: 20),
                            padding: EdgeInsets.only(left: 5),
                            width: 310,
                            height: 150,
                            //baby info
                            decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    const Color.fromARGB(255, 236, 194, 193),
                                    const Color.fromARGB(255, 251, 233, 234),
                                  ],
                                  begin: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(20)),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Image.asset(
                                  "assets/images/babydetails.png",
                                  height: 100,
                                ),
                                RichText(
                                  text: const TextSpan(
                                    style: TextStyle(
                                      fontFamily: 'Urbanist',
                                    ),
                                    children: <TextSpan>[
                                      TextSpan(
                                          text: '     Baby\'s Information',
                                          style: TextStyle(
                                              color: Color.fromARGB(
                                                  255, 96, 95, 95),
                                              fontSize: 18,
                                              fontWeight: FontWeight.w700)),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            print("BABY ID IS $babyID");
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => appointmentHistory(),
                                settings: RouteSettings(arguments: babyID),
                              ),
                            );
                          },
                          child: Container(
                            margin: EdgeInsets.only(bottom: 20),
                            padding: EdgeInsets.only(left: 10),
                            width: 310,
                            height: 150,
                            //weight
                            decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    const Color.fromARGB(255, 236, 194, 193),
                                    const Color.fromARGB(255, 251, 233, 234),
                                  ],
                                  begin: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(20)),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Image.asset(
                                  "assets/images/schedule.png",
                                  height: 100,
                                ),
                                RichText(
                                  text: const TextSpan(
                                    style: TextStyle(
                                      fontFamily: 'Urbanist',
                                    ),
                                    children: <TextSpan>[
                                      TextSpan(
                                          text: '  Appointment History',
                                          style: TextStyle(
                                              color: Color.fromARGB(
                                                  255, 96, 95, 95),
                                              fontSize: 18,
                                              fontWeight: FontWeight.w700)),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            print("BABY ID IS $babyID");
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => weightHistory(),
                                settings: RouteSettings(arguments: babyID),
                              ),
                            );
                          },
                          child: Container(
                            width: 310,
                            height: 150,
                            //appointments
                            decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    const Color.fromARGB(255, 236, 194, 193),
                                    const Color.fromARGB(255, 251, 233, 234),
                                  ],
                                  begin: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(20)),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Image.asset(
                                  "assets/images/weight-scale.png",
                                  height: 130,
                                ),
                                RichText(
                                  text: const TextSpan(
                                    style: TextStyle(
                                      fontFamily: 'Urbanist',
                                    ),
                                    children: <TextSpan>[
                                      TextSpan(
                                          text: '    Weight History',
                                          style: TextStyle(
                                              color: Color.fromARGB(
                                                  255, 96, 95, 95),
                                              fontSize: 18,
                                              fontWeight: FontWeight.w700)),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 60),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
