import "package:flutter/material.dart";
import "package:airaware/Explorepage/explore.dart";
import "package:airaware/Statpage/stats.dart";
import "package:airaware/homepage/home.dart";
import "package:airaware/homepage/widgets/map.dart";
import "package:airaware/backend/jstodart.dart";

class BottomTab extends StatefulWidget {
  const BottomTab({super.key});

  @override
  State<BottomTab> createState() => _BottomTabState();
}

class _BottomTabState extends State<BottomTab> {
  int _selectedIndex = 0;
  PageController _pageController = PageController();

  // List of widgets to display for each tab
  // static const List<Widget> _widgetOptions = <Widget>[
  //   Text('Home', style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold)),
  //   Text('Explore', style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold)),
  //   Text('Stats', style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold)),
  // ];
  static List<Widget> _widgetOptions = <Widget>[
    Home(), // Replace with your actual screens
    ExploreScreen(), // Replace with your actual screens
    StatsScreen(), // Replace with your actual screens
  ];
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.jumpToPage(index);

    // Navigate to the selected screen
    // switch (_selectedIndex) {
    //   case 0:
    //     Navigator.of(context).push(MaterialPageRoute(builder: (context) => Home()));
    //     break;
    //   case 1:
    //     Navigator.of(context).push(MaterialPageRoute(builder: (context) => ExploreScreen()));
    //     break;
    //   case 2:
    //     Navigator.of(context).push(MaterialPageRoute(builder: (context) => StatsScreen()));
    //     break;
    // }
  }

  @override
  void initState() {
    super.initState();
    // Call the function to fetch data and update markers when the widget is first created
    apidata();
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
    );
  }
}
