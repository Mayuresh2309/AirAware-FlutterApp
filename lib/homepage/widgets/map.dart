import 'package:airaware/homepage/widgets/sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

// import 'package:airaware/homepage/widgets/modal.dart';
class MapWidget extends StatefulWidget {
  const MapWidget({super.key});

  @override
  _MapWidgetState createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  List<Marker> _markers = [];

  void updateMarkers(List<dynamic> locations) {
    List<Marker> markers = [];

    locations.forEach((item) {
      final lat = item['latitude'];
      final lon = item['longitude'];
      final int value = item['aqi']; // Assuming each item has an 'aqi' field
      final maxele = item['maxele'];
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

  void _onMarkerTapped(dynamic item) {
    // Handle marker tap event here
    // 'item' contains the data of the tapped marker
    Sheet.showModalBottomSheetWithData(context, item);
    print('Marker tapped: $item');
  }

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      options: MapOptions(
        center: LatLng(22.0, 77.0),
        zoom: 5.5,
        interactiveFlags:
            InteractiveFlag.all & ~InteractiveFlag.rotate, // Disable rotation
        maxBounds: LatLngBounds(
          LatLng(8.0, 68.0), // Southwest corner of India
          LatLng(37.0, 97.0), // Northeast corner of India
        ),
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
          subdomains: ['a', 'b', 'c'],
        ),
        MarkerLayer(
          markers: _markers,
        ),
      ],
    );
  }
}

// Global key to access the state of MapWidget
final GlobalKey<_MapWidgetState> mapWidgetKey = GlobalKey<_MapWidgetState>();

class MapWidgetWithGlobalKey extends StatefulWidget {
  @override
  _MapWidgetWithGlobalKeyState createState() => _MapWidgetWithGlobalKeyState();
}

class _MapWidgetWithGlobalKeyState extends State<MapWidgetWithGlobalKey> {
  @override
  Widget build(BuildContext context) {
    return MapWidget(key: mapWidgetKey);
  }
}
