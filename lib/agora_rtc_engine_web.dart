import 'dart:async';
import 'dart:js';

import 'package:flutter/services.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';

class AgoraRtcEngineWeb {
  static void registerWith(Registrar registrar) {
    final MethodChannel channel =
        MethodChannel('agora_rtc_engine', const StandardMethodCodec(), registrar.messenger);
    final AgoraRtcEngineWeb instance = AgoraRtcEngineWeb();
    channel.setMethodCallHandler(instance.handleMethodCall);

    context['agoraMethodResult'] = (JsObject parameters) {
      final handleId = parameters['handleId'];
      instance._completer[handleId].complete(parameters);
    };
  }

  int _nextHandleId = 0;
  Map<int, Completer> _completer = {};

  Future<dynamic> handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'create':
      case 'joinChannel':
      case 'setupLocalVideo':
      case 'startPreview':
        await _callJs(call);
        return true;
      default:
        throw PlatformException(
            code: 'Unimplemented',
            details: "The url_launcher plugin for web doesn't implement "
                "the method '${call.method}'");
    }
  }

  dynamic _callJs(MethodCall call) {
    final handleId = _nextHandleId++;
    final completer = _completer[handleId] = Completer();
    Map args = call.arguments as Map;
    print("Response is ${context.callMethod(call.method, [handleId, ...args.values])}");
    return completer.future;
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