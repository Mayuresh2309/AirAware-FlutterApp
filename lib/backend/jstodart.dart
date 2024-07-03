import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:airaware/homepage/widgets/map.dart';
import 'package:flutter/material.dart';
import 'package:airaware/Explorepage/explore.dart';
import 'package:airaware/Statpage/stats.dart';
import 'data_model.dart';
class DataProvider with ChangeNotifier {
  List<DataItem> _data = []; // Updated to List<DataItem>
  bool _isLoading = true;

  List<DataItem> get data => _data; // Add this getter
  bool get isLoading => _isLoading;

  Future<void> fetchData() async {
    _isLoading = true;
    notifyListeners();

    try {
      List<DataItem> result =
          await apidata(); // Ensure this returns List<DataItem>
      _data = result;
    } catch (error) {
      print("Error: $error");
      _data = [];
    }

    _isLoading = false;
    notifyListeners();
  }
}
Future<List<DataItem>> apidata() async {
  // print("check 1");
  // Sample key
  // const api="579b464db66ec23bdd0000011c4b6fb8f22e4da36019aceed9576683"; //2nd api
  const api = "579b464db66ec23bdd00000139aeb6041bfa4c7263cda886ed404225";
  final offset = 0;
  final limit = 1000;
  final List<Future<List<dynamic>>> promises = [];
  // print("achahhahaha jiiiii");
  // Access the StatsScreen state using the global key and call updateMarkers
  // if (statsKey.currentState != null) {
  // }

  for (int i = 0; i < 4; i++) {
    promises.add(getData(api, offset + i * 1000, limit).then((data) {
      // print(data);
      return data;
    }).catchError((error) {
      print("Error: $error");
      return []; // Return an empty list in case of an error to avoid breaking Future.wait
    }));
  }
Map<String, dynamic> convertMap(Map<dynamic, dynamic> inputMap) {
  Map<String, dynamic> outputMap = {};

  inputMap.forEach((key, value) {
    outputMap[key.toString()] = value;
  });

  return outputMap;
}
  return Future.wait(promises).then((arrayOfData) {
    final combined = combineUniqueById(arrayOfData.expand((i) => i).toList());
    // mapWidgetKey.currentState?.updateMarkers(combined);
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   statsKey.currentState?.updateMarkers(combined);
    // });
    // print(combined[0]);

    return combined.map((item) => DataItem.fromJson(item)).toList();
  }).catchError((error) {
    print("Error: $error");
    return []; // Return an empty list in case of an error
  });
}

Future<List<dynamic>> getData(String api, int offset, int limit) async {
  final baseUrl = Uri.parse(
      "https://api.data.gov.in/resource/3b01bcb8-0b14-4abf-b6f2-c1bfd384ba69");
  final apiKey = api;
  final url1 = Uri(
      scheme: baseUrl.scheme,
      host: baseUrl.host,
      path: baseUrl.path,
      queryParameters: {
        'api-key': apiKey,
        'format': 'json',
        'offset': offset.toString(),
        'limit': limit.toString(),
      });

  try {
    final response = await http.get(url1);
    if (response.statusCode != 200) {
      throw Exception("Network response was not ok");
    }
    final data = jsonDecode(response.body);
    final pollutionData = data['records'];
    return pollutionData;
  } catch (error) {
    print("Error fetching data: $error");
    return [];
  }
}

