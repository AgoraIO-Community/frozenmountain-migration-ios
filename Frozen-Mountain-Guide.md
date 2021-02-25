# Migration Guide from Frozen Mountain to Agora: iOS Edition

Agora’s voice, video, and live-broadcasting software runs on a Software Defined Real-Time Network (SD-RTN™), which is a real-time transmission network built by Agora and the only network infrastructure specifically designed for real-time engagement in the world. All voice and video services provided by the Agora SDK are deployed and transmitted through the Agora SD-RTN™.

The Agora SD-RTN™ may be one motivation for adopting the Agora iOS SDK for all of your voice, video, and live-broadcasting needs. Or you may be looking for ease of use or lower latency. Whatever the need may be, this guide details how a generically functional app with a working Frozen Mountain (Icelink) video integration may be disintegrated to provide essentially the same functionality but on a totally different infrastructure, with a smaller set of required methods and an entirely new feel.

This guide uses the Icelink 3 Swift example app as a baseline. You can get it from Frozen Mountain's [download page](https://www.frozenmountain.com/downloads#icelink) after creating an account.

## Prerequisites

- An Agora developer account (see [How To Get Started with Agora](https://www.agora.io/en/blog/how-to-get-started-with-agora?utm_source=medium&utm_medium=blog&utm_campaign=ios-frozen-mountain-migration))
- Xcode 11.0 or later
- A device with minimum iOS 10.0
- A basic understanding of iOS development
- CocoaPods

## Overview

The Icelink SDK is built in Objective-C and defines the `FMIceLinkRtcLocalMedia` and `FMIceLinkRtcRemoteMedia` interfaces, which must be implemented in Swift classes to hold local and remote video. The Agora SDK follows similar concepts in referring to local and remote views but requires much less code to set them up. Similarly, Icelink requires managing audio and video streams from various peer connections, while the Agora SDK allows an application to simply join a channel and be immediately connected to everyone who joins the channel. When creating an application using Agora, this difference allows you to focus on getting set up and running in fewer steps, without having to worry about intricacies of scaling a realtime video network.

## Step 1

The first step in integrating Agora is to incorporate the SDK. Frozen Mountain's demo app simply contains the SDK as libraries. While you can incorporate Agora in this manner, the recommended method to include the Agora SDK is through CocoaPods. If you don't already have CocoaPods installed, you can read about installation [here](https://guides.cocoapods.org/using/getting-started.html).

Initialize a new Podfile by running `pod init` in Terminal in the same directory as your `.xcodeproj` file. Open the Podfile in your editor of choice, and add the pod for the Agora SDK where it indicates:

```
# Pods for [Your App Name]
pod 'AgoraRtcEngine_iOS'
```

Then run `pod install` in Terminal to install the Agora SDK. From now on, open the `.xcworkspace` file that CocoaPods generated to edit and run your application.

## Step 2

In `VideoCallViewController.swift`, import the Agora SDK:

```
import AgoraRtcKit
```

Next you create an instance of the Agora singleton and a reference to your Agora App ID:

```
var agoraKit: AgoraRtcEngineKit?
var appID = ""
```

Your Agora App ID serves much the same purpose as your Icelink License Key, in that it authenticates your app with Agora.

## Step 3

Now you set up the Agora singleton instead of the Icelink one. In `viewDidLoad`, delete the creation of the `App` object and the setup of the `.onDisconnect` callback, and initialize the `AgoraRtcEngineKit` instead.

```swift
// _app = App.instance
// _app!.onDisconnect = FMCallback(singleAction: { (errorDescription: Any?) in
//     ...
// })

agoraKit = AgoraRtcEngineKit.sharedEngine(
    withAppId: appID, delegate: self
)
```

Since you set your delegate as `self` you add an extension implementing the `AgoraRtcEngineDelegate` protocol:

```swift
extension VideoCallViewController: AgoraRtcEngineDelegate {}
```

You implement some of the protocol functions a little later.

Note: Agora automatically unpublishes the local stream when a user disconnects, so you don't need to replicate the functionality in the `.onDisconnect` handler in the example app. If you have logic you want to still perform, you can implement the `rtcEngine:didLeaveChannelWithStats:` callback.

## Step 4

The next step is to initialize the local video view and join a channel. The demo app does this in `startSession`. Replace the code there with the code to initialize an `AgoraRtcVideoCanvas` and join a channel:

```swift
// Start session (Agora)

agoraKit?.enableVideo()

let videoCanvas = AgoraRtcVideoCanvas()
videoCanvas.uid = 0
videoCanvas.view = _videoView
videoCanvas.renderMode = .hidden
agoraKit?.setupLocalVideo(videoCanvas)

agoraKit?.joinChannel(
    byToken: nil, channelId: "channelName", info: nil, uid: 0
) { (sid, uid, elapsed) in
    print("successfully joined channel")
}

// Start session (Frozen Mountain)
// _app?.startLocalMedia(container: _videoView).then(
//   resolveFunctionBlock: { [weak self] (o: Any!) -> FMIceLinkFuture? in
//     return (self?._app?.joinAsync())!
//   }, rejectActionBlock: { [weak self] (e: NSException?) in
//     self?.alert(format: "%@", args: [(e?.message())!])
//     FMIceLinkLog.error(withMessage: "Could not start local media. %@", ex:e)
//   }).fail(rejectActionBlock: { [weak self] (e: NSException?) in
//     self?.alert(format: "%@", args: [(e?.message())!])
//     FMIceLinkLog.error(withMessage: "Could not join conference. %@", ex:e)
//   }
// )
```

> "channelName" can be any string. It roughly corresponds to the Icelink sessionId. Any users joining the same channel can see and hear one another.

## Step 5

The final step to make the video call work is to recognize when another user has joined a channel and display their video. This is what the `AgoraRtcEngineDelegate` you set up earlier will be used for. Add the following functions:

```swift
extension VideoCallViewController {
    func rtcEngine(_ engine: AgoraRtcEngineKit, didJoinedOfUid uid: UInt, elapsed: Int) {
        let videoView = UIView()
        videoView.tag = Int(uid)
        videoView.backgroundColor = .purple
        let videoCanvas = AgoraRtcVideoCanvas()
        videoCanvas.uid = uid
        videoCanvas.view = videoView
        videoCanvas.renderMode = .hidden
        agoraKit?.setupRemoteVideo(videoCanvas)
        remoteStackView.addArrangedSubview(videoView)
    }
    
    internal func rtcEngine(
        _ engine: AgoraRtcEngineKit, didOfflineOfUid uid: UInt,
        reason: AgoraUserOfflineReason
    ) {
        if let view = remoteStackView.arrangedSubviews.first(
                where: { view in view.tag == Int(uid) }
        ) {
            remoteStackView.removeArrangedSubview(view)
        }
    }
}
```

These methods are called when another user joins or leaves the channel. For this example, I'm using a `StackView` to display those views simply and easily, but you can use any layout you like. Icelink manages these views with an `FMIceLinkCocoaLayoutManager`, which has no Agora equivalent, but similar levels of layout control can be achieved using a `UICollectionView`.

## Additional Features

The demo app contains a few additional features that are simple to replace with Agora equivalents.

For leaving the channel and switching cameras:

```swift
@IBAction func onLeaveButtonClick(_ sender: AnyObject) {
//    _app?.onDisconnect?.invoke(withArg0: "")
    agoraKit?.leaveChannel({ (stats) in
        self.exit()
    })
}

func exit() {
    DispatchQueue.main.async {
//        self._app?.cleanup()
        self.dismiss(animated: false)
    }
}

@objc func handleDoubleTap(gesture: UITapGestureRecognizer) {
//    if(self._app?._isWebcam == true){
//        self._app?.useNextVideoDevice()
//    }
    agoraKit?.switchCamera()
}
```

Finally, the Icelink demo includes options for enabling and disabling video, audio, and recording. Agora does not support recording video locally, but if you want that feature you can view our [cloud recording guide](https://docs.agora.io/en/cloud-recording/cloud_recording_rest?platform=RESTful). Otherwise, the functions are simple to replace:

```swift
func showActionSheet() {
    // 1
    let optionMenu = UIAlertController(
        title: nil, message: "Choose Option",
        preferredStyle: .actionSheet
    )

    // 2

    let audioRecordTitle = !self.recordingAudio ? "Record Audio" : "Stop Audio Recording"
    let recordAudioAction = UIAlertAction(
        title: audioRecordTitle, style: .default
    ) { _ in
//        self._app?._localMedia?.toggleAudioRecording()
        self.recordingAudio.toggle()
        if (self.recordingAudio) {
            self.agoraKit?.startAudioRecording(
                "/var/mobile/Containers/Data/audio.aac",
                sampleRate: 32,
                quality: .high
            )
        } else {
            self.agoraKit?.stopAudioRecording()
        }
    }

    // Agora doesn't support recording video locally.
//    let videoRecordTitle = !self.recordingVideo ? "Record Video" : "Stop Video Recording"
//    let recordVideoAction = UIAlertAction(
//      title: videoRecordTitle, style: .default
//    ) { _ in
//        self._app?._localMedia?.toggleVideoRecording()
//        self.recordingVideo = !self.recordingVideo
//    })

    let disableAudioTitle = !self.audioDisabled ? "Disable Audio" : "Enable Audio"
    let disableAudioAction = UIAlertAction(
        title: disableAudioTitle, style: .default
    ) { _ in
//        self._app?.toggleStreamDisabled(streamType: FMIceLinkStreamType.audio)
        self.audioDisabled.toggle()
        if (self.audioDisabled) {
            self.agoraKit?.disableAudio()
        } else {
            self.agoraKit?.enableAudio()
        }
    }

    let disableVideoTitle = !self.videoDisabled ? "Disable Video" : "Enable Video"
    let disableVideoAction = UIAlertAction(
        title: disableVideoTitle, style: .default
    ) { _ in
//        self._app?.toggleStreamDisabled(streamType: FMIceLinkStreamType.video)
        self.videoDisabled.toggle()
        if (self.videoDisabled) {
            self.agoraKit?.disableVideo()
        } else {
            self.agoraKit?.enableVideo()
        }
    }


    let muteAudioTitle = !self.audioMute ? "Mute Audio" : "Unmute Audio"
    let muteAudioAction = UIAlertAction(
        title: muteAudioTitle, style: .default
    ) { _ in
//        self._app?._localMedia?.setAudioMuted(!(self._app?._localMedia?.audioMuted())!)
        self.audioMute.toggle()
        self.agoraKit?.muteLocalAudioStream(self.audioMute)
    }

    let muteVideoTitle = !self.videoMute ? "Mute Video" : "Unmute Video"
    let muteVideoAction = UIAlertAction(
      title: muteVideoTitle, style: .default
    ) { _ in
//        self._app?._localMedia?.setVideoMuted(!(self._app?._localMedia?.videoMuted())!)
        self.videoMute.toggle()
        self.agoraKit?.muteLocalVideoStream(self.videoMute)
    }

    //
    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)


    // 4
    optionMenu.addAction(recordAudioAction)
//    optionMenu.addAction(recordVideoAction)
    optionMenu.addAction(disableAudioAction)
    optionMenu.addAction(disableVideoAction)
    optionMenu.addAction(muteAudioAction)
    optionMenu.addAction(muteVideoAction)
    optionMenu.addAction(cancelAction)

    // 5
    DispatchQueue.main.async {
        self.present(optionMenu, animated: true, completion: nil)
    }
}
```

## Run

There you go! If you followed the instructions in this guide, you have successfully adopted Agora! Congratulations! Welcome to the benefits of the Agora SD-RTN™!

Although it would be impossible to account for all of the different integrations, you should note that you replaced all of the salient *generic* features of Frozen Mountain with those of Agora in only five steps. Now it should be easy to simulate fully a large-scale adoption with Agora.

## Further Resources

You can find the completed project [here](https://github.com/AgoraIO-Community/frozenmountain-migration-ios). For further reading and details on how to implement more specific features of the Agora engine, you can take a look at our [documentation](https://docs.agora.io/en/Video/product_video?platform=iOS), [join our Slack community](https://bit.ly/39j4I5h), or email us at devrel@agora.io.


