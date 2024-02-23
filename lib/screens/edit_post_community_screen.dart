import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:preggo/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

extension CapitalizeAfterDigit on String {
  String get capitalizeAnyWord {
    final RegExp digitRegex = RegExp(r"^\d");

    if (digitRegex.hasMatch(this) == false) {
      // The input does not start with a digit
      // Capitalize the first letter and the rest of the word in lower case
      return this[0].toUpperCase() + substring(1).toLowerCase();
    } else {
      // The input starts with a digit
      // Capitalize the first letter after the digit and the rest of the word in lower case
      return replaceAllMapped(RegExp(r'(\d+)([a-zA-Z])([a-zA-Z]*)'), (match) {
        final String firstLetter = match.group(2)?.toUpperCase() ?? '';
        final String restOfWord = match.group(3)?.toLowerCase() ?? '';
        return '${match.group(1)}$firstLetter$restOfWord';
      });
    }
  }
}

class EditPostCommunityScreen extends StatefulWidget {
  const EditPostCommunityScreen({
    super.key,
    required this.postId,
    required this.postTitle,
    required this.postDescription,
  });
  final String postId;
  final String postTitle;
  final String postDescription;

  @override
  State<StatefulWidget> createState() {
    return EditPostCommunityScreenState();
  }
}

class EditPostCommunityScreenState extends State<EditPostCommunityScreen> {
  var errorMessage = "";
  bool isLoading = false;

  Future<void> updateMyPost() async {
    try {
      final userUid = FirebaseAuth.instance.currentUser?.uid;
      if (userUid != null && _formKey.currentState!.validate()) {
        final prefs = await SharedPreferences.getInstance();
        final username = prefs.getString("username")?.capitalizeAnyWord;
        final date = DateTime.now();
        final String updatedDate =
            DateFormat("yyyy/MM/dd hh:mm a").format(date);
        int comments = 0;

        // final DateTime myDate =
        //     DateFormat("yyyy/MM/dd hh:mm a").parse(formatedDate);

        // final Timestamp timestamp = Timestamp.fromDate(myDate);
        final post = {
          "title": _postTitleController.text,
          "body": _postDescriptionController.text,
          "timestamp": updatedDate,
        };
        final communityCollection =
            FirebaseFirestore.instance.collection("community");
        await communityCollection
            .doc(widget.postId)
            .set(post, SetOptions(merge: true))
            .then((value) {
          if (mounted) {
            /// Refresh my posts

            _successDialog();
          }
          setState(() {
            isLoading = false;
            _postTitleController.clear();
            _postDescriptionController.clear();
          });
        }).catchError((error) {});
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
                    child: SingleChildScrollView(
                      padding: EdgeInsets.zero,
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
                            "Post edited successfully!",
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
                                onPressed: () async {
                                  FirebaseFirestore firestore =
                                      FirebaseFirestore.instance;
                                  final DocumentReference postDocRef = firestore
                                      .collection('community')
                                      .doc(widget.postId);
                                  final DocumentSnapshot postSnapshot =
                                      await postDocRef.get();
                                  /*Navigator.of(context).push(
                                    MaterialPageRoute(
                                        builder: (context) => ProfileScreen()),
                                  );*/
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
            ),
          );
        });
  }

  final _formKey = GlobalKey<FormState>();
  late TextEditingController _postTitleController;

  late TextEditingController _postDescriptionController;

  @override
  void initState() {
    super.initState();
    _postTitleController = TextEditingController(text: widget.postTitle);
    _postDescriptionController =
        TextEditingController(text: widget.postDescription);
  }

  @override
  void dispose() {
    _postTitleController.dispose();
    _postDescriptionController.dispose();
    super.dispose();
  }

