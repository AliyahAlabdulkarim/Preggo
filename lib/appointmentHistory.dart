// ignore_for_file: file_names, use_key_in_widget_constructors, camel_case_types, prefer_const_constructors, prefer_const_literals_to_create_immutables, avoid_init_to_null, unused_import, avoid_print, unused_element

import 'package:flutter/material.dart';
import 'package:preggo/colors.dart';
import 'package:preggo/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:timeline_tile/timeline_tile.dart';

class appointmentHistory extends StatefulWidget {
  //const SignUp({Key? key}) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return _appointmentHistory();
  }
}

class _appointmentHistory extends State<appointmentHistory> {
  late final String userId;

  String getUserId() {
    User? user = FirebaseAuth.instance.currentUser;
    return user!.uid;
  }

  Future<Widget> getAppointments(String pregnancyInfoId) async {
    //FirebaseFirestore firestore = FirebaseFirestore.instance;
    String userUid = getUserId();
    QuerySnapshot result = await FirebaseFirestore.instance
        .collection('users')
        .doc(userUid)
        .collection('pregnancyInfo')
        .doc(pregnancyInfoId)
        .collection('appointments')
        .get();
    print('--------------------------------------------------------');
    print(result.docs.length);
    if (result.docs.isEmpty) //no reminders for this date
    {
      return Column(
        children: [
          Center(
            //notification bell image
            child: Padding(
              padding: EdgeInsets.only(top: 150),
              child: Image.asset(
                'assets/images/calendarempty.png',
                height: 100,
                width: 100,
              ),
            ),
          ),
          Container(
              //message
              margin: EdgeInsets.fromLTRB(30, 35, 30, 80),
              child: Text(
                'No Appointment History',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 26,
                  fontFamily: 'Urbanist',
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.28,
                ),
              )),
        ],
      );
    } else {
      //reminders exist for this day
      List appointments = result.docs;
      // Sort the reminders based on the date and time
      appointments.sort((a, b) {
        var dateA = a.data()['date'] ?? '';
        var dateB = b.data()['date'] ?? '';
        return dateA.compareTo(dateB);
      });

      return SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        scrollDirection: Axis.vertical,
        child: SizedBox(
          height: 680,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: appointments.length,
            itemBuilder: (context, index) {
              var date = DateFormat('MMMM dd, yyyy')
                  .format(appointments[index].data()['start'].toDate())
                  .toString();
              var startTime = DateFormat('hh:mm a')
                  .format(appointments[index].data()['start'].toDate())
                  .toString();
              var endTime = DateFormat('hh:mm a')
                  .format(appointments[index].data()['end'].toDate())
                  .toString();
              String doctor = appointments[index].data()['dr'] ?? '';
              String hospital = appointments[index].data()['hospital'] ?? '';
              String title = appointments[index].data()['name'] ?? '';

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 100,
                    child: TimelineTile(
                      axis: TimelineAxis.vertical,
                      alignment: TimelineAlign.start,
                      isFirst: index == 0,
                      isLast: index == appointments.length - 1,
                      indicatorStyle: IndicatorStyle(
                        height: 20,
                        width: 20,
                        color: pinkColor,
                      ),
                      beforeLineStyle: LineStyle(
                        color: pinkColor.withOpacity(0.6),
                      ),
                      endChild: Column(
                        children: [
                          SizedBox(
                            height: 15,
                          ),
                          Container(
                            margin: EdgeInsets.symmetric(horizontal: 12),
                            padding: EdgeInsets.symmetric(
                                horizontal: 10, vertical: 10),
                            decoration: BoxDecoration(
                              //color: backGroundPink.withOpacity(0.3),
                              border:
                                  Border.all(color: backGroundPink, width: 2),
                              borderRadius: BorderRadius.circular(13),
                            ),
                            child: Row(children: [
                              Column(
                                children: [
                                  Container(
                                    //   width: 85,
                                    alignment: Alignment.center,
                                    child: Text(
                                      date,
                                      style: TextStyle(
                                        color: Colors.black.withOpacity(0.7),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        fontFamily: 'Urbanist',
                                      ),
                                    ),
                                  ),
                                  Container(
                                    //width: 85,
                                    alignment: Alignment.center,
                                    child: Text(
                                      '$startTime - $endTime',
                                      style: TextStyle(
                                        color: Colors.black.withOpacity(0.7),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        fontFamily: 'Urbanist',
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                width: 20,
                              ),
                              SizedBox(
                                width: 120,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      title,
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 17,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Urbanist',
                                      ),
                                    ),
                                    Text(
                                      doctor,
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 17,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Urbanist',
                                      ),
                                    ),
                                    Text(
                                      hospital,
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 17,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Urbanist',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ]),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      );
    }
  }

  //////////////////////////////////////////////////////////////////////////////////////////////
  @override
  Widget build(BuildContext context) {
    var pregnancyInfoId = ModalRoute.of(context)?.settings.arguments as String;
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
                    Text(
                      "Appointment History",
                      style: TextStyle(
                        color: Color(0xFFD77D7C),
                        fontSize: 30,
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
                      //padding: EdgeInsets.only(top: 0),
                      child: Container(
                        child: Column(
                          children: [
                            FutureBuilder<Widget>(
                              future: getAppointments(pregnancyInfoId),
                              builder: (BuildContext context,
                                  AsyncSnapshot<Widget> snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
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
                                } else if (snapshot.hasError) {
                                  return Text('Error: ${snapshot.error}');
                                } else {
                                  return snapshot.data ??
                                      Container(); // Return an empty container if data is null
                                }
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
        ));
  }
}
