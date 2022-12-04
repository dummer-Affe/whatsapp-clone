import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:whatsapp_clone/main.dart';

import '../../values/variables.dart';

class MessageFile {
  late String type;
  late String storagePath;
  late String? downloadUrl;
  late String? fileName;
  late String extension;
  late String conversationId;
  late String messageId;
  late String localPath;

  MessageFile({
    required this.type,
    required this.storagePath,
    required this.extension,
    required this.conversationId,
    required this.messageId,
    this.downloadUrl,
    this.fileName,
  }) {
    localPath = generateLocalPath();
    fileName ??= "$messageId.$extension";
  }

  MessageFile.fromFile(File file,
      {required String conversationId,
      required String messageId,
      required this.type}) {
    extension = FileService.extensionOfFile(file);
    storagePath = generateStoragePath();
    fileName = type == "Media"
        ? "$messageId.$extension"
        : FileService.nameOfFile(file);
    localPath = generateLocalPath();
  }

  String generateStoragePath() {
    return "users/${userState.userId!}/$conversationId/$messageId.$extension";
  }

  String generateLocalPath() {
    String fileTypeDir = FileService.getLongTypeFromExtension(extension);
    String fileTmpPath = "$appDir/Media/Whatsapp $fileTypeDir/$fileName";
    return fileTmpPath;
  }

  bool isExist() {
    return File(localPath).existsSync();
  }
}

enum TypeOfFile { image, video, document, audio }

class FileService {
  static String extensionOfFile(File file) {
    return file.path.split(".").last;
  }

  static String extensionFromPath(String path) {
    return path.split(".").last;
  }

  static String nameOfFile(File file) {
    return file.path.split("/").last;
  }

  static String nameFromPath(String path) {
    return path.split("/").last;
  }

  static TypeOfFile getTypeFromFile(File file) {
    String extension = file.path.split(".").last;
    if (imgExt.any((element) => extension == element)) {
      return TypeOfFile.image;
    } else if (vidExt.any((element) => extension == element)) {
      return TypeOfFile.video;
    } else if (audExt.any((element) => extension == element)) {
      return TypeOfFile.audio;
    } else {
      return TypeOfFile.document;
    }
  }

  static TypeOfFile getTypeFromExtension(String extension) {
    if (imgExt.any((element) => extension == element)) {
      return TypeOfFile.image;
    } else if (vidExt.any((element) => extension == element)) {
      return TypeOfFile.video;
    } else if (audExt.any((element) => extension == element)) {
      return TypeOfFile.audio;
    } else {
      return TypeOfFile.document;
    }
  }

  static String getShortFileType(File file) {
    TypeOfFile type = getTypeFromExtension(extensionOfFile(file));
    return type == TypeOfFile.image
        ? "IMG"
        : type == TypeOfFile.video
            ? "VID"
            : type == TypeOfFile.audio
                ? "AUD"
                : "DOC";
  }

  static String getShortTypeFromExtension(String extension) {
    TypeOfFile type = getTypeFromExtension(extension);
    return type == TypeOfFile.image
        ? "IMG"
        : type == TypeOfFile.video
            ? "VID"
            : type == TypeOfFile.audio
                ? "AUD"
                : "DOC";
  }

  static String getLongFileType(File file) {
    TypeOfFile type = getTypeFromExtension(extensionOfFile(file));
    return type == TypeOfFile.image
        ? "Images"
        : type == TypeOfFile.video
            ? "Videos"
            : type == TypeOfFile.audio
                ? "Audios"
                : "Documents";
  }

  static String getLongTypeFromExtension(String extension) {
    TypeOfFile type = getTypeFromExtension(extension);
    return type == TypeOfFile.image
        ? "Images"
        : type == TypeOfFile.video
            ? "Videos"
            : type == TypeOfFile.audio
                ? "Audios"
                : "Documents";
  }
}
