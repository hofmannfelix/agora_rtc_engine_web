console.log("agora sdk version: " + AgoraRTC.VERSION + " compatible: " + AgoraRTC.checkSystemRequirements());

var rtc = {
  client: null,
  joined: false,
  published: false,
  localStream: null,
  streams: {},
  isVideoEnabled: true,
  isAudioEnabled: true,
  defaultStream: 0, //0: high quality, 1: low quality
  lowStreamParameters: null,
  callbackInterval: null,
  params: {},
};

function create(handleId, appId) {
  var mode = "live";
  var codec = "h264";
  rtc.client = AgoraRTC.createClient({mode: mode, codec: codec});
  rtc.client.init(appId, function () {
    handleEvents(rtc);
    agoraMethodResult({'handleId': handleId, 'uid': '' + appId});
  }, (err) => {
    agoraMethodResult({'handleId': handleId, 'error': err});
  });
}

function enableVideo(handleId) {
  rtc.isVideoEnabled = true;
  agoraMethodResult({'handleId': handleId});
}

function enableAudio(handleId) {
  rtc.isAudioEnabled = true;
  agoraMethodResult({'handleId': handleId});
}

function setRemoteVideoStreamType(handleId, uid, streamType) {
  rtc.client.setRemoteVideoStreamType(rtc.streams['' + uid], streamType);
  agoraMethodResult({'handleId': handleId});
}

function setRemoteVideoStreamType(handleId, uid, streamType) {
  rtc.client.setRemoteVideoStreamType(rtc.streams['' + uid], streamType);
  agoraMethodResult({'handleId': handleId});
}

function setRemoteDefaultVideoStreamType(handleId, streamType) {
  rtc.defaultStream = streamType;
  agoraMethodResult({'handleId': handleId});
}

function adjustPlaybackSignalVolume(handleId, volume) {
  rtc.defaultStream = streamType;
  agoraMethodResult({'handleId': handleId});
}

function setLowStreamParameter(handleId, width, height, frameRate, bitRate) {
  rtc.lowStreamParameters = {
    width: width,
    height: height,
    frameRate: frameRate,
    bitRate: bitRate
  };
  agoraMethodResult({'handleId': handleId});
}

function muteLocalAudioStream(handleId, isMuted) {
  if (isMuted)
    rtc.localStream.muteAudio();
  else
    rtc.localStream.unmuteAudio();
  agoraMethodResult({'handleId': handleId});
}

function muteLocalVideoStream(handleId, isMuted) {
  if (isMuted)
    rtc.localStream.muteVideo();
  else
    rtc.localStream.unmuteVideo();
  agoraMethodResult({'handleId': handleId});
}

function enableDualStreamMode(handleId, isEnabled) {
  if (isEnabled)
    rtc.client.enableDualStream(function () {
      agoraMethodResult({'handleId': handleId});
    }, (err) => {
      agoraMethodResult({'handleId': handleId, 'error': err});
    });
  else
    rtc.client.disableDualStream(function () {
      agoraMethodResult({'handleId': handleId});
    }, (err) => {
      agoraMethodResult({'handleId': handleId, 'error': err});
    });
}

function joinChannel(handleId, token, channelId, info, uid) {
  rtc.client.join(token, channelId, uid, function (uid) {
    rtc.params.uid = uid;
    rtc.params.channelId = channelId;
    rtc.joined = true;
    rtc.localStream = AgoraRTC.createStream({
      streamID: uid,
      audio: rtc.isAudioEnabled,
      video: rtc.isVideoEnabled,
      screen: false,
    });
    rtc.streams['' + uid] = rtc.localStream;
    //setLowStreamParameter
    if (rtc.lowStreamParameters != null) rtc.client.setLowStreamParameter(rtc.lowStreamParameters);
    rtc.localStream.init(function () {
      rtc.client.publish(rtc.localStream, function (err) {
        agoraMethodResult({'handleId': handleId, 'error': err});
      });
      initStatsIntervalCallback();
      agoraMethodResult({'handleId': handleId});
    }, function (err) {
      agoraMethodResult({'handleId': handleId, 'error': err});
    })
  }, function(err) {
    agoraMethodResult({'handleId': handleId, 'error': err});
  });
}

