import 'dart:developer';
import 'dart:math';

import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:jiffy/jiffy.dart';
import 'package:preggo/NavBar.dart';
import 'package:preggo/baby_information.dart';
import 'package:preggo/colors.dart';
import 'package:preggo/reminder.dart';

import 'endJourney_babyInfo.dart';

class NewBornInfo extends StatefulWidget {
  const NewBornInfo({super.key, required this.babyId});
  final String babyId;

  @override
  State<StatefulWidget> createState() {
    return NewBornInfoState();
  }
}

class NewBornInfoState extends State<NewBornInfo> {
  DateTime? selectedDate;
  DateTime? selectedTime;
  DateTime? _minimumDate;
  DateTime? _maximumDate;

  var timeFormat = "Select";
  var errorMessage = "";

  bool isLoading = false;

  DateTime subtractMonths(DateTime date, int months) {
    int newMonth = date.month - months;
    int newYear = date.year;
    while (newMonth <= 0) {
      newMonth += 12;
      newYear -= 1;
    }
    return DateTime(newYear, newMonth, date.day);
  }

  DateTime increaseMonths(DateTime date, int months) {
    int newMonth = date.month + months;
    int newYear = date.year;
    while (newMonth <= 0) {
      newMonth += 12;
      newYear -= 1;
    }
    return DateTime(newYear, newMonth, date.day);
  }

  _showDatePicker() {
    _showDialog(
      CupertinoDatePicker(
        initialDateTime: selectedDate != null
            ? DateTime(
                selectedDate!.year,
                selectedDate!.month,
                selectedDate!.day,
              )
            : _minimumDate,
        minimumDate: _minimumDate,
        maximumDate: DateTime(
          _maximumDate!.year,
          _maximumDate!.month,
          _maximumDate!.day,
        ),
        mode: CupertinoDatePickerMode.date,
        onDateTimeChanged: (DateTime newDate) {
          setState(
            () {
              selectedDate = DateTime(
                newDate.year,
                newDate.month,
                newDate.day,
              );
            },
          );
        },
      ),
    );
  }

