import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:googleapis/servicemanagement/v1.dart';
import 'package:intl/intl.dart';
import 'package:preggo/colors.dart';
import 'package:preggo/weightFeature/view_delete_Weight.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:flutter/cupertino.dart';

class editWeight extends StatefulWidget {
  //late final String userId;
  final String weightId;
  final String Pid;
  final double weight;
  final String date;
  final String time;

  //final String pregnancyInfo_id;
  editWeight({
    super.key,
    required this.weightId,
    required this.Pid,
    required this.weight,
    required this.date,
    required this.time,
  });

  @override
  State<StatefulWidget> createState() {
    return _fillWeightForm();
  }
}

class _fillWeightForm extends State<editWeight> {
  //String weightId = '';
  // void initState() {
  //   super.initState();
  //   WidgetsBinding.instance.addPostFrameCallback((timeStamp)async {
  //     weightId = ModalRoute.of(context)

  //   })
  // }

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<FormFieldState> _nameKey = GlobalKey<FormFieldState>();
  final TextEditingController _weightController = TextEditingController();

  //bool showError = false;

  String getUserId() {
    User? user = FirebaseAuth.instance.currentUser;
    return user!.uid;
  }

  editWeight(double? weight, String weightid, String date, String time) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    String userUid = getUserId();

    QuerySnapshot pregnancyInfoSnapshot = await firestore
        .collection('users')
        .doc(userUid)
        .collection('pregnancyInfo')
        .get();

    // DocumentSnapshot firstDocument = pregnancyInfoSnapshot.docs[0];
    // String Pid = firstDocument.id;

