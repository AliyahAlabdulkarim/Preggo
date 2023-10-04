import 'package:preggo/addAppointment.dart';
import 'package:preggo/profile_screen.dart';
import 'package:preggo/screens/PregnancyTracking.dart';
import 'package:preggo/screens/CommunityPage.dart';
//import 'package:preggo/screens/ProfilePage.dart';
import 'package:preggo/screens/ToolsPage.dart';
import 'package:preggo/screens/ArticlesPage.dart';
import 'package:flutter/material.dart';
import 'package:googleapis/calendar/v3.dart' as Cal;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:preggo/viewAppointment.dart';

class NavBar extends StatefulWidget {
  const NavBar({super.key});

  @override
  _NavBar createState() => _NavBar();
}

class _NavBar extends State<NavBar> {
  int currentTab = 0;
  final List<Widget> screens = [
    PregnancyTracking(), //0
    const CommunityPage(), //1
    ProfileScreen(), //ProfilePage(), //2
    const ToolsPage(), //3
    const ArticlesPage() //4
  ];

  final PageStorageBucket bucket = PageStorageBucket();
  Widget currentScreen = PregnancyTracking();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageStorage(
        bucket: bucket,
        child: currentScreen,
      ),

      // the profile page
      floatingActionButton: FloatingActionButton(
        backgroundColor:
            currentTab == 2 ? const Color(0xFFD77D7C) : Colors.grey,
        onPressed: () {
          setState(() {
            currentScreen =
                ProfileScreen(); //ProfileScreen() , //ProfileScreen(), //const ProfilePage();
            currentTab = 2;
          });
        },
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.pregnant_woman_rounded,
              size: 35,
              color: Colors.white,
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 10,
        child: SizedBox(
          height: 80,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              // the pregnancy tracking page
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MaterialButton(
                    minWidth: 40,
                    onPressed: () {
                      setState(() {
                        currentScreen = PregnancyTracking();
                        currentTab = 0;
                      });
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          size: 30,
                          Icons.home_filled,
                          color: currentTab == 0
                              ? const Color(0xFFD77D7C)
                              : Colors.grey,
                        ),
                        Text(
                          "Home",
                          style: TextStyle(
                              color: currentTab == 0
                                  ? const Color(0xFFD77D7C)
                                  : Colors.grey,
                              fontFamily: 'Urbanist'),
                        )
                      ],
                    ),
                  ),

                  // the community page
                  MaterialButton(
                    minWidth: 40,
                    onPressed: () async {
                      const _scopes = [
                        Cal.CalendarApi.calendarScope
                      ]; //scope to CREATE EVENT in calendar

                      GoogleSignIn _googleSignIn = GoogleSignIn(
                        // Optional clientId
                        // clientId: 'your-client_id.apps.googleusercontent.com',
                        scopes: _scopes,
                      );

                      Future<void> _handleSignIn() async {
                        try {
                          await _googleSignIn.signIn();
                        } catch (error) {
                          print(error);
                        }
                      }

                      _googleSignIn.signOut();

                      await _handleSignIn();
                      setState(() {
                        currentScreen = viewAppointment();
                        currentTab = 1;
                        print('HELLOHELLO');
                        print(_googleSignIn.currentUser);
                      });
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          size: 30,
                          Icons.language,
                          color: currentTab == 1
                              ? const Color(0xFFD77D7C)
                              : Colors.grey,
                        ),
                        Text(
                          "Community",
                          style: TextStyle(
                              color: currentTab == 1
                                  ? const Color(0xFFD77D7C)
                                  : Colors.grey,
                              fontFamily: 'Urbanist'),
                        )
                      ],
                    ),
                  ),
                ],
              ),

              //Right Tab Bar icons

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // tools page
                  MaterialButton(
                    minWidth: 40,
                    onPressed: () {
                      //   const _scopes = [
                      //     Cal.CalendarApi.calendarScope
                      //   ]; //scope to CREATE EVENT in calendar

                      //   GoogleSignIn _googleSignIn = GoogleSignIn(
                      //     // Optional clientId
                      //     // clientId: 'your-client_id.apps.googleusercontent.com',
                      //     scopes: _scopes,
                      //   );

                      //   Future<void> _handleSignIn() async {
                      //     try {
                      //       await _googleSignIn.signIn();
                      //     } catch (error) {
                      //       print(error);
                      //     }
                      //   }

                      // await _handleSignIn();
                      setState(() {
                        currentScreen = addAppointment();
                        currentTab = 3;
                        print('HELLOHELLO');
                        // print(_googleSignIn.currentUser);
                      });
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          size: 30,
                          Icons.brush,
                          color: currentTab == 3
                              ? const Color(0xFFD77D7C)
                              : Colors.grey,
                        ),
                        Text(
                          "Tools",
                          style: TextStyle(
                            fontFamily: 'Urbanist',
                            color: currentTab == 3
                                ? const Color(0xFFD77D7C)
                                : Colors.grey,
                          ),
                        )
                      ],
                    ),
                  ),

                  // Articles page
                  MaterialButton(
                    minWidth: 40,
                    onPressed: () {
                      setState(() {
                        currentScreen = const ArticlesPage();
                        currentTab = 4;
                      });
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          size: 30,
                          Icons.description,
                          color: currentTab == 4
                              ? const Color(0xFFD77D7C)
                              : Colors.grey,
                        ),
                        Text(
                          "Articles",
                          style: TextStyle(
                              color: currentTab == 4
                                  ? const Color(0xFFD77D7C)
                                  : Colors.grey,
                              fontFamily: 'Urbanist'),
                        )
                      ],
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
