import 'package:flutter/material.dart';

class BottomTab extends StatefulWidget {
  @override
  _BottomTabState createState() => _BottomTabState();
}

class _BottomTabState extends State<BottomTab> {
  int _selectedIndex = 0;

  // List of widgets to display for each tab
  static const List<Widget> _widgetOptions = <Widget>[
    Text('Home', style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold)),
    Text('Explore', style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold)),
    Text('Stats', style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold)),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.search),
              label: 'Explore',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Stats',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.blue,
          onTap: _onItemTapped,
        ),
      ],
    );
  }
}
