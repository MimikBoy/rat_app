import 'package:logger/logger.dart';
import 'dart:convert';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class SaveFileHandler {
  String fileName;
  int trainerID;
  Map<String, dynamic> data;

  SaveFileHandler(this.fileName, this.trainerID) : data = {};

  Future<void> saveData() async {
    // Logic to save the file
    String jsonString = jsonEncode(data);
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$fileName.json');
    String encryptedData = "decrypted\n${encryptData(jsonString)}";
    await file.writeAsString(encryptedData);
    Logger().i('File saved: ${file.path}');
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
}