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
