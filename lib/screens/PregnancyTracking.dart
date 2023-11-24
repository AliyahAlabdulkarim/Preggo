// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_final_fields, unnecessary_import, sized_box_for_whitespace, library_private_types_in_public_api, avoid_print, prefer_interpolation_to_compose_strings, prefer_const_constructors, unnecessary_cast, prefer_typing_uninitialized_variables, unnecessary_new

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:preggo/colors.dart';

import '../pregnancyInfo.dart';

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

  String babyHeight = ' ';
  String babyWeight = ' ';
  String babyPicture = 'assets/images/w01-02.jpg';
  int weekNo = 0;
  var duedate;

  // _PregnancyTracking({
  //   required this.weekNo,
  //   required this.babyHeight,
  //   required this.babyWeight,
  //   required this.babyPicture,
  // });

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
      duedate = data['DueDate'];
      var cWeek = getCurrentWeek(duedate.toDate());
      // print("due date is ${duedate.toDate()}");

      // if (mounted) {
      // setState(() {
      print("scrolling to " + (cWeek - 1).toString());
      // _scrollController.animateToItem(cWeek - 1,
      //     duration: Duration(milliseconds: 500), curve: Curves.linear);
      //selected = cWeek - 1;
      //   });
      // }
      return cWeek;
    } else {
      return -1;
    }
  }

  int getCurrentWeek(var duedate) {
    var today = DateTime.now();
    final difference = duedate.difference(today).inDays / 7;
    //print("current week is " + difference.round()).toString();
    // if (mounted) {
    //   setState(() {

    // if (true) {
    //   _scrollController.animateToItem(myCurrWeek - 1,
    //       duration: Duration(milliseconds: 500), curve: Curves.linear);
    //   print("scrolling to " + (myCurrWeek - 1).toString());
    // }
    //   });
    // }
    int ans = 40 - (difference.round() as int);
    return ans;
  }

  int row = 40;
  int col = 4;

  // List<List<String>> allWeeks = <List<String>>[];
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
    // print(allWeeks);
    // print(allWeeks.length);
  }

  // getWeek() async {
  //   //final QuerySnapshot snapshot = await firestore.get();

  //   firestore.doc((selected + 1).toString()).get().then((DocumentSnapshot doc) {
  //     setState(() {
  //       babyPicture = doc['image'].toString();
  //       babyHeight = doc['height'].toString();
  //       babyWeight = doc['weight'].toString();
  //     });
  //     print(doc['weight'].toString());
  //     print(doc['height'].toString());
  //     print(doc['image'].toString());

  //     // setState(() {
  //     // weeks = snapshot.docs;
  //     //});
  //   });
  // }

  // jumptoIndex(int cWeek) {
  //   _scrollController.jumpToItem(cWeek - 1);
  // }
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
    // getAllWeeks();
    //getDueDate();
    // getCurrentWeek();
    return FutureBuilder(
      future: myFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasError) {
            // print("snapshot is null");
            return Container();
          } //end if
          else if (snapshot.hasData) {
            if (snapshot.data != -1) {
              data = snapshot.data;
              // _scrollController.animateToItem(data - 1,
              //     duration: Duration(milliseconds: 500), curve: Curves.linear);

              // Extracting data from snapshot object

              // print("DATA is " + data.toString());
              // if (data == null) {
              //   _scrollController = FixedExtentScrollController(initialItem: 0);
              // } else {

              // }
              return Scaffold(
                body: SingleChildScrollView(
                  child: Column(
                    children: [
                      Container(
                          alignment: Alignment.centerLeft,
                          margin: EdgeInsets.only(left: 20, top: 45),
                          child: RichText(
                            text: const TextSpan(
                                style: TextStyle(
                                  fontFamily: 'Urbanist',
                                ),
                                children: <TextSpan>[
                                  TextSpan(
                                      text: 'Baby Tracker',
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 35,
                                          fontWeight: FontWeight.w400)),
                                ]),
                          )),
                      Container(
                        height: 130,
                        //alignment: Alignment.topCenter,
                        child: RotatedBox(
                          quarterTurns: -1,
                          child: ListWheelScrollView(
                            physics: BouncingScrollPhysics(
                                parent: AlwaysScrollableScrollPhysics()),
                            // useMagnifier: true,
                            // magnification: 1.15,
                            onSelectedItemChanged: (x) {
                              setState(() {
                                selected = x;
                              });
                              // print("WEEK" + (selected + 1).toString());
                              //getWeek();
                              // getDueDate();
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
                                          ? Color.fromRGBO(249, 220, 222, 1)
                                          : Colors.transparent,
                                      shape: BoxShape.rectangle,
                                      borderRadius: BorderRadius.circular(15)),
                                  child: Column(
                                    children: [
                                      Text(
                                        '\nweek\n \n    ${x + 1}',
                                        // so it starts from week 1
                                        style:
                                            TextStyle(fontFamily: 'Urbanist'),
                                      ),
                                      x + 1 == data
                                          ? Flexible(
                                              child: Container(
                                                  padding:
                                                      EdgeInsets.only(top: 10),
                                                  child:
                                                      Icon(Icons.expand_less)))
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
                                  color: Color.fromARGB(255, 163, 39, 39),
                                ),
                                Text(
                                  allWeeks[selected][1],
                                  style: TextStyle(
                                      fontFamily: 'Urbanist', fontSize: 15),
                                ),
                                Text(
                                  'Weight',
                                  style: TextStyle(
                                      fontFamily: 'Urbanist', fontSize: 12),
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
                                image: AssetImage(allWeeks[selected][2]),
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
                                  color: Colors.teal[800],
                                ),
                                Text(
                                  allWeeks[selected][0],
                                  style: TextStyle(
                                      fontFamily: 'Urbanist', fontSize: 15),
                                ),
                                Text(
                                  'height',
                                  style: TextStyle(
                                      fontFamily: 'Urbanist', fontSize: 12),
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
                          color: Colors.white,
                          border: Border.all(
                            color: Color.fromRGBO(249, 220, 222, 1),
                            width: 0.1,
                          ),
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                                blurRadius: 2,
                                spreadRadius: 0.5,
                                color: Colors.grey)
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
                                  image: AssetImage("assets/images/sperm.png"),
                                ),
                                borderRadius: BorderRadius.circular(500),
                              ),
                            ),
                            Expanded(
                              child: Column(
                                children: [
                                  Slider(
                                    value: currentWeekProgress.toDouble(),
                                    min: 0,
                                    max:
                                        500, //this was giving me error so i changed it but idk what it is
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
                                  image: AssetImage("assets/images/baby.png"),
                                ),
                                borderRadius: BorderRadius.circular(500),
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
                          color: Colors.white,
                          border: Border.all(
                              color: Color.fromRGBO(249, 220, 222, 1),
                              width: 1.5),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                                blurRadius: 2,
                                spreadRadius: 0.5,
                                color: Colors.grey)
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
                            color: Colors.white,
                            border: Border.all(
                                color: Color.fromRGBO(249, 220, 222, 1),
                                width: 1.5),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                  blurRadius: 2,
                                  spreadRadius: 0.5,
                                  color: Colors.grey)
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
              );
            } else {
              return startNewJourney();
            }
          }
        }

        return Scaffold(
          body: Center(
            child: CircularProgressIndicator(
              color: pinkColor,
              strokeWidth: 5,
            ),
          ),
        );
      },
    );
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

  void getStrCurrentWeek() {
    FirebaseFirestore.instance
        .collection("users")
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection("pregnancyInfo")
        .get()
        .then((value) {
      Timestamp timestamp = value.docs.first.data()["DueDate"];
      var date = timestamp.toDate();

      currentWeekProgress = 280 - date.difference(DateTime.now()).inDays;

      DateTime today = DateTime.now();

      print(date);
      int weeksPregnant = 40 - (date.difference(today).inDays) ~/ 7;
      currentWeekPregnant = weeksPregnant.toString();

      setState(() {});
    });
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
                color: Colors.white,
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
                                    builder: (context) => pregnancyInfo()));
                          },
                          style: ElevatedButton.styleFrom(
                            fixedSize: const Size(55, 55),
                            shape: const CircleBorder(),
                            backgroundColor: darkBlackColor,
                          ),
                          child: Icon(
                            Icons.add,
                            color: Colors.white,
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
}
