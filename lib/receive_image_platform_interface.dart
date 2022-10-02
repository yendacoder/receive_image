import 'dart:io';

import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'receive_image_method_channel.dart';

abstract class ReceiveImagePlatform extends PlatformInterface {
  ReceiveImagePlatform() : super(token: _token);

  static final Object _token = Object();

  static ReceiveImagePlatform _instance = MethodChannelReceiveImage();

  static ReceiveImagePlatform get instance => _instance;

  static set instance(ReceiveImagePlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<File?> getInitialFile() {
    throw UnimplementedError('getInitialFile() has not been implemented.');
  }

  Stream<File> getFileStream() {
    throw UnimplementedError('getFileStream() has not been implemented.');
  }
}
