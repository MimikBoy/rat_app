import 'package:logger/logger.dart';
import 'dart:convert';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'dart:typed_data';
import 'package:shared_preferences/shared_preferences.dart';

class SaveFileHandler {
  
  Map<String, dynamic> data;

  SaveFileHandler() : data = {};

  Future<void> saveData(String fileName, int trainerID) async {
    // Logic to save the file
    String jsonString = jsonEncode(data);
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$fileName.pokko');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? runnerID = prefs.getInt('runnerID');
    String encryptedData = "decrypted\n$runnerID\n${encryptData(jsonString, trainerID)}";
    await file.writeAsString(encryptedData);
    Logger().i('File saved: ${file.path}');
  }

    Future<void> saveDataTrainer(String fileName) async {
    // Logic to save the file
    String jsonString = jsonEncode(data);
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$fileName.json');
    await file.writeAsString(jsonString);
    Logger().i('File saved: ${file.path}');
  }


  Future<void> delete(String fileName) async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$fileName.pokko');
    if (await file.exists()) {
      await file.delete();
      Logger().i('File deleted: ${file.path}');
    } else {
      Logger().e('File does not exist: ${file.path}');
    }
  }

  String encryptData(String jsonData, int trainerID) {
    String paddedKey = trainerID.toString().padLeft(16, '0');

    final key = encrypt.Key.fromUtf8(paddedKey);
    final iv = encrypt.IV.fromLength(16);

    final encrypter = encrypt.Encrypter(encrypt.AES(key));
    final encrypted = encrypter.encrypt(jsonData, iv: iv);

    Logger().i('Encryption Complete, iv: $iv');
    return encrypted.base64;
  }

  String decryptData(String base64Data, int trainerID) {
    String paddedKey = trainerID.toString().padLeft(16, '0');

    final key = encrypt.Key.fromUtf8(paddedKey);
    final iv = encrypt.IV.fromLength(16); // same IV used for encryption

    final encrypter = encrypt.Encrypter(encrypt.AES(key));
    final decrypted = encrypter.decrypt64(base64Data, iv: iv);

    return decrypted;
  }

  Future<void> download(String fileName) async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$fileName.pokko');

    if (!await file.exists()) {
      Logger().e('File does not exist: ${file.path}');
      return;
    }

    String newFilePath = '';
    if (Platform.isWindows) {
      // Get the Windows downloads folder from the USERPROFILE env var.
      final downloads = '${Platform.environment['USERPROFILE']}\\Downloads';
      newFilePath = '$downloads\\$fileName.pokko';
      final copiedFile = await file.copy(newFilePath);
      Logger().i('File copied to: ${copiedFile.path}');
    } else if (Platform.isMacOS) {
      // Build the Downloads folder path for macOS.
      final downloads = '/Users/${Platform.environment['USER']}/Downloads';
      newFilePath = '$downloads/$fileName.pokko';
      final copiedFile = await file.copy(newFilePath);
      Logger().i('File copied to: ${copiedFile.path}');
    } else if (Platform.isLinux) {
      // Use the HOME directory for Linux.
      final downloads = '${Platform.environment['HOME']}/Downloads';
      newFilePath = '$downloads/$fileName.pokko';
      final copiedFile = await file.copy(newFilePath);
      Logger().i('File copied to: ${copiedFile.path}');
    } else if (Platform.isAndroid) {
      final Uint8List fileBytes = await file.readAsBytes();
      final params = SaveFileDialogParams(
        data: fileBytes,
        fileName: '$fileName.pokko',
      );
      final savedPath = await FlutterFileDialog.saveFile(params: params);
      if (savedPath == null) {
        Logger().i('Save aborted by user');
        return;
      }
      Logger().i('File saved to: $savedPath');
    } else if (Platform.isIOS) {
      newFilePath = '${dir.path}/$fileName.pokko';
    } else {
      throw UnsupportedError("Platform not supported.");
    }
  }

  Future<void> clearLocalData() async {
    // Clear SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Logger().i("SharedPreferences cleared.");

    // Get the app's local directory
    final dir = await getApplicationDocumentsDirectory();

    // Delete all files and folders inside the directory
    final files = dir.listSync();
    for (final fileOrDir in files) {
      try {
        await fileOrDir.delete(recursive: true);
        Logger().i("Deleted: ${fileOrDir.path}");
      } catch (e) {
        Logger().e("Error deleting ${fileOrDir.path}: $e");
      }
    }
    Logger().i("All local files cleared.");
  }

  Future<List<String>> getAllRunnerFileNames(String runnerID) async {
    final dir = await getApplicationDocumentsDirectory();
    final directory = Directory('${dir.path}/$runnerID');

    if (await directory.exists()) {
      final files = directory.listSync(); // List all files and directories
      final fileNames = files
          .whereType<File>() // Filter only files
          .map((file) => file.path.split(Platform.pathSeparator).last) // Extract file names
          .toList(); // Convert to a List<String>
      fileNames.sort();
      return fileNames;
    } else {
      throw Exception("Directory does not exist: ${dir.path}/$runnerID");
    }
  }
}
