// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_final_fields, unnecessary_import, sized_box_for_whitespace, library_private_types_in_public_api, avoid_print, prefer_interpolation_to_compose_strings, prefer_const_constructors, unnecessary_cast, prefer_typing_uninitialized_variables, unnecessary_new

import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:preggo/colors.dart';
import 'package:preggo/new_born_info.dart';
import 'package:googleapis/calendar/v3.dart';
import 'package:googleapis_auth/googleapis_auth.dart' as auth show AuthClient;
import '../newPregnancyInfo.dart';

class weeklyModel {}

class PregnancyTracking extends StatefulWidget {
  const PregnancyTracking({super.key});

  //late final String userId;

  @override
  State<StatefulWidget> createState() {
    return _PregnancyTracking();
  }
}

class _PregnancyTracking extends State<PregnancyTracking> {
  @override
  void initState() {
    getAllWeeks();
    getStrCurrentWeek();
    super.initState();
    // getWeek();
  }

  static const _scopes = [CalendarApi.calendarScope];
  String babyHeight = ' ';
  String babyWeight = ' ';
  String babyPicture = 'assets/images/w01-02.jpg';
  int weekNo = 0;
  var expectedBirthDate;

  toJson(DocumentSnapshot doc) {
    return {
      "weekNo": doc.id,
      "babyHeight": doc['height'],
      "babyWeight": doc['weight'],
      "babyPicture": doc['image']
    };
  }

  int currentWeek = 1;

  int currentWeekProgress = 0;
  String currentWeekPregnant = "";

  var firestore = FirebaseFirestore.instance.collection('pregnancytracking');
  late final Future myFuture = getDueDate();
  FixedExtentScrollController _scrollController = FixedExtentScrollController();

  Future<int> getDueDate() async {
    await getAllWeeks();
    //var today = DateTime.now();
    var subCollectionRef = await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('pregnancyInfo')
        .where("ended", isEqualTo: 'false') //get current pregnancy
        .get();

    if (subCollectionRef.docs.isNotEmpty) {
      //SHE IS CURRENTLY PREGNANT
      var data = subCollectionRef.docs.first.data() as Map;
      expectedBirthDate = data['DueDate'];
      var cWeek = getCurrentWeek(expectedBirthDate.toDate());
      print("scrolling to " + (cWeek - 1).toString());
      return cWeek;
    } else {
      return -1;
    }
  }

  int getCurrentWeek(var duedate) {
    var today = DateTime.now();
    final difference = duedate.difference(today).inDays / 7;
    int ans = 40 - (difference.round() as int);
    return ans;
  }

  int row = 40;
  int col = 4;

  var allWeeks = List<List>.generate(
      40, (i) => List<dynamic>.generate(4, (index) => null, growable: false),
      growable: false);
  late int selected = 0;

  getAllWeeks() async {
    var weeks = await firestore.get().then((QuerySnapshot querySnapshot) {
      for (var doc in querySnapshot.docs) {
        print('Doc => ${doc.data()}');
        List<String> eachWeek = [
          doc['height'],
          doc['weight'],
          doc['image'],
          doc['babychanges'],
          doc['motherchanges']
        ];
        // print(eachWeek);
        allWeeks[int.parse(doc.id) - 1] = (eachWeek);
      }
    });
  }

  handleScroll(int x) {
    setState(() {
      selected = x;
    });
  }

  var data;

