import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:googleapis/servicemanagement/v1.dart';
import 'package:preggo/colors.dart';
import 'package:preggo/pregnancyInfo.dart';
import 'package:preggo/screens/ToolsPage.dart';
import 'package:preggo/weightFeature/addWeight.dart';
import 'package:preggo/weightFeature/editWeight.dart';
import 'package:intl/intl.dart';

class ContractionT extends StatefulWidget {
  late DocumentReference _documentReference;

  //final String pregnancyInfo_id;
  ContractionT({
    super.key,
  });

  @override
  _ContractionT createState() => _ContractionT();
}

class _ContractionT extends State<ContractionT> {
  int seconds = 0, minutes = 0;
  String digitSec = "00", digitMin = "00";
  Timer? timer;
  bool started = false;
  List laps = [];
  String startTime = "";
  String endTime = "";

  String getTime() {
    DateTime stamp = DateTime.now();
    String formattedStamp = DateFormat.jm().format(stamp);
    return formattedStamp;
  }

  void stop() {
    timer!.cancel();
    String lap = "$digitMin:$digitSec";
    endTime = getTime();
    setState(() {
      started = false;
      laps.add(lap);
    });
  }

  void reset() {
    timer!.cancel();
    setState(() {
      seconds = 0;
      minutes = 0;

      digitSec = "00";
      digitMin = "00";

      started = false;
    });
  }

  void addLaps() {
    String lap = "$digitMin:$digitSec";
    setState(() {
      laps.add(lap);
    });
  }

  void start() {
    started = true;
    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      int localSeconds = seconds + 1;
      int localMintues = minutes;
      startTime = getTime();

      if (localSeconds > 59) {
        localMintues++;
        localSeconds = 0;
      }
      setState(() {
        seconds = localSeconds;
        minutes = localMintues;

        digitSec = (seconds >= 10) ? "$seconds" : "0$seconds";
        digitMin = (minutes >= 10) ? "$minutes" : "0$minutes";
      });
    });
  }

  Future<void> addContraction() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    String userUid = getUserId();

    CollectionReference subCollectionRef =
        firestore.collection('users').doc(userUid).collection('contractionT');

    subCollectionRef.add({
      'startTime': startTime,
      'endTime': endTime,
      'length': laps,
    });
  }

  String getUserId() {
    User? user = FirebaseAuth.instance.currentUser;
    return user!.uid;
  }

  Future<Widget> getContractionTimer() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    //String Pid = getPregnancyInfoId() as String;
    String userUid = getUserId();

    QuerySnapshot result = await firestore
        .collection('users')
        .doc(userUid)
        .collection('contractionT')
        .get();

    print(result.docs.length);
    print('printed');
    if (result.docs.isEmpty) //no weight
    {
      return Container(
        child: Column(
          children: [
            Center(
              //notification bell image
              child: Padding(
                padding: EdgeInsets.only(top: 180),
                child: Image.asset(
                  'assets/images/no-sport.png',
                  height: 90,
                  width: 100,
                ),
              ),
            ),
            Container(
                //message
                margin: EdgeInsets.fromLTRB(30, 15, 30, 80),
                child: RichText(
                  textAlign: TextAlign.center,
                  text: const TextSpan(
                      style: TextStyle(
                        fontFamily: 'Urbanist',
                      ),
                      children: [
                        TextSpan(
                            text: 'No weight\n',
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 26,
                                fontWeight: FontWeight.w600)),
                        WidgetSpan(
                            child: SizedBox(
                          height: 20,
                        )),
                        TextSpan(
                            text:
                                ' Start your weight tracking journey by adding a new weight',
                            style: TextStyle(
                                color: Color.fromARGB(255, 121, 119, 119))),
                      ]),
                )
                // child: Text(
                //   'No weight',
                //   textAlign: TextAlign.center,
                //   style: TextStyle(
                //     fontSize: 26,
                //     fontFamily: 'Urbanist',
                //     fontWeight: FontWeight.w600,
                //     letterSpacing: -0.28,
                //   ),
                // )
                ),
          ],
        ),
      );
    } else {
      //reminders exist for this day
      List weightResult = result.docs;

      return SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        scrollDirection: Axis.vertical,
        child: Container(
          height: 400,
          decoration: BoxDecoration(
              color: backGroundPink, borderRadius: BorderRadius.circular(8)),
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: weightResult.length,
            itemBuilder: (context, index) {
              String startTimee = weightResult[index].data()['startTime'] ?? '';
              String endTimee = weightResult[index].data()['endTime'] ?? '';
              List length = weightResult[index].data()['length'] ?? '';

              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Laps #${index + 1}"),
                    Text(
                        "${length[index]} , start: $startTimee , end: $endTimee ")
                  ],
                ),
              );
            },
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(
                      Icons.arrow_back,
                      color: blackColor,
                    ),
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  Text(
                    "Contraction timer",
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
                  child: SingleChildScrollView(
                    padding: EdgeInsets.only(top: 15),
                    child: Container(
                      child: Column(
                        children: [
                          Padding(
                            //padding for time
                            padding: const EdgeInsets.only(top: 50),
                            child: Center(
                              child: Text(
                                "$digitMin:$digitSec",
                                style: TextStyle(
                                    color: backGroundPink, fontSize: 75),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 90),
                            child: Row(
                              children: [
                                Text(
                                  "     minute                    second",
                                  style: TextStyle(
                                      color: const Color.fromARGB(
                                          255, 150, 150, 150),
                                      fontSize: 12),
                                )
                              ],
                            ),
                          ),
                          Padding(
                            //top padding for everything
                            padding: const EdgeInsets.only(top: 60),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Padding(
                                    //start button padding
                                    padding: const EdgeInsets.only(
                                        right: 15, left: 6, bottom: 6),
                                    child: RawMaterialButton(
                                      onPressed: () {
                                        (!started) ? start() : stop();
                                        addContraction();
                                      },
                                      fillColor: blackColor,
                                      shape: StadiumBorder(
                                          side: BorderSide(color: blackColor)),
                                      child: Text(
                                        (!started) ? "Start" : "Stop",
                                        style: TextStyle(
                                            color: whiteColor, fontSize: 15),
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Padding(
                                    //Reset button padding
                                    padding: const EdgeInsets.only(
                                        left: 15, right: 6, bottom: 6),
                                    child: RawMaterialButton(
                                      onPressed: () {
                                        reset();
                                      },
                                      fillColor: blackColor,
                                      shape: StadiumBorder(
                                          side: BorderSide(color: blackColor)),
                                      child: Text(
                                        "Reset",
                                        style: TextStyle(
                                            color: whiteColor, fontSize: 15),
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                          FutureBuilder<Widget>(
                            future: getContractionTimer(),
                            builder: (BuildContext context,
                                AsyncSnapshot<Widget> snapshot) {
                              if (snapshot.hasData) {
                                return snapshot.data!;
                              }
                              return Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 100, vertical: 250),
                                child: Align(
                                  alignment: Alignment.center,
                                  child: CircularProgressIndicator(
                                    color: pinkColor,
                                    strokeWidth: 3,
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
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