////
////  RemoteMedia.swift
////  Chat.WebSync4
////
////  Created by Frozen Mountain Software on 2016-09-13.
////  Copyright © 2016 Frozen Mountain Software. All rights reserved.
////
//
//import Foundation
//
//class RemoteMedia : FMIceLinkRtcRemoteMedia {
//    var recordingPath: String = ""
//
//    override init!(disableAudio: Bool, disableVideo: Bool, aecContext: FMIceLinkAecContext?) {
//        super.init(disableAudio: disableAudio, disableVideo: disableVideo, aecContext: aecContext)
//
//        recordingPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
//
//        self.initialize()
//    }
//
//    override func createAudioSink(with config: FMIceLinkAudioConfig) -> FMIceLinkAudioSink? {
//        do {
//            if #available(iOS 10.0, *) {
//                try AVAudioSession.sharedInstance().setCategory(.playAndRecord, mode: .default, options: [.allowBluetooth , (AVAudioSession.CategoryOptions.defaultToSpeaker)])
//            } else {
//                AVAudioSession.sharedInstance().perform(NSSelectorFromString("setCategory:withOptions:error:"),with: AVAudioSession.Category.playAndRecord, with: [.allowBluetooth, AVAudioSession.CategoryOptions.defaultToSpeaker])
//            }
//
//        }
//        catch {
//            FMIceLinkLog.warn(withMessage: "Could not set audio session category for remote media.")
//            return nil;
//        }
//
//        do {
//            try AVAudioSession.sharedInstance().setActive(true);
//        }
//        catch {
//            FMIceLinkLog.warn(withMessage: "Could not activate audio session for remote media.")
//            return nil;
//        }
//
//        return FMIceLinkCocoaAudioUnitSink(config: config)
//    }
//
//    override func createViewSink() -> FMIceLinkViewSink {
//        return FMIceLinkCocoaOpenGLSink(viewScale: FMIceLinkLayoutScale.contain)
//    }
//
//    override func createImageConverter(withOutputFormat outputFormat: FMIceLinkVideoFormat) -> FMIceLinkVideoPipe {
//        return FMIceLinkYuvImageConverter(outputFormat: outputFormat)
//    }
//
//    func createImageScaler() -> FMIceLinkVideoPipe! {
//        return FMIceLinkYuvImageScaler(scale: 1.0)
//    }
//
//    override func createVp8Decoder() -> FMIceLinkVideoDecoder! {
//        return FMIceLinkVp8Decoder()
//    }
//
//    override func createVp9Decoder() -> FMIceLinkVideoDecoder! {
//        return FMIceLinkVp9Decoder()
//    }
//
//    override func createH264Decoder() -> FMIceLinkVideoDecoder! {
//        return FMIceLinkCocoaVideoToolboxH264Decoder()
//    }
//
//    override func createOpusDecoder(with config: FMIceLinkAudioConfig!) -> FMIceLinkAudioDecoder! {
//        return FMIceLinkOpusDecoder(config: config)
//    }
//
//    override func createPcmaDecoder(with config: FMIceLinkAudioConfig!) -> FMIceLinkAudioDecoder! {
//        return FMIceLinkPcmaDecoder(config: config)
//    }
//
//    override func createPcmuDecoder(with config: FMIceLinkAudioConfig!) -> FMIceLinkAudioDecoder! {
//        return FMIceLinkPcmuDecoder(config: config)
//    }
//
//    override func createAudioRecorder(withInputFormat inputFormat: FMIceLinkAudioFormat!) -> FMIceLinkAudioSink! {
//        return FMIceLinkMatroskaAudioSink(path: "remote-audio-\(String(describing: inputFormat.name())).mkv")
//    }
//
//    override func createVideoRecorder(withInputFormat inputFormat: FMIceLinkVideoFormat!) -> FMIceLinkVideoSink! {
//        return FMIceLinkMatroskaVideoSink(path: "remote-video-\(String(describing: inputFormat.name())).mkv")
//    }
//
//}
