import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:get/get_connect/http/src/request/request.dart';
import 'package:path_provider/path_provider.dart';
import 'package:smart_app/smart_app.dart';
import '/functions/functions.dart';
import '/models/chat/group_chat.dart';
import '/models/chat/message_file.dart';
import '../../main.dart';

class Message {
  late String _id;
  late String _sentBy;
  late String _type;
  late MessageFile? _file;
  late String _message;
  late DateTime _sentAt;
  late String _conversationId;
  Stream<MessageTask>? _processStream;
  MessageTask? _lastTask;
  File? _fileTmp;
  String get id => this._id;
  String get sentBy => this._sentBy;
  String get type => this._type;
  String get message => this._message;
  MessageTask? get lastTask => this._lastTask;
  MessageFile? get file => this._file;
  
  bool get trackMessage {
    if (_processStream == null) {
      return false;
    } else {
      var task = _lastTask!.task;
      if (task == TaskState.success) {
        return false;
      } else {
        return true;
      }
    }
  }

  Stream<MessageTask>? get processStream => this._processStream;

  DateTime get sentAt => this._sentAt;
  String get conversationId => this._conversationId;

  Map<String, dynamic> toMap() {
    return {
      'sentBy': _sentBy,
      'type': _type,
      'storagePath': _file != null ? _file!.storagePath : null,
      'downloadUrl': _file != null ? _file!.downloadUrl : null,
      'fileName':
          _file != null && _file!.type == "document" ? _file!.fileName : null,
      'extension': _file != null ? _file!.extension : null,
      'sentAt': _sentAt,
      'message': _message,
    };
  }

  Message.fromDocument(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    _id = snapshot.id;
    _sentBy = snapshot.data()!['sentBy'] as String;
    _type = snapshot.data()!['type'] as String;
    _file = _type != "text"
        ? MessageFile(
            type: type,
            storagePath: snapshot.data()!['storagePath'],
            downloadUrl: snapshot.data()!['downloadUrl'],
            extension: snapshot.data()!['extension'],
            conversationId: _conversationId,
            messageId: _id,
            fileName: snapshot.data()!['fileName'])
        : null;
    _sentAt = snapshot.data()!['sentAt'].toDate();
    _message = snapshot.data()!['message'] as String;
    _conversationId = snapshot.reference.parent.parent!.id;
    if (_file != null) {
      if (!_file!.isExist()) {
        downloadFile();
      }
    }
  }

  Future<void> downloadFile() async {
    StreamController<MessageTask> controller = StreamController<MessageTask>();
    _processStream = controller.stream;

    HttpClient httpClient = new HttpClient();
    List<List<int>> chunks = [];
    int downloaded = 0;
    int sayac = 0;

    try {
      var request = await httpClient.getUrl(Uri.parse(_file!.downloadUrl!));
      var response = await request.close();
      response.listen((List<int> chunk) {
        double percent = (downloaded / request.contentLength);
        if (sayac % 1000 == 0) {
          _lastTask = MessageTask(task: TaskState.running, percent: percent);
          controller.add(_lastTask!);
          print("percentage:$percent");
        }
        chunks.add(chunk);
        downloaded += chunk.length;
        sayac++;
      }, onDone: () async {
        double percent = (downloaded / request.contentLength);
        Uint8List? bytes;
        if (percent == 1) {
          bytes = Uint8List(request.contentLength);
          int offset = 0;
          for (List<int> chunk in chunks) {
            bytes.setRange(offset, offset + chunk.length, chunk);
            offset += chunk.length;
          }
          File(_file!.localPath).writeAsBytes(bytes);
          _lastTask = MessageTask(task: TaskState.success, percent: percent);
          controller.add(_lastTask!);
          controller.close();
        }
      }, onError: (e) {
        double percent = _lastTask != null ? _lastTask!.percent : 0;
        _lastTask = MessageTask(task: TaskState.error, percent: percent);
        controller.add(MessageTask(task: TaskState.error, percent: percent));
        controller.close();
      });
    } catch (ex) {
      _lastTask = MessageTask(task: TaskState.error, percent: 0);
      controller.add(_lastTask!);
      controller.close();
    }
  }

