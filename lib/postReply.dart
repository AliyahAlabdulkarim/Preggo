// ignore_for_file: use_key_in_widget_constructors, camel_case_types, unused_import, prefer_const_constructors, prefer_const_literals_to_create_immutables, non_constant_identifier_names, unused_local_variable, avoid_print

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:preggo/colors.dart';
import 'package:preggo/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math' as math;
import 'package:preggo/profile/profile_screen.dart';
import 'package:preggo/screens/edit_post_community_screen.dart';

class postReply extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _postReply();
  }
}

class _postReply extends State<postReply> {
  String postId = '';
  var errorMessage = "";
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<FormFieldState> _nameKey = GlobalKey<FormFieldState>();
  final TextEditingController _postReplyController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (postId.isNotEmpty) {
      setState(() {
        fetchPostWidgetView = displayPost(postId);
      });
    }
  }

  Future<void> deletePostById({
    required String postId,
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
                      'Are you sure you want to delete this post?',
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
                              final communityCollection = FirebaseFirestore
                                  .instance
                                  .collection("community");

                              /// Delete now
                              await communityCollection
                                  .doc(postId)
                                  .delete()
                                  .then((value) async {
                                if (context.mounted) {
                                  Navigator.of(context).pop();
                                  await _deletePostSuccess(context);
                                }
                              });
                            } catch (error) {
                              print("Delete post:: $error ##");
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

  Future<void> _deletePostSuccess(
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
                          "Post deleted successfully!",
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

  String getTimestamp() {
    DateTime stamp = DateTime.now();
    String formattedStamp = DateFormat('yyyy/MM/dd hh:mm a').format(stamp);
    return formattedStamp;
  }

  //ADD THE REPLY TO FIRESTORE UNDER THE POST IN SUBCOLLECTION 'REPLIES'
  Future<void> addNewReply(String post) async {
    final userUid = FirebaseAuth.instance.currentUser?.uid;
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    //ADD THE REPLY
    if (userUid != null && _formKey.currentState!.validate()) {
      //GET USERNAME AND INCREMENT COMMENTS OF POST BY ONE
      final DocumentReference postDocRef =
          firestore.collection('community').doc(post);
      final DocumentSnapshot postSnapshot = await postDocRef.get();
      if (postSnapshot.exists) {
        final Map<String, dynamic> postData =
            postSnapshot.data() as Map<String, dynamic>;

        int comments = postData['comments'];
        comments++;
        await postDocRef.update({'comments': comments});
      }

      //CREATE THE SUBCOLLECTION & ADD THE REPLY
      CollectionReference repliesRef =
          firestore.collection('community').doc(post).collection('Replies');
      repliesRef.add({
        'userID': userUid,
        'reply': _postReplyController.text,
        'timestamp': getTimestamp(),
      }).then((value) {
        _successDialog();
        setState(() {
          _postReplyController.clear();
        });
      }).catchError((error) {
        setState(() {
          errorMessage = "";
        });
      });
    }
  }

//SHOWS SUCCESS DIALOG WHEN POST IS ADDED SUCCESSFULY
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

                        // Done
                        const Text(
                          "Reply added successfully!",
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

  //SHOWS CONFIRMATION MESSAGE WHEN LEAVING PAGE AND TEXT IS WRITTEN IN THE FIELD
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

  Future<Widget?>? fetchPostWidgetView;

  //DISPLAY THE POST THAT WAS CLICKED ON (PROFILE PIC, USERNAME, TITLE, BODY, TIMESTAMP)
  Future<Widget> displayPost(String postid) async {
    String username = '';
    String title = '';
    String body = '';
    String timestamp = '';

    FirebaseFirestore firestore = FirebaseFirestore.instance;
    final DocumentReference postDocRef =
        firestore.collection('community').doc(postid);
    final DocumentSnapshot postSnapshot = await postDocRef.get();
    if (postSnapshot.exists) {
      final Map<String, dynamic> postData =
          postSnapshot.data() as Map<String, dynamic>;

      username = postData['username'];
      username = username.toString().capitalize();
      title = postData['title'];
      body = postData['body'];
      timestamp = postData['timestamp'];
      final String? postOwnerId = postData['userID'];

      final String? userId = FirebaseAuth.instance.currentUser?.uid;
      final bool showDeleteButton =
          userId != null && postOwnerId != null && userId == postOwnerId;
      return Container(
        decoration: BoxDecoration(
          color: backGroundPink.withOpacity(0.2),
        ),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(0, 40, 0, 0),
              child: Row(
                children: [
                  ///////////////////////////////
                  IconButton(
                    onPressed: () {
                      if (_postReplyController.text.isNotEmpty) {
                        backButton();
                      } else {
                        Navigator.pop(context);
                      }
                    },
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Colors.black,
                    ),
                  ),

                  //POST TITLE
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 20,
                        color: blackColor,
                        fontFamily: 'Urbanist',
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.28,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: EdgeInsets.fromLTRB(20, 0, 15, 5),
              child: Row(
                children: [
                  //PROFILE PIC
                  CircleAvatar(
                    radius: 19,
                    backgroundColor: pinkColor.withOpacity(0.5),
                    child: Text(
                      username.substring(0, 1).toUpperCase(),
                      style: TextStyle(
                        fontFamily: 'Urbanist',
                        fontSize: 20,
                        color: blackColor,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  //USERNAME
                  Text(
                    username,
                    style: TextStyle(
                      color: pinkColor,
                      fontSize: 19,
                      fontFamily: 'Urbanist',
                      fontWeight: FontWeight.w700,
                      height: 1.30,
                      letterSpacing: -0.28,
                    ),
                  ),
                  Text(
                    '  posted: ',
                    style: TextStyle(
                      color: blackColor,
                      fontSize: 19,
                      fontFamily: 'Urbanist',
                      fontWeight: FontWeight.w600,
                      height: 1.30,
                      letterSpacing: -0.28,
                    ),
                  ),
                ],
              ),
            ),

            /////////////////
            Padding(
              padding: EdgeInsets.fromLTRB(20, 5, 15, 10),
              child: Row(
                children: [
                  //POST BODY
                  Expanded(
                      child: Text(
                    body,
                    style: TextStyle(
                      fontSize: 15.5,
                      color: blackColor,
                      fontFamily: 'Urbanist',
                      fontWeight: FontWeight.w500,
                      letterSpacing: -0.28,
                    ),
                  )),
                ],
              ),
            ),

            Padding(
              padding: EdgeInsets.fromLTRB(20, 10, 5, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  //TIMESTAMP
                  Expanded(
                      child: Text(
                    timestamp,
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontSize: 12,
                      color: grayColor,
                      fontFamily: 'Urbanist',
                      fontWeight: FontWeight.w500,
                      letterSpacing: -0.28,
                    ),
                  )),

                  /// Delete Post icon - show it if the current user logged in and the post it is post owner
                  if (showDeleteButton) ...[
                    IconButton(
                      constraints: BoxConstraints(
                        maxWidth: 20,
                        // maxHeight: 20,
                      ),
                      splashRadius: 14,
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) {
                              return EditPostCommunityScreen(
                                postTitle: title,
                                postDescription: body,
                                postId: postId,
                              );
                            },
                          ),
                        ).then(
                          (value) {
                            setState(() {});
                          },
                        );
                      },
                      icon: Icon(
                        Icons.edit,
                        size: 14.5,
                        color: Color.fromARGB(255, 79, 79, 81),
                      ),
                      style: TextButton.styleFrom(
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                    IconButton(
                      splashRadius: 14,
                      onPressed: () async {
                        final String? postId = ModalRoute.of(context)
                            ?.settings
                            .arguments as String?;

                        if (postId != null && postId.isNotEmpty) {
                          await deletePostById(
                              postId: postId, context: context);
                        }
                      },
                      icon: Icon(
                        Icons.delete,
                        size: 14.5,
                        color: Colors.red,
                      ),
                      style: TextButton.styleFrom(
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            SizedBox(
              height: 10,
            ),
          ],
        ),
      );
    } else {
      return Container(
          child: Text(
        'Post Not Found',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 26,
          fontFamily: 'Urbanist',
          fontWeight: FontWeight.w600,
          letterSpacing: -0.28,
        ),
      ));
    }
  }

  //RETURNS USERNAME WHEN GIVEN THE ID
  Future<String> getUsername(String userID) async {
    String replyUsername = '';
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    final DocumentReference userDocRef =
        firestore.collection('users').doc(userID);
    final DocumentSnapshot userSnapshot = await userDocRef.get();
    if (userSnapshot.exists) {
      final Map<String, dynamic> userData =
          userSnapshot.data() as Map<String, dynamic>;
      replyUsername = userData['username'];
      return replyUsername;
    } else {
      return replyUsername;
    }
  }

  //DISPLAY ALL REPLIES OF THE POSTS
  Future<Widget> getReplies(String postid) async {
    QuerySnapshot result = await FirebaseFirestore.instance
        .collection('community')
        .doc(postid)
        .collection('Replies')
        .get();
    print(result.docs.length);

    if (result.docs.isEmpty) //no replies for this date
    {
      return Center(
        child: Column(
          children: [
            Center(
              //no replies image
              child: Padding(
                padding: EdgeInsets.only(top: 100),
                child: Image.asset(
                  'assets/images/comment.png',
                  height: 50,
                  width: 50,
                ),
              ),
            ),
            Container(
                //message
                margin: EdgeInsets.fromLTRB(30, 20, 30, 80),
                child: Text(
                  'No Replies Yet',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontFamily: 'Urbanist',
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.28,
                  ),
                )),
          ],
        ),
      );
    } else {
      //there are replies for this post
      List replyResult = result.docs;

      //sort the replies based on the date and time showing newest first
      replyResult.sort((a, b) {
        String timeA = a.data()['timestamp'] ?? '';
        String timeB = b.data()['timestamp'] ?? '';
        // Convert 'timestamp' strings to DateTime objects for comparison
        DateFormat format = DateFormat("yyyy/MM/dd hh:mm a");
        DateTime dateTimeA = format.parse(timeA);
        DateTime dateTimeB = format.parse(timeB);
        return dateTimeB.compareTo(dateTimeA);
      });

      return ListView.builder(
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: replyResult.length,
        itemBuilder: (context, index) {
          String id = replyResult[index].data()['userID'] ?? '';
          String ReplyBody = replyResult[index].data()['reply'] ?? '';
          String Replytimestamp = replyResult[index].data()['timestamp'] ?? '';
          String replierUsername = '';
          bool isLoading = true;

          return FutureBuilder<String>(
            future: getUsername(id),
            builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                if (isLoading && index == 0) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: pinkColor,
                    ),
                  );
                } else {
                  return SizedBox(); // Return an empty SizedBox while loading subsequent items
                }
              } else if (snapshot.hasData) {
                String replierUsername = snapshot.data!;
                replierUsername = replierUsername.capitalize();

                return Container(
                  margin: EdgeInsets.symmetric(vertical: 5, horizontal: 8),
                  child: Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          //PROFILE PIC AND USERNAME
                          children: [
                            SizedBox(
                              width: 13,
                            ),
                            CircleAvatar(
                              radius: 17,
                              backgroundColor: pinkColor.withOpacity(0.5),
                              child: Text(
                                replierUsername.substring(0, 1).toUpperCase(),
                                style: TextStyle(
                                  fontFamily: 'Urbanist',
                                  fontSize: 20,
                                  color: blackColor,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Text(
                              replierUsername,
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 14,
                                fontFamily: 'Urbanist',
                                fontWeight: FontWeight.w700,
                                height: 1.30,
                                letterSpacing: -0.28,
                              ),
                            ),
                            SizedBox(height: 2),
                          ],
                        ),
                        Container(
                          //ACTUAL POST REPLY AND TIMESTAMP
                          margin:
                              EdgeInsets.only(bottom: 20, left: 10, right: 10),
                          padding: EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),

                          decoration: BoxDecoration(
                            color: backGroundPink.withOpacity(0.3),
                            border: Border.all(color: backGroundPink, width: 2),
                            borderRadius: BorderRadius.circular(13),
                          ),
                          child: IntrinsicHeight(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    ReplyBody,
                                    //overflow: TextOverflow.visible,
                                    //maxLines: 3,
                                    softWrap: true,
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 11.5,
                                      fontFamily: 'Urbanist',
                                      fontWeight: FontWeight.w600,
                                      height: 1.30,
                                      letterSpacing: -0.28,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Align(
                                  alignment: Alignment.bottomLeft,
                                  child: Text(
                                    Replytimestamp,
                                    style: TextStyle(
                                      color: Color.fromARGB(200, 121, 113, 113),
                                      fontSize: 9,
                                      fontFamily: 'Urbanist',
                                      fontWeight: FontWeight.w700,
                                      height: 1.30,
                                      letterSpacing: -0.28,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else {
                return SizedBox();
              }
            },
          );
        },
      );
    }
  }

  ///////////////////////////////////////////

  @override
  Widget build(BuildContext context) {
    postId = ModalRoute.of(context)?.settings.arguments as String;

    final String? userId = FirebaseAuth.instance.currentUser?.uid;
    var textStyleError = Theme.of(context).textTheme.bodyMedium?.copyWith(
          fontSize: 12.0,
          color: Theme.of(context).colorScheme.error,
          fontWeight: FontWeight.normal,
        );

    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              FutureBuilder<Widget?>(
                future: displayPost(postId),
                builder: (context, snapshot) {
                  if (snapshot.hasData && snapshot.data != null) {
                    return snapshot.data!;
                  }

                  return Center(
                      //child: CircularProgressIndicator(
                      //color: pinkColor),
                      );
                },
              ),
              Expanded(
                child: SingleChildScrollView(
                  physics: AlwaysScrollableScrollPhysics(),
                  scrollDirection: Axis.vertical,
                  child: FutureBuilder<Widget>(
                    future: getReplies(postId),
                    builder:
                        (BuildContext context, AsyncSnapshot<Widget> snapshot) {
                      if (snapshot.hasData) {
                        return snapshot.data!;
                      }

                      return Container();
                    },
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(5, 5, 0, 5),
                      child: Form(
                        key: _formKey,
                        child: SizedBox(
                          width: 305,
                          child: TextFormField(
                            key: _nameKey,
                            maxLength: 250,
                            controller: _postReplyController,

                            style: const TextStyle(
                              fontSize: 15.0,
                              fontFamily: 'Urbanist',
                              // color: pinkColor,
                            ),
                            decoration: InputDecoration(
                              errorStyle: textStyleError,
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 15.0, horizontal: 15),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              enabledBorder: const OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(12.0)),
                                borderSide: BorderSide(color: darkGrayColor),
                              ),
                              focusedBorder: const OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(12.0)),
                                borderSide: BorderSide(color: darkGrayColor),
                                // borderSide: BorderSide(color: darkGrayColor),
                              ),
                              hintText: "Write your Reply...",
                              filled: true,
                              fillColor: const Color(0xFFF7F8F9),
                            ),
                            //autovalidateMode:
                            //AutovalidateMode.onUserInteraction,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return "This field cannot be empty.";
                              }
                              return null;
                            },
                          ),
                        ),
                      ),
                    ),
                    Transform.translate(
                      offset: Offset(0, -12),
                      child: Transform.rotate(
                        angle: 325 * math.pi / 180,
                        child: IconButton(
                          onPressed: () {
                            addNewReply(postId);
                          },
                          icon: const Icon(
                            Icons.send,
                            color: darkBlackColor,
                            size: 26,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
