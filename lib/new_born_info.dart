import 'dart:developer';

import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:jiffy/jiffy.dart';
import 'package:preggo/colors.dart';
import 'package:preggo/reminder.dart';

class NewBornInfo extends StatefulWidget {
  const NewBornInfo({super.key});

  @override
  State<StatefulWidget> createState() {
    return NewBornInfoState();
  }
}

class NewBornInfoState extends State<NewBornInfo> {
  DateTime selectedDate = DateTime.now();
  DateTime selectedTime = DateTime.now();
  DateTime _minDate = DateTime.now();

  var timeFormat = Jiffy.now().format(pattern: "hh:mm a");
  var errorMessage = "";

  List<Map<String, dynamic>> days = [
    {
      "id": "1",
      "day": "Every Sunday",
      "short": "Sun",
      "selected": false,
    },
    {
      "id": "2",
      "day": "Every Monday",
      "short": "Mon",
      "selected": false,
    },
    {
      "id": "3",
      "day": "Every Tuesday",
      "short": "Tue",
      "selected": false,
    },
    {
      "id": "4",
      "day": "Every Wednesday",
      "short": "Wed",
      "selected": false,
    },
    {
      "id": "5",
      "day": "Every Thursday",
      "short": "Thu",
      "selected": false,
    },
    {
      "id": "6",
      "day": "Every Friday",
      "short": "Fri",
      "selected": false,
    },
    {
      "id": "7",
      "day": "Every Saturday",
      "short": "Sat",
      "selected": false,
    },
  ];

  List<Map<String, dynamic>> selectedDays = [];

  bool isLoading = false;

  _showDatePicker() {
    _showDialog(
      CupertinoDatePicker(
        initialDateTime: selectedDate.isAfter(DateTime.now())
            ? selectedDate
            : DateTime.now(),
        minimumDate: _minDate,
        maximumDate: DateTime.now().copyWith(
          year: DateTime.now().year + 10,
          month: 12,
          day: 31,
        ),
        mode: CupertinoDatePickerMode.date,
        onDateTimeChanged: (DateTime newDate) {
          setState(
            () {
              selectedDate = DateTime(
                newDate.year,
                newDate.month,
                newDate.day,
                selectedTime.hour,
                selectedTime.minute,
                selectedTime.second,
              );
              print("::: Selected date is: $selectedDate #");
              _minDate = DateTime.now();
            },
          );
        },
      ),
    );
  }

  _showTimePicker() {
    print("Selected Time:# $selectedTime #");
    print("Selected DATE:# $selectedDate #");
    final initial = DateTime.now().isBefore(selectedDate);
    print("Selected initial:# $initial #");

    final isToday = selectedDate.year == DateTime.now().year &&
        selectedDate.month == DateTime.now().month &&
        selectedDate.day == DateTime.now().day;
    _showDialog(
      CupertinoDatePicker(
        initialDateTime: DateTime.now().isBefore(selectedDate) ||
                DateTime.now().isBefore(selectedTime)
            ? selectedTime
            : DateTime.now(),
        minimumDate: isToday
            ? DateTime(
                DateTime.now().year,
                DateTime.now().month,
                DateTime.now().day,
                DateTime.now().hour,
                DateTime.now().minute,
              )
            : null,
        mode: CupertinoDatePickerMode.time,
        onDateTimeChanged: (DateTime newTime) {
          setState(() {
            selectedTime = DateTime(
              newTime.year,
              newTime.month,
              newTime.day,
              newTime.hour,
              newTime.minute,
            );
          });
          print(newTime.toString());
          var jiffy = Jiffy.parse(newTime.toString());
          timeFormat = jiffy.format(pattern: "hh:mm a");
          print(timeFormat);
        },
      ),
    );
  }

