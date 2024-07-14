import 'package:flutter/material.dart';
import 'package:airaware/homepage/widgets/sheet.dart';
import 'package:provider/provider.dart';
import 'package:airaware/backend/jstodart.dart';

class Nav extends StatefulWidget {
  const Nav({Key? key}) : super(key: key);

  @override
  _NavState createState() => _NavState();
}

class _NavState extends State<Nav> {
  List<dynamic> _locations = [];
  final TextEditingController _searchController = TextEditingController();
  String? selectedLocation;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final dataProvider = Provider.of<DataProvider>(context);
    if (!dataProvider.isLoading) {
      updateMarkers(dataProvider.data);
    }
  }

  void updateMarkers(List<dynamic> locations) {
    setState(() {
      _locations = locations;
    });
  }

  void _handleSearch() {
    if (selectedLocation != null && selectedLocation!.isNotEmpty) {
      List<dynamic> filteredLocations = _locations.where((location) =>
        location.station.toString().toLowerCase().contains(selectedLocation!.toLowerCase())
      ).toList();

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

  @override
  Widget build(BuildContext context) {
    final dataProvider = Provider.of<DataProvider>(context);

    if (dataProvider.isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 15, vertical: 40),
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
                    .where((station) =>
                      station.toLowerCase().contains(textEditingValue.text.toLowerCase())
                    );
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
                      contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 10), // Adjust padding as needed
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
    );
  }
}
