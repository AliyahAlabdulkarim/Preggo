// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, avoid_print, no_leading_underscores_for_local_identifiers, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:flutter_toggle_tab/flutter_toggle_tab.dart';
import '../colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../postReply.dart';
import 'post_community.dart';
import 'package:preggo/screens/profile_screen.dart';

class CommunityPage extends StatefulWidget {
  const CommunityPage({super.key});
  @override
  _CommunityPage createState() => _CommunityPage();
}

int _tabTextIndexSelected = 0;
List<String> _listTextTabToggle = ['All Posts', 'My Posts'];
late Future<QuerySnapshot<Map<String, dynamic>>> _allPosts;
late Future<QuerySnapshot<Map<String, dynamic>>> _myPosts;

Future<QuerySnapshot<Map<String, dynamic>>> getAllPosts() async {
  var result = FirebaseFirestore.instance.collection('community').get();
  return result;
}

Future<QuerySnapshot<Map<String, dynamic>>> getMyPosts() async {
  User? user = FirebaseAuth.instance.currentUser;
  String uid = user!.uid;
  print(uid);
  var result = FirebaseFirestore.instance
      .collection('community')
      .where('userID', isEqualTo: uid)
      .get();

  return result;
}

class _CommunityPage extends State<CommunityPage> {
  @override
  void initState() {
    _allPosts = getAllPosts();
    _myPosts = getMyPosts();
    super.initState();
  }

  int count = 0;
  refreshData() {
    count++;
    print(count);
  }

