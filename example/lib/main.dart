import 'dart:io';

import 'package:flutter/material.dart';
import 'dart:async';

import 'package:receive_image/receive_image.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  File? _lastReceivedFile;
  StreamSubscription? _subscription;

  @override
  void initState() {
    super.initState();
    _listenToStream();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  Future<void> _listenToStream() async {
    _lastReceivedFile = await ReceiveImage.getInitialFile();
    if (_lastReceivedFile != null) {
      setState(() {});
    }
    _subscription = ReceiveImage.getFileStream().listen((file) {
      setState(() {
        _lastReceivedFile = file;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          appBar: AppBar(
            title: const Text('Receive image example'),
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (_lastReceivedFile == null)
                const Text('Share an image from another application'),
              if (_lastReceivedFile != null)
                Text('Received file: $_lastReceivedFile'),
              if (_lastReceivedFile != null)
                Image.file(
                  _lastReceivedFile!,
                  fit: BoxFit.contain,
                ),
            ],
          )),
    );
  }
}
