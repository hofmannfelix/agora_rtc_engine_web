import 'package:agora_rtc_engine_web/agora_rtc_engine.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int myUid = 1;
  List<int> _joinedUids = [];

  @override
  void initState() {
    super.initState();
    _init();
  }

  _init() async {
    final agoraAppId = "409d9805ff80450b993d4ec3c2d121ea";
    AgoraRtcEngine.onUserJoined = (int uid, int elapsed) => setState(() {
          print("Add uid $uid");
        });
    AgoraRtcEngine.onJoinChannelSuccess = (String channel, int uid, int elapsed) => setState(() {
          _joinedUids.add(uid);
          print("Added uid $uid to $_joinedUids");
          setState(() {});
        });
    AgoraRtcEngine.onUserOffline = (int uid, int reason) => setState(() {
          _joinedUids.remove(uid);
          print("Removed uid $uid from $_joinedUids");
          setState(() {});
        });
    AgoraRtcEngine.onRemoteVideoStats = (stats) => setState(() {
          print("Remote video stats ${stats.receivedBitrate}");
        });
    await AgoraRtcEngine.setParameters(
        '{\"che.video.lowBitRateStreamParameter\":{\"width\":90,\"height\":160,\"frameRate\":15,\"bitRate\":65}}');
    await AgoraRtcEngine.create(agoraAppId);
    await AgoraRtcEngine.joinChannel(null, "xcept-channel", "", myUid);
    _joinedUids.add(myUid);
    setState(() {});
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
            Row(children: [
              ..._joinedUids.map(
                (uid) => SizedBox.fromSize(
                  size: Size(400, 300),
                  child: Container(
                    color: Colors.black12,
                    child: AgoraRenderWidget(uid, local: uid == myUid, preview: true),
                  ),
                ),
              ),
            ]),
            FlatButton(
              child: Text("click me"),
              onPressed: () => AgoraRtcEngine.leaveChannel(),
            ),
          ],
        ),
      ),
    );
  }
}
