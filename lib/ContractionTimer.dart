import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:preggo/colors.dart';
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
  String time = "";
  //String endTime = "";

  String getTime() {
    String formattedStamp = DateFormat.jm().format(DateTime.now());
    return formattedStamp;
  }

  void toggleButton() {
    setState(() {
      if (time == "") {
        start();
        time = getTime();
        // endTime = "";
        // start();
      } else {
        stop();
        addContraction();
        time = "";
      }
    });
  }

  void stop() {
    timer!.cancel();
    String lap = "$digitMin:$digitSec";
    //endTime = getTime();
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
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      int localSeconds = seconds + 1;
      int localMintues = minutes;
      // startTime = getTime();
      // endTime = "";

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

  void backButton() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
          content: SizedBox(
            height: 170,
            child: Column(
              children: <Widget>[
                const Center(
                  child: Padding(
                    padding: EdgeInsets.only(top: 10, bottom: 30),
                    child: Text(
                      'By going back, all the contraction timer records will be deleted. \n \n Are you sure you want to go back? ',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      height: 45.0,
                      child: Center(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: blackColor,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(40)),
                            padding: const EdgeInsets.only(
                                left: 30, top: 15, right: 30, bottom: 15),
                          ),
                          child: const Text(
                            "No",
                          ),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      height: 45.0,
                      child: Center(
                        child: ElevatedButton(
                          onPressed: () async {
                            Navigator.pop(context);
                            Navigator.pop(context);
                            await deleteContraction();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Theme.of(context).colorScheme.error,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(40)),
                            padding: const EdgeInsets.only(
                                left: 30, top: 15, right: 30, bottom: 15),
                          ),
                          child: const Text(
                            "Yes",
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> addContraction() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    String userUid = getUserId();

    CollectionReference subCollectionRef =
        firestore.collection('users').doc(userUid).collection('contractionT');

    //DocumentReference docRef =
    //await
    subCollectionRef.add({'startTime': time, 'endTime': getTime()});
  }

  String getUserId() {
    User? user = FirebaseAuth.instance.currentUser;
    return user!.uid;
  }

  Future deleteContraction() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    String userUid = getUserId();

    CollectionReference subCollectionRef =
        firestore.collection('users').doc(userUid).collection('contractionT');

    QuerySnapshot subCollectionQuery = await subCollectionRef.get();

    for (QueryDocumentSnapshot doc in subCollectionQuery.docs) {
      DocumentReference docRefContraction = subCollectionRef.doc(doc.id);
      await docRefContraction.delete();
    }
  }

  Future<Widget> getContractionTimer() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
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
            // Center(
            //   //notification bell image
            //   child: Padding(
            //     padding: EdgeInsets.only(top: 180),
            //     child: Image.asset(
            //       'assets/images/no-sport.png',
            //       height: 90,
            //       width: 100,
            //     ),
            //   ),
            // ),
            Container(
                //message
                margin: const EdgeInsets.fromLTRB(30, 15, 30, 80),
                child: RichText(
                  textAlign: TextAlign.center,
                  text: const TextSpan(
                      style: TextStyle(
                        fontFamily: 'Urbanist',
                      ),
                      children: [
                        // TextSpan(
                        //     text: 'No weight\n',
                        //     style: TextStyle(
                        //         color: Colors.black,
                        //         fontSize: 26,
                        //         fontWeight: FontWeight.w600)),
                        WidgetSpan(
                            child: SizedBox(
                          height: 150,
                        )),
                        TextSpan(
                            text:
                                ' Start the contraction timer by pressing on the start button',
                            style: TextStyle(
                                color: Color.fromARGB(255, 121, 119, 119),
                                fontWeight: FontWeight.w600)),
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
      weightResult.sort((a, b) {
        var dateTimeC = a['startTime']; //before -> var adate = a.expiry;
        var dateTimeD = b['startTime']; //before -> var bdate = b.expiry;
        //to get the order other way just switch `adate & bdate`
        return dateTimeC.compareTo(dateTimeD);
      });

      weightResult.sort((a, b) {
        var dateTimeC = a['endTime']; //before -> var adate = a.expiry;
        var dateTimeD = b['endTime']; //before -> var bdate = b.expiry;
        //to get the order other way just switch `adate & bdate`
        return dateTimeC.compareTo(dateTimeD);
      });

      return SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        scrollDirection: Axis.horizontal,
        child: Container(
          margin: const EdgeInsets.only(
            top: 30,
          ),
          height: 350,
          width: 340,
          decoration: BoxDecoration(
              color: const Color.fromARGB(255, 255, 234, 240),
              borderRadius: BorderRadius.circular(8)),
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: DataTable(
              dividerThickness: 3,
              columns: const [
                DataColumn(
                    label: Text(
                  'Duration',
                  style: TextStyle(fontWeight: FontWeight.w600),
                )),
                DataColumn(
                    label: Text('Start Time',
                        style: TextStyle(fontWeight: FontWeight.w600))),
                DataColumn(
                    label: Text('End time',
                        style: TextStyle(fontWeight: FontWeight.w600)))
              ],
              rows: List.generate(weightResult.length, (index) {
                String startTimee =
                    weightResult[index].data()['startTime'] ?? '';
                String endTimee = weightResult[index].data()['endTime'] ?? '';
                return DataRow(
                  cells: [
                    DataCell(Text("${laps[index]}")),
                    DataCell(Text("$startTimee")),
                    DataCell(Text("$endTimee")),
                  ],
                );
              }).toList(),
            ),
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
              const SizedBox(
                height: 40,
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: backButton,
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  const Text(
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
              const SizedBox(
                height: 10,
              ),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18.0,
                    vertical: 0.0,
                  ),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(45.0),
                    ),
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(top: 15),
                    child: Container(
                      child: Column(
                        children: [
                          Padding(
                            //padding for time
                            padding: const EdgeInsets.only(top: 50),
                            child: Center(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: const [
                                    BoxShadow(
                                        color: backGroundPink,
                                        offset: Offset(4, 6),
                                        blurRadius: 8)
                                  ],
                                ),
                                child: Text(
                                  "$digitMin:$digitSec",
                                  style: const TextStyle(
                                      color: Color.fromRGBO(235, 170, 175, 1),
                                      fontSize: 75),
                                ),
                              ),
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.only(top: 8, left: 90),
                            child: Row(
                              children: [
                                Text(
                                  "    minute                    second",
                                  style: TextStyle(
                                      color: Color.fromARGB(255, 150, 150, 150),
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
                                        // if (!started) {
                                        //   start();
                                        //   // startTime = getTime();
                                        //   // endTime = "";
                                        // } else {
                                        //   stop();
                                        //   // endTime = getTime();
                                        //   addContraction();
                                        // }

                                        toggleButton();
                                      },
                                      fillColor: blackColor,
                                      shape: const StadiumBorder(
                                          side: BorderSide(color: blackColor)),
                                      child: Text(
                                        (!started) ? "Start" : "Stop",
                                        style: const TextStyle(
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
                                      shape: const StadiumBorder(
                                          side: BorderSide(color: blackColor)),
                                      child: const Text(
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
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 100, vertical: 250),
                                child: const Align(
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
