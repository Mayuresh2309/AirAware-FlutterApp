import 'package:airaware/homepage/widgets/bottomtab.dart';
import 'package:airaware/homepage/widgets/nav.dart';
import 'package:airaware/homepage/widgets/sheet.dart';
import 'package:flutter/material.dart';
import 'package:airaware/homepage/widgets/map.dart';
import 'package:airaware/backend/jstodart.dart'; 


class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  void initState() {
    super.initState();
    // Call the function to fetch data and update markers when the widget is first created
    apidata();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        child: Stack(
          children: [
            MapWidgetWithGlobalKey(), // Use the MapWidget with global key
            // Add other widgets here, like 
            // Sheet(),
            BottomTab(), 
            Nav(),
            // CallApi()
          ],
        ),
      ),
    );
  }
}
