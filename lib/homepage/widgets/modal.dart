import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class Modal extends StatefulWidget {
  final dynamic data;
  final int state;

  const Modal({Key? key, required this.data, required this.state})
      : super(key: key);

  @override
  State<Modal> createState() => _Modal1State();
}

class _Modal1State extends State<Modal> with TickerProviderStateMixin {
  double? maxY;
  double? stepValue;
  final List<int> aqiValues = [0, 50, 100, 200, 300, 400, 500];

  @override
  void initState() {
    super.initState();
    calculateMaxYAndStepValue();
  }

  void calculateMaxYAndStepValue() {
    try {
      double maxPollutantValue = 0.0;
      widget.data['pollutants'].forEach((key, value) {
        if (value['pollutantAvg'] > maxPollutantValue) {
          maxPollutantValue = value['pollutantAvg'].toDouble();
        }
        if (key.toString() == "OZONE" || key.toString() == "CO") {
          if (value['pollutantMax'] > maxPollutantValue) {
            maxPollutantValue = value['pollutantMax'].toDouble();
          }
        }
      });
      setState(() {
        maxY = (maxPollutantValue / 10).ceil() * 10;
        stepValue = ((maxY! / 5).ceilToDouble() / 10).ceil() * 10;
      });
    } catch (e) {
      // Handle potential errors during data processing
      setState(() {
        maxY = 100.0;
        stepValue = 20.0;
      });
      print("Error calculating maxY and stepValue: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (maxY == null || stepValue == null) {
      return Center(child: CircularProgressIndicator());
    }
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(left: 10, right: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (widget.state == 1) ...[
              SizedBox(height: 30),
            ] else ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 50, // Adjust width as needed
                    child: Container(
                      height: 5,
                      margin: EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        color: Color.fromARGB(255, 84, 84, 84),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  )
                ],
              )
            ],
            Text(
              "${widget.data.station}",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
            ),
            Text(
              "Maharashtra",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.normal,
                color: Color.fromARGB(255, 124, 124, 124),
              ),
            ),
            SizedBox(height: 15),
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: getAqiInfo(widget.data.aqi.toInt())['color'],
                borderRadius: BorderRadius.circular(30),
              ),
              child: Center(
                  child: Column(
                children: [
                  Text(
                    "AQI: ${widget.data.aqi.toInt()}",
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                  ),
                  Text("${getAqiInfo(widget.data.aqi.toInt())['level']}")
                ],
              )),
            ),
            SizedBox(height: 20),
            Text(
              "Pollutants in the last 24 hours",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Container(
              height: 250,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children:
                    widget.data.pollutants.entries.map<Widget>((entry) {
                  return Row(
                    children: [
                      Card(
                        margin: EdgeInsets.symmetric(horizontal: 10),
                        child: Container(
                          width: 200,
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.blueAccent,
                                Colors.lightBlueAccent,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                spreadRadius: 3,
                                blurRadius: 7,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                entry.key,
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 10),
                              Text(
                                "Average: ${entry.value.pollutantAvg?.toString()}",
                                style: TextStyle(fontSize: 16),
                              ),
                              SizedBox(height: 10),
                              Text(
                                "Maximum: ${entry.value.pollutantMax?.toString()}",
                                style: TextStyle(fontSize: 16),
                              ),
                              SizedBox(height: 10),
                              Text(
                                "Minimum: ${entry.value.pollutantMin?.toString()}",
                                style: TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
            SizedBox(height: 20),
            Text(
              "Distribution ",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Container(
              height: 300,
              child: BarChart(
                BarChartData(
                  barGroups: widget.data.pollutants.entries
                      .map<BarChartGroupData>((entry) {
                    double yVal = entry.value.pollutantAvg;
                    if (entry.key.toString() == "OZONE" ||
                        entry.key.toString() == "CO") {
                      yVal = entry.value.pollutantMax;
                    }

                    return BarChartGroupData(
                      x: widget.data.pollutants.keys
                          .toList()
                          .indexOf(entry.key),
                      barRods: [
                        BarChartRodData(
                          y: yVal,
                          colors: [getColor(entry.key.toString())],
                          width: 30,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(5),
                            topRight: Radius.circular(5),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                  titlesData: FlTitlesData(
                    bottomTitles: SideTitles(
                      showTitles: true,
                      getTextStyles: (value) => TextStyle(
                        color: const Color.fromARGB(255, 64, 64, 64),
                        fontWeight: FontWeight.normal,
                        fontSize: 14,
                      ),
                      margin: 8,
                      getTitles: (double value) {
                        int index = value.toInt();
                        if (index >= 0 &&
                            index < widget.data.pollutants.length) {
                          return widget.data.pollutants.keys.toList()[index];
                        }
                        return '';
                      },
                    ),
                    leftTitles: SideTitles(
                      showTitles: true,
                      getTextStyles: (value) => TextStyle(
                        color: const Color.fromARGB(255, 64, 64, 64),
                        fontWeight: FontWeight.normal,
                        fontSize: 14,
                      ),
                      margin: 8,
                      reservedSize: 30,
                      getTitles: (value) {
                        if (value % stepValue! == 0) {
                          return value.toInt().toString();
                        }
                        return '';
                      },
                    ),
                  ),
                  borderData: FlBorderData(
                    show: false,
                  ),
                  minY: 0,
                  maxY: maxY,
                ),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Text(
              "Standard Value",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black),
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(12.0),
                  child: Table(
                    children: [
                      // Header row
                      TableRow(
                        decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 255, 255, 255)),
                        children: [
                          Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Center(
                                child: Text(
                                  'AQI Value',
                                  style: TextStyle(
                                      fontWeight: FontWeight.normal,
                                      color: Colors.black),
                                ),
                              )),
                          Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Center(
                                child: Text(
                                  'Category',
                                  style: TextStyle(
                                      fontWeight: FontWeight.normal,
                                      color: Colors.black),
                                ),
                              )),
                        ],
                      ),
                      // Data rows
                      ...aqiValues.map((aqi) {
                        var aqiInfo = getAqiInfo(aqi);
                        return TableRow(
                          children: [
                            Container(
                                color: aqiInfo['color'].withOpacity(0.7),
                                padding: EdgeInsets.all(4.0),
                                child: Center(
                                  child: Text(
                                    ' $aqi',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                )),
                            Container(
                                color: aqiInfo['color'].withOpacity(0.7),
                                padding: EdgeInsets.all(4.0),
                                child: Center(
                                  child: Text(
                                    aqiInfo['level'],
                                    style: TextStyle(color: Colors.white),
                                  ),
                                )),
                          ],
                        );
                      }).toList(),
                    ],
                  )),
            )
          ],
        ),
      ),
    );
  }

  Map<String, dynamic> getAqiInfo(int aqi) {
    if (aqi <= 0) {
      return {
        "level": "Aqi Can't Be Calulated",
        "color": Color.fromARGB(250, 85, 85, 85) // Green
      };
    } else if (aqi <= 50) {
      return {
        "level": "Good",
        "color": Color.fromARGB(239, 48, 221, 13) // Green
      };
    } else if (aqi <= 100) {
      return {
        "level": "Satisfactory",
        "color": Color.fromARGB(237, 29, 103, 0) // Yellow
      };
    } else if (aqi <= 200) {
      return {
        "level": "Moderate",
        "color": Color.fromARGB(241, 237, 209, 0) // Orange
      };
    } else if (aqi <= 300) {
      return {
        "level": "Poor",
        "color": Color.fromARGB(230, 255, 123, 0) // Red
      };
    } else if (aqi <= 400) {
      return {
        "level": "Very Poor",
        "color": Color.fromARGB(220, 212, 29, 29) // Purple
      };
    } else if (aqi <= 500) {
      return {
        "level": "Severe",
        "color": Color.fromARGB(206, 111, 0, 0) // Maroon
      };
    } else {
      return {
        "level": "Invalid AQI value",
        "color": Color.fromARGB(255, 0, 0, 0) // Black
      };
    }
  }

  Color getColor(String col) {
    switch (col) {
      case "NH3":
        return Color.fromARGB(128, 0, 128, 0); // Green
      case "CO":
        return Color.fromARGB(128, 0, 0, 255); // Blue
      case "SO2":
        return Color.fromARGB(179, 255, 255, 0); // Yellow
      case "OZONE":
        return Color.fromARGB(128, 255, 165, 0); // Orange
      case "NO2":
        return Color.fromARGB(128, 255, 0, 0); // Red
      case "PM10":
        return Color.fromARGB(128, 128, 0, 128); // Purple
      case "PM25":
        return Color.fromARGB(128, 0, 0, 0); // Black
      default:
        return Color.fromARGB(128, 128, 128, 128); // Grey
    }
  }
}
