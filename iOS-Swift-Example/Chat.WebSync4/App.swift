//
//  App.swift
//  Chat.WebSync4
//
//  Created by Frozen Mountain Software on 2016-09-13.
//  Copyright © 2016 Frozen Mountain Software. All rights reserved.
//

import Foundation

class App : NSObject {
//    var _localMedia: LocalMedia?
//    var _layoutManager: FMIceLinkCocoaLayoutManager?
    
    //Formerly _sessionId
    var _channelName: String = ""
    var _username: String = ""
    
    var _iceServers: NSMutableArray = []
    var _websyncServerUrl: String = ""
    
//    var onMessageReceived: FMCallback?
//    var onDisconnect: FMCallback?
    
    class Message {
        enum MessageType {
            case ServiceMessage
            case UserMessage
        }
        
        var type: MessageType?
        var data: String?
    }
    
    var _disconnecting = false
    
    // Stream management flags
    var _isAudioSendEnabled = false
    var _isAudioReceiveEnabled = false
    var _isVideoSendEnabled = false
    var _isVideoReceiveEnabled = false
    
    // Video Source
    var _isWebcam = true
    
    
    // This flag determines the signalling mode used.
    // Note that Manual and Auto signalling do not Interop.
//    var _manualSignalling: Bool = false
//    var _signalling: Signalling?
    
