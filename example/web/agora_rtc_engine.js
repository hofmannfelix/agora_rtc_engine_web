console.log("agora sdk version: " + AgoraRTC.VERSION + " compatible: " + AgoraRTC.checkSystemRequirements());
//
//function addView (streamViewId, id) {
//
////TODO: call flutter method to create new view
//  let remoteStreamView = fltFindNativeElement(streamViewId);
//
//  let remoteVideoPanel = document.createElement('div');
//  remoteVideoPanel.setAttribute("id", "remote_video_panel_" + id);
//  remoteVideoPanel.setAttribute("class", "video-view");
//  remoteVideoPanel.style.width = "100%";
//  remoteVideoPanel.style.height = "100%";
//  remoteStreamView.appendChild(remoteVideoPanel);
//
//  let remoteVideo = document.createElement('div');
//  remoteVideo.setAttribute("id", "remote_video_" + id);
//  remoteVideo.setAttribute("class", "video-placeholder");
//  remoteVideo.style.width = "100%";
//  remoteVideo.style.height = "100%";
//  remoteVideoPanel.appendChild(remoteVideo);
//}
//
//function removeView (streamViewId, id) {
//  let remoteStreamView = fltFindNativeElement(streamViewId);
//  remoteStreamView.firstChild.remove();
//}
//
//function getDevices (next) {
//  AgoraRTC.getDevices(function (items) {
//
//  });
//}
//
//var rtc = {
//  client: null,
//  joined: false,
//  published: false,
//  localStream: null,
//  remoteStreams: [],
//  params: {}
//};
//
//function handleEvents (rtc) {
//  // Occurs when an error message is reported and requires error handling.
//  rtc.client.on("error", (err) => {
//    console.log(err)
//  })
//  // Occurs when the peer user leaves the channel; for example, the peer user calls Client.leave.
//  rtc.client.on("peer-leave", function (evt) {
//    var id = evt.uid;
//    console.log("id", evt);
//    if (id != rtc.params.uid) {
//      var streamViewId = fltEvent({'eventType': '1', 'uid': '' + id});
//      console.log("flutter removed stream view id " + streamViewId);
//      removeView(streamViewId, id);
//    }
//    console.log('peer-leave', id);
//  })
//  // Occurs when the local stream is published.
//  rtc.client.on("stream-published", function (evt) {
//    console.log("stream-published");
//  })
//  // Occurs when the remote stream is added.
//  rtc.client.on("stream-added", function (evt) {
//    var remoteStream = evt.stream;
//    var id = remoteStream.getId();
//    if (id !== rtc.params.uid) {
//      rtc.client.subscribe(remoteStream, function (err) {
//        console.log("stream subscribe failed", err);
//      })
//    }
//    console.log('stream-added remote-uid: ', id);
//  });
//  // Occurs when a user subscribes to a remote stream.
//  rtc.client.on("stream-subscribed", function (evt) {
//    var remoteStream = evt.stream;
//    var id = remoteStream.getId();
//    rtc.remoteStreams.push(remoteStream);
//
//    var streamViewId = fltEvent({'eventType': '0', 'uid': '' + id});
//    console.log("flutter got stream view id " + streamViewId);
//
//    addView(streamViewId, id);
//    remoteStream.play("remote_video_" + id);
//    console.log('stream-subscribed remote-uid: ', id);
//  })
//  // Occurs when the remote stream is removed; for example, a peer user calls Client.unpublish.
//  rtc.client.on("stream-removed", function (evt) {
//    var remoteStream = evt.stream;
//    var id = remoteStream.getId();
//    remoteStream.stop("remote_video_" + id);
//    rtc.remoteStreams = rtc.remoteStreams.filter(function (stream) {
//      return stream.getId() !== id
//    })
//
//    var streamViewId = fltEvent({'eventType': '1', 'uid': '' + id});
//    console.log("flutter removed stream view id " + streamViewId);
//
//    removeView(streamViewId, id);
//    console.log('stream-removed remote-uid: ', id);
//  })
//  rtc.client.on("onTokenPrivilegeWillExpire", function(){
//    // After requesting a new token
//    // rtc.client.renewToken(token);
//    console.log("onTokenPrivilegeWillExpire")
//  });
//  rtc.client.on("onTokenPrivilegeDidExpire", function(){
//    // After requesting a new token
//    // client.renewToken(token);
//    console.log("onTokenPrivilegeDidExpire")
//  })
//}
//
///**
//  * rtc: rtc object
//  * option: {
//  *  mode: string, 'live' | 'rtc'
//  *  codec: string, 'h264' | 'vp8'
//  *  appID: string
//  *  channel: string, channel name
//  *  uid: number
//  *  token; string,
//  * }
// **/
//function join (rtc, option) {
//  if (rtc.joined) {
//    console.log("Your already joined");
//    return;
//  }
//
//  /**
//   * A class defining the properties of the config parameter in the createClient method.
//   * Note:
//   *    Ensure that you do not leave mode and codec as empty.
//   *    Ensure that you set these properties before calling Client.join.
//   *  You could find more detail here. https://docs.agora.io/en/Video/API%20Reference/web/interfaces/agorartc.clientconfig.html
//  **/
//  rtc.client = AgoraRTC.createClient({mode: option.mode, codec: option.codec});
//
//  rtc.params = option;
//
//  // handle AgoraRTC client event
//  handleEvents(rtc);
//
//  // init client
//  rtc.client.init(option.appID, function () {
//    console.log("init success");
//
//    /**
//     * Joins an AgoraRTC Channel
//     * This method joins an AgoraRTC channel.
//     * Parameters
//     * tokenOrKey: string | null
//     *    Low security requirements: Pass null as the parameter value.
//     *    High security requirements: Pass the string of the Token or Channel Key as the parameter value. See Use Security Keys for details.
//     *  channel: string
//     *    A string that provides a unique channel name for the Agora session. The length must be within 64 bytes. Supported character scopes:
//     *    26 lowercase English letters a-z
//     *    26 uppercase English letters A-Z
//     *    10 numbers 0-9
//     *    Space
//     *    "!", "#", "$", "%", "&", "(", ")", "+", "-", ":", ";", "<", "=", ".", ">", "?", "@", "[", "]", "^", "_", "{", "}", "|", "~", ","
//     *  uid: number | null
//     *    The user ID, an integer. Ensure this ID is unique. If you set the uid to null, the server assigns one and returns it in the onSuccess callback.
//     *   Note:
//     *      All users in the same channel should have the same type (number or string) of uid.
//     *      If you use a number as the user ID, it should be a 32-bit unsigned integer with a value ranging from 0 to (232-1).
//    **/
//    rtc.client.join(option.token ? option.token : null, option.channel, option.uid ? + option.uid : null, function (uid) {
//      console.log("join channel: " + option.channel + " success, uid: " + uid);
//      rtc.joined = true;
//
//      rtc.params.uid = uid;
//
//      // create local stream
//      rtc.localStream = AgoraRTC.createStream({
//        streamID: rtc.params.uid,
//        audio: true,
//        video: true,
//        screen: false,
//        microphoneId: option.microphoneId,
//        cameraId: option.cameraId
//      })
//
//      // init local stream
//      rtc.localStream.init(function () {
//        console.log("init local stream success");
//        // play stream with html element id "local_stream"
//        rtc.localStream.play("local_stream")
//
//        // publish local stream
//        publish(rtc);
//      }, function (err)  {
//        console.error("init local stream failed ", err);
//      })
//    }, function(err) {
//      console.error("client join failed", err)
//    })
//  }, (err) => {
//    console.error(err);
//  });
//}
//
//function publish (rtc) {
//  if (!rtc.client) {
//    console.log("Please Join Room First");
//    return;
//  }
//  if (rtc.published) {
//    console.log("Your already published");
//    return;
//  }
//  var oldState = rtc.published;
//
//  // publish localStream
//  rtc.client.publish(rtc.localStream, function (err) {
//    rtc.published = oldState;
//    console.log("publish failed");
//    console.error(err);
//  })
//  rtc.published = true
//}
//
//function unpublish (rtc) {
//  if (!rtc.client) {
//    console.log("Please Join Room First");
//    return;
//  }
//  if (!rtc.published) {
//    console.log("Your didn't publish");
//    return;
//  }
//  var oldState = rtc.published;
//  rtc.client.unpublish(rtc.localStream, function (err) {
//    rtc.published = oldState;
//    console.log("unpublish failed");
//    console.error(err);
//  })
//  rtc.published = false;
//}
//
//function leave (rtc) {
//  if (!rtc.client) {
//    console.log("Please Join First!");
//    return;
//  }
//  if (!rtc.joined) {
//    console.log("You are not in channel");
//    return;
//  }
//  /**
//   * Leaves an AgoraRTC Channel
//   * This method enables a user to leave a channel.
//   **/
//  rtc.client.leave(function () {
//    // stop stream
//    rtc.localStream.stop();
//    // close stream
//    rtc.localStream.close();
//    while (rtc.remoteStreams.length > 0) {
//      var stream = rtc.remoteStreams.shift();
//      var id = stream.getId();
//      stream.stop();
//      removeView(id);
//    }
//    rtc.localStream = null;
//    rtc.remoteStreams = [];
//    rtc.client = null;
//    console.log("client leaves channel success");
//    rtc.published = false;
//    rtc.joined = false;
//  }, function (err) {
//    console.log("channel leave failed");
//    console.error(err);
//  })
//}
//
//function xceptJoin() {
//  params = {
//    appID: "409d9805ff80450b993d4ec3c2d121ea",
//    channel: "xcept-channel",
//    codec: "h264",
//    mode: "live",
//    token: "",
//    uid: 0
//  };
//  join(rtc, params);
//}
//
//function fltFindNativeElement(id) {
//  //getElementsByTagName('flt-platform-view')[0].shadowRoot.getElementById(t.elementID)
//  let fltPlatformViews = document.getElementsByTagName('flt-platform-view');
//  for(var i = 0; i < fltPlatformViews.length; i++)
//    if (fltPlatformViews[i].shadowRoot.getElementById(id) !== null)
//      return fltPlatformViews[i].shadowRoot.getElementById(id);
//  return null;
//}


function xceptJoin() {
  alert("fuck you");
}
