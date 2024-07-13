// import 'package:airaware/homepage/widgets/bottomtab.dart';
import 'package:airaware/homepage/widgets/nav.dart';
// import 'package:airaware/homepage/widgets/sheet.dart';
import 'package:flutter/material.dart';
import 'package:airaware/homepage/widgets/map.dart';
import 'package:airaware/backend/jstodart.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              children: [
                MapWidget(),
                // Add other widgets here, like
                // Sheet(),
                Nav(),
                // if(_selectedIndex ==1) ...[
                //   Center(
                //     child: Container(
                //       height: 50,
                //       width: 50,
                //       decoration: BoxDecoration(
                //         color: Colors.amber[700],
                //       ),
                //     ),
                //   )
                // ],
                // CallApi()
              ],
            ),
          ),
          //  BottomTab(),
        ],
      )),
    );
  }
}
