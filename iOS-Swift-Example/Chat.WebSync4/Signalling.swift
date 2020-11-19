////
////  Signalling.swift
////  Chat.WebSync4
////
////  Copyright © 2017 Frozen Mountain Software. All rights reserved.
////
//
//import Foundation
//
//class Signalling: NSObject {
//    var sessionId: String = ""
//    var websyncServerUrl: String = ""
//    var name: String = ""
//    var userId: String = ""
//    var sessionChannel: String = ""
//    var metadataChannel: String = ""
//    var userIdKey: String = "userId"
//    var userNameKey: String = "userName"
//    var textMessageKey: String = "textMsg"
//    var createConnection: FMIceLinkFunction1?
//    var onReceivedText: FMIceLinkAction2?
//    var client: FMWebSyncClient?
//    var connections: FMIceLinkConnectionCollection?
//    
//    init(serverUrl: String, name: String, sessionId: String, createConnection: FMIceLinkFunction1, onReceivedText: FMIceLinkAction2) {
//        super.init()
//        
//        self.websyncServerUrl = serverUrl
//        self.sessionId = sessionId
//        self.name = name
//        self.createConnection = createConnection
//        self.userId = UUID().uuidString
//        self.onReceivedText = onReceivedText
//        
//        self.defineChannels()
//    }
//    
//    func defineChannels() {
//        fatalError("This method must be overridden")
//    }
//    
//    func closeAllConnections() {
//        for conn in (self.connections?.values())! {
//            let connection = conn as! FMIceLinkConnection
//            connection.close()
//         }
//        self.connections?.removeAll();
//    }
//    
//    func bindUserMetadata(k: String, v: String) -> FMIceLinkFuture {
//        let promise = FMIceLinkPromise()
//        
//        let bindArgs = FMWebSyncBindArgs(record: FMWebSyncRecord(key: k, valueJson: FMIceLinkJsonSerializer.serializeString(v)))
//        bindArgs?.setOnSuccessBlock { (args:FMWebSyncBindSuccessArgs?) in
//            promise?.resolve(withResult: nil)
//        }
//        bindArgs?.setOnFailureBlock { (args:FMWebSyncBindFailureArgs?) in
//            promise?.reject(with: args?.exception())
//        }
//        
//        self.client!.bind(with: bindArgs)
//        
//        return promise!
//    }
//    
//    func unbindUserMetadata(k: String) -> FMIceLinkFuture {
//        let promise = FMIceLinkPromise()
//        
//        let unbindArgs = FMWebSyncUnbindArgs(record: FMWebSyncRecord(key: k))
//        
//        unbindArgs!.setOnSuccessBlock { (args: FMWebSyncUnbindSuccessArgs?) in
//            promise?.resolve(withResult: nil)
//        }
//        unbindArgs!.setOnFailureBlock { (args: FMWebSyncUnbindFailureArgs?) in
//            promise?.reject(with: args?.exception())
//        }
//        
//        self.client!.unbind(with: unbindArgs)
//        
//        return promise!
//    }
//    
//    func unsubscribeFromChannel(channel: String) -> FMIceLinkFuture {
//        let promise = FMIceLinkPromise()
//        
//        let unsubscribeArgs = FMWebSyncUnsubscribeArgs()
//        unsubscribeArgs!.setChannel(channel)
//        unsubscribeArgs!.setOnSuccessBlock { (args: FMWebSyncUnsubscribeSuccessArgs?) in
//            promise?.resolve(withResult: nil)
//        }
//        unsubscribeArgs!.setOnFailureBlock { (args: FMWebSyncUnsubscribeFailureArgs?) in
//            promise?.reject(with: args?.exception())
//        }
//        
//        self.client?.unsubscribe(with: unsubscribeArgs)
//        
//        return promise!
//    }
//    
//    func joinAsync() -> FMIceLinkFuture {
//        let promise = FMIceLinkPromise()
//        
//        /*
//            Used to override the client's default backoff.
//            By default the backoff doubles after each failure.
//            For example purposes that gets too long.
//            Add a comment to this line
//         */
//        let retryBackoff = FMCallback.init { () -> Int in
//            return 1000 // milliseconds
//        }
//        
//        self.connections = FMIceLinkConnectionCollection()
//        self.client = FMWebSyncClient(requestUrl: websyncServerUrl)
//        
//        let args = FMWebSyncConnectArgs()
//        args?.setOnSuccessBlock { (args:FMWebSyncConnectSuccessArgs?) in
//            self.subscribeToMetadataChannel()
//                .then(resolveActionBlock: { (o: Any?) in
//                    self.doJoinAsync(with: promise!)
//                })
//        }
//        args?.setOnFailureBlock { (args:FMWebSyncConnectFailureArgs?) in
//            if (promise?.state() == FMIceLinkFutureState.pending) {
//                promise?.reject(with: args?.exception())
//            }
//        }
//        
//        // Called after OnFailure
//        args?.setRetryBackoff(retryBackoff)
//        
//        self.client!.connect(with: args)
//        
//        return promise!
//    }
//    
//    func leaveAsync() -> FMIceLinkFuture {
//        let promise = FMIceLinkPromise()
//        
//        self.closeAllConnections()
//        
//        let disconnectArgs = FMWebSyncDisconnectArgs()
//        disconnectArgs?.setOnComplete({ (completeArgs: FMWebSyncDisconnectCompleteArgs?) in
//            promise!.resolve(withResult: completeArgs)
//        })
//        
//        self.client?.disconnect(with: disconnectArgs)
//        
//        return promise!
//    }
//    
//    func subscribeToMetadataChannel() -> FMIceLinkFuture {
//        let promise = FMIceLinkPromise()
//        let subscribeArgs = FMWebSyncSubscribeArgs()
//        subscribeArgs!.setChannel(self.metadataChannel)
//        subscribeArgs!.setOnSuccessBlock { (subscribeSuccessArgs: FMWebSyncSubscribeSuccessArgs?) in
//            promise?.resolve(withResult: nil)
//        }
//        subscribeArgs!.setOnFailureBlock { (subscribeFailureArgs: FMWebSyncSubscribeFailureArgs?) in
//            promise?.reject(with: subscribeFailureArgs?.exception())
//        }
//        subscribeArgs!.setOnReceive { (subscribeReceiveArgs: FMWebSyncSubscribeReceiveArgs?) in
//            if (!(subscribeReceiveArgs?.wasSentByMe())!)
//            {
//                let jsonString = subscribeReceiveArgs?.dataJson()!
//                if let data = jsonString?.data(using: .utf8) {
//                    do {
//                        var jsonObj = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
//                        let n = jsonObj?.removeValue(forKey: self.userNameKey) as! String
//                        let m = jsonObj?.removeValue(forKey: self.textMessageKey) as! String
//                        self.onReceivedText?.invoke(withP1: n, p2: m)
//                    } catch {
//                        FMIceLinkLog.error(withMessage: "Could not parse text message", ex: error as? NSException)
//                    }
//                }
//                
//            }
//        }
//        
//        self.client?.subscribe(with: subscribeArgs)
//        
//        return promise!
//    }
//    
//    func writeLine(message: String) {
//        let m = [self.userNameKey: self.name, self.textMessageKey: message]
//        let jsonData = try! JSONSerialization.data(withJSONObject: m, options: [])
//        let jsonString = NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue)! as String
//        let publishArgs = FMWebSyncPublishArgs()
//        publishArgs!.setChannel(self.metadataChannel)
//        publishArgs!.setDataJson(jsonString)
//        self.client!.publish(with: publishArgs)
//    }
//    
//    func doJoinAsync(with promise: FMIceLinkPromise) {
//        fatalError("This method must be overridden")
//    }
//    
//    func reconnectPeer(remoteClient: FMIceLinkWebSync4PeerClient, connection: FMIceLinkConnection) {
//        fatalError("This method must be overridden")
//    }
//    
//    func renegotiateSessionChannelForConnection(connection: FMIceLinkConnection) {
//        fatalError("This method must be overridden")
//    }
//}
//
//class AutoSignalling: Signalling {
//    
//    override init(serverUrl: String, name: String, sessionId: String, createConnection: FMIceLinkFunction1, onReceivedText: FMIceLinkAction2) {
//        super.init(serverUrl: serverUrl, name: name, sessionId: sessionId, createConnection: createConnection, onReceivedText: onReceivedText)
//    }
//    
//    override func defineChannels() {
//        self.sessionChannel = "/\(self.sessionId)"
//        self.metadataChannel = "\(self.sessionChannel)/metadata"
//    }
//    
//    override func doJoinAsync(with promise: FMIceLinkPromise) {
//        
//        let rejectOnFail = FMIceLinkAction1.init { (e) -> Void in
//            if (promise.state() == FMIceLinkFutureState.pending) {
//                let ex = e as! NSException
//                promise.reject(with: ex)
//            }
//        }
//        
//        self.connections = FMIceLinkConnectionCollection()
//        self.bindUserMetadata(k: self.userIdKey, v: self.userId)
//            .then(resolveFunctionBlock: { (o: Any?) in
//                return self.bindUserMetadata(k: self.userNameKey, v: self.name)
//            })
//            .then(resolveFunctionBlock: { (o: Any?) in
//                return self.subscribeToSessionChannel()
//            })
//            .then(resolveActionBlock: { (o: Any?) in
//                if (promise.state() == FMIceLinkFutureState.pending) {
//                    promise.resolve(withResult: nil)
//                }
//            })
//            .fail { (e: NSException?) in
//                rejectOnFail?.invoke(withP: e)
//        }
//    }
//    
//    func subscribeToSessionChannel() -> FMIceLinkFuture {
//        let promise = FMIceLinkPromise()
//        let conferenceArgs = FMIceLinkWebSync4JoinConferenceArgs(conferenceChannel: self.sessionChannel)
//        conferenceArgs!.setOnSuccessBlock { (args: FMIceLinkWebSync4JoinConferenceSuccessArgs?) in
//            promise?.resolve(withResult: nil)
//        }
//        conferenceArgs!.setOnFailureBlock { (args: FMIceLinkWebSync4JoinConferenceFailureArgs?) in
//            promise?.reject(with: args?.exception())
//        }
//        conferenceArgs!.setOnRemoteClientBlock { [weak self] (peer: FMIceLinkWebSync4PeerClient?) -> FMIceLinkConnection? in
//            let connection = (self?.createConnection!.invoke(withP: peer) as! FMIceLinkConnection)
//            self?.connections?.add(connection)
//            return connection
//        }
//        
//        self.client!.joinConference(with: conferenceArgs)
//        
//        return promise!
//    }
//    
//    override func reconnectPeer(remoteClient: FMIceLinkWebSync4PeerClient, connection: FMIceLinkConnection) {
//        self.client!.reconnectRemoteClient(remoteClient, failedConnection: connection)
//    }
//    
//    override func renegotiateSessionChannelForConnection(connection: FMIceLinkConnection) {
//        FMWebSyncClient.renegotiate(with: self.client, conferenceChannel: self.sessionChannel, connection: connection)
//    }
//}
//
//class ManualSignalling: Signalling {
//    
//    var offerTag: String = "offer"
//    var answerTag: String = "answer"
//    var candidateTag: String = "candidate"
//    var userChannel: String = ""
//    
//    func remoteUserChannel(remoteUserId: String) -> String {
//        return "/user/\(remoteUserId)"
//    }
//    
//    override init(serverUrl: String, name: String, sessionId: String, createConnection: FMIceLinkFunction1, onReceivedText: FMIceLinkAction2) {
//        super.init(serverUrl: serverUrl, name: name, sessionId: sessionId, createConnection: createConnection, onReceivedText: onReceivedText)
//    }
//    
//    override func defineChannels() {
//        self.userChannel = "/user/\(self.userId)"
//        self.sessionChannel = "/manual-signalling/\(self.sessionId)"
//        self.metadataChannel = "\(self.sessionChannel)/metadata"
//    }
//    
//    override func doJoinAsync(with promise: FMIceLinkPromise) {
//        
//        let rejectOnFail = FMIceLinkAction1.init { (e) -> Void in
//            if (promise.state() == FMIceLinkFutureState.pending) {
//                let ex = e as! NSException
//                promise.reject(with: ex)
//            }
//        }
//        
//        self.connections = FMIceLinkConnectionCollection()
//        self.bindUserMetadata(k: self.userIdKey, v: self.userId)
//            .then(resolveFunctionBlock: { (o: Any?) in
//                return self.bindUserMetadata(k: self.userNameKey, v: self.name)
//            })
//            .then(resolveFunctionBlock: { (o: Any?) in
//                return self.subscribeToUserChannel()
//            })
//            .then(resolveFunctionBlock: { (o: Any?) in
//                return self.subscribeToSessionChannel()
//            })
//            .then(resolveActionBlock: { (o: Any?) in
//                if (promise.state() == FMIceLinkFutureState.pending) {
//                    promise.resolve(withResult: nil)
//                }
//            })
//            .fail { (e: NSException?) in
//                rejectOnFail?.invoke(withP: e)
//        }
//    }
//    
//    func subscribeToUserChannel() -> FMIceLinkFuture {
//        let promise = FMIceLinkPromise()
//        let subscribeArgs = FMWebSyncSubscribeArgs()
//        subscribeArgs!.setChannel(self.userChannel)
//        subscribeArgs!.setOnSuccessBlock { (subscribeSuccessArgs: FMWebSyncSubscribeSuccessArgs?) in
//            promise?.resolve(withResult: nil)
//        }
//        subscribeArgs!.setOnFailureBlock { (subscribeFailureArgs: FMWebSyncSubscribeFailureArgs?) in
//            promise?.reject(with: subscribeFailureArgs?.exception())
//        }
//        subscribeArgs!.setOnReceive { (subscribeReceiveArgs: FMWebSyncSubscribeReceiveArgs?) in
//            let remoteClientId: String = (subscribeReceiveArgs?.client().clientId().toString())!
//            let remoteUserId: String = FMIceLinkSerializer.deserializeString(withValueJson: subscribeReceiveArgs?.publishingClient().getBoundRecordValueJson(withKey: self.userIdKey))
//            var conn: FMIceLinkConnection? = self.connections?.getByExternalId(remoteClientId)
//            
//            if (subscribeReceiveArgs?.tag() == self.candidateTag) {
//                if (conn == nil) {
//                    let peer = FMIceLinkWebSync4PeerClient()
//                    peer.setInstanceId(subscribeReceiveArgs?.publishingClient().clientId().toString())
//                    peer.setBoundRecords(subscribeReceiveArgs?.publishingClient().boundRecords())
//                    conn = self.createConnectionAndWireOnLocalCandidate(remoteClient: peer, remoteUserId: remoteUserId)
//                    conn?.setExternalId(remoteClientId)
//                    self.connections?.add(conn)
//                }
//                
//                FMIceLinkLog.info(withMessage: "Received candidate from remote peer.")
//                
//                conn?.addRemoteCandidate(FMIceLinkCandidate.fromJson(withCandidateJson: subscribeReceiveArgs?.dataJson()))
//                    .fail(rejectActionBlock: { (e: NSException?) in
//                        FMIceLinkLog.error(withMessage: "Received candidate from remote peer.", ex: e)
//                    })
//            }
//            else if (subscribeReceiveArgs?.tag() == self.offerTag) {
//                
//                FMIceLinkLog.info(withMessage: "Received offer from remote peer.")
//                
//                if (conn == nil) {
//                    
//                    let peer = FMIceLinkWebSync4PeerClient()
//                    peer.setInstanceId(subscribeReceiveArgs?.publishingClient().clientId().toString())
//                    peer.setBoundRecords(subscribeReceiveArgs?.publishingClient().boundRecords())
//                    conn = self.createConnectionAndWireOnLocalCandidate(remoteClient: peer, remoteUserId: remoteUserId)
//                    conn?.setExternalId(remoteClientId)
//                    self.connections?.add(conn)
//                    
//                    conn?.setRemoteDescription(FMIceLinkSessionDescription.fromJson(withSessionDescriptionJson: subscribeReceiveArgs?.dataJson()))
//                        .then(resolveFunctionBlock: { (o: Any?) in
//                            return conn?.createAnswer()
//                        })
//                        .then(resolveFunctionBlock: { (o: Any?) in
//                            return conn?.setLocalDescription(o as? FMIceLinkSessionDescription)
//                        })
//                        .then(resolveActionBlock: { (answer: Any?) in
//                            let a = answer as! FMIceLinkSessionDescription
//                            let publishArgs = FMWebSyncPublishArgs()
//                            publishArgs?.setChannel(self.remoteUserChannel(remoteUserId: remoteUserId))
//                            publishArgs?.setDataJson(a.toJson())
//                            publishArgs?.setTag(self.answerTag)
//                            publishArgs!.setOnSuccessBlock { (args: FMWebSyncPublishSuccessArgs?) in
//                                promise?.resolve(withResult: nil)
//                                FMIceLinkLog.info(withMessage: "Published answer to remote peer.")
//                            }
//                            publishArgs!.setOnFailureBlock { (args: FMWebSyncPublishFailureArgs?) in
//                                promise?.reject(with: args?.exception())
//                                FMIceLinkLog.error(withMessage: "Could not publish answer to remote peer.", ex: args?.exception())
//                            }
//                            
//                            self.client?.publish(with: publishArgs)
//                        })
//                        .fail(rejectActionBlock: { (e: NSException?) in
//                            FMIceLinkLog.error(withMessage: "Could not process offer from remote peer.", ex: e)
//                        })
//                }
//            }
//            else if (subscribeReceiveArgs?.tag() == self.answerTag) {
//                if (conn != nil) {
//                    FMIceLinkLog.info(withMessage: "Received answer from remote peer")
//                    conn?.setRemoteDescription(FMIceLinkSessionDescription.fromJson(withSessionDescriptionJson: subscribeReceiveArgs?.dataJson()))
//                        .fail(rejectActionBlock: { (e: NSException?) in
//                            FMIceLinkLog.error(withMessage: "Could not process answer from remote peer.", ex: e)
//                        })
//                }
//                else {
//                    FMIceLinkLog.error(withMessage: "Received answer, but connection does not exist!")
//                }
//            }
//            
//        }
//        
//        self.client?.subscribe(with: subscribeArgs)
//        
//        return promise!
//    }
//    
//    func subscribeToSessionChannel() -> FMIceLinkFuture {
//        let promise = FMIceLinkPromise()
//        let subscribeArgs = FMWebSyncSubscribeArgs()
//        subscribeArgs!.setChannel(self.sessionChannel)
//        subscribeArgs!.setOnSuccessBlock { (subscribeSuccessArgs: FMWebSyncSubscribeSuccessArgs?) in
//            promise?.resolve(withResult: nil)
//        }
//        subscribeArgs!.setOnFailureBlock { (subscribeFailureArgs: FMWebSyncSubscribeFailureArgs?) in
//            promise?.reject(with: subscribeFailureArgs?.exception())
//        }
//        subscribeArgs!.setOnClientSubscribeBlock { (clientSubscribeArgs: FMWebSyncSubscribersClientSubscribeArgs?) in
//            let remoteClientId: String = (clientSubscribeArgs?.client().clientId().toString())!
//            let remoteUserId: String = FMIceLinkSerializer.deserializeString(withValueJson: clientSubscribeArgs?.subscribedClient().getBoundRecordValueJson(withKey: self.userIdKey))
//            let peer = FMIceLinkWebSync4PeerClient()
//            peer.setInstanceId(clientSubscribeArgs?.subscribedClient().clientId().toString())
//            peer.setBoundRecords(clientSubscribeArgs?.subscribedClient().boundRecords())
//            let conn = self.createConnectionAndWireOnLocalCandidate(remoteClient: peer, remoteUserId: remoteUserId)
//            conn.setExternalId(remoteClientId)
//            self.connections?.add(conn)
//            
//            conn.createOffer().then(resolveFunctionBlock: { (offer: Any?) in
//                return conn.setLocalDescription(offer as? FMIceLinkSessionDescription)
//            })
//                .then(resolveActionBlock: { (o: Any?) in
//                    let offer = o as! FMIceLinkSessionDescription
//                    let publishArgs = FMWebSyncPublishArgs()
//                    
//                    publishArgs?.setChannel(self.remoteUserChannel(remoteUserId: remoteUserId))
//                    publishArgs?.setDataJson(offer.toJson())
//                    publishArgs?.setTag(self.offerTag)
//                    publishArgs!.setOnSuccessBlock { (args: FMWebSyncPublishSuccessArgs?) in
//                        FMIceLinkLog.info(withMessage: "Published offer to remote peer.")
//                    }
//                    publishArgs!.setOnFailureBlock { (args: FMWebSyncPublishFailureArgs?) in
//                        FMIceLinkLog.error(withMessage: "Could not publish offer to remote peer.", ex: args?.exception())
//                    }
//                    
//                    self.client?.publish(with: publishArgs)
//                })
//        }
//        subscribeArgs!.setOnClientUnsubscribeBlock { (clientUnsubscribeArgs: FMWebSyncSubscribersClientUnsubscribeArgs?) in
//            let remoteClientId: String = (clientUnsubscribeArgs?.client().clientId().toString())!
//            
//            let conn = self.connections?.getById(remoteClientId)
//            if (conn != nil) {
//                self.connections?.remove(conn)
//                conn?.close()
//            }
//        }
//        
//        self.client?.subscribe(with: subscribeArgs)
//        
//        return promise!
//    }
//    
//    func createConnectionAndWireOnLocalCandidate(remoteClient: FMIceLinkWebSync4PeerClient, remoteUserId: String) -> FMIceLinkConnection {
//        let conn = (self.createConnection!.invoke(withP: remoteClient) as! FMIceLinkConnection)
//        
//        conn.addOnLocalCandidate({ (conn, candidate) in
//            let publishArgs = FMWebSyncPublishArgs()
//            
//            publishArgs?.setChannel(self.remoteUserChannel(remoteUserId: remoteUserId))
//            publishArgs?.setDataJson(candidate?.toJson())
//            publishArgs?.setTag(self.candidateTag)
//            publishArgs!.setOnSuccessBlock { (args: FMWebSyncPublishSuccessArgs?) in
//                FMIceLinkLog.info(withMessage: "Published candidate to remote peer.")
//            }
//            publishArgs!.setOnFailureBlock { (args: FMWebSyncPublishFailureArgs?) in
//                FMIceLinkLog.error(withMessage: "Could not publish candidate to remote peer.", ex: args?.exception())
//            }
//            
//            self.client?.publish(with: publishArgs)
//        })
//        
//        return conn
//    }
//}
