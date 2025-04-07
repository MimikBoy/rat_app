import 'package:logger/logger.dart';
import 'dart:convert';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'dart:typed_data';

class SaveFileHandler {
  String fileName;
  int trainerID;
  Map<String, dynamic> data;

  SaveFileHandler(this.fileName, this.trainerID) : data = {};

  Future<void> saveData() async {
    // Logic to save the file
    String jsonString = jsonEncode(data);
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$fileName.pokko');
    String encryptedData = "decrypted\n${encryptData(jsonString)}";
    await file.writeAsString(encryptedData);
    Logger().i('File saved: ${file.path}');
  }

  Future<void> delete() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$fileName.pokko');
    if (await file.exists()) {
      await file.delete();
      Logger().i('File deleted: ${file.path}');
    } else {
      Logger().e('File does not exist: ${file.path}');
    }
  }

  String encryptData(String jsonData){
    String paddedKey = trainerID.toString().padLeft(16, '0');

    final key = encrypt.Key.fromUtf8(paddedKey);
    final iv = encrypt.IV.fromLength(16);

    final encrypter = encrypt.Encrypter(encrypt.AES(key));
    final encrypted = encrypter.encrypt(jsonData, iv: iv);

    Logger().i('Encryption Complete, iv: $iv');
    return encrypted.base64;
  }

  Future<void> download() async {
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
}