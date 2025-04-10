import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

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