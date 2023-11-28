import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:preggo/colors.dart';
import 'package:preggo/weightFeature/addWeight.dart';
import 'package:preggo/weightFeature/editWeight.dart';
import 'package:intl/intl.dart';

class view_delete_Weight extends StatefulWidget {
  late DocumentReference _documentReference;

  //final String pregnancyInfo_id;
  view_delete_Weight({
    super.key,
  });

  @override
  _view_delete_Weight createState() => _view_delete_Weight();
}

class _view_delete_Weight extends State<view_delete_Weight> {
  late final String userId;

  String getUserId() {
    User? user = FirebaseAuth.instance.currentUser;
    return user!.uid;
  }

  String getDate() {
    DateTime stamp = DateTime.now();
    String formattedStamp = DateFormat.yMd().format(stamp);
    return formattedStamp;
  }

  String getTime() {
    DateTime stamp = DateTime.now();
    String formattedStamp = DateFormat.jm().format(stamp);
    return formattedStamp;
  }

  Future<void> deleteWeightSuccess(
    BuildContext context,
  ) async {
    //deleting happens here

    showDialog(
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
                          "weight deleted successfully!",
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
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          width: MediaQuery.sizeOf(context).width * 0.80,
                          height: 45.0,
                          child: Center(
                            child: ElevatedButton(
                              onPressed: () {
                                // Navigator.of(context).pop();
                                // Navigator.of(context).pop();

                                // Navigator.pop(
                                //   context,
                                //   MaterialPageRoute(
                                //     builder: (context) => ViewWeight(),
                                //   ),
                                // );
                                Navigator.of(context).pop();
                                Navigator.of(context).pop();
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            view_delete_Weight()));
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: blackColor,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(40)),
                                padding: const EdgeInsets.only(
                                    left: 70, top: 15, right: 70, bottom: 15),
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
  }

  Future<void> deleteWeightById({
    required String weightId,
    required String pregnancyInfoId,
    required BuildContext context,
  }) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
          content: SizedBox(
            height: 130,
            child: Column(
              children: <Widget>[
                const Center(
                  child: Padding(
                    padding: EdgeInsets.only(top: 10, bottom: 30),
                    child: Text(
                      'Are you sure you want to delete this weight?',
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
                            "Cancel",
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
                            try {
                              final usersCollection = FirebaseFirestore.instance
                                  .collection("users");
                              final String? currentUserId =
                                  FirebaseAuth.instance.currentUser?.uid;
                              final reminderCollection = usersCollection
                                  .doc(currentUserId)
                                  .collection("pregnancyInfo")
                                  .doc(pregnancyInfoId)
                                  .collection("weight");

                              /// Delete now
                              await reminderCollection
                                  .doc(weightId)
                                  .delete()
                                  .then((value) async {
                                if (context.mounted) {
                                  Navigator.of(context).pop();
                                  await deleteWeightSuccess(context);
                                }
                              });
                            } catch (error) {
                              print("Delete weight:: $error ##");
                            }
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
                            "Delete",
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

  Future<Widget> getWeight() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    //String Pid = getPregnancyInfoId() as String;
    String userUid = getUserId();
    //to get pregnancy info document ID
    QuerySnapshot pregnancyInfoSnapshot = await firestore
        .collection('users')
        .doc(userUid)
        .collection('pregnancyInfo')
        .where('ended', isEqualTo: 'false')
        .get();

    DocumentSnapshot firstDocument = pregnancyInfoSnapshot.docs[0];
    String Pid = firstDocument.id;

    QuerySnapshot result = await firestore
        .collection('users')
        .doc(userUid)
        .collection('pregnancyInfo')
        .doc(Pid)
        .collection('weight')
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
      weightResult.sort((a, b) {
        var dateTimeA = a['date']; //before -> var adate = a.expiry;
        var dateTimeB = b['date']; //before -> var bdate = b.expiry;
        //to get the order other way just switch `adate & bdate`
        return dateTimeB.compareTo(dateTimeA);
      });
      weightResult.sort((a, b) {
        var dateTimeC = a['time']; //before -> var adate = a.expiry;
        var dateTimeD = b['time']; //before -> var bdate = b.expiry;
        //to get the order other way just switch `adate & bdate`
        return dateTimeD.compareTo(dateTimeC);
      });

      return SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        scrollDirection: Axis.vertical,
        child: Container(
          height: 680,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: weightResult.length,
            itemBuilder: (context, index) {
              String id = weightResult[index].data()['id'] ?? '';
              double weight = weightResult[index].data()['weight'] ?? '';
              String date = weightResult[index].data()['date'] ?? '';
              String time = weightResult[index].data()['time'] ?? '';

              return Container(
                margin: EdgeInsets.all(8),
                //padding: EdgeInsets.all(10),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 17),
                      decoration: BoxDecoration(
                        color: backGroundPink.withOpacity(0.3),
                        border: Border.all(color: backGroundPink, width: 2),
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: Row(children: [
                        Container(
                          width: 85,
                          child: Text(
                            '$date \n  $time',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'Urbanist',
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 20,
                        ),
                        Expanded(
                          child: Text(
                            '$weight Kg',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Urbanist',
                            ),
                          ),
                        ),

                        //edit button
                        GestureDetector(
                          onTap: () async {
                            String weightId = id;
                            String PregnancyInfoId = Pid;
                            double Weight = weight;
                            String Date = date;
                            String Time = time;

                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => editWeight(
                                  weightId: weightId,
                                  Pid: PregnancyInfoId,
                                  weight: Weight,
                                  date: Date,
                                  time: Time,
                                ),
                              ),
                            ).then((value) {
                              getWeight();
                              setState(() {});
                            });
                          },
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              "edit |",
                              style: TextStyle(
                                decoration: TextDecoration.underline,
                                color: Colors.black,
                                fontSize: 15.5,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Urbanist',
                              ),
                            ),
                            // child: Icon(
                            //   Icons.edit,
                            //   color: Colors.black,
                            //   size: 20,
                            // ),
                          ),
                        ),
                        //delete button
                        GestureDetector(
                          onTap: () {
                            deleteWeightById(
                                weightId: id,
                                pregnancyInfoId: Pid,
                                context: context);
                          },
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              " delete",
                              style: TextStyle(
                                decoration: TextDecoration.underline,
                                color: Colors.redAccent,
                                fontSize: 15.5,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Urbanist',
                              ),
                            ),
                            // child: Icon(
                            //   Icons.delete,
                            //   color: Colors.redAccent,
                            //   size: 20,

                            // ),
                          ),
                        ),
                      ]),
                    ),
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
                    "    My weights",
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
              SizedBox(height: 15),
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
                  child: SingleChildScrollView(
                    padding: EdgeInsets.only(top: 15),
                    child: Container(
                      child: Column(
                        children: [
                          FutureBuilder<Widget>(
                            future: getWeight(),
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
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: EdgeInsets.fromLTRB(0, 100, 20, 50),
              child: ElevatedButton(
                onPressed: () async {
                  await Navigator.push(
                      context,
                      MaterialPageRoute(
                          //  maintainState: false,
                          builder: (context) => addWeight())).then((value) {
                    getWeight();
                    setState(() {});
                  });
                },
                // onPressed: () async {
                //   await Navigator.push(context,
                //           MaterialPageRoute(builder: (context) => addWeight()))
                //       .then((value) {
                //     getWeight();
                //     setState(() {});
                //   });
                // },

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
          ),
        ],
      ),
    );
  }
}
