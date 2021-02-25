//
//  VideoCallViewController.swift
//  Chat.WebSync4
//
//  Created by Frozen Mountain Software on 2016-09-21.
//  Copyright © 2016 Frozen Mountain Software. All rights reserved.
//

import UIKit
import AgoraRtcKit

class VideoCallViewController: UIViewController {

    // UIAlertController outlets
    @IBOutlet var _username: UITextField!
    @IBOutlet var _sessionId: UITextField!
    @IBOutlet weak var _leaveButton: UIButton!
    @IBOutlet weak var _sessionIdLabel: UILabel!
    
    // VideoCallViewController outlets
    @IBOutlet weak var _videoView: UIView!
    @IBOutlet weak var remoteStackView: UIStackView!
    
    // Application class
    var _app: App?
    var agoraKit: AgoraRtcEngineKit?
    var appID = ""
    
    // Locals
    var recordingAudio = false
    var recordingVideo = false
    var audioDisabled = false
    var videoDisabled = false
    var audioMute = false
    var videoMute = false
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(VideoCallViewController.handleDoubleTap(gesture:)))
        gesture.numberOfTapsRequired = 2
        self.view.addGestureRecognizer(gesture)
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(VideoCallViewController.handleLongPress(sender:)))
        longPress.minimumPressDuration = 0.7
        longPress.allowableMovement = 70
        self.view.addGestureRecognizer(longPress)
        
        DispatchQueue.main.async {
            let toastLabel = UILabel(frame: CGRect.init(origin: CGPoint.init(x: self.view.frame.size.width/2 - 150, y: self.view.frame.size.height-150), size: CGSize.init(width: 300, height: 70)))//CGRectMake(self.view.frame.size.width/2 - 150, self.view.frame.size.height-150, 300, 70))
            toastLabel.backgroundColor = UIColor.black
            toastLabel.textColor = UIColor.white
            toastLabel.textAlignment = NSTextAlignment.center;
            toastLabel.numberOfLines = 0
            self.view.addSubview(toastLabel)
            toastLabel.text = "Double-tap to switch camera. \n Long press for options."
            toastLabel.alpha = 1.0
            toastLabel.layer.cornerRadius = 10;
            toastLabel.clipsToBounds  =  true
            UIView.animate(withDuration: 4, delay: 0.1, options: .curveEaseOut) {
                toastLabel.alpha = .zero
            }
        }
        
