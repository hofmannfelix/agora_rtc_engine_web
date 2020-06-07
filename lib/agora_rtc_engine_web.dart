import 'dart:async';
import 'dart:convert';
import 'dart:js';

import 'package:agorartcengineweb/agora_rtc_engine.dart';
import 'package:flutter/services.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';

class AgoraRtcEngineWeb {
  static const methodChannelName = "agora_rtc_engine";
  static const eventChannelName = "agora_rtc_engine_event_channel";

  static void registerWith(Registrar registrar) {
    final channel =
        MethodChannel(methodChannelName, const StandardMethodCodec(), registrar.messenger);
    final AgoraRtcEngineWeb instance = AgoraRtcEngineWeb();
    channel.setMethodCallHandler(instance.handleMethodCall);

    context['agoraMethodResult'] = (JsObject parameters) {
      final handleId = parameters['handleId'];
      final error = parameters['error'];
      print("Completed method with handle id $handleId");
      if (error == null)
        instance._completer[handleId].complete(parameters);
      else
        instance._completer[handleId].complete(parameters);
    };

    context['agoraEvent'] = (JsObject parameters) {
      final method = parameters['method'];
      instance.callEvent(method, parameters);
    };
  }

  int _nextHandleId = 0;
  Map<int, Completer> _completer = {};

  Future<dynamic> handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'create':
      case 'enableVideo':
      case 'enableAudio':
      case 'joinChannel':
      case 'leaveChannel':
      case 'setupLocalVideo':
      case 'setupRemoteVideo':
      case 'muteLocalAudioStream':
      case 'muteLocalVideoStream':
      case 'enableDualStreamMode':
      case 'setRemoteDefaultVideoStreamType':
      case 'setRemoteVideoStreamType':
        await _callJs(call);
        return true;
      case 'setParameters':
        final Map params = jsonDecode(call.arguments['params']);
        if (params?.containsKey('che.video.lowBitRateStreamParameter') == true)
          await _callJs(
              MethodCall('setLowStreamParameter', params['che.video.lowBitRateStreamParameter']));
        return 0;
      case 'startPreview':
      case 'stopPreview':
      case 'removeNativeView':
      case 'setChannelProfile':
      case 'setAudioProfile':
      case 'setVideoEncoderConfiguration':
      case 'setRemoteUserPriority':
      case 'adjustPlaybackSignalVolume':
        print("The method ${call.method} has no effect on web");
        break;
      default:
        throw PlatformException(
            code: 'Unimplemented',
            details: "The agora_rtc_engine plugin for web doesn't implement "
                "the method '${call.method}'");
    }
  }

  dynamic _callJs(MethodCall call) {
    final handleId = _nextHandleId++;
    final completer = _completer[handleId] = Completer();
    Map args = call.arguments as Map ?? {};
    context.callMethod(call.method, [handleId, ...args.values]);
    return completer.future..then((f) => _completer.remove(handleId));
  }

  dynamic callEvent(String method, JsObject args) {
    switch (method) {
      case 'onJoinChannelSuccess':
        if (AgoraRtcEngine.onJoinChannelSuccess != null)
          AgoraRtcEngine.onJoinChannelSuccess(args['channelId'], args['uid'], args['elapsed']);
        break;
      case 'onUserJoined':
        if (AgoraRtcEngine.onUserJoined != null)
          AgoraRtcEngine.onUserJoined(args['uid'], args['elapsed']);
        break;
      case 'onUserOffline':
        if (AgoraRtcEngine.onUserOffline != null)
          AgoraRtcEngine.onUserOffline(args['uid'], args['reason']);
        break;
      case 'onLocalVideoStats':
        if (AgoraRtcEngine.onLocalVideoStats != null)
          AgoraRtcEngine.onLocalVideoStats(LocalVideoStats.fromJson(jsonDecode(args['stats'])));
        break;
      case 'onRemoteVideoStats':
        if (AgoraRtcEngine.onRemoteVideoStats != null)
          AgoraRtcEngine.onRemoteVideoStats(RemoteVideoStats.fromJson(jsonDecode(args['stats'])));
        break;
    }
  }
}

