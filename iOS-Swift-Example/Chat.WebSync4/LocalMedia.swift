////
////  LocalMedia.swift
////  Chat.WebSync4
////
////  Created by Frozen Mountain Software on 2016-09-12.
////  Copyright © 2016 Frozen Mountain Software. All rights reserved.
////
//
//import Foundation
//
//class LocalCameraMedia : LocalMedia {
//    var preview: FMIceLinkCocoaAVCapturePreview?
//    
//    override init!(disableAudio: Bool, disableVideo: Bool, aecContext: FMIceLinkAecContext?) {
//        super.init(disableAudio: disableAudio, disableVideo: disableVideo, aecContext: aecContext)
//        
//        self.preview = FMIceLinkCocoaAVCapturePreview()
//        
//        // default
//        self.videoConfig = FMIceLinkVideoConfig(width: 640, height: 480, frameRate: 30)
//        
//        // Alternatively, you can use AVCaptureSession Presets for VideoConfig
//        //self.videoConfig = FMIceLinkVideoConfig(preset: "AVCaptureSessionPreset640x480", frameRate: 30)
//
//        // 360p
//        //self.videoConfig = FMIceLinkVideoConfig(width: 480, height: 360, frameRate: 30)
//        
//        // 480p
//        //self.videoConfig = FMIceLinkVideoConfig(width: 858, height: 480, frameRate: 30)
//        
//        //720p  Half HD
//        //self.videoConfig = FMIceLinkVideoConfig(width: 1280, height: 720, frameRate: 60)
//        
//        //1080p full HD
//        // self.videoConfig = FMIceLinkVideoConfig(width: 1920, height: 1080, frameRate: 30)
//        self.initialize()
//    }
//    
//    override func createVideoSource() -> FMIceLinkVideoSource {
//        return FMIceLinkCocoaAVCaptureSource(preview: preview, config: videoConfig)
//    }
//    
//    override func createViewSink() -> FMIceLinkViewSink! {
//        return nil
//    }
//    
//    override func view() -> Any! {
//        return self.preview
//    }
//}
//
//class LocalScreenMedia : LocalMedia {
//    override init!(disableAudio: Bool, disableVideo: Bool, aecContext: FMIceLinkAecContext?) {
//        super.init(disableAudio: disableAudio, disableVideo: disableVideo, aecContext: aecContext)
//        
//        self.initialize()
//    }
//    
//    override func createVideoSource() -> FMIceLinkVideoSource {
//        return FMIceLinkCocoaScreenSource(frameRate: 3)
//    }
//    
//    override func createViewSink() -> FMIceLinkViewSink! {
//        return FMIceLinkCocoaImageViewSink()
//    }
//}
//
//class LocalMedia : FMIceLinkRtcLocalMedia {
//    var videoConfig: FMIceLinkVideoConfig?
//    var recordingPath: String = ""
//    
//    override init!(disableAudio: Bool, disableVideo: Bool, aecContext: FMIceLinkAecContext?) {
//        super.init(disableAudio: disableAudio, disableVideo: disableVideo, aecContext: aecContext)
//        
//        self.recordingPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
//    }
//    
//    override func doStart() -> FMIceLinkFuture! {
//        if (!self.audioDisabled()) {
//            do {
//             
//                if #available(iOS 10.0, *) {
//                    try AVAudioSession.sharedInstance().setCategory(.playAndRecord, mode: .default, options: [.allowBluetooth , (AVAudioSession.CategoryOptions.defaultToSpeaker)])
//                } else {
//                    AVAudioSession.sharedInstance().perform(NSSelectorFromString("setCategory:withOptions:error:"),with: AVAudioSession.Category.playAndRecord, with: [.allowBluetooth, AVAudioSession.CategoryOptions.defaultToSpeaker])
//                }
//            }
//            catch {
//                return FMIceLinkPromise.rejectNow(withEx: NSException.init(fmMessage: "Could not set audio session category for local media."))
//            }
//            
//            do {
//                try AVAudioSession.sharedInstance().setActive(true);
//            }
//            catch {
//                return FMIceLinkPromise.rejectNow(withEx: NSException.init(fmMessage: "Could not activate audio session for local media."))
//            }
//        }
//        
//        return super.doStart()
//    }
//    
//    override func createAudioSource(with config: FMIceLinkAudioConfig) -> FMIceLinkAudioSource {
//        return FMIceLinkCocoaAudioUnitSource(config: config)
//    }
//    
//    override func createImageConverter(withOutputFormat outputFormat: FMIceLinkVideoFormat) -> FMIceLinkVideoPipe {
//        return FMIceLinkYuvImageConverter(outputFormat: outputFormat)
//    }
//    
//    override func createVp8Encoder() -> FMIceLinkVideoEncoder! {
//        return FMIceLinkVp8Encoder()
//    }
//    
//    override func createVp9Encoder() -> FMIceLinkVp9Encoder? {
//        return FMIceLinkVp9Encoder()
//    }
//    
//    override func createH264Encoder() -> FMIceLinkVideoEncoder! {
//        return nil //FMIceLinkCocoaVideoToolboxH264Encoder()
//    }
//    
//    override func createOpusEncoder(with config: FMIceLinkAudioConfig) -> FMIceLinkAudioEncoder {
//        return FMIceLinkOpusEncoder(config: config)
//    }
//    
//    override func createPcmaEncoder(with config: FMIceLinkAudioConfig) -> FMIceLinkAudioEncoder {
//        return FMIceLinkPcmaEncoder(config: config)
//    }
//    
//    override func createPcmuEncoder(with config: FMIceLinkAudioConfig) -> FMIceLinkAudioEncoder {
//        return FMIceLinkPcmuEncoder(config: config)
//    }
//    
//    override func createAudioRecorder(withInputFormat inputFormat: FMIceLinkAudioFormat!) -> FMIceLinkAudioSink! {
//        return FMIceLinkMatroskaAudioSink(path: "local-audio-\(String(describing: inputFormat.name())).mkv")
//    }
//    
//    override func createVideoRecorder(withInputFormat inputFormat: FMIceLinkVideoFormat!) -> FMIceLinkVideoSink! {
//        return FMIceLinkMatroskaVideoSink(path: "local-video-\(String(describing: inputFormat.name())).mkv")
//    }
//    
//}
