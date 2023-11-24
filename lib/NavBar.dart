import 'package:preggo/deleteApptsEndJourney.dart';
import 'package:preggo/profile/profile_screen.dart';
import 'package:preggo/screens/PregnancyTracking.dart';
import 'package:preggo/screens/CommunityPage.dart';

//import 'package:preggo/screens/ProfilePage.dart';
import 'package:preggo/screens/ToolsPage.dart';
import 'package:preggo/screens/ArticlesPage.dart';
import 'package:flutter/material.dart';

class NavBar extends StatefulWidget {
  const NavBar({
    super.key,
    this.currentTab = 0,
  });

  final int currentTab;

  @override
  _NavBar createState() => _NavBar();
}

class _NavBar extends State<NavBar> {
  int currentTab = 0;
  final List<Widget> screens = [
    const PregnancyTracking(), //0
    const CommunityPage(), //1
    ProfileScreen(), //ProfilePage(), //2
    const ToolsPage(), //3
    const ArticlesPage() //4
  ];

  final PageStorageBucket bucket = PageStorageBucket();
  Widget currentScreen = const PregnancyTracking();
  @override
  void initState() {
    if (widget.currentTab == 2) {
      setState(() {
        currentTab = 2;
        currentScreen = ProfileScreen();
      });
    }
    super.initState();
  }

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
                        currentScreen = const PregnancyTracking();
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
                    onPressed: () {
                      setState(() {
                        currentScreen = const CommunityPage();
                        currentTab = 1;
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
                      setState(() {
                        currentScreen = const ToolsPage();
                        currentTab = 3;
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
