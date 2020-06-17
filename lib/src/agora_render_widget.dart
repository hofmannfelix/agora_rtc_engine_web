import 'dart:html';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../agora_rtc_engine.dart';
import 'base.dart';

/// AgoraRenderWidget - This widget will automatically manage the native view.
///
/// Enables create native view with `uid` `mode` `local` and destroy native view automatically.
///
class AgoraRenderWidget extends StatefulWidget {
  // uid
  final int uid;

  // local flag
  final bool local;

  // local preview flag;
  final bool preview;

  /// render mode
  final VideoRenderMode mode;

  AgoraRenderWidget(this.uid, {
    this.mode = VideoRenderMode.Hidden,
    this.local = false,
    this.preview = false,
  })
      : assert(uid != null),
        assert(mode != null),
        assert(local != null),
        assert(preview != null),
        super(key: Key(uid.toString()));

  @override
  State<StatefulWidget> createState() => _AgoraRenderWidgetState();
}

class _AgoraRenderWidgetState extends State<AgoraRenderWidget> {
  Widget _nativeView;
  String _viewId;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    _viewId = "stream-view-${widget.uid}";
    final agoraElement = DivElement()
      ..id = _viewId
      ..className = "video-placeholder";

    // ignore: undefined_prefixed_name
    ui.platformViewRegistry.registerViewFactory(_viewId, (_) => agoraElement);

    Future.delayed(Duration(seconds: 1), () => _bindView());
  }

  @override
  void dispose() {
    _isDisposed = true;
    AgoraRtcEngine.removeNativeView(widget.uid);
    if (widget.preview) AgoraRtcEngine.stopPreview();
    super.dispose();
  }

  @override
  void didUpdateWidget(AgoraRenderWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if ((widget.uid != oldWidget.uid || widget.local != oldWidget.local) &&
        _viewId != null) {
      //_bindView();
      return;
    }

    if (widget.mode != oldWidget.mode) {
      //_changeRenderMode();
      return;
    }
  }

  void _bindView() {
    if (_isDisposed) return;
    if (widget.local) {
      AgoraRtcEngine.setupLocalVideo(widget.uid, widget.mode);
      if (widget.preview) AgoraRtcEngine.startPreview();
    } else {
      AgoraRtcEngine.setupRemoteVideo(widget.uid, widget.mode, widget.uid);
    }
  }

  void _changeRenderMode() {
    if (widget.local) {
      AgoraRtcEngine.setLocalRenderMode(widget.mode);
    } else {
      AgoraRtcEngine.setRemoteRenderMode(widget.uid, widget.mode);
    }
  }

  @override
  Widget build(BuildContext context) => _nativeView ??= HtmlElementView(viewType: _viewId);
}