//        _app?.onMessageReceived = FMCallback(doubleAction: self.displayMessage)
    }
    
    func exit() {
        DispatchQueue.main.async {
//            self._app?.cleanup()
            self.dismiss(animated: false)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        #if compiler(>=5.1)
        if #available(iOS 13.0, *) {
            // Always adopt a light interface style.
            overrideUserInterfaceStyle = .light
        }
        #endif
        
        agoraKit = AgoraRtcEngineKit.sharedEngine(withAppId: appID, delegate: self)
        _app = App.instance
//        _app!.onDisconnect = FMCallback(singleAction: { (errorDescription: Any?) in
//            if !(self._app?._disconnecting)! {
//                var exceptionLogMessage = "Could not stop local media"
//                self._app?._disconnecting = true
//                let errorDesc = errorDescription as! String
//                if !errorDesc.isEmpty {
//                    self.alert(format: "%@", args: [errorDesc])
//                }
//                else {
//                    exceptionLogMessage = "Failed to stop local media"
//                    self._app?.leaveAsync().fail(rejectActionBlock: { [weak self] (e: NSException?) in
//                            self?.alert(format: "%@", args: [(e?.message())!])
//                            FMIceLinkLog.error(withMessage: "Failed to leave.", ex: e)
//                            self?._app?._disconnecting = false
//                    })
//                }
//                self._app?.stopLocalMedia().then(resolveActionBlock: { [weak self] (o: Any?) in
//                    self?.exit()
//                })?.fail(rejectActionBlock: { [weak self] (e: NSException?) in
//                    self?.alert(format: "%@", args: [(e?.message())!])
//                    FMIceLinkLog.error(withMessage: exceptionLogMessage, ex: e)
//                    self?.exit()
//                })
//            }
//        })
        
        self.startSession()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func handleLongPress(sender: UILongPressGestureRecognizer) {
        if (sender.state == UIGestureRecognizer.State.ended) {
            //Do Whatever You want on End of Gesture
        }
        else if (sender.state == UIGestureRecognizer.State.began){
            //Do Whatever You want on Began of Gesture
            self.showActionSheet()
        }
    }
    
    func startSession() {
        // Show hidden graphic elements
        _leaveButton.isHidden = false
        _sessionIdLabel.isHidden = false
        
        _sessionIdLabel.text = _sessionIdLabel.text! + (_app?._channelName)!
        
        agoraKit?.enableVideo()
        
        let videoCanvas = AgoraRtcVideoCanvas()
        videoCanvas.uid = 0
        videoCanvas.view = _videoView
        videoCanvas.renderMode = .hidden
        agoraKit?.setupLocalVideo(videoCanvas)
        
        agoraKit?.joinChannel(
            byToken: nil, channelId: (_app?._channelName)!, info:nil, uid:0
        ) { (sid, uid, elapsed) in
            print("successfully joined channel")
        }

//        // Start session
//        _app?.startLocalMedia(container: _videoView).then(resolveFunctionBlock: { [weak self] (o: Any!) -> FMIceLinkFuture? in
//            return (self?._app?.joinAsync())!
//            }, rejectActionBlock: { [weak self] (e: NSException?) in
//                self?.alert(format: "%@", args: [(e?.message())!])
//                FMIceLinkLog.error(withMessage: "Could not start local media. %@", ex:e)
//        }).fail(rejectActionBlock: { [weak self] (e: NSException?) in
//            self?.alert(format: "%@", args: [(e?.message())!])
//            FMIceLinkLog.error(withMessage: "Could not join conference. %@", ex:e)
//        })
    }

    @IBAction func onLeaveButtonClick(_ sender: AnyObject) {
//        _app?.onDisconnect?.invoke(withArg0: "")
        agoraKit?.leaveChannel({ (stats) in
            self.exit()
        })
    }
    
    @objc func handleDoubleTap(gesture: UITapGestureRecognizer) {
//        if(self._app?._isWebcam == true){
//            self._app?.useNextVideoDevice()
//        }
        agoraKit?.switchCamera()
    }
    
    func alert(format: String, args: [CVarArg]) {
        let alert = UIAlertController(title: "Alert", message: String(format: format, arguments: args), preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            DispatchQueue.main.async{
            }
        })
        
        alert.addAction(okAction)
        
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func displayMessage(clientId: Any?, message: Any?) {
        DispatchQueue.main.async {
            let msg = message as! App.Message
            let textVC = self.tabBarController!.viewControllers![1] as! TextChatViewController
        
            if msg.type == .UserMessage {
                textVC.newMessages.add(String(format: "%@: %@", arguments: [clientId as! String, msg.data!]))
                textVC._numberOfUnreadMessages = textVC._numberOfUnreadMessages + 1
                (self.tabBarController?.tabBar.items![1])!.badgeValue = String(textVC._numberOfUnreadMessages)
            }
            else if msg.type == .ServiceMessage {
                // Notification not raised for service messages
                textVC.newMessages.add(String(format: "%@ %@", arguments: [clientId as! String, msg.data!]))
            }
            else {
                NSLog("%@: type: %@, data: %@", "Unknown message received", msg.type.debugDescription, msg.data!)
            }
        }
    }
    
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

//         Agora doesn't support recording video locally.
//        let videoRecordTitle = !self.recordingVideo ? "Record Video" : "Stop Video Recording"
//        let recordVideoAction = UIAlertAction(
//          title: videoRecordTitle, style: .default
//        ) { _ in
//            self._app?._localMedia?.toggleVideoRecording()
//            self.recordingVideo = !self.recordingVideo
//        })

        let disableAudioTitle = !self.audioDisabled ? "Disable Audio" : "Enable Audio"
        let disableAudioAction = UIAlertAction(
            title: disableAudioTitle, style: .default
        ) { _ in
//            self._app?.toggleStreamDisabled(streamType: FMIceLinkStreamType.audio)
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
//            self._app?.toggleStreamDisabled(streamType: FMIceLinkStreamType.video)
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
//            self._app?._localMedia?.setAudioMuted(!(self._app?._localMedia?.audioMuted())!)
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
//        optionMenu.addAction(recordVideoAction)
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

}

extension VideoCallViewController: AgoraRtcEngineDelegate {
    func rtcEngine(_ engine: AgoraRtcEngineKit, didJoinedOfUid uid: UInt, elapsed: Int) {
        let videoView = UIView()
        videoView.tag = Int(uid)
        videoView.backgroundColor = UIColor.purple
        let videoCanvas = AgoraRtcVideoCanvas()
        videoCanvas.uid = uid
        videoCanvas.view = videoView
        videoCanvas.renderMode = .hidden
        agoraKit?.setupRemoteVideo(videoCanvas)
        remoteStackView.addArrangedSubview(videoView)
    }

    internal func rtcEngine(_ engine: AgoraRtcEngineKit, didOfflineOfUid uid:UInt, reason:AgoraUserOfflineReason) {
        if let view = remoteStackView.arrangedSubviews.first(
                where: { view in view.tag == Int(uid) }
        ) {
            remoteStackView.removeArrangedSubview(view)
        }
    }
}