List<dynamic> combineUniqueById(List<dynamic> arrays) {
  // print("check 3");
  final uniqueIds = Set();
  final repeatedIds = Set();

  // Organizing the data by station and including constant fields
  final stationData = {};

  arrays.forEach((item) {
    final id = item['id'];
    // Check if the ID has been encountered before
    if (uniqueIds.contains(id)) {
      repeatedIds.add(id); // Add to repeated IDs set
    } else {
      uniqueIds.add(id); // Add to unique IDs set
    }

    // Store pollutant data under the station
    final station = item['station'];
    // print("check 4");

    if (stationData[station] == null) {
      // Create an entry for the station including constant fields
      stationData[station] = {
        'country': item['country'],
        'state': item['state'],
        'city': item['city'],
        'station': item['station'],
        'latitude': double.parse(item['latitude']),
        'longitude': double.parse(item['longitude']),
        'last_update': item['last_update'],
        'aqi': 0,
        'max': 0,
        'maxele': "none",
        'pollutants':
            {}, // Initialize pollutants object to store pollutant data
      };
    }
    // Store pollutant data under the station
    final pollutantId = item['pollutant_id'];

    if (stationData[station]['pollutants'][pollutantId] == null) {
      stationData[station]['pollutants'][pollutantId] = {
        'pollutant_avg': 0.0,
        'pollutant_max': 0.0,
        'pollutant_min': 0.0,
      };
    }
    try {
      stationData[station]['pollutants'][pollutantId]['pollutant_avg'] =
          double.parse(item['pollutant_avg']);
    } catch (e) {
      stationData[station]['pollutants'][pollutantId]['pollutant_avg'] = -1.0;
    }
    try {
      stationData[station]['pollutants'][pollutantId]['pollutant_max'] =
          double.parse(item['pollutant_max']);
    } catch (e) {
      stationData[station]['pollutants'][pollutantId]['pollutant_max'] = -1.0;
    }
    try {
      stationData[station]['pollutants'][pollutantId]['pollutant_min'] =
          double.parse(item['pollutant_min']);
    } catch (e) {
      stationData[station]['pollutants'][pollutantId]['pollutant_min'] = -1.0;
    }
  });
  stationData.forEach((key, item) {
    item!['aqi'] = calmax(item['pollutants']);
    item!['maxele'] = maxele(item['pollutants'], item['aqi']);
  });

  // Sort stations alphabetically based on state, city, and station4
  final sortedStations = stationData.values.toList()
    ..sort((a, b) {
      if (a['state'] != b['state']) {
        return a['state'].compareTo(b['state']);
      } else if (a['city'] != b['city']) {
        return a['city'].compareTo(b['city']);
      } else {
        return a['station'].compareTo(b['station']);
      }
      // return 0; // Return 0 if properties are equal
    });

  // Assign IDs to the sorted stations
  final stationsWithIds = sortedStations.asMap().entries.map((entry) {
    final index = entry.key;
    final station = entry.value;
    return {
      'id': index + 1, // Assigning IDs starting from 1
      ...station,
    };
  }).toList();

  // Compute unique and repeated city names
  final uniqueCities = Set();
  final repeatedCities = Set();
  stationsWithIds.forEach((item) {
    final city = item['city'];
    if (uniqueCities.contains(city)) {
      repeatedCities.add(city);
    } else {
      uniqueCities.add(city);
    }
  });

  return stationsWithIds;
}

int calmax(Map<dynamic, dynamic>? pollutants) {
  // print("check 8");
// return 0;
  if (pollutants == null)
    return -1; // or handle null case according to your logic
  final AQICO = (pollutants['CO'] as Map<String, dynamic>?)?['pollutant_max'] !=
          null
      ? (pollutants['CO'] as Map<String, dynamic>?)!['pollutant_max']! / 1000
      : 0;
  final AQINH3 =
      (pollutants['NH3'] as Map<String, dynamic>?)?['pollutant_avg'] ?? 0;
  final AQINO2 =
      (pollutants['NO2'] as Map<String, dynamic>?)?['pollutant_avg'] ?? 0;
  final AQIO3 =
      (pollutants['OZONE'] as Map<String, dynamic>?)?['pollutant_max'] ?? 0;
  final AQIPM10 =
      (pollutants['PM10'] as Map<String, dynamic>?)?['pollutant_avg'] ?? 0;
  final AQIPM25 =
      (pollutants['PM2.5'] as Map<String, dynamic>?)?['pollutant_avg'] ?? 0;
  final AQISO2 =
      (pollutants['SO2'] as Map<String, dynamic>?)?['pollutant_avg'] ?? 0;

  final List<double> values = [
    AQICO.toDouble(),
    AQINH3.toDouble(),
    AQINO2.toDouble(),
    AQIO3.toDouble(),
    AQIPM10.toDouble(),
    AQIPM25.toDouble(),
    AQISO2.toDouble(),
  ];

  if (AQIPM10 == 0 && AQIPM25 == 0) {
    // print("check 17");
    return -1;
  }

  return values.reduce((max, value) => max > value ? max : value).toInt();
}

String maxele(Map<dynamic, dynamic> pollutants, int max) {
  // print("check 10");
  if (pollutants['CO']?['pollutant_max'] != null &&
      max == pollutants['CO']?['pollutant_max'] / 1000) {
    return "co";
  } else if (pollutants['NH3']?['pollutant_avg'] != null &&
      max == pollutants['NH3']?['pollutant_avg']) {
    return "nh3";
  } else if (pollutants['NO2']?['pollutant_avg'] != null &&
      max == pollutants['NO2']?['pollutant_avg']) {
    return "no2";
  } else if (pollutants['OZONE']?['pollutant_max'] != null &&
      max == pollutants['OZONE']?['pollutant_max']) {
    return "Ozone";
  } else if (pollutants['PM10']?['pollutant_avg'] != null &&
      max == pollutants['PM10']?['pollutant_avg']) {
    return "pm10";
  } else if (pollutants['PM2.5']?['pollutant_avg'] != null &&
      max == pollutants['PM2.5']?['pollutant_avg']) {
    return "pm25";
  } else if (pollutants['SO2']?['pollutant_avg'] != null &&
      max == pollutants['SO2']?['pollutant_avg']) {
    return "so2";
  } else if (pollutants['OZONE']?['pollutant_max'] != null &&
      max == pollutants['OZONE']?['pollutant_max']) {
    return "Ozone";
  }

  return "none";
}
