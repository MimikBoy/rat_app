import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rat_app/utils/file_management.dart';
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:fl_chart/fl_chart.dart'; //used for the  graphs

// import 'package:file_picker/file_picker.dart'; //used for uploading
// import 'package:path/path.dart' as p; //used for uploading

PageRouteBuilder<dynamic> pageTransSwipeLeft(Widget page) {
  return PageRouteBuilder(
    transitionDuration: const Duration(milliseconds: 150),
    reverseTransitionDuration: const Duration(milliseconds: 150),
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(1.0, 0.0);
      const end = Offset.zero;
      final tween = Tween(begin: begin, end: end);
      return SlideTransition(position: animation.drive(tween), child: child);
    },
  );
}

class TrainerHomePage extends StatefulWidget {
  final Function(String runnerID) onRunnerSelected;
  const TrainerHomePage({super.key, required this.onRunnerSelected});

  @override
  State<TrainerHomePage> createState() => _TrainerHomePageState();
}

class _TrainerHomePageState extends State<TrainerHomePage> {
  List<String> knownRunners = [];
  final bool useTestData = true; //used for testing data

  void getRunners() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      knownRunners = prefs.getStringList('runnerIDList') ?? [];
      useTestData ? knownRunners.add("TriangleTestRun") : null;
    });
  }

  @override
  void initState() {
    super.initState();
    getRunners();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      itemCount: knownRunners.length,
      separatorBuilder: (context, index) => const Divider(),
      itemBuilder: (context, index) {
        return InkWell(
          onTap: () {
            Logger().i('Tapped on item $index');
            widget.onRunnerSelected(knownRunners[index]);
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Container(
              // Instead of extra margin, only use internal padding.
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 2),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Runner ID: ${knownRunners[index]}',
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 20,
                    color: Colors.grey[600],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class DataVisualizationPage extends StatefulWidget {
  final String runnerID;
  const DataVisualizationPage({super.key, required this.runnerID});

  @override
  State<DataVisualizationPage> createState() => _DataVisualizationPageState();
}

class _DataVisualizationPageState extends State<DataVisualizationPage> {
  List<String> runNames = [];
  int currentIndex = 0;
  String selectedRun = '';
  Map<String, List<double>> runnerMap = {};
  final bool useTestData = true; //used for testing data

  void fetchRunNames(String runnerID) async {
    List<String> fetchedRunNames = await SaveFileHandler()
        .getAllRunnerFileNames(runnerID);
    setState(() {
      runNames = fetchedRunNames;
      updateSelectedRun(runNames[0]);
    });
  }

  Future<void> updateSelectedRun(String run) async {
    selectedRun = run;
    String dataJson = await getRunData(widget.runnerID, selectedRun);
    setState(() {
      runnerMap = jsonToMap(dataJson);
    });
  }

  @override
  void initState() {
    super.initState();
    if (useTestData) {
      // mock triangle data
      runnerMap = {
        "timeGrfLeft": List.generate(100, (i) => i.toDouble()),
        "grfLeft": List.generate(
          100,
          (i) => (i % 20 < 10 ? i % 10 : 10 - (i % 10)).toDouble(),
        ),
        "timeGrfRight": List.generate(100, (i) => i.toDouble()),
        "grfRight": List.generate(
          100,
          (i) => (i % 25 < 13 ? i % 13 : 13 - (i % 13)).toDouble(),
        ),
        "timeAngleLeft": List.generate(100, (i) => i.toDouble()),
        "angleLeft": List.generate(
          100,
          (i) => (i % 30 < 15 ? i % 15 : 15 - (i % 15)).toDouble(),
        ),
        "timeAngleRight": List.generate(100, (i) => i.toDouble()),
        "angleRight": List.generate(
          100,
          (i) => (i % 17 < 9 ? i % 9 : 9 - (i % 9)).toDouble(),
        ),
      };
      setState(() {
        runNames = ["TriangleTestRun"];
        selectedRun = "TriangleTestRun";
      });
    } else {
      fetchRunNames(widget.runnerID);
    }
  }

  //Turns the jsonstring from the datafile and turns it into a map
  Map<String, List<double>> jsonToMap(String jsonString) {
    final decoded = jsonDecode(jsonString) as Map<String, dynamic>;

    return decoded.map((key, value) {
      List<double> doubleList =
          (value as List<dynamic>)
              .map((e) => e is double ? e : double.parse(e.toString()))
              .toList();
      return MapEntry(key, doubleList);
    });
  }

  //gets String from file
  Future<String> getRunData(String runnerID, String selectedRun) async {
    final dir = await getApplicationDocumentsDirectory();
    final String filePathString = "${dir.path}/$runnerID/$selectedRun.json";
    final file = File(filePathString);

    if (await file.exists()) {
      String output = await file.readAsString();
      return output;
    } else {
      Logger().w("File does not exist, returning empty string");
      return "";
    }
  }

  // Convert List<double> into FlSpot list for plotting
  List<FlSpot> _createDataPoints(List<double> x, List<double> y) {
    List<FlSpot> output = List.generate(
      x.length,
      (index) => FlSpot(x[index], y[index]),
    );
    return output;
  }

  // @override
  // Widget build(BuildContext context) {
  //   return Column(
  //     children: [
  //       AspectRatio(aspectRatio: 2.0, child: LineChart(LineChartData())),
  //     ],
  //   );
  // }

  Widget build(BuildContext context) {
    return runNames.isEmpty
        ? const Center(child: CircularProgressIndicator())
        : Column(
          mainAxisAlignment:
              MainAxisAlignment.start, // Align content to the top
          crossAxisAlignment: CrossAxisAlignment.center, // Center horizontally
          children: [
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_left, size: 40),
                    onPressed:
                        currentIndex == 0
                            ? null // Disable the button if it's the last item
                            : () {
                              setState(() {
                                currentIndex--;
                                selectedRun = runNames[currentIndex];
                              });
                            },
                  ),
                  // GestureDetector or PopupMenuButton for date display:
                  Flexible(
                    child: PopupMenuButton<String>(
                      onSelected: (String run) {
                        setState(() {
                          selectedRun = run;
                          currentIndex = runNames.indexOf(run);
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 8.0,
                        ),
                        child: Text(
                          // Format your selected date as needed.
                          selectedRun,
                          style: TextStyle(fontSize: 20),
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      itemBuilder: (BuildContext context) {
                        return runNames.map((String date) {
                          return PopupMenuItem<String>(
                            value: date,
                            child: Text(date),
                          );
                        }).toList();
                      },
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.arrow_right, size: 40),
                    onPressed:
                        currentIndex == runNames.length - 1
                            ? null // Disable the button if it's the last item
                            : () {
                              setState(() {
                                currentIndex++;
                                selectedRun = runNames[currentIndex];
                              });
                            },
                  ),
                ],
              ),
            ),
            const Divider(),
            AspectRatio(
              aspectRatio: 1.5,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: true),
                  titlesData: FlTitlesData(show: true),
                  borderData: FlBorderData(show: true),
                  minX: 0,
                  maxX:
                      useTestData
                          ? 100
                          : runnerMap["timeGrfLeft"]!.reduce(
                            (a, b) => a > b ? a : b,
                          ),
                  minY:
                      useTestData
                          ? 0
                          : runnerMap["grfLeft"]!.reduce(
                            (a, b) => a < b ? a : b,
                          ), //could also have manual min/max to filter out spikes, sorta
                  maxY:
                      useTestData
                          ? 15
                          : runnerMap["grfLeft"]!.reduce((a, b) => a > b ? a : b),
                  lineBarsData: [
                    LineChartBarData(
                      show: true,
                      spots: _createDataPoints(
                        runnerMap["timeGrfLeft"]!,
                        runnerMap["grfLeft"]!,
                      ), // Left data
                      isCurved: true,
                      color: Colors.blue,
                      barWidth: 4,
                      belowBarData: BarAreaData(show: false),
                    ),
                    LineChartBarData(
                      spots: _createDataPoints(
                        runnerMap["timeGrfRight"]!,
                        runnerMap["grfRight"]!,
                      ), // Right data
                      isCurved: true,
                      color: Colors.red,
                      barWidth: 4,
                      belowBarData: BarAreaData(show: false),
                    ),
                  ],
                ),
              ),
            ),
            AspectRatio(aspectRatio: 1.5,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: true),
                  titlesData: FlTitlesData(show: true),
                  borderData: FlBorderData(show: true),
                  minX: 0,
                  maxX: useTestData ? 100 : runnerMap["timeAngleLeft"]!.reduce(
                    (a, b) => a > b ? a : b,
                  ),
                  minY: useTestData ? 0 : runnerMap["angleLeft"]!.reduce(
                    (a, b) => a < b ? a : b,
                  ), //these angles could also have manual min/max
                  maxY: useTestData ? 15 : runnerMap["angleLeft"]!.reduce((a, b) => a > b ? a : b),
                  lineBarsData: [
                    LineChartBarData(
                      spots: _createDataPoints(
                        runnerMap["timeAngleLeft"]!,
                        runnerMap["angleLeft"]!,
                      ), // Left data
                      isCurved: true,
                      color: Colors.blue,
                      barWidth: 4,
                      belowBarData: BarAreaData(show: false),
                    ),
                    LineChartBarData(
                      spots: _createDataPoints(
                        runnerMap["timeAngleRight"]!,
                        runnerMap["angleRight"]!,
                      ), // Right data
                      isCurved: true,
                      color: Colors.red,
                      barWidth: 4,
                      belowBarData: BarAreaData(show: false),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
  }
}
