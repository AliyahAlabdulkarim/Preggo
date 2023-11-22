// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, avoid_print, camel_case_types

import 'package:flutter/material.dart';
import 'package:preggo/weight_history.dart';

import 'appointmentHistory.dart';

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
      body: Stack(
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
                    text: 'Pregnancy Details\n',
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 35,
                        fontWeight: FontWeight.w400),
                  ),
                  TextSpan(
                    text: ' something something something',
                    style: TextStyle(
                      color: Color.fromARGB(255, 121, 119, 119),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Center(
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
                                      color: Color.fromARGB(255, 96, 95, 95),
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
                                      color: Color.fromARGB(255, 96, 95, 95),
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
                                      color: Color.fromARGB(255, 96, 95, 95),
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700)),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
