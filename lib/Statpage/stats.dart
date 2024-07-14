import 'package:airaware/backend/data_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:airaware/backend/jstodart.dart';

final GlobalKey<_StatsScreenState> statsKey = GlobalKey<_StatsScreenState>();

class StatsScreen extends StatefulWidget {
  const StatsScreen({Key? key}) : super(key: key);

  @override
  _StatsScreenState createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  List<dynamic> _locations = [];
  DataItem? _closestStation;
  bool _sortByAqi = true; // Track sorting by AQI or station
  bool _ascending = true; // Track ascending or descending order
  String _filterState = ''; // Track selected state for filtering

  List<String> _states = []; // List to store unique states

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
      _states = _locations
          .map((location) => location.state as String)
          .toSet()
          .toList(); // Extract unique states
    });
  }

  Color getAqiInfo2(int aqi) {
    if (aqi <= 0) {
      return Color.fromARGB(175, 0, 0, 0); // Black
    } else if (aqi <= 50) {
      return Color.fromARGB(184, 43, 227, 6); // Green
    } else if (aqi <= 100) {
      return Color.fromARGB(196, 28, 86, 4); // Yellow
    } else if (aqi <= 200) {
      return Color.fromARGB(200, 237, 237, 0); // Orange
    } else if (aqi <= 300) {
      return Color.fromARGB(191, 255, 123, 0); // Red
    } else if (aqi <= 400) {
      return Color.fromARGB(192, 212, 29, 29); // Purple
    } else if (aqi <= 500) {
      return Color.fromARGB(206, 111, 0, 0); // Maroon
    } else {
      return Color.fromARGB(255, 0, 0, 0); // Black
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

  void sortLocations() {
    setState(() {
      if (_sortByAqi) {
        if (_ascending) {
          _locations.sort((a, b) => a.aqi.compareTo(b.aqi));
        } else {
          _locations.sort((a, b) => b.aqi.compareTo(a.aqi));
        }
      } else {
        if (_ascending) {
          _locations.sort((a, b) => a.station.compareTo(b.station));
        } else {
          _locations.sort((a, b) => b.station.compareTo(a.station));
        }
      }
    });
  }

  void filterLocations(String state) {
    setState(() {
      _filterState = state;
    });
  }

  List<dynamic> getFilteredLocations() {
    if (_filterState.isEmpty) {
      return _locations;
    } else {
      return _locations
          .where((location) => location.state == _filterState)
          .toList();
    }
  }

  void _showStateFilterDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Select State'),
          content: Container(
            width: double.minPositive,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _states.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_states[index]),
                  onTap: () {
                    filterLocations(_states[index]);
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  void clearFilter() {
    setState(() {
      _filterState = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    List<dynamic> filteredLocations = getFilteredLocations();

    return Scaffold(
        appBar: AppBar(
          // title: Text('Stats Screen'),
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(10.0),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.filter_list),
                    onPressed: _showStateFilterDialog,
                  ),
                  Expanded(
                    child: Wrap(
                      spacing: 6.0,
                      runSpacing: 6.0,
                      children: _filterState.isEmpty
                          ? [
                              Chip(
                                label: Text("India"),
                                // onDeleted: clearFilter,
                              )
                            ]
                          : [
                              Chip(
                                label: Text(_filterState),
                                onDeleted: clearFilter,
                              )
                            ],
                    ),
                  ),
                  DropdownButton<String>(
                    value: _sortByAqi ? 'aqi' : 'station',
                    onChanged: (value) {
                      setState(() {
                        _sortByAqi = value == 'aqi';
                        sortLocations();
                      });
                    },
                    items: [
                      DropdownMenuItem(
                        value: 'aqi',
                        child: Text('AQI'),
                      ),
                      DropdownMenuItem(
                        value: 'station',
                        child: Text('A - Z'),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: Icon(
                        _ascending ? Icons.arrow_upward : Icons.arrow_downward),
                    onPressed: () {
                      setState(() {
                        _ascending = !_ascending;
                        sortLocations();
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
        body: Column(
          children: [
            Container(
              margin: EdgeInsets.symmetric(vertical: 8, horizontal: 14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25.0),
                // color: getAqiInfo(_closestStation!.aqi),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Color.fromARGB(255, 193, 193, 193),
                    blurRadius: 0.5,
                    offset: Offset(0, 2),
                  ),
                ],
                border: Border.all(color:getAqiInfo(_closestStation!.aqi) , width: 4),
              ),
              child: ListTile(
                contentPadding:
                    EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                title: Text(
                  _closestStation!.station,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.black,
                  ),
                ),
                subtitle: Text(
                  '${_closestStation!.state} \nAQI: ${_closestStation!.aqi}\nNearest station to you',
                  style: TextStyle(color: Colors.black),
                ),
                leading: Icon(Icons.location_on, color: Colors.black),
                trailing: Icon(Icons.arrow_forward, color: Colors.black),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: filteredLocations.length,
                itemBuilder: (context, index) {
                  final item = filteredLocations[index];
                  final station = item.station;
                  final int aqi = item.aqi;
                  final lat = item.latitude;
                  final lon = item.longitude;
                  final state = item.state;
                  return Container(
                    margin: EdgeInsets.symmetric(vertical: 8, horizontal: 14),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12.0),
                      color: getAqiInfo(aqi),
                    ),
                    child: ListTile(
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 8, horizontal: 16),
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
            )
          ],
        ));
  }
}