    // Connections and Remote medias
    var _connections: NSMutableArray = []
    var _remoteMedias: NSMutableArray = []
    
    
    static let instance = App()
    
//    override init() {
//        super.init()
//
//        FMIceLinkLog.setProvider(FMIceLinkNSLogProvider(logLevel: FMIceLinkLogLevel.debug))
//
//        //NB: url "turn:turn.icelink.fm:443" implies that the relay server supports both TCP and UDP
//        //if you want to restrict the network protocol, use "turn:turn.icelink.fm:443?transport=udp"
//        //or "turn:turn.icelink.fm:443?transport=tcp". For further info, refer to RFC 7065 3.1 URI Scheme Syntax
//        _iceServers = [FMIceLinkIceServer.init(url: "stun:turn.frozenmountain.com:3478"),
//                       FMIceLinkIceServer.init(url: "turn:turn.frozenmountain.com:80", username: "test", password: "pa55w0rd!"),
//                       FMIceLinkIceServer.init(url: "turns:turn.frozenmountain.com:443", username: "test", password: "pa55w0rd!")]
//
//        _websyncServerUrl = "https://v4.websync.fm/websync.ashx"; // WebSync On-Demand
//    }
//
//    func startLocalMedia(container: UIView) -> FMIceLinkFuture {
//        let promise = FMIceLinkPromise()
//
//        if self._isWebcam {
//            self._localMedia = LocalCameraMedia(disableAudio: !self._isAudioSendEnabled, disableVideo: !self._isVideoSendEnabled, aecContext:  nil)
//            if self._localMedia?.videoSource() != nil {
//                let source = self._localMedia?.videoSource() as! FMIceLinkCocoaAVCaptureSource
//                self._localMedia?.changeVideoSourceInput(source.frontInput())
//            }
//        }
//        else {
//            self._localMedia = LocalScreenMedia(disableAudio: !self._isAudioSendEnabled, disableVideo: !self._isVideoSendEnabled, aecContext:  nil)
//        }
//
//        if (self._localMedia!.view() != nil) {
//            (self._localMedia!.view() as! UIView).accessibilityIdentifier = "localView"
//        }
//
//        self._layoutManager = FMIceLinkCocoaLayoutManager(container: container)
//        self._layoutManager!.setLocalView(self._localMedia!.view())
//
//        self._localMedia!.start().then(resolveActionBlock: { (o: Any?) in
//            promise!.resolve(withResult: o as! NSObject)
//        }, rejectActionBlock: { (e: NSException?) in
//            promise!.reject(with: e)
//        })
//
//        return promise!
//    }
//
//    func stopLocalMedia() -> FMIceLinkFuture {
//        let promise = FMIceLinkPromise()
//
//        if (_localMedia != nil) {
//
//            self._localMedia!.stop().then(resolveActionBlock: { [weak self] (o: Any?) in
//                if (self?._layoutManager != nil) {
//                    DispatchQueue.main.async {
//                        self?._layoutManager?.removeRemoteViews()
//                        self?._layoutManager?.unsetLocalView()
//                        self?._layoutManager = nil
//                        if self?._localMedia != nil {
//                            self?._localMedia?.destroy()
//                            self?._localMedia = nil
//                        }
//                        promise?.resolve(withResult: nil)
//                    }
//                }
//                else {
//                    promise?.resolve(withResult: nil)
//                }
//
//                }, rejectActionBlock: { (e: NSException?) in
//                    promise!.reject(with: e)
//            })
//        }
//        return promise!
//    }
//
//    func joinAsync() -> FMIceLinkFuture {
//        if (self._manualSignalling) {
//            self._signalling = self.manualSignalling()
//        }
//        else {
//            self._signalling = self.autoSignalling()
//        }
//
//        return (self._signalling?.joinAsync())!
//    }
//
//    func autoSignalling() -> AutoSignalling
//    {
//        let createConnection = FMIceLinkFunction1.init { (peer) -> FMIceLinkConnection? in
//            return self.connection(peer: peer!)
//        }
//
//        let onReceivedText = FMIceLinkAction2.init { (n, m) -> Void in
//            let msg = Message()
//            let name = n as! String
//            let message = m as! String
//            msg.type = .ServiceMessage
//            msg.data = message
//            self.onMessageReceived?.invoke(withArg0: name, arg1: msg)
//        }
//
//        let a = AutoSignalling(serverUrl: self._websyncServerUrl, name: self._username, sessionId: self._channelName, createConnection: createConnection!, onReceivedText: onReceivedText!)
//        return a
//    }
//
//    func manualSignalling() -> ManualSignalling
//    {
//        let createConnection = FMIceLinkFunction1.init { (peer) -> FMIceLinkConnection? in
//            return self.connection(peer: peer!)
//        }
//
//        let onReceivedText = FMIceLinkAction2.init { (n, m) -> Void in
//            let msg = Message()
//            let name = n as! String
//            let message = m as! String
//            msg.type = .ServiceMessage
//            msg.data = message
//            self.onMessageReceived?.invoke(withArg0: name, arg1: msg)
//        }
//
//        let a = ManualSignalling(serverUrl: self._websyncServerUrl, name: self._username, sessionId: self._channelName, createConnection: createConnection!, onReceivedText: onReceivedText!)
//        return a
//    }
//
//    func connection(peer: Any) -> FMIceLinkConnection
//    {
//        let remoteClient = peer as! FMIceLinkWebSync4PeerClient
//        let remoteMedia = RemoteMedia(disableAudio: false, disableVideo: false, aecContext: nil)
//        if !self._remoteMedias.contains(remoteMedia!) {
//            self._remoteMedias.add(remoteMedia!)
//        }
//
//        let audioStream = FMIceLinkAudioStream(localMedia: self._localMedia, remoteMedia: remoteMedia)
//        audioStream?.setLocalSend(self._isAudioSendEnabled)
//        audioStream?.setLocalReceive(self._isAudioReceiveEnabled)
//
//        let videoStream = FMIceLinkVideoStream(localMedia: self._localMedia, remoteMedia: remoteMedia)
//        videoStream?.setLocalSend(self._isVideoSendEnabled)
//        videoStream?.setLocalReceive(self._isVideoReceiveEnabled)
//
//
//        var clientId = "Unknown"
//        if (remoteClient.boundRecords().getObjectAtKey("userName") != nil) {
//            clientId = (remoteClient.boundRecords().getObjectAtKey("userName") as AnyObject).valueJson()
//        }
//        let connection = FMIceLinkConnection(streams: [audioStream!, videoStream!])
//
//        if !self._connections.contains(connection as Any) {
//            self._connections.add(connection as Any)
//        }
//
//        connection?.setIceServers(self._iceServers)
//
//        connection?.addOnStateChange({ [weak self] (obj: Any!) in
//            let conn = obj as! FMIceLinkConnection
//            if (conn.state() == FMIceLinkConnectionState.connecting)
//            {
//                if (remoteMedia?.view() != nil)
//                {
//                    (remoteMedia!.view() as! UIView).accessibilityIdentifier = "remoteView_" + remoteMedia!.id()
//                    self?._layoutManager?.addRemoteView(withId: remoteMedia?.id(), view: remoteMedia?.view())
//                }
//            }
//            else if (conn.state() == FMIceLinkConnectionState.connected)
//            {
//                let msg = Message()
//                msg.type = .ServiceMessage
//                msg.data = " joined the chat"
//                self?.onMessageReceived?.invoke(withArg0: clientId, arg1: msg)
//            }
//            else if (conn.state() == FMIceLinkConnectionState.closing ||
//                conn.state() == FMIceLinkConnectionState.failing)
//            {
//                self?._layoutManager?.removeRemoteView(withId: remoteMedia?.id())
//                if (self?._remoteMedias.contains(remoteMedia!))! {
//                    self?._remoteMedias.remove(remoteMedia!)
//                }
//                if (self?._connections.contains(conn))! {
//                    self?._connections.remove(conn)
//                }
//
//                // https://forums.developer.apple.com/thread/22133
//                // https://trac.pjsip.org/repos/ticket/1697
//                // Workaround to fix reduced volume issue after the teardown of audio unit.
//                do {
//                    if #available(iOS 10.0, *) {
//                           try AVAudioSession.sharedInstance().setCategory(.record, mode: .default)
//                    } else {
//                        AVAudioSession.sharedInstance().perform(NSSelectorFromString("setCategory:error:"), with: AVAudioSession.Category.record)
//                    }
//                }
//                catch {
//                    FMIceLinkLog.error(withMessage: "Could not set audio session category before destroying remote media.")
//                }
//                remoteMedia?.destroy()
//                do {
//                    if #available(iOS 10.0, *) {
//                        try AVAudioSession.sharedInstance().setCategory(.playAndRecord, mode: .default, options: [.allowBluetooth , (AVAudioSession.CategoryOptions.defaultToSpeaker)])
//                    } else {
//                        AVAudioSession.sharedInstance().perform(NSSelectorFromString("setCategory:withOptions:error:"),with: AVAudioSession.Category.playAndRecord, with: [.allowBluetooth, AVAudioSession.CategoryOptions.defaultToSpeaker])
//                    }
//                }
//                catch {
//                    FMIceLinkLog.error(withMessage: "Could not set audio session category after destroying remote media.")
//                }
//            }
//            else if (conn.state() == FMIceLinkConnectionState.closed) {
//                let msg = Message()
//                msg.type = .ServiceMessage
//                msg.data = " left the chat"
//                self?.onMessageReceived?.invoke(withArg0: clientId, arg1: msg)
//            }
//            else if (conn.state() == FMIceLinkConnectionState.failed)
//            {
//                let msg = Message()
//                msg.type = .ServiceMessage
//                msg.data = " left the chat"
//                self?.onMessageReceived?.invoke(withArg0: clientId, arg1: msg)
//
//                if (!(self?._manualSignalling)!) {
//                    self?._signalling?.reconnectPeer(remoteClient: remoteClient, connection: conn)
//                }
//            }
//        })
//
//        return connection!
//    }
//
//    func leaveAsync() -> FMIceLinkFuture {
//        if (self._signalling != nil)
//        {
//            return (self._signalling?.leaveAsync())!
//        }
//        let promise = FMIceLinkPromise()
//        promise?.resolve(withResult: nil)
//        return promise!
//    }
//
//
//    func useNextVideoDevice() -> Void {
//        if self._localMedia?.videoSource() != nil {
//            let source = self._localMedia?.videoSource() as! FMIceLinkCocoaAVCaptureSource
//            if source.input().id() == source.backInput().id() {
//                self._localMedia?.changeVideoSourceInput(source.frontInput())
//            }
//            else {
//                self._localMedia?.changeVideoSourceInput(source.backInput())
//            }
//        }
//    }
//
//    func send(message: String) {
//        self._signalling?.writeLine(message: message)
//    }
//
//    func pauseAudio() {
//
//    }
//
//    func resumeAudio() {
//
//    }
//
//    func toggleStreamDisabled(streamType: FMIceLinkStreamType) {
//        for conn in _connections {
//            self.toggleDirection(connection: conn as! FMIceLinkConnection, streamType: streamType, isLocal: true);
//
//            if (!self._manualSignalling)
//            {
//                self._signalling?.renegotiateSessionChannelForConnection(connection: conn as! FMIceLinkConnection)
//            }
//            else
//            {
//                FMIceLinkLog.info(withMessage: "Renegotiation not currenctly supported with manual signalling.");
//            }
//        }
//    }
//
//    func toggleDirection(connection: FMIceLinkConnection, streamType: FMIceLinkStreamType, isLocal: Bool) -> Bool {
//        var found = false;
//
//        for strm in connection.streams() {
//            let stream = strm as! FMIceLinkStream
//            if (stream.type() == streamType) {
//                found = true;
//                var newDirection = FMIceLinkStreamDirection.inactive;
//
//                if (stream.localDirection() == FMIceLinkStreamDirection.sendReceive)
//                {
//                    if (isLocal)
//                    {
//                        newDirection = FMIceLinkStreamDirection.receiveOnly;
//                    }
//                    else
//                    {
//                        newDirection = FMIceLinkStreamDirection.sendOnly;
//                    }
//                }
//                else if (stream.localDirection() == FMIceLinkStreamDirection.sendOnly)
//                {
//                    if (isLocal)
//                    {
//                        newDirection = FMIceLinkStreamDirection.inactive;
//                    }
//                    else
//                    {
//                        newDirection = FMIceLinkStreamDirection.sendReceive;
//                    }
//                }
//                else if (stream.localDirection() == FMIceLinkStreamDirection.receiveOnly)
//                {
//                    if (isLocal)
//                    {
//                        newDirection = FMIceLinkStreamDirection.sendReceive;
//                    }
//                    else
//                    {
//                        newDirection = FMIceLinkStreamDirection.inactive;
//                    }
//                }
//                else
//                {
//                    if (isLocal)
//                    {
//                        newDirection = FMIceLinkStreamDirection.sendOnly;
//                    }
//                    else
//                    {
//                        newDirection = FMIceLinkStreamDirection.receiveOnly;
//                    }
//                }
//                let error = stream.changeDirection(withNewDirection: newDirection)
//                if (error != nil)
//                {
//                    return false;
//                }
//            }
//        }
//        if (found)
//        {
//            return true;
//        }
//        else
//        {
//            return false;
//        }
//    }
//
//    func cleanup () {
//
//        if _localMedia != nil {
//            _localMedia?.destroy()
//            _localMedia = nil
//        }
//
//        if (_remoteMedias.count > 0) {
//            for remoteMedia in _remoteMedias {
//                let remote = remoteMedia as! RemoteMedia
//                _layoutManager?.removeRemoteView(withId: remote.id())
//                remote.destroy()
//            }
//            _remoteMedias.removeAllObjects()
//        }
//
//        if _layoutManager != nil {
//            _layoutManager = nil
//        }
//
//        if (_connections.count > 0) {
//            for conn in _connections {
//                let connection = conn as! FMIceLinkConnection
//                connection.close()
//            }
//            _connections.removeAllObjects();
//        }
//
//        _disconnecting = false
//
//        // Stream management flags
//        _isAudioSendEnabled = false
//        _isAudioReceiveEnabled = false
//        _isVideoSendEnabled = false
//        _isVideoReceiveEnabled = false
//
//        _channelName = ""
//        _username = ""
//
//        onMessageReceived = nil
//        onDisconnect = nil
//    }
//
//    deinit {
//
//        _localMedia = nil
//        _layoutManager = nil
//    }
}
