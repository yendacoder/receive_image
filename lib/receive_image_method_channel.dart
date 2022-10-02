import 'dart:io';

import 'package:flutter/services.dart';

import 'receive_image_platform_interface.dart';

class MethodChannelReceiveImage extends ReceiveImagePlatform {
  final _methodChannel = const MethodChannel('receive_image');
  final _eventChannel = const EventChannel('receive_image/files');

  @override
  Future<File?> getInitialFile() async {
    final path = await _methodChannel.invokeMethod<String?>('getInitialFile');
    return path == null ? null : File(path);
  }

  @override
  Stream<File> getFileStream() {
    return _eventChannel.receiveBroadcastStream().map((path) => File(path));
  }
}
