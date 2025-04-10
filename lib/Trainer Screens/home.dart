import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rat_app/file_management.dart';

PageRouteBuilder<dynamic> pageTransSwipeLeft(Widget page) {
  return PageRouteBuilder(
    transitionDuration: const Duration(milliseconds: 150),
    reverseTransitionDuration: const Duration(milliseconds: 150),
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(1.0, 0.0);
      const end = Offset.zero;
      final tween = Tween(begin: begin, end: end);
      return SlideTransition(
        position: animation.drive(tween),
        child: child,
      );
    },
  );
}

class TrainerHomePage extends StatefulWidget {
  const TrainerHomePage({super.key});

  @override
  State<TrainerHomePage> createState() => _TrainerHomePageState();
}

class _TrainerHomePageState extends State<TrainerHomePage> {
  List<String> knownRunners = [];

  void getRunners() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setStringList('runnerIDList', ['123', '456', '789']);
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
            Navigator.push(
              context,
              pageTransSwipeLeft(DataVisualizationPage(runnerID: knownRunners[index])),
            );
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
                    style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
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

class DataVisualizationPage extends StatefulWidget{
  final String runnerID;
  const DataVisualizationPage({super.key, required this.runnerID});

  @override
  State<DataVisualizationPage> createState() => _DataVisualizationPageState();
}

class _DataVisualizationPageState extends State<DataVisualizationPage> {
  List<String> runNames = [];
  int currentIndex = 0;

  void fetchRunNames(String runnerID) async{
    List<String> fetchedRunNames = await SaveFileHandler().getAllRunnerFileNames(runnerID);
    setState(() {
      runNames = fetchedRunNames;
    });
  }

  @override
  void initState() {
    super.initState();
    // Fetch the runs data for the specific runnerID
    fetchRunNames(widget.runnerID);
  }

  @override
  Widget build(BuildContext context) {
    return runNames.isEmpty
      ? const Center(child: CircularProgressIndicator())
      : Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Selected Date: ${runNames[currentIndex]}',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: currentIndex > 0
                    ? () {
                        setState(() {
                          currentIndex--;
                        });
                      }
                    : null,
              ),
              IconButton(
                icon: const Icon(Icons.arrow_forward),
                onPressed: currentIndex < runNames.length - 1
                    ? () {
                        setState(() {
                          currentIndex++;
                        });
                      }
                    : null,
              ),
            ],
          ),
        ],
      );
  }
}