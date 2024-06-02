import 'package:flutter/material.dart';
import 'package:airaware/backend/jstodart.dart';

// void main() {
//   runApp(MyApp());
// }

class CallApi extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('API Data Display'),
        ),
        body: Center(
          child: FutureBuilder<List<dynamic>>(
            future: apidata(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                // print("check 1");
                return CircularProgressIndicator();
              } else if (snapshot.hasError) {
                // print("check 2");
                return Text('Error: ${snapshot.error}');
              } else if (snapshot.data != null) {
                // Null check for snapshot.data
                return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, outerIndex) {
                    // print(snapshot.data![outerIndex].runtimeType);
                    final List<dynamic> outerList = snapshot.data![outerIndex];
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: outerList.map<Widget>((item) {
                        return ListTile(
                          title: Text('Station ${item['station']}'),
                          subtitle: Text('Poll ${item['maxele']} ${item['aqi']}'),
                          // Display other data fields as needed
                        );
                      }).toList(),
                    );
                  },
                );
              } else {
                return Text('No data available.');
              }
            },
          ),
        ),
      ),
    );
  }
}
