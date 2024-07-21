import 'package:flutter/material.dart';
import 'package:airaware/homepage/widgets/sheet.dart';
import 'package:provider/provider.dart';
import 'package:airaware/backend/jstodart.dart';
import 'package:airaware/backend/data_model.dart';

class Nav extends StatefulWidget {
  const Nav({Key? key}) : super(key: key);

  @override
  _NavState createState() => _NavState();
}

class _NavState extends State<Nav> {
  List<dynamic> _locations = [];
  List<dynamic> _navlocations = [];

  final TextEditingController _searchController = TextEditingController();
  String? selectedLocation;
  DataItem? _closestStation;

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
      _locations = locations;
      _closestStation = Nearest;
      if (Nearest != null) {
        _navlocations =
            locations.where((element) => element.city == Nearest.city).toList();
      } else {
        locations
            .where((element) => element.city.toString() == "Mumbai")
            .toList();
      }
    });
  }

  void _handleSearch() {
    if (selectedLocation != null && selectedLocation!.isNotEmpty) {
      List<dynamic> filteredLocations = _locations
          .where((location) => location.station
              .toString()
              .toLowerCase()
              .contains(selectedLocation!.toLowerCase()))
          .toList();
      setState(() {
        if (selectedLocation != null) {
          _navlocations = _locations
              .where((element) =>
                  element.city.toString() == filteredLocations[0].city)
              .toList();
        }
      });
      if (filteredLocations.isNotEmpty) {
        Sheet.showModalBottomSheetWithData(context, filteredLocations[0]);
      } else {
        // Handle no results found scenario
        print('No matching station found');
      }
    } else {
      // Handle empty search scenario
      print('Enter a valid location to search');
    }
  }

  Color getAqiInfo(int aqi) {
    if (aqi <= 0) {
      return Color.fromARGB(255, 0, 0, 0); // Black
    } else if (aqi <= 50) {
      return Color.fromARGB(255, 43, 227, 6); // Green
    } else if (aqi <= 100) {
      return Color.fromARGB(255, 255, 255, 0); // Yellow
    } else if (aqi <= 200) {
      return Color.fromARGB(255, 255, 165, 0); // Orange
    } else if (aqi <= 300) {
      return Color.fromARGB(255, 255, 0, 0); // Red
    } else if (aqi <= 400) {
      return Color.fromARGB(255, 128, 0, 128); // Purple
    } else if (aqi <= 500) {
      return Color.fromARGB(255, 111, 0, 0); // Maroon
    } else {
      return Color.fromARGB(255, 0, 0, 0); // Black
    }
  }

  String _getLocationLabel() {
    if (selectedLocation != null) {
      final parts = selectedLocation!.split(',');
      if (parts.length > 1) {
        return parts[1];
      }
    }
    if (_closestStation != null) {
      return _closestStation!.city;
    }
    return "Mumbai";
  }

  @override
  Widget build(BuildContext context) {
    final dataProvider = Provider.of<DataProvider>(context);

    if (dataProvider.isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        Container(
          margin: EdgeInsets.only(top: 40, bottom: 0, right: 15, left: 15),
          padding: EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(100.0),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 2,
                blurRadius: 5,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: <Widget>[
              // Logo on the left
              Image.asset(
                'assets/logo.jpg', // Adjust path as per your asset location
                fit: BoxFit.contain,
                height: 46,
              ),
              SizedBox(width: 10),
              // Expanded widget to center the search box
              Expanded(
                child: Container(
                  height: 50, // Set the desired height here

                  child: Autocomplete<String>(
                    optionsBuilder: (TextEditingValue textEditingValue) {
                      if (textEditingValue.text.isEmpty) {
                        return const Iterable<String>.empty();
                      }
                      return _locations
                          .map((location) => location.station.toString())
                          .where((station) => station
                              .toLowerCase()
                              .contains(textEditingValue.text.toLowerCase()));
                    },
                    onSelected: (String selection) {
                      setState(() {
                        selectedLocation = selection;
                      });
                      _handleSearch();
                    },
                    fieldViewBuilder: (BuildContext context,
                        TextEditingController textEditingController,
                        FocusNode focusNode,
                        VoidCallback onFieldSubmitted) {
                      return TextFormField(
                        controller: textEditingController,
                        focusNode: focusNode,
                        decoration: InputDecoration(
                          hintText: "Search Location ..",
                          labelText: null,
                          border: InputBorder.none,
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 0,
                              horizontal: 10), // Adjust padding as needed
                        ),
                        onChanged: (value) {
                          setState(() {
                            selectedLocation = value;
                          });
                        },
                      );
                    },
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.search, color: Colors.black),
                onPressed: _handleSearch,
              ),
              SizedBox(width: 10),
            ],
          ),
        ),
        Container(
          margin: EdgeInsets.only(top: 15, right: 15, left: 15),
          padding: EdgeInsets.all(4),
          height: 60, // Set an explicit height
          decoration: BoxDecoration(
            // color: Colors.white,
            borderRadius: BorderRadius.circular(100.0),
            // boxShadow: [
            //   BoxShadow(
            //     color: Colors.grey.withOpacity(0.5),
            //     spreadRadius: 2,
            //     blurRadius: 5,
            //     offset: Offset(0, 3),
            //   ),
            // ],
          ),
          child: Row(
            children: [
              Chip(
                label: Text(
                  _getLocationLabel(),
                ),
              ),
              Expanded(
                child: Container(
                  height: double
                      .infinity, // Ensure the ListView takes up the full height of the parent Container
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _navlocations.length,
                    itemBuilder: (context, index) {
                      final item = _navlocations[index];
                      final station = item.station;
                      final int aqi = item.aqi;
                      final lat = item.latitude;
                      final lon = item.longitude;
                      final state = item.state;
                      final processedStation = station.split(',')[0];

                      return IntrinsicWidth(
                        child: Container(
                            // width:
                            //  fit-content, // Set a width to ensure items are properly sized horizontally
                            margin: EdgeInsets.symmetric(
                                vertical: 0, horizontal: 5),
                            // decoration: BoxDecoration(
                            //   borderRadius: BorderRadius.circular(12.0),
                            //   color: getAqiInfo(aqi),
                            // ),
                            child: Chip(label: Text(processedStation))),
                      );
                    },
                  ),
                ),
              )
            ],
          ),
        )
      ],
    );
  }
}
