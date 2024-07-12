import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:airaware/backend/jstodart.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({Key? key}) : super(key: key);

  @override
  _ExploreScreenState createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  List<dynamic> _locations = [];

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

  final List<String> diseases = [
    'Asthma',
    'Chronic obstructive pulmonary disease (COPD)',
    'Lung Cancer',
    'Bronchitis',
    "Emphysema",
    "Influenza",
    "Bronchiectasis",
    "Pleural effusion"
  ];
  final Map<String, int> diseaseAqiMap = {
    'Asthma': 150,
    'Chronic obstructive pulmonary disease (COPD)': 100,
    'Lung Cancer': 150,
    'Bronchitis': 50,
    "Emphysema": 150,
    "Influenza": 100,
    "Bronchiectasis": 50,
    "Pleural effusion": 200
  };

  String? selectedDisease;
  String? selectedLocation;
  int? locationAqi;
  bool? isLocationSafe;

  void checkLocationSafety() {
    if (selectedDisease != null && locationAqi != null) {
      int diseaseAqiThreshold = diseaseAqiMap[selectedDisease!]!;
      setState(() {
        isLocationSafe = locationAqi! <= diseaseAqiThreshold;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('AQI Safety Checker'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.teal.shade50,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Check if a location is safe for your condition:',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal,
                      ),
                    ),
                    SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: 'Select Disease',
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      value: selectedDisease,
                      items: diseases.map((String disease) {
                        return DropdownMenuItem<String>(
                          value: disease,
                          child: Text(disease),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedDisease = value;
                        });
                      },
                    ),
                    SizedBox(height: 16),
                    Autocomplete<String>(
                      optionsBuilder: (TextEditingValue textEditingValue) {
                        if (textEditingValue.text.isEmpty) {
                          return const Iterable<String>.empty();
                        }
                        return _locations
                            .map((location) => location['station'] as String)
                            .where((station) => station
                                .toLowerCase()
                                .contains(textEditingValue.text.toLowerCase()));
                      },
                      onSelected: (String selection) {
                        setState(() {
                          selectedLocation = selection;
                        });
                      },
                      fieldViewBuilder: (BuildContext context,
                          TextEditingController textEditingController,
                          FocusNode focusNode,
                          VoidCallback onFieldSubmitted) {
                        return TextFormField(
                          controller: textEditingController,
                          focusNode: focusNode,
                          decoration: InputDecoration(
                            labelText: 'Enter Location',
                            border: OutlineInputBorder(),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          onChanged: (value) {
                            setState(() {
                              selectedLocation = value;
                            });
                          },
                        );
                      },
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        // Dummy AQI value for the location; replace this with actual AQI lookup logic
                        setState(() {
                          locationAqi =
                              120; // For example purposes, replace with actual logic
                        });
                        checkLocationSafety();
                      },
                      style: ElevatedButton.styleFrom(
                        primary: Colors.teal,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text('Check Safety'),
                    ),
                    SizedBox(height: 16),
                    if (isLocationSafe != null)
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isLocationSafe! ? Colors.green : Colors.red,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          isLocationSafe!
                              ? 'The location is safe for you.'
                              : 'The location is not safe for you.',
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