function leaveChannel(handleId) {
  rtc.localStream.stop();
  rtc.localStream.close();
  rtc.client.leave(function() {
    if (rtc.callbackInterval != null) clearInterval(rtc.callbackInterval);
    rtc.joined = false;
    rtc.params.uid = null;
    rtc.params.channelId = null;
    rtc.localStream = null;
    rtc.streams = {};
    rtc.callbackInterval = null;
    agoraMethodResult({'handleId': handleId});
  }, function(err) {
    agoraMethodResult({'handleId': handleId, 'error': err});
  });
}

function setupLocalVideo(handleId, uid, renderMode) {
  rtc.localStream.play("stream-view-" + uid);
  agoraMethodResult({'handleId': handleId});
}

function setupRemoteVideo(handleId, uid, renderMode) {
  rtc.streams['' + uid].play("stream-view-" + uid);
  agoraMethodResult({'handleId': handleId});
}

function startPreview(handleId) {
  agoraMethodResult({'handleId': handleId});
}

function initStatsIntervalCallback() {
  rtc.callbackInterval = setInterval(() => {
    rtc.client.getLocalVideoStats((stats) => {
      for(var uid in stats) {
        var s = stats[uid];
        var statistics = JSON.stringify({
          sentBitrate: parseInt(s.SendBitrate),
          sentFrameRate: parseInt(s.SendFrameRate),
          encoderOutputFrameRate: 0,
          rendererOutputFrameRate: 0,
          sentTargetBitrate: parseInt(s.TargetSendBitrate),
          sentTargetFrameRate: parseInt(s.CaptureFrameRate),
          qualityAdaptIndication: 0,
          encodedBitrate: 0,
          encodedFrameWidth: parseInt(s.CaptureResolutionWidth),
          encodedFrameHeight: parseInt(s.CaptureResolutionHeight),
          encodedFrameCount: 0,
          codecType: 0
        });
        agoraEvent({'method': 'onLocalVideoStats', 'stats': statistics});
      }
    });
    rtc.client.getRemoteVideoStats((stats) => {
      for(var uid in stats) {
        var s = stats[uid];
        var statistics = JSON.stringify({
            uid: parseInt(uid),
            width: parseInt(s.RecvResolutionWidth),
            height: parseInt(s.RecvResolutionHeight),
            receivedBitrate: parseInt(s.RecvBitrate) || 0,
            decoderOutputFrameRate: 0,
            rendererOutputFrameRate: 0,
            packetLostRate: parseInt(s.PacketLossRate) || 0,
            rxStreamType: 0,
            totalFrozenTime: parseInt(s.TotalFreezeTime) || 0,
            frozenRate: 0
        });
        agoraEvent({'method': 'onRemoteVideoStats', 'stats': statistics});
      }
    });
  }, 2000);
}

function handleEvents(rtc) {
  // Occurs when an error message is reported and requires error handling.
  rtc.client.on("error", (err) => {
    console.log(err)
  });
  // Occurs when the remote stream is added.
  rtc.client.on("stream-added", function (evt) {
    var remoteStream = evt.stream;
    var uid = remoteStream.getId();
    if (uid !== rtc.params.uid) {
      rtc.client.setRemoteVideoStreamType(remoteStream, rtc.defaultStream);
      rtc.client.subscribe(remoteStream, function (err) {
        console.log("stream subscribe failed", err);
      });
      agoraEvent({'method': 'onUserJoined', 'uid': uid, 'elapsed': 0});
    }
  });
  // Occurs when a user subscribes to a remote stream.
  rtc.client.on("stream-subscribed", function (evt) {
    var remoteStream = evt.stream;
    var uid = remoteStream.getId();
    rtc.streams['' + uid] = remoteStream;
    agoraEvent({'method': 'onJoinChannelSuccess', 'channelId': rtc.params.channelId, 'uid': uid, 'elapsed': 0});
  });

  // Occurs when the remote stream is removed; for example, a peer user calls Client.unpublish.
  rtc.client.on("peer-leave", function (evt) {
    var uid = evt.uid;
    agoraEvent({'method': 'onUserOffline', 'uid': uid, 'reason': 0});
    delete rtc.streams['' + uid];
  });
}

/// Helper function called within Agora SDK to find dom element created by flutter
function fltFindNativeElement(id) {
  //getElementsByTagName('flt-platform-view')[0].shadowRoot.getElementById(t.elementID)
  let fltPlatformViews = document.getElementsByTagName('flt-platform-view');
  for(var i = 0; i < fltPlatformViews.length; i++)
    if (fltPlatformViews[i].shadowRoot.getElementById(id) !== null)
      return fltPlatformViews[i].shadowRoot.getElementById(id);
  return null;
}