  _showTimePicker() {
    _showDialog(
      CupertinoDatePicker(
        initialDateTime: selectedTime,
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

  Future<void> updateDatePicker() async {
    final String? currentUserUuid = FirebaseAuth.instance.currentUser?.uid;
    final data = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUserUuid)
        .collection('pregnancyInfo')
        .doc(widget.babyId)
        // .where("DueDate", isGreaterThanOrEqualTo: Timestamp.now())
        .get();

    final Timestamp dueDate = data['DueDate'];

    _minimumDate = subtractMonths(dueDate.toDate(), 5);
    _maximumDate = increaseMonths(dueDate.toDate(), 1);
  }

  Future<void> addNewBornInfo() async {
    try {
      final String? currentUserUuid = FirebaseAuth.instance.currentUser?.uid;
      final bool hasValidGender = selectedGender != null &&
          selectedGender!.isNotEmpty &&
          selectedGender!.toLowerCase() != "unknown";

      print("hasValidGender:::: $hasValidGender ###");
      if (currentUserUuid != null &&
          _formKey.currentState!.validate() &&
          hasValidGender) {
        final newbornInfoCollection = FirebaseFirestore.instance
            .collection("users")
            .doc(currentUserUuid)
            .collection("pregnancyInfo")
            .doc(widget.babyId)
            .collection("newbornInfo");

        final time = selectedTime == null
            ? ""
            : TimeOfDay.fromDateTime(selectedTime!).format(context);
        final Map<String, dynamic> babyData = {
          // "Name": _nameController.text.trim(),
          "Place": _placeOfBirthController.text.trim(),
          "Height": _heightController.text.trim(),
          "Weight": _weightController.text.trim(),
          "Blood": selectedBloodType,
          "Date": selectedDate == null
              ? ""
              : "${selectedDate?.month}-${selectedDate?.day}-${selectedDate?.year}",
          "Time": time,
        };

        await updateByNamAndGender(widget.babyId);
        await newbornInfoCollection.add(babyData).then((value) async {
          setState(() {
            errorMessage = "";
            isLoading = false;
            _nameController.clear();
            _placeOfBirthController.clear();
            _heightController.clear();
            _weightController.clear();
          });
          if (mounted) {
            _successDialog();
          }
        });
      } else if (hasValidGender == false) {
        setState(() {
          errorMessage = "Gender cannot be empty";
        });
        // return;
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
                          "Information added successfully!",
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
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        BabyInformationEndJourney(),
                                    settings:
                                        RouteSettings(arguments: widget.babyId),
                                  ),
                                );
                                // Navigator.of(context).pop();
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
  // DateTime? _dateOfBirth;
  // DateTime? _timeOfBirth;
  // String? _selectedGender;
  // String? _selectedBloodType;

  Future<Map<String, dynamic>?> getBabyInfoById(String babyId) async {
    Map<String, dynamic>? data;
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId != null) {
        final pregnancyInfoCollection = FirebaseFirestore.instance
            .collection("users")
            .doc(userId)
            .collection("pregnancyInfo");

        final babyData = await pregnancyInfoCollection.doc(babyId).get();

        print("babyData.docs:: ${babyData.data()}");
        data = babyData.data();
      }
    } catch (error) {}

    return data;
  }

  Future<void> updateByNamAndGender(String babyId) async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;

      if (userId != null) {
        final pregnancyInfoCollection = FirebaseFirestore.instance
            .collection("users")
            .doc(userId)
            .collection("pregnancyInfo");

        await pregnancyInfoCollection.doc(babyId).update(
          {
            "Baby's name": _nameController.text.trim(),
            "Gender": selectedGender,
          },
        );
      }
    } catch (error) {}
  }

  @override
  void initState() {
    super.initState();
    errorMessage = "";
    print("BABY ID:: ${widget.babyId} ##");
    _nameController = TextEditingController();
    _heightController = TextEditingController();
    _weightController = TextEditingController();
    _placeOfBirthController = TextEditingController();
    // WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
    //   await updateDatePicker();
    //   final Map<String, dynamic>? baby = await getBabyInfoById(widget.babyId);
    //   if (baby != null) {
    //     setState(() {
    //       _nameController.text = baby['Baby\'s name'];
    //       selectedGender = baby['Gender'];
    //     });
    //   }
    // });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    updateDatePicker();
    getBabyInfoById(widget.babyId).then((value) {
      if (value != null) {
        setState(() {
          _nameController.text = value['Baby\'s name'];
          selectedGender = value['Gender'];
        });
      }
    });
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
                            // Navigator.push(
                            //   context,
                            //   MaterialPageRoute(
                            //     builder: (context) => BabyInformation(),
                            //     settings:
                            //         RouteSettings(arguments: widget.babyId),
                            //   ),
                            // );
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const NavBar()),
                            );
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

  String? selectedGender;
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

  String? weightValidator(String? value) {
    // Weight should be in the format 0.5
    // Weight should be in between 0.5 - 10.0 kg
    /// Validate if the entered value is only number

    if (value != null && value.isNotEmpty) {
      final double? myValue = double.tryParse(value);

      bool containsInvalidCharacters = value.contains(RegExp(r'[a-zA-Z,]')) ||
          RegExp(r'\..*\.').hasMatch(value) ||
          RegExp(r'^(.*[^.])(?<!\.)$').hasMatch(value);

      final bool valueContainsNumbers =
          RegExp(r'^-?\d*\.?\d+$').hasMatch(value.trim());

      final bool isStartWithDot = value.trim().startsWith(".");
      final bool isEndWithDot = value.trim().endsWith(".");

      final specialCharacters = RegExp(r"[!@#$%^&*()]").hasMatch(value.trim());

      if (valueContainsNumbers && (isStartWithDot || isEndWithDot)) {
        return "Weight should be in the format: 0.5";
      } else if (isStartWithDot) {
        return "Only numbers allowed";
      } else if (isEndWithDot) {
        return "Only numbers allowed";
      } else if (isStartWithDot && isEndWithDot) {
        return "Only numbers allowed";
      } else if (specialCharacters) {
        return "Only numbers allowed";
      } else if (myValue != null) {
        final isValueValidNumber = myValue < 0.5 || myValue > 10.0;
        if (isValueValidNumber) {
          return "Weight should be in between 0.5 - 10.0 kg";
        }
      } else if (containsInvalidCharacters) {
        return "Only numbers allowed";
      }
    }
    return null;
  }

  String? heightValidator(String? value) {
    if (value != null && value.isNotEmpty) {
      final double? myValue = double.tryParse(value);

      bool containsInvalidCharacters = value.contains(RegExp(r'[a-zA-Z,]')) ||
          RegExp(r'\..*\.').hasMatch(value) ||
          RegExp(r'^(.*[^.])(?<!\.)$').hasMatch(value);

      final bool valueContainsNumbers =
          RegExp(r'^-?\d*\.?\d+$').hasMatch(value.trim());

      final bool isStartWithDot = value.trim().startsWith(".");
      final bool isEndWithDot = value.trim().endsWith(".");

      final specialCharacters = RegExp(r"[!@#$%^&*()]").hasMatch(value.trim());

      if (valueContainsNumbers && (isStartWithDot || isEndWithDot)) {
        return "Height should be in the format: 43.5";
      } else if (isStartWithDot) {
        return "Only numbers allowed";
      } else if (isEndWithDot) {
        return "Only numbers allowed";
      } else if (isStartWithDot && isEndWithDot) {
        return "Only numbers allowed";
      } else if (specialCharacters) {
        return "Only numbers allowed";
      } else if (myValue != null) {
        final isValueValidNumber = myValue < 35.0 || myValue > 65.0;
        if (isValueValidNumber) {
          return "Height should be in between 35.0 - 65.0 cm";
        }
      } else if (containsInvalidCharacters) {
        return "Only numbers allowed";
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    // RegExp regex = RegExp(r'^\d*\.?\d*$');
    // RegExp regex = RegExp(r'^(?!\.)(\d+(\.\d*)?)?$');
    // RegExp regex = RegExp(r'^(?!\.)\d+(\.\d+)?$');
    // final regex = RegExp(r'^\d+(\.\d+)?$');
    // final RegExp regex = RegExp(r'^\d*\.?\d*$');
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

    return WillPopScope(
      onWillPop: () async {
        backButton();

        return false;
      },
      child: Scaffold(
        backgroundColor: backGroundPink,
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          child: Column(
            children: [
              /* Align(
                alignment: Alignment.bottomLeft,
                child: SizedBox(
                  height: 25,
                  child: BackButton(
                    onPressed: backButton,
                    style: const ButtonStyle(
                      padding: MaterialStatePropertyAll(
                        EdgeInsets.zero,
                      ),
                    ),
                  ),
                ),
              ),*/
              const Text(
                "Newborn Information",
                style: TextStyle(
                  color: Color(0xFFD77D7C),
                  fontSize: 30,
                  fontFamily: 'Urbanist',
                  fontWeight: FontWeight.w600,
                  height: 1.45,
                  letterSpacing: -0.28,
                ),
              ),
              const SizedBox(height: 15),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18.0,
                  ),
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFFFFF),
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(50.0),
                    ),
                  ),
                  child: SingleChildScrollView(
                    physics: const NeverScrollableScrollPhysics(),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                Container(
                                  margin: const EdgeInsets.only(
                                    top: 20,
                                    left: 5,
                                    bottom: 2,
                                  ),
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

                                TextFormField(
                                  maxLength: 25,
                                  controller: _nameController,
                                  style: const TextStyle(
                                    fontSize: 15.0,
                                    fontFamily: 'Urbanist',
                                  ),
                                  keyboardType: TextInputType.name,
                                  decoration: InputDecoration(
                                    hintText: "Example: Amal",
                                    hintStyle: const TextStyle(
                                      fontSize: 15.0,
                                      fontFamily: 'Urbanist',
                                      color: Color.fromARGB(255, 150, 149, 149),
                                    ),
                                    errorStyle: textStyleError,
                                    contentPadding: const EdgeInsets.symmetric(
                                        vertical: 15.0, horizontal: 15),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12.0),
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
                                    final lettersRegExpOnly =
                                        RegExp(r'^[a-z A-Z]+$');

                                    /// cannot be empty
                                    if (value == null || value.isEmpty) {
                                      return "Field cannot be empty";
                                    }

                                    /// allow upper and lower case alphabets and space if input is written
                                    if (!lettersRegExpOnly.hasMatch(value)) {
                                      return "Only letters allowed";
                                    } else {
                                      return null;
                                    }
                                  },
                                ),

                                /// HEIGHT
                                Column(
                                  children: [
                                    Container(
                                      margin: const EdgeInsets.only(
                                        top: 0,
                                        left: 5,
                                        bottom: 2,
                                      ),
                                      alignment: Alignment.centerLeft,
                                      child: const Text(
                                        "Height",
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
                                    TextFormField(
                                      maxLength: 4,
                                      controller: _heightController,
                                      // keyboardType: TextInputType.number,
                                      validator: heightValidator,
                                      style: const TextStyle(
                                        fontSize: 15.0,
                                        fontFamily: 'Urbanist',
                                      ),
                                      decoration: InputDecoration(
                                        hintText: "Height in cm. Example: 45.0",
                                        hintStyle: const TextStyle(
                                          fontSize: 15.0,
                                          fontFamily: 'Urbanist',
                                          color: Color.fromARGB(
                                              255, 150, 149, 149),
                                        ),
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
                                  ],
                                ),

                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      margin: const EdgeInsets.only(
                                        top: 0,
                                        left: 5,
                                        bottom: 2,
                                      ),
                                      alignment: Alignment.centerLeft,
                                      child: const Text(
                                        "Weight",
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
                                    TextFormField(
                                      maxLength: 4,
                                      controller: _weightController,
                                      validator: weightValidator,
                                      style: const TextStyle(
                                        fontSize: 15.0,
                                        fontFamily: 'Urbanist',
                                      ),
                                      decoration: InputDecoration(
                                        hintText: "Weight in kg. Example: 3.5",
                                        hintStyle: const TextStyle(
                                          fontSize: 15.0,
                                          fontFamily: 'Urbanist',
                                          color: Color.fromARGB(
                                              255, 150, 149, 149),
                                        ),
                                        // keyboardType: TextInputType.number,
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
                                  ],
                                ),

                                /// PLACE OF BIRTH
                                Container(
                                  margin: const EdgeInsets.only(
                                    top: 0,
                                    left: 5,
                                    bottom: 2,
                                  ),
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

                                /// Place of Birth Field
                                TextFormField(
                                  maxLength: 35,
                                  controller: _placeOfBirthController,
                                  style: const TextStyle(
                                    fontSize: 15.0,
                                    fontFamily: 'Urbanist',
                                  ),
                                  validator: (value) {
                                    final lettersRegExpOnly =
                                        RegExp(r'^[a-z A-Z]+$');
                                    final RegExp noSpacesRegExp =
                                        RegExp(r'^[^\s]+$');
                                    final isFieldEmpty = _placeOfBirthController
                                        .text
                                        .trim()
                                        .isEmpty;

                                    /// allow empty field
                                    if (value == null || value.isEmpty) {
                                      return null;
                                    }

                                    /// allow upper and lower case alphabets and space if input is written
                                    if (!lettersRegExpOnly.hasMatch(value)) {
                                      return "Only letters allowed";
                                    } else if (!noSpacesRegExp
                                            .hasMatch(value) &&
                                        isFieldEmpty) {
                                      return "Only letters allowed";
                                    }
                                  },
                                  decoration: InputDecoration(
                                    hintText: "Example: Riyadh",
                                    hintStyle: const TextStyle(
                                      fontSize: 15.0,
                                      fontFamily: 'Urbanist',
                                      color: Color.fromARGB(255, 150, 149, 149),
                                    ),
                                    errorStyle: textStyleError,
                                    contentPadding: const EdgeInsets.symmetric(
                                        vertical: 15.0, horizontal: 15),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12.0),
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

                                const SizedBox(height: 3),

                                /// Date & Time of Birth
                                CustomResizeWidget(
                                  hasBottomBorder: false,
                                  children: <Widget>[
                                    const Text(
                                      "Date of Birth",
                                      style: TextStyle(
                                        color: Colors.black,
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
                                            selectedDate == null
                                                ? "Select"
                                                : '${selectedDate?.month}-${selectedDate?.day}-${selectedDate?.year}',
                                            overflow: TextOverflow.ellipsis,
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
                                            padding: EdgeInsetsDirectional.only(
                                                start: 5),
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

                                CustomResizeWidget(
                                  hasBottomBorder: false,
                                  children: <Widget>[
                                    const Text(
                                      "Time of Birth",
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
                                      children: [
                                        CupertinoButton(
                                          padding: EdgeInsets.zero,
                                          onPressed: _showTimePicker,
                                          child: Text(
                                            timeFormat,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontSize: 16.0,
                                              fontFamily: 'Urbanist',
                                              color: Colors.black,
                                            ),
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: _showTimePicker,
                                          child: const Padding(
                                            padding: EdgeInsetsDirectional.only(
                                                start: 5),
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

                                /// Blood Type
                                CustomResizeWidget(
                                  hasBottomBorder: false,
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
                                        color: Color.fromARGB(255, 0, 0, 0),
                                        fontSize: 17,
                                        fontFamily: 'Urbanist',
                                        fontWeight: FontWeight.w700,
                                        height: 1.30,
                                        letterSpacing: -0.28,
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        Text(
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

                                /// Gender
                                GenderViewWidget(
                                  gender: gender,
                                  selectedValue: selectedGender ?? "",
                                  onChanged: (value) {
                                    setState(() {
                                      selectedGender = value;
                                    });
                                  },
                                ),
                                Container(
                                  height: 20,
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    errorMessage,
                                    style: textStyleError,
                                  ),
                                ),
                                // Container(
                                //   alignment: Alignment.centerLeft,
                                //   child:
                                //       Text(errorMessage, style: textStyleError),
                                // ),
                                const SizedBox(height: 10),
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
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
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
        height: 50,
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
                    color: CupertinoColors.inactiveGray,
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

  String? selectedBlood = "";

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
        selectedBlood = widget.initialBloodValue ?? "";
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
              // setState(() {
              //   for (var item in bloodTypes) {
              //     item['isSelected'] = false;
              //   }
              //   // bloodTypes.map((e) => e['isSelected'] = false);
              // });

              setState(() {
                selectedBlood = null;
                bloodTypes.map((e) => e['isSelected'] = false);
              });
            },
            child: const Text(
              "Clear",
              style: TextStyle(
                color: Colors.red,
                fontFamily: 'Urbanist',
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                if (selectedBlood != null) {
                  widget.onSelectedItem(selectedBlood!);
                } else {
                  widget.onSelectedItem("");
                }
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
                        bloodTypes[i]['isSelected'] && selectedBlood != null
                            ? pinkColor
                            : Colors.black,
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
                    toggleable: false,
                    onFocusChange: (value) {
                      print("BLOOD TYPES::--focus $value");
                    },
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

class GenderViewWidget extends StatelessWidget {
  const GenderViewWidget({
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
    var textStyleError = Theme.of(context).textTheme.bodyMedium?.copyWith(
          fontSize: 12.0,
          color: Theme.of(context).colorScheme.error,
          fontWeight: FontWeight.normal,
        );
    return CustomResizeWidget(
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
                    activeColor: pinkColor,
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
    );
  }
}
