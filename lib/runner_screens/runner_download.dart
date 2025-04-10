import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rat_app/utils/file_management.dart';

const Color redButtons = Color.fromARGB(255, 211, 47, 47);
const Color greenButtons = Color.fromARGB(255, 76, 175, 80);

class RunnerDownloadPage extends StatefulWidget {
  const RunnerDownloadPage({super.key});

  @override
  State<RunnerDownloadPage> createState() => _RunnerDownloadPageState();
}

class _RunnerDownloadPageState extends State<RunnerDownloadPage> {
  int itemCount = 0;
  List<String> currentList = [];

  Future<void> _loadSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    currentList = prefs.getStringList('fileNames') ?? [];
    setState(() {
      itemCount = currentList.length;
    });
  }

  void _moveToDownloads(String fileName) async {
    try{
      SaveFileHandler fileManager = SaveFileHandler();
      await fileManager.download(fileName);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('File moved to Downloads'),
          duration: const Duration(seconds: 3),
        ),
      );
    } catch (e) {
      Logger().e('Error copying file: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to move file: $e'),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _deleteFile(String fileName, int index) async {
    bool? confirmed = await showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text('Are you sure you want to delete "$fileName"?',),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Color.fromARGB(255, 100, 181, 246)),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Delete',
              style: TextStyle(color: Color.fromARGB(255, 100, 181, 246)),
            ),
          ),
        ],
      );
    },
  );

  if (confirmed != true) return;

    try {
      SaveFileHandler fileManager = SaveFileHandler();
      await fileManager.delete(fileName);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('File deleted'),
          duration: const Duration(seconds: 3),
        ),
      );
    } catch (e) {
      Logger().e('Error deleting file: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to delete file: $e'),
          duration: const Duration(seconds: 3),
        ),
      );
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> currentListTemp = prefs.getStringList('fileNames') ?? [];
    currentListTemp.removeAt(index);
    await prefs.setStringList('fileNames', currentListTemp);

    setState(() {
      currentList.removeAt(index);
      itemCount = currentList.length;
    });

  }

  @override
  void initState(){
    super.initState();
    _loadSharedPreferences();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      itemCount: itemCount,
      separatorBuilder: (context, index) => const Divider(),
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  currentList[itemCount - index - 1],
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
                ),
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      _moveToDownloads(currentList[itemCount - index - 1]);
                    },
                    icon: Icon(Icons.download_rounded),
                    color: greenButtons,
                  ),
                  IconButton(
                    onPressed: () {
                      _deleteFile(currentList[itemCount - index - 1], itemCount - index - 1);
                    },
                    icon: Icon(Icons.delete_rounded),
                    color: redButtons,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
