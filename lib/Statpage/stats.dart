import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:airaware/backend/jstodart.dart';

// Define the GlobalKey for StatsScreen
final GlobalKey<_StatsScreenState> statsKey = GlobalKey<_StatsScreenState>();

class StatsScreen extends StatefulWidget {
  const StatsScreen({Key? key}) : super(key: key);

  @override
  _StatsScreenState createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  List<dynamic> _locations = [];
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Listen for changes in the DataProvider
    final dataProvider = Provider.of<DataProvider>(context);
    if (!dataProvider.isLoading) {
      updateMarkers(dataProvider.data);
    }
  }

  void updateMarkers(List<dynamic> locations) {
    // print("function call received");

    setState(() {
      _locations = locations;
    });
  }

  Color getColor(int value) {
    if (value < 50) return Colors.green;
    if (value < 100) return Colors.yellow;
    if (value < 150) return Colors.orange;
    if (value < 200) return Colors.red;
    return Colors.purple;
  }

  Color getAqiInfo(int aqi) {
    if (aqi <= 0) {
      return Color.fromARGB(250, 85, 85, 85);
    } else if (aqi <= 50) {
      return Color.fromARGB(239, 48, 221, 13) // Green
          ;
    } else if (aqi <= 100) {
      return Color.fromARGB(237, 29, 103, 0) // Yellow
          ;
    } else if (aqi <= 200) {
      return Color.fromARGB(241, 237, 209, 0) // Orange
          ;
    } else if (aqi <= 300) {
      return Color.fromARGB(230, 255, 123, 0) // Red
          ;
    } else if (aqi <= 400) {
      return Color.fromARGB(220, 212, 29, 29) // Purple
          ;
    } else if (aqi <= 500) {
      return Color.fromARGB(206, 111, 0, 0) // Maroon
          ;
    } else {
      return Color.fromARGB(255, 0, 0, 0) // Black
          ;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text('Stats Screen'),
      // ),
      body: ListView.builder(
        itemCount: _locations.length,
        itemBuilder: (context, index) {
          final item = _locations[index];
          final station = item.station;
          final int aqi = item.aqi; // Air Quality Index
          final lat = item.latitude;
          final lon = item.longitude;
          final state = item.state;
          return Container(
            margin: EdgeInsets.symmetric(vertical: 8 , horizontal: 14),
            // padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.0),
              color: getAqiInfo(aqi),
            ),
            child: ListTile(
              contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              title: Text(
                station,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
              subtitle: Text(
                '$state \nAQI: $aqi\nLat: $lat, Lon: $lon',
                style: TextStyle(color: Colors.white70),
              ),
              leading: Icon(Icons.location_on, color: Colors.white),
              trailing: Icon(Icons.arrow_forward, color: Colors.white),
            ),
          );
        },
      ),
    );
  }
}
