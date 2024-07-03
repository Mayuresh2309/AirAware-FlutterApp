import 'package:flutter/material.dart';
import 'package:airaware/homepage/widgets/sheet.dart';
import 'package:provider/provider.dart';
import 'package:airaware/backend/jstodart.dart';

class Nav extends StatelessWidget {
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final dataProvider = Provider.of<DataProvider>(context);

    if (dataProvider.isLoading) {
      return Center(child: CircularProgressIndicator());
    }
    final data = dataProvider.data;
    List<String> StationList = [];
    data.forEach((element) {
      StationList.add(element.station
          .toString()); // Assuming 'station' is a property of each element
    });
    final height = MediaQuery.of(context).size.height;

    void _handleSearch() {
      String searchText = _searchController.text;
      List<String> filteredWords = StationList.where(
              (word) => word.toLowerCase().contains(searchText.toLowerCase()))
          .toList();
      data.forEach((element) {
        try{
        if ( element.station.toString() == filteredWords[0]) {
          Sheet.showModalBottomSheetWithData(context, element);
        }
        }catch(e){};
      });
      print(filteredWords);
    }

    return Container(
      child: Container(
        margin: EdgeInsets.only(left: 15, right: 15, top: 40),
        padding: EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Color.fromARGB(255, 255, 255, 255),
          borderRadius: BorderRadius.circular(100.0),
        ),
        child: Row(
          children: <Widget>[
            // Logo on the left
            Image.asset(
              'assets/logo.jpg', // Make sure to add your logo in the assets folder
              fit: BoxFit.contain,
              height: 46,
            ),
            SizedBox(width: 10),
            // Expanded widget to center the search box
            Expanded(
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search...',
                  hintStyle: TextStyle(color: Color.fromARGB(137, 0, 0, 0)),
                  border: InputBorder.none,
                ),
                style: TextStyle(color: Color.fromARGB(255, 255, 0, 0)),
                onSubmitted: (String value) {
                  _handleSearch();
                },
              ),
            ),
            IconButton(
              icon:
                  Icon(Icons.search, color: const Color.fromARGB(255, 0, 0, 0)),
              onPressed: _handleSearch,
            ),
            SizedBox(width: 10),
          ],
        ),
      ),
    );
  }
}