  Future<void> addNewBornInfo() async {
    try {
      final today = DateTime(DateTime.now().year, DateTime.now().month,
          DateTime.now().day, DateTime.now().hour, DateTime.now().minute);
      final isDateAfterToday = selectedDate.isAfter(today);
      final isSelectedTimeEqualOrGraterThanNow =
          selectedTime.hour == DateTime.now().hour &&
                  selectedTime.minute == DateTime.now().minute ||
              selectedTime.hour > DateTime.now().hour &&
                  selectedTime.minute > DateTime.now().minute;
      final isSelectedTimeValid = isDateAfterToday ||
          isSelectedTimeEqualOrGraterThanNow ||
          selectedTime.isAfter(DateTime.now());
      print("today:: $today #");
      print("isDateAfterToday:: $isDateAfterToday #");
      print("isSelectedTimeValid:: $isSelectedTimeValid #");
      print("selectedDate:: $selectedDate #");
      print("selectedTime:: $selectedTime #");

      final String? currentUserUuid = FirebaseAuth.instance.currentUser?.uid;

      if (currentUserUuid != null &&
          _formKey.currentState!.validate() &&
          isSelectedTimeValid == true) {
        setState(() {
          isLoading = true;
          errorMessage = "";
        });

        /// /users
        ///
        /// pregnancyInfo
        ///
        /// newbornInfo

        final newbornInfoCollection = FirebaseFirestore.instance
            .collection("users")
            .doc(currentUserUuid)
            .collection("pregnancyInfo")
            .doc()
            .collection("newbornInfo");

        final dueDate = await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUserUuid)
            .collection('pregnancyInfo')
            .where("DueDate", isGreaterThanOrEqualTo: Timestamp.now())
            .get();

        final Map<String, dynamic> babyData = {
          "Name": _nameController.text.trim(),
          "Place": _placeOfBirthController.text.trim(),
          "Height": _heightController.text.trim(),
          "Weight": _weightController.text.trim(),
          "Gender": selectedGender,
          "Blood": selectedBloodType,
          "Date":
              "${selectedDate.month}-${selectedDate.day}-${selectedDate.year}",
          "Time": TimeOfDay.fromDateTime(selectedTime).format(context),
        };
        await newbornInfoCollection.add(babyData).then((value) async {
          // await remindersCollection.doc(value.id).set(
          //   {
          //     "id": value.id,
          //   },
          //   SetOptions(merge: true),
          // );

          if (mounted) {
            _successDialog();
          }
          setState(() {
            isLoading = false;

            _nameController.clear();
            _placeOfBirthController.clear();
            _heightController.clear();
            _weightController.clear();

            selectedDate = DateTime.now();
            selectedTime = DateTime.now();
          });
        });
      } else if (isSelectedTimeValid == false) {
        setState(() {
          errorMessage = "Time cannot be in the past.";
        });
      } else {
        setState(() {
          isLoading = false;
          errorMessage = "";
        });
      }
    } catch (error) {
      setState(() {
        isLoading = false;
        errorMessage = "";
      });
    }
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
                          ),
                          child: const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 35,
                          ),
                        ),
                        const SizedBox(height: 25),
                        const Text(
                          "Reminder added successfully!",
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

  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _heightController;
  late TextEditingController _weightController;
  late TextEditingController _placeOfBirthController;
  DateTime? _dateOfBirth;
  DateTime? _timeOfBirth;
  String? _selectedGender;
  String? _selectedBloodType;

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController();
    _heightController = TextEditingController();
    _weightController = TextEditingController();
    _placeOfBirthController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _placeOfBirthController.dispose();

    super.dispose();
  }

  String formatDate(DateTime? dateTime) {
    if (dateTime == null) return '';
    final date = DateFormat.yMMMMd().format(dateTime);

    return date;
  }

  String formatTime(DateTime? dateTime) {
    if (dateTime == null) return '';
    final time = DateFormat.jms().format(dateTime);

    return time;
  }

  void _showDialog(Widget child) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => Container(
        height: 216,
        padding: const EdgeInsets.only(top: 6.0),
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        color: CupertinoColors.systemBackground.resolveFrom(context),
        child: SafeArea(
          top: false,
          child: child,
        ),
      ),
    );
  }

  void backButton() {
    showDialog(
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
                      'Are you sure you want to go back?',
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

  String selectedGender = "";
  String selectedBloodType = "";
  final gender = [
    {"type": "Boy", "isSelected": false, "id": "101"},
    {"type": "Girl", "isSelected": false, "id": "102"},
  ];

  final bloodType = [
    {"value": "A+", "isSelected": false, "id": "101"},
    {"value": "A-", "isSelected": false, "id": "102"},
    {"value": "B+", "isSelected": false, "id": "103"},
    {"value": "B-", "isSelected": false, "id": "104"},
    {"value": "O+", "isSelected": false, "id": "105"},
    {"value": "O-", "isSelected": false, "id": "106"},
    {"value": "AB+", "isSelected": false, "id": "107"},
    {"value": "AB-", "isSelected": false, "id": "108"},
  ];

  @override
  Widget build(BuildContext context) {
    var textStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
          fontSize: 12.0,
          color: Theme.of(context).colorScheme.error,
          fontWeight: FontWeight.normal,
        );

    var textStyleError = Theme.of(context).textTheme.bodyMedium?.copyWith(
          fontSize: 12.0,
          color: Theme.of(context).colorScheme.error,
          fontWeight: FontWeight.normal,
        );

    return Scaffold(
      backgroundColor: backGroundPink,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.bottomLeft,
              child: BackButton(
                onPressed: backButton,
                style: const ButtonStyle(
                  padding: MaterialStatePropertyAll(
                    EdgeInsets.zero,
                  ),
                ),
              ),
            ),
            const Text(
              "Add a new born info",
              style: TextStyle(
                color: Color(0xFFD77D7C),
                fontSize: 32,
                fontFamily: 'Urbanist',
                fontWeight: FontWeight.w600,
                letterSpacing: -0.28,
              ),
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
                  color: Color(0xFFFFFFFF),
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(80.0),
                  ),
                ),
                child: SingleChildScrollView(
                  physics: const NeverScrollableScrollPhysics(),
                  child: Container(
                    margin:
                        const EdgeInsets.symmetric(vertical: 5, horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 5.0),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                Container(
                                  margin:
                                      const EdgeInsets.only(top: 30, left: 5),
                                  alignment: Alignment.centerLeft,
                                  child: const Text(
                                    "Baby Name",
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                      color: Color.fromARGB(255, 0, 0, 0),
                                      fontSize: 17,
                                      fontFamily: 'Urbanist',
                                      fontWeight: FontWeight.w700,
                                      height: 1.30,
                                      letterSpacing: -0.28,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 5.0),
                                  child: TextFormField(
                                    maxLength: 25,
                                    controller: _nameController,
                                    style: const TextStyle(
                                      fontSize: 15.0,
                                      fontFamily: 'Urbanist',
                                    ),
                                    keyboardType: TextInputType.name,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.allow(
                                          RegExp("[a-zA-Z ]")),
                                    ],
                                    decoration: InputDecoration(
                                      errorStyle: textStyleError,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              vertical: 15.0, horizontal: 15),
                                      border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(12.0),
                                      ),
                                      enabledBorder: const OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(12.0)),
                                        borderSide: BorderSide(
                                            color: textFieldBorderColor),
                                      ),
                                      focusedBorder: const OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(12.0)),
                                        borderSide:
                                            BorderSide(color: darkGrayColor),
                                      ),
                                      filled: true,
                                      fillColor: const Color(0xFFF7F8F9),
                                    ),
                                    validator: (value) {
                                      if (value == null ||
                                          value.trim().isEmpty) {
                                        return "This field cannot be empty.";
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                                Container(
                                  margin:
                                      const EdgeInsets.only(top: 5, left: 5),
                                  alignment: Alignment.centerLeft,
                                  child: const Text(
                                    "Place of Birth",
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                      color: Color.fromARGB(255, 0, 0, 0),
                                      fontSize: 17,
                                      fontFamily: 'Urbanist',
                                      fontWeight: FontWeight.w700,
                                      height: 1.30,
                                      letterSpacing: -0.28,
                                    ),
                                  ),
                                ),

                                /// Place of Birth
                                Padding(
                                  padding: const EdgeInsets.only(top: 5),
                                  child: TextFormField(
                                    maxLength: 35,
                                    controller: _placeOfBirthController,
                                    keyboardType: TextInputType.name,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.allow(
                                          RegExp("[a-zA-Z ]")),
                                    ],
                                    style: const TextStyle(
                                      fontSize: 15.0,
                                      fontFamily: 'Urbanist',
                                    ),
                                    decoration: InputDecoration(
                                      errorStyle: textStyleError,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              vertical: 15.0, horizontal: 15),
                                      border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(12.0),
                                      ),
                                      enabledBorder: const OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(12.0)),
                                        borderSide: BorderSide(
                                            color: textFieldBorderColor),
                                      ),
                                      focusedBorder: const OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(12.0)),
                                        borderSide:
                                            BorderSide(color: darkGrayColor),
                                      ),
                                      filled: true,
                                      fillColor: const Color(0xFFF7F8F9),
                                    ),
                                  ),
                                ),

                                /// Height & Wieght
                                Container(
                                  padding: const EdgeInsets.only(top: 5.0),
                                  child: Row(
                                    children: [
                                      Expanded(
                                          child: Column(
                                        children: [
                                          Container(
                                            margin: const EdgeInsets.only(
                                                top: 5, left: 5),
                                            alignment: Alignment.centerLeft,
                                            child: const Text(
                                              "Height",
                                              textAlign: TextAlign.left,
                                              style: TextStyle(
                                                color: Color.fromARGB(
                                                    255, 0, 0, 0),
                                                fontSize: 17,
                                                fontFamily: 'Urbanist',
                                                fontWeight: FontWeight.w700,
                                                height: 1.30,
                                                letterSpacing: -0.28,
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 5.0),
                                            child: TextFormField(
                                              maxLength: 4,
                                              controller: _heightController,
                                              keyboardType:
                                                  TextInputType.number,
                                              validator: (value) {
                                                if (value != null &&
                                                    value.isNotEmpty) {
                                                  final val =
                                                      double.tryParse(value);
                                                  if (val != null) {
                                                    if (val > 35.0 ||
                                                        val < 65.0) {
                                                      return null;
                                                    } else {
                                                      return "Height should be between 35.0 - 65.0 cm.";
                                                    }
                                                  } else {
                                                    return "Height should be between 35.0 - 65.0 cm.";
                                                  }
                                                }
                                                return null;
                                              },
                                              inputFormatters: [
                                                // FilteringTextInputFormatter
                                                //     .allow("[0-9]"),
                                              ],
                                              style: const TextStyle(
                                                fontSize: 15.0,
                                                fontFamily: 'Urbanist',
                                              ),
                                              decoration: InputDecoration(
                                                errorStyle: textStyleError,
                                                contentPadding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 15.0,
                                                        horizontal: 15),
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          12.0),
                                                ),
                                                enabledBorder:
                                                    const OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(
                                                              12.0)),
                                                  borderSide: BorderSide(
                                                      color:
                                                          textFieldBorderColor),
                                                ),
                                                focusedBorder:
                                                    const OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(
                                                              12.0)),
                                                  borderSide: BorderSide(
                                                      color: darkGrayColor),
                                                ),
                                                filled: true,
                                                fillColor:
                                                    const Color(0xFFF7F8F9),
                                              ),
                                            ),
                                          ),
                                        ],
                                      )),
                                      const SizedBox(width: 15),
                                      Expanded(
                                        child: Column(
                                          children: [
                                            Container(
                                              margin: const EdgeInsets.only(
                                                  top: 5, left: 5),
                                              alignment: Alignment.centerLeft,
                                              child: const Text(
                                                "Weight",
                                                textAlign: TextAlign.left,
                                                style: TextStyle(
                                                  color: Color.fromARGB(
                                                      255, 0, 0, 0),
                                                  fontSize: 17,
                                                  fontFamily: 'Urbanist',
                                                  fontWeight: FontWeight.w700,
                                                  height: 1.30,
                                                  letterSpacing: -0.28,
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 5.0),
                                              child: TextFormField(
                                                maxLength: 3,
                                                controller: _weightController,
                                                keyboardType:
                                                    TextInputType.number,
                                                inputFormatters: [
                                                  FilteringTextInputFormatter
                                                      .digitsOnly,
                                                ],
                                                style: const TextStyle(
                                                  fontSize: 15.0,
                                                  fontFamily: 'Urbanist',
                                                ),
                                                decoration: InputDecoration(
                                                  errorStyle: textStyleError,
                                                  contentPadding:
                                                      const EdgeInsets
                                                          .symmetric(
                                                          vertical: 15.0,
                                                          horizontal: 15),
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12.0),
                                                  ),
                                                  enabledBorder:
                                                      const OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.all(
                                                            Radius.circular(
                                                                12.0)),
                                                    borderSide: BorderSide(
                                                        color:
                                                            textFieldBorderColor),
                                                  ),
                                                  focusedBorder:
                                                      const OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.all(
                                                            Radius.circular(
                                                                12.0)),
                                                    borderSide: BorderSide(
                                                        color: darkGrayColor),
                                                  ),
                                                  filled: true,
                                                  fillColor:
                                                      const Color(0xFFF7F8F9),
                                                ),
                                                validator: (value) {
                                                  if (value == null ||
                                                      value.trim().isEmpty) {
                                                    return "This field cannot be empty.";
                                                  }
                                                  return null;
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                /// Gender
                                _GenderViewWidget(
                                  gender: gender,
                                  selectedValue: selectedGender,
                                  onChanged: (value) {
                                    setState(() {
                                      selectedGender = value;
                                    });
                                  },
                                ),

                                /// Blood Type
                                CustomResizeWidget(
                                  // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  onTap: () async {
                                    await showDialog(
                                      context: context,
                                      builder: (context) {
                                        return BloodDialog(
                                          initialBloodValue: selectedBloodType,
                                          onSelectedItem: (value) {
                                            setState(() {
                                              selectedBloodType = value;
                                            });
                                            print("VALUE:: $value #");
                                          },
                                        );
                                        // return DaysDialog(
                                        //   days: days,
                                        //   selectedDays: selectedDays,
                                        // );
                                      },
                                    ).then((value) {
                                      // setState(() {
                                      //   selectedDays.sort((a, b) => a['id'].compareTo(b['id']));
                                      // });
                                    });
                                  },
                                  children: [
                                    const Text(
                                      "Blood Type",
                                      style: TextStyle(
                                        // color: Colors.black,
                                        fontSize: 17,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Urbanist',
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 5.0),
                                          child: Text(
                                            selectedBloodType.isEmpty
                                                ? "Select"
                                                : selectedBloodType,
                                            style: const TextStyle(
                                              //selected days size
                                              fontSize: 16.0,
                                              fontFamily: 'Urbanist',

                                              /// Selected days Color
                                              color: Colors.black,
                                            ),
                                          ),
                                        ),
                                        const Padding(
                                          padding: EdgeInsetsDirectional.only(
                                              start: 5),
                                          child: Icon(
                                            Icons.keyboard_arrow_down,
                                            // color: Colors.black,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),

                                /// Date & Time of Birth
                                Row(
                                  children: [
                                    Expanded(
                                      child: CustomResizeWidget(
                                        children: <Widget>[
                                          const Text(
                                            "Date of Birth",
                                            style: TextStyle(
                                              color:
                                                  Color.fromARGB(255, 0, 0, 0),
                                              fontSize: 17,
                                              fontFamily: 'Urbanist',
                                              fontWeight: FontWeight.w700,
                                              height: 1.30,
                                              letterSpacing: -0.28,
                                            ),
                                          ),
                                          const Spacer(),
                                          Row(
                                            children: [
                                              CupertinoButton(
                                                padding: EdgeInsets.zero,
                                                onPressed: _showDatePicker,
                                                child: Text(
                                                  '${selectedDate.month}-${selectedDate.day}-${selectedDate.year}',
                                                  style: const TextStyle(
                                                    fontSize: 16.0,
                                                    fontFamily: 'Urbanist',
                                                    color: Colors.black,
                                                  ),
                                                ),
                                              ),
                                              GestureDetector(
                                                onTap: _showDatePicker,
                                                child: const Padding(
                                                  padding: EdgeInsetsDirectional
                                                      .only(start: 5),
                                                  child: Icon(
                                                    Icons.keyboard_arrow_down,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      child: CustomResizeWidget(
                                        children: <Widget>[
                                          const Text(
                                            "Time of Birth",
                                            style: TextStyle(
                                              color:
                                                  Color.fromARGB(255, 0, 0, 0),
                                              fontSize: 17,
                                              fontFamily: 'Urbanist',
                                              fontWeight: FontWeight.w700,
                                              height: 1.30,
                                              letterSpacing: -0.28,
                                            ),
                                          ),
                                          Row(
                                            children: [
                                              CupertinoButton(
                                                padding: EdgeInsets.zero,
                                                onPressed: _showTimePicker,
                                                child: Text(
                                                  timeFormat,
                                                  style: TextStyle(
                                                    fontSize: 16.0,
                                                    fontFamily: 'Urbanist',
                                                    color: errorMessage.isEmpty
                                                        ? Colors.black
                                                        : Theme.of(context)
                                                            .colorScheme
                                                            .error,
                                                  ),
                                                ),
                                              ),
                                              GestureDetector(
                                                onTap: _showTimePicker,
                                                child: const Padding(
                                                  padding: EdgeInsetsDirectional
                                                      .only(start: 5),
                                                  child: Icon(
                                                    Icons.keyboard_arrow_down,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  alignment: Alignment.centerLeft,
                                  child:
                                      Text(errorMessage, style: textStyleError),
                                ),
                                const SizedBox(height: 30),
                                SizedBox(
                                  height: 45.0,
                                  child: ElevatedButton(
                                    onPressed: addNewBornInfo,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: blackColor,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(40)),
                                      padding: const EdgeInsets.only(
                                          left: 85,
                                          top: 15,
                                          right: 85,
                                          bottom: 15),
                                    ),
                                    child: const Text("Add Information",
                                        style: TextStyle(
                                          fontFamily: 'Urbanist',
                                        )),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CustomResizeWidget extends StatelessWidget {
  const CustomResizeWidget({
    super.key,
    required this.children,
    this.onTap,
    this.hasTopBorder = true,
    this.hasBottomBorder = true,
    this.mainAxisAlignment = MainAxisAlignment.spaceBetween,
  });

  final List<Widget> children;
  final GestureTapCallback? onTap;
  final bool hasTopBorder;
  final bool hasBottomBorder;
  final MainAxisAlignment mainAxisAlignment;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 60,
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        decoration: BoxDecoration(
          border: Border(
            top: hasTopBorder
                ? const BorderSide(
                    color: CupertinoColors.inactiveGray,
                    width: 0.0,
                  )
                : BorderSide.none,
            bottom: hasBottomBorder
                ? const BorderSide(
                    color: Color.fromARGB(255, 36, 33, 33),
                    width: 0.0,
                  )
                : BorderSide.none,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: children,
        ),
      ),
    );
  }
}

class BloodDialog extends StatefulWidget {
  const BloodDialog({
    super.key,
    this.initialBloodValue,
    required this.onSelectedItem,
  });

  final void Function(String) onSelectedItem;
  final String? initialBloodValue;

  @override
  State<BloodDialog> createState() => _BloodDialogState();
}

class _BloodDialogState extends State<BloodDialog> {
  List<Map<String, dynamic>> bloodTypes = [
    {"value": "A+", "isSelected": false, "id": "101"},
    {"value": "A-", "isSelected": false, "id": "102"},
    {"value": "B+", "isSelected": false, "id": "103"},
    {"value": "B-", "isSelected": false, "id": "104"},
    {"value": "O+", "isSelected": false, "id": "105"},
    {"value": "O-", "isSelected": false, "id": "106"},
    {"value": "AB+", "isSelected": false, "id": "107"},
    {"value": "AB-", "isSelected": false, "id": "108"},
  ];

  String selectedBlood = "";

  initialValue() {
    if (widget.initialBloodValue != null &&
        widget.initialBloodValue!.isNotEmpty) {
      /// Update blood types list
      // bloodTypes.map((e) {
      //   return e['value'] == widget.initialBloodValue
      //       ? e['isSelected'] == true
      //       : e['isSelected'] == false;
      // }).toList();

      setState(() {
        selectedBlood = widget.initialBloodValue!;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    initialValue();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AlertDialog(
        title: const Text(
          "Select",
          style: TextStyle(
            fontFamily: 'Urbanist',
            fontSize: 17,
          ),
        ),
        contentPadding: EdgeInsets.zero,
        clipBehavior: Clip.antiAliasWithSaveLayer,
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text("Cancel",
                style: TextStyle(
                  color: Colors.black,
                  fontFamily: 'Urbanist',
                )),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                widget.onSelectedItem(selectedBlood);
              });
            },
            child: const Text(
              "Save",
              style: TextStyle(
                color: pinkColor,
                fontFamily: 'Urbanist',
              ),
            ),
          ),
        ],
        content: SizedBox(
          width: MediaQuery.sizeOf(context).width * 0.74,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(
              bloodTypes.length,
              (i) {
                return Theme(
                  data: ThemeData(
                    unselectedWidgetColor:
                        bloodTypes[i]['isSelected'] ? pinkColor : Colors.black,
                  ),
                  child: RadioListTile(
                    groupValue: selectedBlood,
                    controlAffinity: ListTileControlAffinity.leading,
                    activeColor: pinkColor,
                    title: Text(
                      bloodTypes[i]['value'],
                      style: const TextStyle(
                        fontSize: 15.0,
                        fontFamily: 'Urbanist',
                      ),
                    ),
                    value: bloodTypes[i]['value'],
                    onChanged: (value) {
                      setState(
                        () {
                          bloodTypes.map((element) {
                            return element['id'] == bloodTypes[i]['id']
                                ? element['isSelected'] = true
                                : element['isSelected'] = false;
                          }).toList();

                          selectedBlood = value;

                          print("BLOOD TYPES:: $selectedBlood #");
                        },
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _GenderViewWidget extends StatelessWidget {
  const _GenderViewWidget({
    super.key,
    required this.gender,
    required this.onChanged,
    required this.selectedValue,
  });

  final List<Map<String, dynamic>> gender;
  final void Function(dynamic)? onChanged;
  final String selectedValue;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: CustomResizeWidget(
        children: <Widget>[
          const Text(
            "Gender",
            style: TextStyle(
              color: Color.fromARGB(255, 0, 0, 0),
              fontSize: 17,
              fontFamily: 'Urbanist',
              fontWeight: FontWeight.w700,
              height: 1.30,
              letterSpacing: -0.28,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(gender.length, (index) {
              return Padding(
                padding: const EdgeInsetsDirectional.only(start: 20),
                child: Row(
                  children: [
                    Radio(
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      value: gender[index]['type'],
                      groupValue: selectedValue,
                      onChanged: onChanged,
                    ),
                    Text(
                      gender[index]['type'].toString(),
                      style: const TextStyle(fontSize: 17),
                    ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