//class AgoraWidget {
//  void initialize() {
//
//
//    // The error event fires when some form of error occurs while attempting to load or perform the media.
//    videoElement.onError.listen((Event _) {
//      // The Event itself (_) doesn't contain info about the actual error.
//      // We need to look at the HTMLMediaElement.error.
//      // See: https://developer.mozilla.org/en-US/docs/Web/API/HTMLMediaElement/error
//      MediaError error = videoElement.error;
//      eventController.addError(PlatformException(
//        code: _kErrorValueToErrorName[error.code],
//        message: error.message != '' ? error.message : _kDefaultErrorMessage,
//        details: _kErrorValueToErrorDescription[error.code],
//      ));
//    });
//
//    videoElement.onEnded.listen((dynamic _) {
//      eventController.add(VideoEvent(eventType: VideoEventType.completed));
//    });
//  }
//}
//
//class VideoPlayer {
//  _VideoPlayer({this.uri, this.textureId});
//
//  final StreamController<VideoEvent> eventController = StreamController<VideoEvent>();
//
//  final Uri uri;
//  final int textureId;
//  VideoElement videoElement;
//  bool isInitialized = false;
//
//  void initialize() {
//    // ignore: undefined_prefixed_name
//    ui.platformViewRegistry.registerViewFactory(
//        streamViewId,
//        (int viewId) => DivElement()
//          ..id = streamViewId
//          ..className = "video-placeholder");
//
//    videoElement = VideoElement()
//      ..src = uri.toString()
//      ..autoplay = false
//      ..controls = false
//      ..style.border = 'none';
//
//    // TODO(hterkelsen): Use initialization parameters once they are available
//    // ignore: undefined_prefixed_name
//    ui.platformViewRegistry
//        .registerViewFactory('videoPlayer-$textureId', (int viewId) => videoElement);
//
//    videoElement.onCanPlay.listen((dynamic _) {
//      if (!isInitialized) {
//        isInitialized = true;
//        sendInitialized();
//      }
//    });
//
//    // The error event fires when some form of error occurs while attempting to load or perform the media.
//    videoElement.onError.listen((Event _) {
//      // The Event itself (_) doesn't contain info about the actual error.
//      // We need to look at the HTMLMediaElement.error.
//      // See: https://developer.mozilla.org/en-US/docs/Web/API/HTMLMediaElement/error
//      MediaError error = videoElement.error;
//      eventController.addError(PlatformException(
//        code: _kErrorValueToErrorName[error.code],
//        message: error.message != '' ? error.message : _kDefaultErrorMessage,
//        details: _kErrorValueToErrorDescription[error.code],
//      ));
//    });
//
//    videoElement.onEnded.listen((dynamic _) {
//      eventController.add(VideoEvent(eventType: VideoEventType.completed));
//    });
//  }
//
//  void sendBufferingUpdate() {
//    eventController.add(VideoEvent(
//      buffered: _toDurationRange(videoElement.buffered),
//      eventType: VideoEventType.bufferingUpdate,
//    ));
//  }
//
//  Future<void> play() {
//    return videoElement.play().catchError((e) {
//      // play() attempts to begin playback of the media. It returns
//      // a Promise which can get rejected in case of failure to begin
//      // playback for any reason, such as permission issues.
//      // The rejection handler is called with a DomException.
//      // See: https://developer.mozilla.org/en-US/docs/Web/API/HTMLMediaElement/play
//      DomException exception = e;
//      eventController.addError(PlatformException(
//        code: exception.name,
//        message: exception.message,
//      ));
//    }, test: (e) => e is DomException);
//  }
//
//  void pause() {
//    videoElement.pause();
//  }
//
//  void setLooping(bool value) {
//    videoElement.loop = value;
//  }
//
//  void setVolume(double value) {
//    videoElement.volume = value;
//  }
//
//  void seekTo(Duration position) {
//    videoElement.currentTime = position.inMilliseconds.toDouble() / 1000;
//  }
//
//  Duration getPosition() {
//    return Duration(milliseconds: (videoElement.currentTime * 1000).round());
//  }
//
//  void sendInitialized() {
//    eventController.add(
//      VideoEvent(
//        eventType: VideoEventType.initialized,
//        duration: Duration(
//          milliseconds: (videoElement.duration * 1000).round(),
//        ),
//        size: Size(
//          videoElement.videoWidth.toDouble() ?? 0.0,
//          videoElement.videoHeight.toDouble() ?? 0.0,
//        ),
//      ),
//    );
//  }
//
//  void dispose() {
//    videoElement.removeAttribute('src');
//    videoElement.load();
//  }
//
//  List<DurationRange> _toDurationRange(TimeRanges buffered) {
//    final List<DurationRange> durationRange = <DurationRange>[];
//    for (int i = 0; i < buffered.length; i++) {
//      durationRange.add(DurationRange(
//        Duration(milliseconds: (buffered.start(i) * 1000).round()),
//        Duration(milliseconds: (buffered.end(i) * 1000).round()),
//      ));
//    }
//    return durationRange;
//  }
//}

//import 'dart:js';
//
//import 'package:flutter/services.dart';
//import 'package:flutter_web_plugins/flutter_web_plugins.dart';
//
//enum JsEventTypes {
//  userJoined,
//  userLeft,
//}
//
//class AgoraRtcEngineWeb {
//  static void registerWith(Registrar registrar) {
//    final MethodChannel channel =
//        MethodChannel('agora_rtc_engine', const StandardMethodCodec(), registrar.messenger);
//    final instance = AgoraRtcEngineWeb();
//    channel.setMethodCallHandler(instance.handleMethodCall);
//  }
//
//  Future<dynamic> handleMethodCall(MethodCall call) async {
//
//    context.callMethod(call.method, call.arguments);
//    return;
//
////    switch (call.method) {
////      case 'create':
////        final String url = call.arguments['appId'];
////        return _launch(url);
////      default:
////        throw PlatformException(
////            code: 'Unimplemented',
////            details: "The url_launcher plugin for web doesn't implement "
////                "the method '${call.method}'");
////    }
//  }
//
//  set jsEventHandler(Function(JsEventTypes, JsObject) handler) {
//    context['fltEvent'] = (JsObject parameters) {
//      final eventType = JsEventTypes.values[int.parse(parameters['eventType'])];
//      return handler(eventType, parameters);
//    };
//  }
//
//  joinSession() async {
//    context.callMethod('xceptJoin', []);
//  }
//}
