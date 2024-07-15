import 'package:flutter/material.dart';
import 'package:airaware/Explorepage/explore.dart';
import 'package:airaware/Statpage/stats.dart';
import 'package:airaware/homepage/home.dart';
import 'package:airaware/backend/jstodart.dart';

class BottomTab extends StatefulWidget {
  // const BottomTab({super.key});
  final Function getLocationAndFetchData;
  const BottomTab({
    Key? key,
    required this.getLocationAndFetchData,
  }) : super(key: key);
  @override
  State<BottomTab> createState() => _BottomTabState();
}

class _BottomTabState extends State<BottomTab> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController();
  late List<Widget> _widgetOptions;

  @override
  void initState() {
    super.initState();
    apidata();

    _widgetOptions = <Widget>[
      Home(getLocationAndFetchData: widget.getLocationAndFetchData),
      ExploreScreen(),
      StatsScreen(),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.jumpToPage(index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        children: _widgetOptions,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Map',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shield),
            label: 'Safety Check',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Cities',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        onTap: _onItemTapped,
      ),
    );
  }
}