  Message.text(
      {required String id,
      required String sentBy,
      required String message,
      required String conversationId}) {
    _type = "text";
    _id = id;
    _sentBy = sentBy;
    _conversationId = conversationId;
    _message = message;
  }

  Message.document(File file,
      {required String id,
      required String sentBy,
      required String message,
      required String conversationId}) {
    _type = "document";
    _id = id;
    _sentBy = sentBy;
    _fileTmp = file;
    _file = MessageFile.fromFile(file,
        conversationId: conversationId, messageId: id, type: type);
    _conversationId = conversationId;
    _message = message;
  }

  Message.media(File file,
      {required String id,
      required String sentBy,
      required String message,
      required String conversationId}) {
    _type = "document";
    _id = id;
    _sentBy = sentBy;
    _fileTmp = file;
    _file = MessageFile.fromFile(file,
        conversationId: conversationId, messageId: id, type: type);
    _conversationId = conversationId;
    _message = message;
  }

  void send() {
    if (_type == "text") {
      _saveTextMessage();
    } else {
      _saveFileMessage();
    }
  }

  void _saveTextMessage() {
    StreamController<MessageTask> controller = StreamController<MessageTask>();
    _processStream = controller.stream;
    dynamic conversation = conversationState.findConversation(id);
    if (conversation != null) {
      _sentAt = DateTime.now();
      conversation.addMessage(this);
      firestore
          .collection("conversations")
          .doc(_conversationId)
          .collection("messages")
          .doc(_id)
          .set(toMap())
          .then((value) {
        _lastTask = MessageTask(task: TaskState.success, percent: 100);
        controller.add(_lastTask!);
        controller.close();
      }, onError: (e) {
        _lastTask = MessageTask(task: TaskState.error, percent: 0);
        controller.add(_lastTask!);
        controller.close();
      });
    }
  }

  void _saveFileMessage() {
    StreamController<MessageTask> controller = StreamController<MessageTask>();
    _processStream = controller.stream;
    dynamic conversation = conversationState.findConversation(id);
    if (conversation != null) {
      _sentAt = DateTime.now();
      conversation.addMessage(this);
      UploadTask task = storage.ref(_file!.storagePath).putFile(_fileTmp!);
      task.snapshotEvents.listen((taskSnapshot) {
        double percent =
            taskSnapshot.bytesTransferred / taskSnapshot.totalBytes;
        switch (taskSnapshot.state) {
          case TaskState.running:
            _lastTask = MessageTask(task: TaskState.running, percent: percent);
            controller.add(_lastTask!);
            break;
          case TaskState.paused:
            _lastTask = MessageTask(task: TaskState.paused, percent: percent);
            controller.add(_lastTask!);
            break;
          case TaskState.success:
            storage
                .ref(_file!.storagePath)
                .getDownloadURL()
                .then((downloadUrl) {
              firestore
                  .collection("conversations")
                  .doc(_conversationId)
                  .collection("messages")
                  .doc(_id)
                  .set(toMap())
                  .then((value) {
                _lastTask = MessageTask(task: TaskState.success, percent: 100);
                controller.add(_lastTask!);
                controller.close();
              }, onError: (e) {
                _lastTask = MessageTask(task: TaskState.error, percent: 0);
                controller.add(_lastTask!);
                controller.close();
              });
            });
            break;
          case TaskState.canceled:
            _lastTask = MessageTask(task: TaskState.canceled, percent: percent);
            controller.add(_lastTask!);
            controller.close();
            break;
          case TaskState.error:
            _lastTask = MessageTask(task: TaskState.error, percent: percent);
            controller.add(_lastTask!);
            controller.close();
            break;
        }
      });
    }
  }

  Future<void> deleteItem() async {
    await firestore
        .collection("conversations")
        .doc(_conversationId)
        .collection("messages")
        .doc(_id)
        .delete();
  }

  String toJson() => json.encode(toMap());
}

class MessageTask {
  TaskState task;
  double percent;

  MessageTask({required this.task, required this.percent});
}