  bool first = true;
  double itemWidth = 60.0;
  int itemCount = 40;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: myFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) {
              return Container();
            } //end if
            else if (snapshot.hasData) {
              if (currentWeekProgress <= 308 && snapshot.data != -1) {
                data = snapshot.data;
                return Scaffold(
                  body: Stack(
                    children: [
                      SingleChildScrollView(
                        child: SafeArea(
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Container(
                                      alignment: Alignment.centerLeft,
                                      margin: EdgeInsets.only(left: 20, top: 5),
                                      child: Row(
                                        children: [
                                          RichText(
                                            text: TextSpan(
                                                style: TextStyle(
                                                  fontFamily: 'Urbanist',
                                                ),
                                                children: <TextSpan>[
                                                  TextSpan(
                                                      text: 'Baby Tracker',
                                                      style: TextStyle(
                                                          color: Appcolors
                                                              .blackColor,
                                                          fontSize: 35,
                                                          fontWeight:
                                                              FontWeight.w400)),
                                                ]),
                                          ),
                                          SizedBox(
                                            width: 5,
                                          ),
                                          Padding(
                                            padding: EdgeInsets.fromLTRB(
                                                0, 10, 0, 0),
                                            child: ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              40)),
                                                  backgroundColor:
                                                      Appcolors.blackColor),
                                              child: Text("End Pregnancy"),
                                              onPressed: () async {
                                                showDialog<void>(
                                                  context: context,
                                                  barrierDismissible: false,
                                                  // user must tap button!
                                                  builder:
                                                      (BuildContext contextx) {
                                                    return AlertDialog(
                                                      contentPadding:
                                                          EdgeInsets.symmetric(
                                                              horizontal: 10,
                                                              vertical: 15),
                                                      content: SizedBox(
                                                        height: 130,
                                                        child: Column(
                                                          children: <Widget>[
                                                            Center(
                                                              child: Padding(
                                                                padding: EdgeInsets
                                                                    .only(
                                                                        top: 10,
                                                                        bottom:
                                                                            30),
                                                                child: Text(
                                                                  'Are you sure you want to end your pregnancy journey?',
                                                                  textAlign:
                                                                      TextAlign
                                                                          .center,
                                                                ),
                                                              ),
                                                            ),
                                                            Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              children: <Widget>[
                                                                Container(
                                                                  padding: EdgeInsets
                                                                      .symmetric(
                                                                          horizontal:
                                                                              5),
                                                                  height: 45.0,
                                                                  child: Center(
                                                                    child:
                                                                        ElevatedButton(
                                                                      onPressed:
                                                                          () {
                                                                        Navigator.of(context)
                                                                            .pop();
                                                                      },
                                                                      style: ElevatedButton
                                                                          .styleFrom(
                                                                        backgroundColor:
                                                                            blackColor,
                                                                        shape: RoundedRectangleBorder(
                                                                            borderRadius:
                                                                                BorderRadius.circular(40)),
                                                                        padding: const EdgeInsets.fromLTRB(
                                                                            30,
                                                                            15,
                                                                            30,
                                                                            15),
                                                                      ),
                                                                      child:
                                                                          const Text(
                                                                        "No",
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                                Container(
                                                                  padding: EdgeInsets
                                                                      .symmetric(
                                                                          horizontal:
                                                                              5),
                                                                  height: 45.0,
                                                                  child: Center(
                                                                    child:
                                                                        ElevatedButton(
                                                                      onPressed:
                                                                          () async {
                                                                        Navigator.of(context)
                                                                            .pop();
                                                                        await endPregnancyJourney();
                                                                      },
                                                                      style: ElevatedButton
                                                                          .styleFrom(
                                                                        backgroundColor: Theme.of(context)
                                                                            .colorScheme
                                                                            .error,
                                                                        shape: RoundedRectangleBorder(
                                                                            borderRadius:
                                                                                BorderRadius.circular(40)),
                                                                        padding: const EdgeInsets.only(
                                                                            left:
                                                                                30,
                                                                            top:
                                                                                15,
                                                                            right:
                                                                                30,
                                                                            bottom:
                                                                                15),
                                                                      ),
                                                                      child:
                                                                          const Text(
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
                                              },
                                            ),
                                          )
                                        ],
                                      )),
                                ],
                              ),
                              Container(
                                height: 130,
                                //alignment: Alignment.topCenter,
                                child: RotatedBox(
                                  quarterTurns: -1,
                                  child: ListWheelScrollView(
                                    physics: BouncingScrollPhysics(
                                        parent:
                                            AlwaysScrollableScrollPhysics()),
                                    onSelectedItemChanged: (x) {
                                      setState(() {
                                        selected = x;
                                      });
                                    },
                                    controller: _scrollController,
                                    itemExtent: itemWidth,
                                    children: List.generate(
                                      itemCount,
                                      (x) => RotatedBox(
                                        quarterTurns: 1,
                                        child: AnimatedContainer(
                                          duration: Duration(milliseconds: 400),
                                          width: x == selected ? 70 : 60,
                                          height: x == selected ? 80 : 70,
                                          alignment: Alignment.center,
                                          decoration: BoxDecoration(
                                              color: x == selected
                                                  ? Color.fromRGBO(
                                                      249, 220, 222, 1)
                                                  : Appcolors.transparent,
                                              shape: BoxShape.rectangle,
                                              borderRadius:
                                                  BorderRadius.circular(15)),
                                          child: Column(
                                            children: [
                                              Text(
                                                '\nweek\n \n    ${x + 1}',
                                                // so it starts from week 1
                                                style: TextStyle(
                                                    fontFamily: 'Urbanist'),
                                              ),
                                              x + 1 == data
                                                  ? Flexible(
                                                      child: Container(
                                                          padding:
                                                              EdgeInsets.only(
                                                                  top: 10),
                                                          child: Icon(Icons
                                                              .expand_less)))
                                                  : Container()
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  //weight icon
                                  Container(
                                    width: 90,
                                    height: 70,
                                    child: Column(
                                      children: [
                                        Icon(
                                          Icons.monitor_weight_outlined,
                                          color:
                                              Color.fromARGB(255, 163, 39, 39),
                                        ),
                                        Text(
                                          allWeeks[selected][1],
                                          style: TextStyle(
                                              fontFamily: 'Urbanist',
                                              fontSize: 15),
                                        ),
                                        Text(
                                          'Weight',
                                          style: TextStyle(
                                              fontFamily: 'Urbanist',
                                              fontSize: 12),
                                        )
                                      ],
                                    ),
                                  ),
                                  Container(
                                    //baby pic
                                    width: 170,
                                    height: 170,
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                        fit: BoxFit.cover,
                                        image:
                                            AssetImage(allWeeks[selected][2]),
                                      ),
                                      borderRadius: BorderRadius.circular(500),
                                    ),
                                  ),

                                  Container(
                                    //length icon
                                    width: 90,
                                    height: 70,
                                    child: Column(
                                      children: [
                                        Icon(
                                          Icons.straighten,
                                          color:
                                              Color.fromARGB(255, 163, 39, 39),
                                        ),
                                        Text(
                                          allWeeks[selected][0],
                                          style: TextStyle(
                                              fontFamily: 'Urbanist',
                                              fontSize: 15),
                                        ),
                                        Text(
                                          'height',
                                          style: TextStyle(
                                              fontFamily: 'Urbanist',
                                              fontSize: 12),
                                        )
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                margin: EdgeInsets.only(top: 10),
                                padding: EdgeInsets.all(5),
                                width: 330,
                                decoration: BoxDecoration(
                                  color: Appcolors.whiteColor,
                                  border: Border.all(
                                    color: Color.fromRGBO(249, 220, 222, 1),
                                    width: 0.1,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: [
                                    BoxShadow(
                                        blurRadius: 2,
                                        spreadRadius: 0.5,
                                        color: Appcolors.grayColor)
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      //baby pic
                                      width: 50,
                                      height: 50,
                                      decoration: BoxDecoration(
                                        image: DecorationImage(
                                          fit: BoxFit.cover,
                                          image: AssetImage(
                                              "assets/images/sperm.png"),
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(500),
                                      ),
                                    ),
                                    Expanded(
                                      child: Column(
                                        children: [
                                          Slider(
                                            value:
                                                currentWeekProgress.toDouble(),
                                            min: 0,
                                            max: 308,
                                            //this was giving me error so i changed it but idk what it is
                                            onChanged: (double value) {},
                                            activeColor: pinkColor,
                                            inactiveColor: NavBraGrayColor,
                                          ),
                                          Text(
                                            "You’re currently pregnant in week $data",
                                            style: TextStyle(
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      //baby pic
                                      width: 50,
                                      height: 50,
                                      decoration: BoxDecoration(
                                        image: DecorationImage(
                                          fit: BoxFit.cover,
                                          image: AssetImage(
                                              "assets/images/baby.png"),
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(500),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.only(top: 10),
                                padding: EdgeInsets.all(5),
                                width: 330,
                                decoration: BoxDecoration(
                                  color: Appcolors.whiteColor,
                                  border: Border.all(
                                      color: Color.fromRGBO(249, 220, 222, 1),
                                      width: 1.5),
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                        blurRadius: 2,
                                        spreadRadius: 0.5,
                                        color: Appcolors.grayColor)
                                  ],
                                ),
                                child: Column(
                                  children: [
                                    Text(
                                      'Highlights of The Week',
                                      style: TextStyle(
                                        color: pinkColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(motherChanges())
                                  ],
                                ),
                              ),
                              Visibility(
                                visible: selected != 0 && selected != 1,
                                child: Container(
                                  margin: EdgeInsets.only(top: 10),
                                  padding: EdgeInsets.all(5),
                                  width: 330,
                                  decoration: BoxDecoration(
                                    color: Appcolors.whiteColor,
                                    border: Border.all(
                                        color: Color.fromRGBO(249, 220, 222, 1),
                                        width: 1.5),
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                          blurRadius: 2,
                                          spreadRadius: 0.5,
                                          color: Appcolors.grayColor)
                                    ],
                                  ),
                                  child: Column(
                                    children: [
                                      Text(
                                        'Baby Development ',
                                        style: TextStyle(
                                          color: pinkColor,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(babyChanges())
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(height: 50),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              } else {
                return startNewJourney();
              }
            }
          }

          return Scaffold(
            body: Center(
              child: Container(
                // height: 200,
                // width: 200,
                child: CircularProgressIndicator(
                  color: pinkColor,
                  strokeWidth: 5,
                ),
              ),
            ),
          );
        });
  }

  String babyChanges() {
    final baby = allWeeks[selected][3].toString().split('.');
    String changes = "";
    for (var element in baby) {
      changes += "$element\n";
    }
    return changes;
  }

  String motherChanges() {
    final mother = allWeeks[selected][4].toString().split('.');
    String changes = "";
    for (var element in mother) {
      changes += "$element\n";
    }
    return changes;
  }

  getStrCurrentWeek() async {
    Timestamp timestamp = Timestamp.now();
    await FirebaseFirestore.instance
        .collection("users")
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection("pregnancyInfo")
        .get()
        .then((value) async {
      for (var element in value.docs) {
        if (element.data()["ended"] == "false") {
          timestamp = element.data()["DueDate"];
        }
      }
      var date = timestamp.toDate();
      currentWeekProgress = 280 - date.difference(DateTime.now()).inDays;
      DateTime today = DateTime.now();
      int weeksPregnant = 40 - (date.difference(today).inDays) ~/ 7;
      currentWeekPregnant = weeksPregnant.toString();
      if (currentWeekProgress > 308) await endPregnancyJourney();
      setState(() {});
    });
  }

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: _scopes,
  );
  deleteAllAppointments() async {
    String? id = '';
    await _googleSignIn.signInSilently();
    final auth.AuthClient? client = await _googleSignIn.authenticatedClient();
    final CalendarApi googleCalendarApi = CalendarApi(client!);
    var list = await googleCalendarApi.calendarList.list();
    var items = list.items;
    for (CalendarListEntry entry in items!) {
      if (entry.summary == "Preggo Calendar") {
        id = entry.id;
        break;
      }
    }
    if (id != '') {
      print('CALENDAR ID IS $id');
      googleCalendarApi.calendars
          .delete(
              id!) //this deletes entire calendar and there is a clear calendar method but it gives me an api exception
          .then((value) => print('deleted all from google calendar'));
    } else {
      print('no preggo calendar in google calendar to delete from');
    }
  }

  String? babyId;

  Future endPregnancyJourney() async {
    deleteAllReminders();
    deleteAllAppointments();
    showEndJourneyPopup();
  }

  showEndJourneyPopup() {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context2) {
        return Center(
          child: SizedBox(
            height: 350,
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
                      Image.asset(
                        "assets/images/end.jpeg",
                        height: 60,
                      ),
                      const SizedBox(height: 25),

                      // Done
                      Center(
                        child: const Text(
                          "I admire your bravery\nEnding a journey is heartfelt.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color.fromARGB(255, 0, 0, 0),
                            fontSize: 15,
                            fontFamily: 'Urbanist',
                            fontWeight: FontWeight.w400,
                            // height: 1.30,
                            // letterSpacing: -0.28,
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      /// OK Button
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        width: MediaQuery.sizeOf(context).width * 0.80,
                        height: 45.0,
                        child: Center(
                          child: ElevatedButton(
                            onPressed: () {
// TO ALIYAH PAGE
                              if (mounted) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => NewBornInfo(
                                      babyId: babyId!,
                                    ),
                                  ),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: blackColor,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(40)),
                              padding:
                                  const EdgeInsets.fromLTRB(70, 15, 70, 15),
                            ),
                            child: const Text(
                              "OK",
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget startNewJourney() {
    return Scaffold(
      backgroundColor: backGroundPink,
      body: Column(
        children: [
          SizedBox(
            height: 50,
          ), //120 is exactly like pregnancyInfo page

          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 18.0,
                vertical: 0.0,
              ),
              decoration: BoxDecoration(
                color: whiteColor,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(80.0),
                ),
              ),
              child: Column(
                children: [
                  Center(
                    child: Padding(
                      padding: EdgeInsets.only(top: 40),
                      child: Image.asset(
                        'assets/images/calendar.png',
                        height: 280,
                        width: 280,
                      ),
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 6, horizontal: 25),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Start New Journey",
                        style: TextStyle(
                          color: darkBlackColor,
                          fontSize: 34,
                          fontFamily: 'Urbanist',
                          fontWeight: FontWeight.w600,
                          height: 1.30,
                          letterSpacing: -0.28,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 2, horizontal: 25),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Add new pregnancy details to access pregnancy tracking and tools!",
                        style: TextStyle(
                          color: pinkColor,
                          fontSize: 20,
                          fontFamily: 'Urbanist',
                          fontWeight: FontWeight.w600,
                          height: 1.30,
                          letterSpacing: -0.28,
                        ),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.fromLTRB(258, 59, 0, 0),
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => newPregnancyInfo()));
                          },
                          style: ElevatedButton.styleFrom(
                            fixedSize: const Size(55, 55),
                            shape: const CircleBorder(),
                            backgroundColor: darkBlackColor,
                          ),
                          child: Icon(
                            Icons.add,
                            color: whiteColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  deleteAllReminders() async {
    await FirebaseFirestore.instance
        .collection("users")
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection("pregnancyInfo")
        .get()
        .then((value) async {
      for (var element in value.docs) {
        if (element.data()["ended"] == "false") {
          babyId = element.id;
          print("##################################################$babyId");
          await FirebaseFirestore.instance
              .collection("users")
              .doc(FirebaseAuth.instance.currentUser!.uid)
              .collection("pregnancyInfo")
              .doc(element.id)
              .update({"ended": "true"});
        }
      }
      setState(() {});
    });
    final userDocRef = FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid);
    CollectionReference subCollectionRefReminder =
        userDocRef.collection('reminders');
    QuerySnapshot subCollectionQueryReminder =
        await subCollectionRefReminder.get();
    for (QueryDocumentSnapshot doc in subCollectionQueryReminder.docs) {
      DocumentReference docRefReminder = subCollectionRefReminder.doc(doc.id);
      await docRefReminder.delete();
    }
  }
}
