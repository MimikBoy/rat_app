import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;

class UploadScreen extends StatefulWidget {
  @override
  _UploadScreenState createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  List<PlatformFile> uploadedFiles = [];

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(allowMultiple: true);

    if (result != null) {
      setState(() {
        uploadedFiles.addAll(result.files);
      });
    } else {
      // User canceled the picker
    }
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
              child: uploadedFiles.isEmpty
                  ? Text("No files uploaded yet.")
                  : ListView.builder(
                      itemCount: uploadedFiles.length,
                      itemBuilder: (context, index) {
                        final file = uploadedFiles[index];
                        return ListTile(
                          leading: Icon(Icons.insert_drive_file),
                          title: Text(p.basename(file.name)),
                          subtitle: Text('${(file.size / 1024).toStringAsFixed(2)} KB'),
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