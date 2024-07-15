import 'dart:async'; // Import the timer package

import 'package:airaware/homepage/widgets/sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:airaware/backend/jstodart.dart';
import 'package:airaware/backend/data_model.dart';

class MapWidget extends StatefulWidget {
  final Function getLocationAndFetchData;
  const MapWidget({
    Key? key,
    required this.getLocationAndFetchData,
  }) : super(key: key);

  @override
  _MapWidgetState createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  List<Marker> _allMarkers = [];
  List<Marker> _visibleMarkers = [];
  DataItem? _closestLocation;

  Timer? _debounceTimer;
  late DataProvider dataProvider;
  final MapController _mapController = MapController();

  LatLng _centerlocation = LatLng(19.13, 72.91);
  double zoomLevel = 9.5;
  @override
  void initState() {
    super.initState();
    dataProvider = Provider.of<DataProvider>(context, listen: false);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final dataProvider = Provider.of<DataProvider>(context);
    if (!dataProvider.isLoading) {
      initializeMarkers(dataProvider.data, dataProvider.closestStationData);
      setState(() {
        _closestLocation = dataProvider.closestStationData;
      });
    }
  }

  void initializeMarkers(List<dynamic> locations, DataItem? nearest) {
    List<Marker> markers = [];
    locations.forEach((item) {
      final lat = item.latitude;
      final lon = item.longitude;
      final int value = item.aqi;
      final maxele = item.maxele;
      if (lat != null && lon != null && value >= 0) {
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
                  borderRadius: BorderRadius.circular(100.0),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: getColor(maxele),
                    borderRadius: BorderRadius.circular(100.0),
                    border: Border.all(
                      color: Color.fromARGB(234, 96, 96, 96),
                      width: 0.7,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      '$value',
                      style: TextStyle(
                        color: Color.fromARGB(255, 0, 0, 0),
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

    if (nearest != null) {
      markers.add(
        Marker(
          height: 20,
          width: 100,
          point: LatLng(nearest.latitude + 0.01, nearest.longitude),
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
              style: TextStyle(
                  fontSize: 10,
                  color: Colors.black,
                  fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    setState(() {
      _allMarkers = markers;
      updateMarkersInView(null); // Initialize visible markers
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
    Sheet.showModalBottomSheetWithData(context, item);
    // print('Marker tapped: $item');
  }

  void _zoomToLocation(LatLng location, double zoom) {
    print(location);
    try {
      // _mapController.move(location, zoom);
      setState(() {
        _centerlocation = location; // Replace with actual coordinates
        zoomLevel = 11;
      });
    } catch (e) {
      print(e);
    }
  }

  void _requestLocation() async {
    if (_closestLocation != null) {
      LatLng londonLocation =
          LatLng(_closestLocation!.latitude, _closestLocation!.longitude);
      double zoomLevel = 10.0;
      _zoomToLocation(londonLocation, zoomLevel);
    } else {
      print("somethong 90");
      widget.getLocationAndFetchData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DataProvider>(
      builder: (context, dataProvider, child) {
        if (dataProvider.isLoading) {
          return Center(child: CircularProgressIndicator());
        } else {
          return Stack(
            children: [
              FlutterMap(
                options: MapOptions(
                  center: _centerlocation,
                  // _closestLocation != null
                  //     ? LatLng(_closestLocation!.latitude,
                  //         _closestLocation!.longitude)
                  //     : LatLng(19.13, 72.91)
                  zoom: zoomLevel,
                  // _closestLocation != null ? 10.0 : 9.5,
                  interactiveFlags:
                      InteractiveFlag.all & ~InteractiveFlag.rotate,
                  maxBounds: LatLngBounds(
                    LatLng(8.0, 68.0),
                    LatLng(37.0, 97.0),
                  ),
                  onPositionChanged: (mapPosition, _) {
                    if (_debounceTimer?.isActive ?? false)
                      _debounceTimer!.cancel();
                    _debounceTimer = Timer(Duration(milliseconds: 500), () {
                      updateMarkersInView(mapPosition.bounds);
                    });
                  },
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                    subdomains: ['a', 'b', 'c'],
                  ),
                  MarkerLayer(
                    markers: _visibleMarkers,
                  ),
                ],
              ),
              Positioned(
                bottom: 32.0,
                right: 32.0,
                child: FloatingActionButton(
                  onPressed: () {
                    _requestLocation();
                  },
                  child: Icon(
                    Icons.gps_fixed_rounded,
                    color: Colors.blue[900],
                  ),
                ),
              ),
            ],
          );
        }
      },
    );
  }

  void updateMarkersInView(LatLngBounds? bounds) {
    if (bounds == null) {
      setState(() {
        _visibleMarkers = _allMarkers;
      });
      return;
    }

    final visibleMarkers = _allMarkers.where((marker) {
      return bounds.contains(marker.point);
    }).toList();

    setState(() {
      _visibleMarkers = visibleMarkers;
    });
  }
}
