import 'package:airaware/homepage/widgets/sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:airaware/backend/jstodart.dart';
import 'package:airaware/backend/data_model.dart';

class MapWidget extends StatefulWidget {
  const MapWidget({super.key});

  @override
  _MapWidgetState createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  List<Marker> _markers = [];

  DataItem? _closestLocation; // Variable to store the closest station

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final dataProvider = Provider.of<DataProvider>(context);
    if (!dataProvider.isLoading) {
      updateMarkers(dataProvider.data, dataProvider.closestStationData);
    }
  }

  void updateMarkers(List<dynamic> locations, DataItem? Nearest) {
    setState(() {
      _closestLocation = Nearest;
    });
    List<Marker> markers = [];
    locations.forEach((item) {
      final lat = item.latitude;
      final lon = item.longitude;
      final int value = item.aqi;
      final maxele = item.maxele;
      if (lat != null && lon != null) {
        markers.add(
          Marker(
            point: LatLng(lat, lon),
            width: 30,
            height: 30,
            builder: (ctx) => GestureDetector(
              onTap: () => _onMarkerTapped(item),
              child: Container(
                decoration: BoxDecoration(
                  color: Color.fromARGB(182, 255, 255, 255),
                  borderRadius: BorderRadius.circular(100.0), // Border radius
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: getColor(maxele), // Background color
                    borderRadius: BorderRadius.circular(100.0), // Border radius
                    border: Border.all(
                      color: Color.fromARGB(
                          234, 96, 96, 96), // RGBA color for the border
                      width: 0.7, // Border width
                    ),
                  ),
                  child: Center(
                    child: Text(
                      '$value',
                      style: TextStyle(
                        color: Color.fromARGB(255, 0, 0, 0), // Text color
                        fontWeight: FontWeight.bold,
                        fontSize: 10.0,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }
if (_closestLocation != null) {
  markers.add(
    Marker(
      height: 20,
      width: 100,
      point: LatLng(_closestLocation!.latitude + 0.01, _closestLocation!.longitude),
      builder: (ctx) => Container(
              height: 20,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.8),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Color.fromARGB(226, 160, 160, 160),
                    blurRadius: 0.2,
                    offset: Offset(0, 2),
                  ),
                ],
                border: Border.all(color: Colors.blue, width: 1),
              ),
              padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              child: Text(
                'Nearest Station',
                style: TextStyle(fontSize: 10, color: Colors.black ,fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
         
    ),
  );
}

    });

    setState(() {
      _markers = markers;
    });
  }

  Color getColor(String col) {
    switch (col) {
      case "nh3":
        return Color.fromARGB(128, 0, 128, 0); // Green
      case "co":
        return Color.fromARGB(128, 0, 0, 255); // Blue
      case "so2":
        return Color.fromARGB(179, 255, 255, 0); // Yellow
      case "Ozone":
        return Color.fromARGB(128, 255, 165, 0); // Orange
      case "no2":
        return Color.fromARGB(128, 255, 0, 0); // Red
      case "pm10":
        return Color.fromARGB(128, 128, 0, 128); // Purple
      case "pm25":
        return Color.fromARGB(128, 0, 0, 0); // Black
      default:
        return Color.fromARGB(128, 128, 128, 128); // Grey
    }
  }

  void _onMarkerTapped(DataItem item) {
    // Handle marker tap event here
    // 'item' contains the data of the tapped marker
    Sheet.showModalBottomSheetWithData(context, item);
    print('Marker tapped: $item');
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DataProvider>(
      builder: (context, dataProvider, child) {
        if (dataProvider.isLoading) {
          return Center(child: CircularProgressIndicator());
        } else {
          return FlutterMap(
            options: MapOptions(
              center: _closestLocation != null
                  ? LatLng(
                      _closestLocation!.latitude, _closestLocation!.longitude)
                  : LatLng(22, 77.0),
              zoom: _closestLocation != null ? 10.0 : 5.5,
              interactiveFlags: InteractiveFlag.all &
                  ~InteractiveFlag.rotate, // Disable rotation
              maxBounds: LatLngBounds(
                LatLng(8.0, 68.0), // Southwest corner of India
                LatLng(37.0, 97.0), // Northeast corner of India
              ),
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                subdomains: ['a', 'b', 'c'],
              ),
              MarkerLayer(
                markers: _markers,
              ),
            ],
          );
        }
      },
    );
  }
}