  void _showDialog(Widget child) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => Container(
        height: 216,
        padding: const EdgeInsets.only(top: 6.0),
        // The Bottom margin is provided to align the popup above the system
        // navigation bar.
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        // Provide a background color for the popup.
        color: CupertinoColors.systemBackground.resolveFrom(context),
        // Use a SafeArea widget to avoid system overlaps.
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

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height * 0.40;
    final width = MediaQuery.sizeOf(context).width * 0.85;
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
              "Edit post",
              style: TextStyle(
                color: Color(0xFFD77D7C),
                fontSize: 32,
                fontFamily: 'Urbanist',
                fontWeight: FontWeight.w600,
                // height: 1.30,
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
                                  //title label
                                  margin:
                                      const EdgeInsets.only(top: 30, left: 5),
                                  alignment: Alignment.centerLeft,
                                  child: const Text(
                                    "Post Title",
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
                                  //baby name text field
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 5.0),
                                  child: TextFormField(
                                    maxLength: 25,
                                    controller: _postTitleController,
                                    style: const TextStyle(
                                      fontSize: 15.0,
                                      fontFamily: 'Urbanist',
                                      // color: pinkColor,
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
                                        // borderSide: BorderSide(color: darkGrayColor),
                                      ),
                                      filled: true,
                                      fillColor: const Color(0xFFF7F8F9),
                                    ),
                                    // autovalidateMode:
                                    //     AutovalidateMode.onUserInteraction,
                                    validator: (value) {
                                      if (value == null ||
                                          value.trim().isEmpty) {
                                        return "This field cannot be empty.";
                                      }
                                      return null;
                                      // if (!RegExp(r'^[a-z A-Z0-9]+$')
                                      //     .hasMatch(value)) {
                                      //   //allow alphanumerical only AND SPACE
                                      //   return "Please enter letters only.";
                                      // } else {
                                      //   return null;
                                      // }
                                    },
                                  ),
                                ), //end of text field

                                /// Description
                                Container(
                                  //title name label
                                  margin:
                                      const EdgeInsets.only(top: 5, left: 5),
                                  alignment: Alignment.centerLeft,
                                  child: const Text(
                                    "Post Description",
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
                                  // height: 500,
                                  //baby name text field
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 10.0),
                                  child: TextFormField(
                                    maxLines: 7,
                                    minLines: 7,
                                    maxLength: 250,

                                    style: const TextStyle(
                                      fontSize: 15.0,
                                      fontFamily: 'Urbanist',
                                      // color: pinkColor,
                                    ),
                                    // maxLengthEnforcement:
                                    //     MaxLengthEnforcement.none,

                                    controller: _postDescriptionController,
                                    // scrollPadding: EdgeInsets.zero,

                                    decoration: InputDecoration(
                                      hintText: "Optional",
                                      hintStyle: const TextStyle(
                                        fontSize: 15.0,
                                        fontFamily: 'Urbanist',
                                        // color: pinkColor,
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              vertical: 15.0, horizontal: 15),
                                      focusedErrorBorder: OutlineInputBorder(
                                        gapPadding: 0.5,
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: const BorderSide(
                                          width: 0.50,
                                          color:
                                              Color.fromRGBO(255, 100, 100, 1),
                                        ),
                                      ),
                                      errorBorder: OutlineInputBorder(
                                        gapPadding: 0.5,
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: const BorderSide(
                                          width: 0.50,
                                          color:
                                              Color.fromRGBO(255, 100, 100, 1),
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        gapPadding: 0.5,
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: const BorderSide(
                                          width: 0.50,
                                          color: Color.fromARGB(
                                              255, 221, 225, 232),
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        // gapPadding: 100,
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: const BorderSide(
                                          width: 0.50,
                                          color: Color.fromARGB(
                                              255, 221, 225, 232),
                                        ),
                                      ),
                                      filled: true,
                                      fillColor: const Color(0xFFF7F8F9),
                                    ),
                                    // autovalidateMode:
                                    //     AutovalidateMode.onUserInteraction,
                                    // validator: (value) {
                                    //   if (value!.isEmpty) {
                                    //     return "This field cannot be empty.";
                                    //   }
                                    //   if (!RegExp(r'^[a-z A-Z0-9]+$')
                                    //       .hasMatch(value)) {
                                    //     //allow alphanumerical only AND SPACE
                                    //     return "Please enter letters only.";
                                    //   } else {
                                    //     return null;
                                    //   }
                                    // },
                                  ),
                                ), //end of text field

                                /// End description
                                Container(
                                  alignment: Alignment.centerLeft,
                                  child:
                                      Text(errorMessage, style: textStyleError),
                                ),
                                // const SizedBox(height: 30),
                                SizedBox(
                                  height: 45.0,
                                  width:
                                      MediaQuery.sizeOf(context).width * 0.73,
                                  child: ElevatedButton(
                                    onPressed: () async {
                                      await updateMyPost();
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: blackColor,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(40)),
                                      // padding: const EdgeInsets.only(
                                      //     left: 85,
                                      //     top: 15,
                                      //     right: 85,
                                      //     bottom: 15),
                                    ),
                                    child: const Text("Edit Post",
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
