import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart'; //used for uploading
import 'package:path/path.dart' as p; //used for uploading
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rat_app/file_management.dart'; //used for decrypting
import 'dart:convert'; //also used for decrypting
import 'package:logger/src/logger.dart';

const Color textColor = Color.fromARGB(255, 224, 224, 224);
const Color seperatorColor = Color.fromARGB(100, 189, 189, 189);
const Color redButtons = Color.fromARGB(255, 211, 47, 47);
const Color greenButtons = Color.fromARGB(255, 76, 175, 80);
const Color greyButtons = Color.fromARGB(255, 158, 158, 158);

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  _UploadScreenState createState() => _UploadScreenState();
}

//TODO  show checkmark
//TODO show proper errors
class _UploadScreenState extends State<UploadScreen> {
  int? trainerID;
  List<PlatformFile> uploadedFiles = [];

  // runs initially to set up the class/state
  @override
  void initState() {
    super.initState();
    _loadSharedPreferences();

    setState(() {
      //fill in
    });
  }

  Future<void> _loadSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    trainerID = prefs.getInt('trainerID') ?? 0;
    setState(() {
      //fill in
    });
  }

  //Decrypts file and saves it as json instead. Also add the 
  Future<void> _decryptUpload(int index) async {
    SaveFileHandler decrypter = SaveFileHandler();
    String runnerID = "0";

    String encryptedData = String.fromCharCodes(uploadedFiles[index].bytes!);
    //extract the runner ID and actual encrypted data from the 3 lines
    List<String> lines = encryptedData.split('\n');
    if(lines[0] == "decrypted"){
          runnerID = lines[1];
          encryptedData = lines[2];
          Logger().i('RunnerID: $runnerID and encryptedData extracted');
    }else{
          runnerID = "error";
          encryptedData = "error";
          Logger().i('RunnerID and encryptedData not found');
    }
    String decryptedData = decrypter.decryptData(
      encryptedData,
      trainerID ?? 0000000,
    );
    Map<String, dynamic> dataMap = jsonDecode(decryptedData);
    decrypter.data = dataMap;
    decrypter.saveDataTrainer(uploadedFiles[index].name,runnerID);
    Logger().i('File decrypted and saved to folder');
  }

  // adds the file to the list of uploaded files
  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
    );

    if (result != null && result.count == 1 && isPokkoFile(result.names[0])) {
      setState(() {
        uploadedFiles.addAll(result.files);
        Logger().i('File Uploaded');
      });
    } else {
      // User canceled the picker
    }

    //decrypt and save to correct folder
    int index = uploadedFiles.length - 1;
    if(uploadedFiles[index].bytes != null){
      _decryptUpload(index);
    }else{
      Logger().e('File at index $index not found.\n File size: ${uploadedFiles[index].size}.\n Bytes: ${uploadedFiles[index].bytes}');
    }
    
  }

  // checks if the file extension is a .pokko extension
  bool isPokkoFile(String? filePath) {
    return p.extension(filePath!).toLowerCase() == '.pokko';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Upload Files')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton.icon(
              onPressed: _pickFile,
              icon: Icon(Icons.upload_file),
              label: Text('Select Files'),
            ),
            SizedBox(height: 20),
            Expanded(
              child:
                  uploadedFiles.isEmpty
                      ? Text("No files uploaded yet.")
                      : ListView.builder(
                        itemCount: uploadedFiles.length,
                        itemBuilder: (context, index) {
                          final file = uploadedFiles[index];
                          return ListTile(
                            leading: Icon(Icons.insert_drive_file),
                            title: Text(
                              p.basename(file.name),
                              style: TextStyle(color: textColor),
                            ),
                            subtitle: Text(
                              '${(file.size / 1024).toStringAsFixed(2)} KB',
                            ),
                          );
                        },
                      ),
            ),
          ],
        ),
      ),
    );
  }
}