    CollectionReference subCollectionRef = firestore
        .collection('users')
        .doc(userUid)
        .collection('pregnancyInfo')
        .doc(widget.Pid)
        .collection('weight');
    await subCollectionRef.doc(widget.weightId).update({
      'id': weightid,
      'weight': weight,
      'date': date,
      'time': time
    }).catchError((error) => print('failed to add info:$error'));
    if (mounted) {
      _successDialog();
    }
  }

  @override
  void initState() {
    super.initState();
    double w = widget.weight;
    _weightController.text = w.toString();
  }

  void backButton() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
          content: SizedBox(
            height: 130,
            child: Column(
              children: <Widget>[
                const Center(
                  child: Padding(
                    padding: EdgeInsets.only(top: 10, bottom: 30),
                    child: Text(
                      'Are you sure you want to go back?',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 5),
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
                      padding: EdgeInsets.symmetric(horizontal: 5),
                      height: 45.0,
                      child: Center(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            Navigator.of(context).pop();
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

  Future<dynamic> _successDialog() {
    return showDialog(
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
                    color: Colors.white,
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
                            // color: pinkColor,
                            // border: Border.all(
                            //   width: 1.3,
                            //   color: Colors.black,
                            // ),
                          ),
                          child: const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 35,
                          ),
                        ),
                        const SizedBox(height: 25),

                        // Done
                        const Text(
                          "Weight edited successfully!",
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
                                Navigator.of(context).pop();
                                Navigator.of(context).pop();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: blackColor,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(40)),
                                padding: const EdgeInsets.only(
                                    left: 70, top: 15, right: 70, bottom: 15),
                              ),
                              child: const Text("OK",
                                  style: TextStyle(
                                    fontFamily: 'Urbanist',
                                  )),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: backGroundPink,
        body: Column(
          children: [
            SizedBox(
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
                SizedBox(
                  width: 25,
                ),
                Text(
                  "   Edit weight",
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
                        top: Radius.circular(80.0),
                      ),
                    ),
                    child: SingleChildScrollView(
                        physics: NeverScrollableScrollPhysics(),
                        child: Container(
                          margin:
                              EdgeInsets.symmetric(vertical: 5, horizontal: 20),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(top: 5.0),
                                  child: Form(
                                    key: _formKey,
                                    child: Column(children: [
                                      Container(
                                        //baby name label
                                        margin:
                                            EdgeInsets.only(top: 30, left: 5),
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          "Your weight",
                                          textAlign: TextAlign.left,
                                          style: TextStyle(
                                            color: Color.fromARGB(255, 0, 0, 0),
                                            fontSize: 20,
                                            fontFamily: 'Urbanist',
                                            fontWeight: FontWeight.w700,
                                            height: 1.30,
                                            letterSpacing: -0.28,
                                          ),
                                        ),
                                      ),
                                      // Padding(
                                      //   padding: const EdgeInsets.only(
                                      //       top: 5, bottom: 2, right: 90),
                                      //   child: ListTile(
                                      //     leading: new Image.asset(
                                      //       "assets/images/scales.png",
                                      //       height: 24,
                                      //       width: 24,
                                      //     ),
                                      //     title: new Text('value: $weight'),
                                      //     onTap: () =>
                                      //         _showWeightPicker(context),
                                      //   ),
                                      // ),
                                      // Visibility(
                                      //   visible: showError,
                                      //   child: Align(
                                      //     alignment: Alignment.centerLeft,
                                      //     child: Padding(
                                      //         padding:
                                      //             EdgeInsets.only(left: 12.5),
                                      //         child: Text(
                                      //           'Please select a weight',
                                      //           style: TextStyle(
                                      //               color: Color.fromARGB(
                                      //                   255, 203, 51, 40),
                                      //               fontSize: 13),
                                      //           textAlign: TextAlign.left,
                                      //         )),
                                      //   ),
                                      // ),

                                      Padding(
                                        //weight text field
                                        padding: const EdgeInsets.only(
                                            top: 15, bottom: 20),
                                        child: TextFormField(
                                          key: _nameKey,
                                          controller: _weightController,
                                          decoration: InputDecoration(
                                            //hintText: 'huhuu',
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                                    vertical: 15.0,
                                                    horizontal: 15),
                                            focusedErrorBorder:
                                                OutlineInputBorder(
                                              gapPadding: 0.5,
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              borderSide: BorderSide(
                                                width: 0.50,
                                                color: Color.fromRGBO(
                                                    255, 100, 100, 1),
                                              ),
                                            ),
                                            errorBorder: OutlineInputBorder(
                                              gapPadding: 0.5,
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              borderSide: BorderSide(
                                                width: 0.50,
                                                color: Color.fromRGBO(
                                                    255, 100, 100, 1),
                                              ),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              gapPadding: 0.5,
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              borderSide: BorderSide(
                                                width: 0.50,
                                                color: Color.fromARGB(
                                                    255, 221, 225, 232),
                                              ),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              // gapPadding: 100,
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              borderSide: BorderSide(
                                                width: 0.50,
                                                color: Color.fromARGB(
                                                    255, 221, 225, 232),
                                              ),
                                            ),
                                            filled: true,
                                            fillColor: Color(0xFFF7F8F9),
                                          ),
                                          validator: (value) {
                                            if (value!.trim().isEmpty) {
                                              return "please enter your weight.";
                                            }

                                            if (!RegExp(r'^[0-9]+(\.[0-9]+)?$')
                                                .hasMatch(value.trim())) {
                                              return "Please Enter numbers only.";
                                            }

                                            if (!RegExp(r'^\d+(\.\d{1})?$')
                                                .hasMatch(value.trim())) {
                                              return "Please Enter weight with one decimal place only.";
                                            }
                                            if (!RegExp(
                                                    r'^(?:2[0-4][0-9]|2[5-9]|[3-9][0-9]|1[0-9]{2}|25[0-9]|2[6-9][0-9]|300|200|250)(?:\.\d+)?$')
                                                .hasMatch(value.trim())) {
                                              return "Please Enter weight between 25 and 300";
                                            }
                                          },
                                        ),
                                      ),
                                      // end of weight text field
                                      // start of date bar

                                      Row(
                                        children: [
                                          Text.rich(
                                            TextSpan(
                                              style: TextStyle(
                                                fontSize: 16,
                                              ),
                                              children: [
                                                TextSpan(
                                                  text: '  ',
                                                ),
                                                WidgetSpan(
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            right: 10),
                                                    child: Icon(
                                                        Icons.calendar_month),
                                                  ),
                                                ),
                                                TextSpan(
                                                  text: widget.date,
                                                ),
                                                TextSpan(
                                                  text: ' | ',
                                                ),
                                                TextSpan(
                                                  text: widget.time,
                                                )
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),

                                      Padding(
                                        //start journey button
                                        padding:
                                            const EdgeInsets.only(top: 30.0),
                                        child: ElevatedButton(
                                          onPressed: () {
                                            // setState(() {
                                            //   if (weight == null) {
                                            //     showError = true;
                                            //   } else {
                                            //     showError = false;
                                            //   }
                                            // });
                                            print("here");

                                            if (_formKey.currentState!
                                                .validate()) {
                                              double weightNum = double.parse(
                                                  _weightController.text);

                                              // String Date = getDate();
                                              // String Time = getTime();

                                              editWeight(
                                                  weightNum,
                                                  widget.weightId,
                                                  widget.date,
                                                  widget.time);

                                              // Navigator.push(
                                              //     context,
                                              //     MaterialPageRoute(
                                              //         builder: (context) =>
                                              //             ViewWeight()));
                                            }
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.black,
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(40)),
                                            padding: EdgeInsets.only(
                                                left: 90,
                                                top: 15,
                                                right: 110,
                                                bottom: 15),
                                          ),
                                          child: Text(
                                            "Submit",
                                            softWrap: false,
                                          ),
                                        ),
                                      ),
                                    ]),
                                  ),
                                ),
                              ]),
                        ))))
          ],
        ));
  }
}
