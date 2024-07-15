import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import 'data_model.dart';

class DataProvider with ChangeNotifier {
  List<DataItem> _data = [];
  DataItem? _closestStationData; // Add this variable
  bool _isLoading = true;

  List<DataItem> get data => _data;
  bool get isLoading => _isLoading;
  DataItem? get closestStationData => _closestStationData; // Add this getter

  Future<void> fetchData() async {
    _isLoading = true;
    notifyListeners();

    try {
      List<DataItem> result = await apidata();
      _data = result;
    } catch (error) {
      print("Error: $error");
      _data = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> findClosestStation(Position position) async {
    if (_data.isEmpty) {
      await fetchData(); // Ensure data is fetched before finding the closest station
    }

    double minDistance = double.infinity;
    DataItem? closestStation;

    for (var item in _data) {
      double distance = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        item.latitude,
        item.longitude,
      );

      if (distance < minDistance) {
        minDistance = distance;
        closestStation = item;
      }
    }

    _closestStationData = closestStation;
    notifyListeners();
  }
}

Future<List<DataItem>> apidata() async {
  const api = "579b464db66ec23bdd00000139aeb6041bfa4c7263cda886ed404225";
  final offset = 0;
  final limit = 1000;
  final List<Future<List<dynamic>>> promises = [];

  for (int i = 0; i < 4; i++) {
    promises.add(getData(api, offset + i * 1000, limit).then((data) {
      return data;
    }).catchError((error) {
      print("Error: $error");
      return [];
    }));
  }

  return Future.wait(promises).then((arrayOfData) {
    final combined = combineUniqueById(arrayOfData.expand((i) => i).toList());
    return combined.map((item) => DataItem.fromJson(item)).toList();
  }).catchError((error) {
    print("Error: $error");
    return [];
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
  final uniqueIds = Set();
  final repeatedIds = Set();
  final stationData = {};

  arrays.forEach((item) {
    final id = item['id'];
    if (uniqueIds.contains(id)) {
      repeatedIds.add(id);
    } else {
      uniqueIds.add(id);
    }

    final station = item['station'];

    if (stationData[station] == null) {
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
        'pollutants': {},
      };
    }

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

  final sortedStations = stationData.values.toList()
    ..sort((a, b) {
      if (a['state'] != b['state']) {
        return a['state'].compareTo(b['state']);
      } else if (a['city'] != b['city']) {
        return a['city'].compareTo(b['city']);
      } else {
        return a['station'].compareTo(b['station']);
      }
    });

  final stationsWithIds = sortedStations.asMap().entries.map((entry) {
    final index = entry.key;
    final station = entry.value;
    return {
      'id': index + 1,
      ...station,
    };
  }).toList();

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
  if (pollutants == null)
    return -1;
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

  if (AQIPM10 <= 0 && AQIPM25 <= 0) {
    return -1;
  }

  return values.reduce((max, value) => max > value ? max : value).toInt();
}

String maxele(Map<dynamic, dynamic> pollutants, int max) {
  if(max <= 0){
    return "none";
  };
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
