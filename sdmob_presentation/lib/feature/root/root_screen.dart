import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ssecretdiary/feature/feed/feed_screen.dart';
import 'package:ssecretdiary/feature/profile/profile_screen.dart';

class RootScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _RootState();
  }
}

class _RootState extends State<RootScreen> {
  int _currentPageIndex = 0;
  final List<Widget> bottomTabsPages = [FeedScreen(), ProfileScreen()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: bottomTabsPages[_currentPageIndex],
      bottomNavigationBar: BottomNavigationBar(
        onTap: _tabsNavigationManager,
        currentIndex: _currentPageIndex,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.list), title: Text('Feed')),
          BottomNavigationBarItem(
              icon: Icon(Icons.accessibility), title: Text('Profile')),
        ],
      ),
    );
  }

  void _tabsNavigationManager(int pageIndex) {
    setState(() {
      _currentPageIndex = pageIndex;
    });
  }
}