  onGoBack(dynamic value) {
    print('in on go back');
    refreshData();
    setState(() {
      _allPosts = getAllPosts();
      _myPosts = getMyPosts();
      print('on go back set state');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            margin: const EdgeInsets.only(left: 20, top: 45),
            // child: RichText(
            //   text: const TextSpan(
            //     style: TextStyle(
            //       fontFamily: 'Urbanist',
            //     ),
            //     children: <TextSpan>[
            //       TextSpan(
            //           text: 'Community\n',
            //           style: TextStyle(
            //               color: Colors.black,
            //               fontSize: 35,
            //               fontWeight: FontWeight.w400)),
            //       TextSpan(
            //           text: ' Welcome to the Preggo Community!',
            //           style:
            //               TextStyle(color: Color.fromARGB(255, 121, 119, 119))),
            //     ],
            //   ),
            // ),
          ),
          // communityWidget(_tabTextIndexSelected),
          _tabTextIndexSelected == 0 ? allPosts() : myPosts(),
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: EdgeInsets.fromLTRB(0, 20, 20, 50),
              child: ElevatedButton(
                onPressed: () async {
                  await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: ((context) => PostCommunityScreen()),
                      )).then(onGoBack);
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
          ),
          Container(
            padding: EdgeInsets.only(top: 50, left: 65),
            child: FlutterToggleTab(
              width: 60, // width in percent
              borderRadius: 30,
              height: 50,
              selectedIndex: _tabTextIndexSelected,
              selectedBackgroundColors: [pinkColor, pinkColor],
              selectedTextStyle: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700),
              unSelectedTextStyle: TextStyle(
                  color: Colors.black87,
                  fontSize: 14,
                  fontWeight: FontWeight.w500),
              labels: _listTextTabToggle,
              selectedLabelIndex: (index) {
                setState(
                  () {
                    _tabTextIndexSelected = index;
                    print(_tabTextIndexSelected);
                  },
                );
              },
              isScroll: false,
            ),
          ),
        ], //column children
      ),
    );
  }

  Widget communityWidget(_tabTextIndexSelected) {
    if (_tabTextIndexSelected == 0) //All posts
    {
      setState(() {});
      return allPosts();
    } else //My posts
    {
      setState(() {});
      return myPosts();
    }
  }

  Widget allPosts() {
    return FutureBuilder(
      future: _allPosts,
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
          //there are posts
          List allPosts = snapshot.data!.docs;
          allPosts.sort((a, b) {
            //SORTING THE POSTS BY LATEST
            String timeA = a.data()['timestamp'] ?? '';
            String timeB = b.data()['timestamp'] ?? '';
            // Convert 'timestamp' strings to DateTime objects for comparison
            DateFormat format = DateFormat("yyyy/MM/dd hh:mm a");
            DateTime dateTimeA = format.parse(timeA);
            DateTime dateTimeB = format.parse(timeB);
            return dateTimeB.compareTo(dateTimeA);
          });

          return SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            scrollDirection: Axis.vertical,
            child: SizedBox(
              height: 800,
              child: ListView.builder(
                itemCount: snapshot.data!.docs.length + 2,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return Container(height: 70);
                  } else if (index > 0 &&
                      index < snapshot.data!.docs.length + 1) {
                    String username = allPosts[index - 1]
                        .data()['username']
                        .toString()
                        .capitalize();
                    String postTitle = allPosts[index - 1].data()['title'];
                    String postBody = allPosts[index - 1].data()['body'];
                    String timestamp = allPosts[index - 1].data()['timestamp'];
                    String comments =
                        allPosts[index - 1].data()['comments'].toString();
                    String postID = allPosts[index - 1].reference.id.toString();
                    return GestureDetector(
                      onTap: () {
                        print(postID);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => postReply(),
                            settings: RouteSettings(arguments: postID),
                          ),
                        ).then(onGoBack);
                        //rana's page ^^^^^
                      },
                      child: Column(
                        children: [
                          Container(
                            margin: EdgeInsets.only(left: 20, bottom: 1),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                CircleAvatar(
                                  radius: 18,
                                  backgroundColor: pinkColor.withOpacity(0.5),
                                  child: Text(
                                    username.substring(0, 1).toUpperCase(),
                                    style: TextStyle(
                                      fontFamily: 'Urbanist',
                                      fontSize: 22,
                                      color: blackColor,
                                    ),
                                  ),
                                ),
                                Text(
                                  "  $username",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 14,
                                    fontFamily: 'Urbanist',
                                    fontWeight: FontWeight.w700,
                                    height: 1.30,
                                    letterSpacing: -0.28,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IntrinsicHeight(
                            child: Container(
                              margin: EdgeInsets.only(bottom: 27),
                              padding: EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 10,
                              ),
                              //  height: 110,
                              width: 330,
                              decoration: BoxDecoration(
                                color: backGroundPink.withOpacity(0.3),
                                border:
                                    Border.all(color: backGroundPink, width: 2),
                                borderRadius: BorderRadius.circular(13),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          postTitle,
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 14,
                                            fontFamily: 'Urbanist',
                                            fontWeight: FontWeight.w800,
                                            height: 1.30,
                                            letterSpacing: -0.28,
                                          ),
                                        ),
                                        SizedBox(
                                          height: 5,
                                        ),
                                        Expanded(
                                          child: Text(
                                            postBody,
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 3,
                                            softWrap: true,
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 11,
                                              fontFamily: 'Urbanist',
                                              fontWeight: FontWeight.w600,
                                              height: 1.30,
                                              letterSpacing: -0.28,
                                            ),
                                          ),
                                        ),
                                        // SizedBox(
                                        //   height: 4,
                                        // ),
                                        Row(
                                          children: [
                                            SizedBox(
                                              width: 260,
                                              height: 10,
                                              child: Align(
                                                alignment: Alignment.bottomLeft,
                                                child: Text(
                                                  timestamp,
                                                  style: TextStyle(
                                                    color: Color.fromARGB(
                                                        200, 121, 113, 113),
                                                    fontSize: 9,
                                                    fontFamily: 'Urbanist',
                                                    fontWeight: FontWeight.w700,
                                                    height: 1.30,
                                                    letterSpacing: -0.28,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Align(
                                              alignment: Alignment.bottomRight,
                                              child: Row(
                                                children: [
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            right: 1.0),
                                                    child: Icon(
                                                      Icons.chat_bubble_outline,
                                                      color: Color.fromARGB(
                                                          200, 121, 113, 113),
                                                      size: 15,
                                                    ),
                                                  ),
                                                  Text(
                                                    comments,
                                                    style: TextStyle(
                                                      color: Color.fromARGB(
                                                          200, 121, 113, 113),
                                                      fontSize: 12,
                                                      fontFamily: 'Urbanist',
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      height: 1.30,
                                                      letterSpacing: -0.28,
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  } else {
                    return Container(height: 185);
                  }
                },
              ),
            ),
          );
        } else if (snapshot.hasData && snapshot.data!.docs.isEmpty) {
          //no posts
          return Center(
            child: Column(
              children: [
                SizedBox(height: 350),
                Image.asset(
                  'assets/images/comment.png',
                  height: 70,
                  width: 70,
                ),
                Text(
                  'No Posts Yet',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 26,
                    fontFamily: 'Urbanist',
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.28,
                  ),
                ),
              ],
            ),
          );
        } else {
          return Center(
              child: CircularProgressIndicator(
            color: pinkColor,
          ));
        }
      },
    );
  }

  Widget myPosts() {
    print('my posts');
    return FutureBuilder(
      future: _myPosts,
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
          List myPosts = snapshot.data!.docs;
          //Posts exist. first we sort before displaying the posts:
          myPosts.sort((a, b) {
            //SORT BY LATEST
            String timeA = a.data()['timestamp'] ?? '';
            String timeB = b.data()['timestamp'] ?? '';
            // Convert 'timestamp' strings to DateTime objects for comparison
            DateFormat format = DateFormat("yyyy/MM/dd hh:mm a");
            DateTime dateTimeA = format.parse(timeA);
            DateTime dateTimeB = format.parse(timeB);
            return dateTimeB.compareTo(dateTimeA);
          });
          return SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            scrollDirection: Axis.vertical,
            child: SizedBox(
              height: 800,
              child: ListView.builder(
                itemCount: snapshot.data!.docs.length + 2,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    print('index 0');
                    return Container(height: 70);
                  } else if (index > 0 &&
                      index < snapshot.data!.docs.length + 1) {
                    String username = myPosts[index - 1]
                        .data()['username']
                        .toString()
                        .capitalize();
                    String postTitle = myPosts[index - 1].data()['title'];
                    String postBody = myPosts[index - 1].data()['body'];
                    String timestamp = myPosts[index - 1].data()['timestamp'];
                    String postID = myPosts[index - 1].reference.id.toString();
                    String comments =
                        myPosts[index - 1].data()['comments'].toString();

                    return GestureDetector(
                      onTap: () {
                        print(postID);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => postReply(),
                            settings: RouteSettings(arguments: postID),
                          ),
                        ).then(onGoBack);
                        //rana's page ^^^^
                      },
                      child: Column(
                        children: [
                          Container(
                            margin: EdgeInsets.only(left: 20, bottom: 1),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                CircleAvatar(
                                  radius: 18,
                                  backgroundColor: pinkColor.withOpacity(0.5),
                                  child: Text(
                                    username.substring(0, 1).toUpperCase(),
                                    style: TextStyle(
                                      fontFamily: 'Urbanist',
                                      fontSize: 22,
                                      color: blackColor,
                                    ),
                                  ),
                                ),
                                Text(
                                  "  $username",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 14,
                                    fontFamily: 'Urbanist',
                                    fontWeight: FontWeight.w700,
                                    height: 1.30,
                                    letterSpacing: -0.28,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IntrinsicHeight(
                            child: Container(
                              margin: EdgeInsets.only(bottom: 27),
                              padding: EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 10,
                              ),
                              //  height: 110,
                              width: 330,
                              decoration: BoxDecoration(
                                color: backGroundPink.withOpacity(0.3),
                                border:
                                    Border.all(color: backGroundPink, width: 2),
                                borderRadius: BorderRadius.circular(13),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          postTitle,
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 14,
                                            fontFamily: 'Urbanist',
                                            fontWeight: FontWeight.w800,
                                            height: 1.30,
                                            letterSpacing: -0.28,
                                          ),
                                        ),
                                        SizedBox(
                                          height: 5,
                                        ),
                                        Expanded(
                                          child: Text(
                                            postBody,
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 3,
                                            softWrap: true,
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 11,
                                              fontFamily: 'Urbanist',
                                              fontWeight: FontWeight.w600,
                                              height: 1.30,
                                              letterSpacing: -0.28,
                                            ),
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            SizedBox(
                                              width: 260,
                                              height: 10,
                                              child: Align(
                                                alignment: Alignment.bottomLeft,
                                                child: Text(
                                                  timestamp,
                                                  style: TextStyle(
                                                    color: Color.fromARGB(
                                                        200, 121, 113, 113),
                                                    fontSize: 9,
                                                    fontFamily: 'Urbanist',
                                                    fontWeight: FontWeight.w700,
                                                    height: 1.30,
                                                    letterSpacing: -0.28,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Align(
                                              alignment: Alignment.bottomRight,
                                              child: Row(
                                                children: [
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            right: 1.0),
                                                    child: Icon(
                                                      Icons.chat_bubble_outline,
                                                      color: Color.fromARGB(
                                                          200, 121, 113, 113),
                                                      size: 15,
                                                    ),
                                                  ),
                                                  Text(
                                                    comments,
                                                    style: TextStyle(
                                                      color: Color.fromARGB(
                                                          200, 121, 113, 113),
                                                      fontSize: 12,
                                                      fontFamily: 'Urbanist',
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      height: 1.30,
                                                      letterSpacing: -0.28,
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  } else {
                    return Container(height: 185);
                  }
                },
              ),
            ),
          );
        } else if (snapshot.hasData && snapshot.data!.docs.isEmpty) {
          //no posts
          return Center(
            child: Column(
              children: [
                SizedBox(height: 350),
                Image.asset(
                  'assets/images/comment.png',
                  height: 70,
                  width: 70,
                ),
                Text(
                  'No Posts Yet',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 26,
                    fontFamily: 'Urbanist',
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.28,
                  ),
                ),
              ],
            ),
          );
        } else {
          return Center(child: CircularProgressIndicator(color: pinkColor));
        }
      },
    );
  }
}
