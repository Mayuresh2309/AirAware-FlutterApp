import 'package:airaware/homepage/home.dart';
import 'package:flutter/material.dart';
import 'package:airaware/backend/jstodart.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:airaware/homepage/widgets/bottomtab.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => DataProvider()..fetchData(),
      child: MyApp(),
    ),
  );
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: Colors.transparent, // Make the status bar transparent
    statusBarIconBrightness: Brightness.dark, // For dark icons on a light background
  ));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Consumer<DataProvider>(
          builder: (context, dataProvider, child) {
            if (dataProvider.isLoading) {
              return Center(child: CircularProgressIndicator());
            } else {
              return BottomTab();
            }
          },
        ),
      ),
    );
  }
}






















////////////////////////////////////////////////////////////////////////////////////////////////////////
class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
        body: SingleChildScrollView(
      child: SizedBox(
        child: Stack(
          children: [
            Container(
              height: height / 2,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 28, 163, 7)
                ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    // height: height/2,
                    child: Text("damnnns"),
                  )
                ],
              ),
            ),
            Container(
              height: height,
              decoration: BoxDecoration(color: Color.fromRGBO(230, 19, 26, 0)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Text("data"),
                    ),
                    // child: Text("data"),
                  ),
                  Container(
                    height: 200,
                    decoration:
                        BoxDecoration(color: Color.fromARGB(255, 225, 209, 67)),
                  ),
                ],
              ),
            ),
            Visibility(
              visible: false,
              child:   Drawer(
              
              backgroundColor: Color.fromARGB(210, 50, 151, 251),
              // elevation: BorderSide.strokeAlignOutside,
              child: ListView(
                padding: EdgeInsets.zero,
                children: <Widget>[
                  DrawerHeader(
                    child: Text(
                      'Drawer Header',
                      style: TextStyle(color: Colors.white, fontSize: 24),
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                    ),
                  ),
                  ListTile(
                    leading: Icon(Icons.contacts),
                    title: Text('Contact'),
                    onTap: () {
                      Navigator.pop(context);
                      // Handle navigation to the contact page
                    },
                  ),
                  Divider(),
                 
                ],
              ),
            )
            ),
          
          ],
        ),
      ),
    ));
  }
}
