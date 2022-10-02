
import 'dart:io';

import 'receive_image_platform_interface.dart';

class ReceiveImage {
  static Future<File?> getInitialFile() {
    return ReceiveImagePlatform.instance.getInitialFile();
  }

  static Stream<File> getFileStream() {
    return ReceiveImagePlatform.instance.getFileStream();
  }
}
