import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rat_app/file_management.dart';
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

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
  Map<String, List<double>> toStore = {};

  void getRunners() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      knownRunners = prefs.getStringList('runnerIDList') ?? [];
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

  void fetchRunNames(String runnerID) async {
    List<String> fetchedRunNames = await SaveFileHandler()
        .getAllRunnerFileNames(runnerID);
    setState(() {
      runNames = fetchedRunNames;
      updateSelectedRun(runNames[0]);
    });
  }

  void updateSelectedRun(String run) {
    setState(() {
      selectedRun = run;
    });
  }

  @override
  void initState() {
    super.initState();
    // Fetch the runs data for the specific runnerID
    fetchRunNames(widget.runnerID);
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
    final String filePathString = "${dir.path}/$runnerID/$selectedRun";
    final file = File(filePathString);

    if (await file.exists()) {
      String output = await file.readAsString();
      return output;
    } else {
      Logger().w("File does not exist, returning empty string");
      return "";
    }
  }

  @override
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
                    onPressed: currentIndex == 0
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
                          style: TextStyle(fontSize: 20,),
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
                    onPressed: currentIndex == runNames.length - 1
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
          ],
        );
  }
}
