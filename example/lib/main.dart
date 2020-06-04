import 'package:agorartcengineweb/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  bool _showPreview = false;

  @override
  void initState() {
    super.initState();

    final agoraAppId = "409d9805ff80450b993d4ec3c2d121ea";
    AgoraRtcEngine.create(agoraAppId);
    AgoraRtcEngine.joinChannel(null, "test", "", 0);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Column(
          children: [
            FlatButton(
              child: Text("click me"),
              onPressed: () => setState(() => _showPreview = true),
            ),
            if (_showPreview)
              AgoraRenderWidget(0, preview: true),
          ],
        ),
      ),
    );
  }
}
