class DataItem {
  final int id;
  final String country;
  final String state;
  final String city;
  final String station;
  final double latitude;
  final double longitude;
  final String lastUpdate;
  final int aqi;
  final int max;
  final String maxele;
  final Map<String, PollutantData> pollutants;

  DataItem({
    required this.id,
    required this.country,
    required this.state,
    required this.city,
    required this.station,
    required this.latitude,
    required this.longitude,
    required this.lastUpdate,
    required this.aqi,
    required this.max,
    required this.maxele,
    required this.pollutants,
  });

  factory DataItem.fromJson(Map<dynamic, dynamic> json) {
    // Handle parsing from JSON to DataItem
    // Ensure proper type conversion here
    return DataItem(
      id: json['id'] ?? 0,
      country: json['country'] ?? '',
      state: json['state'] ?? '',
      city: json['city'] ?? '',
      station: json['station'] ?? '',
      latitude: json['latitude'] != null ? double.parse(json['latitude'].toString()) : 0.0,
      longitude: json['longitude'] != null ? double.parse(json['longitude'].toString()) : 0.0,
      lastUpdate: json['last_update'] ?? '',
      aqi: json['aqi'] ?? 0,
      max: json['max'] ?? 0,
      maxele: json['maxele'] ?? 'none',
      pollutants: (json['pollutants'] as Map<dynamic, dynamic> ?? {}).map(
        (key, value) => MapEntry(
          key,
          PollutantData.fromJson(value as Map<dynamic, dynamic>),
        ),
      ),
    );
  }
}

class PollutantData {
  final double pollutantAvg;
  final double pollutantMax;
  final double pollutantMin;

  PollutantData({
    required this.pollutantAvg,
    required this.pollutantMax,
    required this.pollutantMin,
  });

  factory PollutantData.fromJson(Map<dynamic, dynamic> json) {
    return PollutantData(
      pollutantAvg: json['pollutant_avg'] ?? -1.0,
      pollutantMax: json['pollutant_max'] ?? -1.0,
      pollutantMin: json['pollutant_min'] ?? -1.0,
    );
  }
}
