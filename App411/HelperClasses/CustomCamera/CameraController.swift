//
//  CameraController.swift
//  App411Camera
//
//  Created by osvinuser on 7/18/17.
//  Copyright © 2017 osvinuser. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation
import Photos

//https://developer.apple.com/library/content/samplecode/AVCam/Listings/Swift_AVCam_CameraViewController_swift.html

class CameraController: NSObject {
    
    var captureDevice : AVCaptureDevice? // check capture device availability
    var currentCameraPosition: CameraPosition?
    var frontCameraInput: AVCaptureDeviceInput?
    var rearCameraInput: AVCaptureDeviceInput?
    var captureSession: AVCaptureSession?
    var frontCamera: AVCaptureDevice?
    var rearCamera: AVCaptureDevice?
    var photoOutput: AVCapturePhotoOutput?
    var previewLayer: AVCaptureVideoPreviewLayer?
    var flashMode = AVCaptureFlashMode.off
    var photoCaptureCompletionBlock: ((UIImage?, Error?) -> Void)?
    let movieOutput = AVCaptureMovieFileOutput()
    var activeInput: AVCaptureDeviceInput?
    var outputURL: URL!

    //block for get images
    var photocompletionHandler: ((UIImage)->Void)?
    var videocompletionHandler: ((URL?, Error?)->Void)?

    fileprivate func tempFilePath() -> URL {
        let tempURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("tempMovie\(Date().timeIntervalSince1970)").appendingPathExtension("mp4")
        return tempURL
    }
}

extension CameraController {
    
    func prepare(completionHandler: @escaping (Error?) -> Void) {
        
        self.setUpCameraView { (error) in
            completionHandler(error)
        }
        
    }
    
    func createCaptureSession() {
        self.captureSession = AVCaptureSession()
    }
    
    func configureCaptureDevices() throws {
        let session = AVCaptureDeviceDiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: AVMediaTypeVideo, position: .unspecified)
        
        guard let cameras = (session?.devices.flatMap { $0 }), !cameras.isEmpty else { throw CameraControllerError.noCamerasAvailable }
        
        for camera in cameras {
            if camera.position == .front {
                self.frontCamera = camera
                
            }
            
            if camera.position == .back {
                self.rearCamera = camera
                
                try camera.lockForConfiguration()
                camera.focusMode = .continuousAutoFocus
                camera.unlockForConfiguration()
            }
        }
    }
    
    func configureDeviceInputs() throws {
        guard let captureSession = self.captureSession else { throw CameraControllerError.captureSessionIsMissing }
        
        if let rearCamera = self.rearCamera {
            self.rearCameraInput = try AVCaptureDeviceInput(device: rearCamera)
            
            if captureSession.canAddInput(self.rearCameraInput!) { captureSession.addInput(self.rearCameraInput!) }
            
            self.currentCameraPosition = .rear
        }
            
        else if let frontCamera = self.frontCamera {
            self.frontCameraInput = try AVCaptureDeviceInput(device: frontCamera)
            
            if captureSession.canAddInput(self.frontCameraInput!) { captureSession.addInput(self.frontCameraInput!) }
            else { throw CameraControllerError.inputsAreInvalid }
            
            self.currentCameraPosition = .front
        }
            
        else { throw CameraControllerError.noCamerasAvailable }
    }
    
    func configurePhotoOutput() throws {
        guard let captureSession = self.captureSession else { throw CameraControllerError.captureSessionIsMissing }
        
        self.photoOutput = AVCapturePhotoOutput()
        self.photoOutput!.setPreparedPhotoSettingsArray([AVCapturePhotoSettings(format: [AVVideoCodecKey : AVVideoCodecJPEG])], completionHandler: nil)
        
        if captureSession.canAddOutput(self.photoOutput) { captureSession.addOutput(self.photoOutput) }
        captureSession.startRunning()
    }
    
    func setUpCameraView(completionHandler: @escaping (Error?) -> Void) {
        
        DispatchQueue(label: "prepare").async {
            do {
                self.createCaptureSession()
                try self.configureCaptureDevices()
                try self.configureDeviceInputs()
                try self.configurePhotoOutput()
            }
                
            catch {
                DispatchQueue.main.async {
                    completionHandler(error)
                }
                
                return
            }
            
            DispatchQueue.main.async {
                completionHandler(nil)
            }
        }
    }
    
    func displayPreview(on view: UIView) throws {
        guard let captureSession = self.captureSession, captureSession.isRunning else { throw CameraControllerError.captureSessionIsMissing }
        
        self.previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        self.previewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
        self.previewLayer?.connection?.videoOrientation = .portrait
        
        view.layer.insertSublayer(self.previewLayer!, at: 0)
        self.previewLayer?.frame = view.frame
    }
    
    func switchCameras() throws {
        guard let currentCameraPosition = currentCameraPosition, let captureSession = self.captureSession, captureSession.isRunning else { throw CameraControllerError.captureSessionIsMissing }
        
        captureSession.beginConfiguration()
        
        func switchToFrontCamera() throws {
            guard let inputs = captureSession.inputs as? [AVCaptureInput], let rearCameraInput = self.rearCameraInput, inputs.contains(rearCameraInput),
                let frontCamera = self.frontCamera else { throw CameraControllerError.invalidOperation }
            
            self.frontCameraInput = try AVCaptureDeviceInput(device: frontCamera)
            
            captureSession.removeInput(rearCameraInput)
            
            if captureSession.canAddInput(self.frontCameraInput!) {
                captureSession.addInput(self.frontCameraInput!)
                
                self.currentCameraPosition = .front
            } else {
                throw CameraControllerError.invalidOperation
            }
        }
        
        func switchToRearCamera() throws {
            
            guard let inputs = captureSession.inputs as? [AVCaptureInput], let frontCameraInput = self.frontCameraInput, inputs.contains(frontCameraInput),
                let rearCamera = self.rearCamera else { throw CameraControllerError.invalidOperation }
            
            self.rearCameraInput = try AVCaptureDeviceInput(device: rearCamera)
            
            captureSession.removeInput(frontCameraInput)
            
            if captureSession.canAddInput(self.rearCameraInput!) {
                captureSession.addInput(self.rearCameraInput!)
                
                self.currentCameraPosition = .rear
            }
                
            else { throw CameraControllerError.invalidOperation }
        }
        
        switch currentCameraPosition {
        case .front:
            try switchToRearCamera()
            
        case .rear:
            try switchToFrontCamera()
        }
        
        captureSession.commitConfiguration()
    }
    
    func captureImage(completion: @escaping (UIImage?, Error?) -> Void) {
        guard let captureSession = captureSession, captureSession.isRunning else { completion(nil, CameraControllerError.captureSessionIsMissing); return }
        
        let settings = AVCapturePhotoSettings()
        settings.flashMode = self.flashMode
        
        self.photoOutput?.capturePhoto(with: settings, delegate: self)
        self.photoCaptureCompletionBlock = completion
    }
    
    //MARK: - Video Record Functions Start
    
    fileprivate func startVideoRecording() {
        
        
    }
    
    func currentVideoOrientation() -> AVCaptureVideoOrientation {
        var orientation: AVCaptureVideoOrientation
        
        switch UIDevice.current.orientation {
        case .portrait:
            orientation = AVCaptureVideoOrientation.portrait
        case .landscapeRight:
            orientation = AVCaptureVideoOrientation.landscapeLeft
        case .portraitUpsideDown:
            orientation = AVCaptureVideoOrientation.portraitUpsideDown
        default:
            orientation = AVCaptureVideoOrientation.landscapeRight
        }
        
        return orientation
    }
    
    //MARK:- setupVideoSession
    
   fileprivate func setupVideoSession() {
    
        guard let captureSession = self.captureSession else {
               print(CameraControllerError.captureSessionIsMissing)
            return
         }
    
        captureSession.beginConfiguration()
        
        //set video quality
        captureSession.sessionPreset = AVCaptureSessionPresetHigh
        
        // Setup Microphone
        let microphone = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeAudio)
        
        do {
            let micInput = try AVCaptureDeviceInput(device: microphone)
            if captureSession.canAddInput(micInput) {
                captureSession.addInput(micInput)
            }
        } catch {
            print("Error setting device audio input: \(error)")
            return
        }
        
        captureSession.commitConfiguration()
        
        // Movie output
        if captureSession.canAddOutput(self.movieOutput) {
            captureSession.addOutput(self.movieOutput)
        }
        
        if self.movieOutput.isRecording == false {
            
            let connection = self.movieOutput.connection(withMediaType: AVMediaTypeVideo)
            if (connection?.isVideoOrientationSupported)! {
                connection?.videoOrientation = self.currentVideoOrientation()
            }
            
            if (connection?.isVideoStabilizationSupported)! {
                connection?.preferredVideoStabilizationMode = AVCaptureVideoStabilizationMode.auto
            }
            
            //EDIT2: And I forgot this
            self.outputURL = self.tempFilePath()
            self.movieOutput.startRecording(toOutputFileURL: self.outputURL, recordingDelegate: self)
            
        } else {
            self.movieOutput.stopRecording() // stop video recording
        }
    }
    
    func toggleTorch(on: Bool) {
        guard let device = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo) else { return }
        
        if device.hasTorch {
            do {
                try device.lockForConfiguration()
                
                if on == true {
                    device.torchMode = .on
                } else {
                    device.torchMode = .off
                }
                
                device.unlockForConfiguration()
            } catch {
                print("Torch could not be used")
            }
        } else {
            print("Torch is not available")
        }
    }
    
   fileprivate func stopSession() throws {
        
        guard let captureSesion = self.captureSession else { throw CameraControllerError.captureSessionIsMissing }

        if captureSesion.isRunning {
            videoQueue().async {
                captureSesion.stopRunning()
            }
        }
    }
    
    func videoQueue() -> DispatchQueue {
        return DispatchQueue.main
    }
    
    
   public func startCaptureVideoRecording() {
    
    self.setupVideoSession()  //check whether video has valid session
   }
    
    public func stopRecording(completion: @escaping (URL?, Error?) -> Void) {
        
        if movieOutput.isRecording == true {
            movieOutput.stopRecording() // stop video recording
            self.videocompletionHandler = completion
        }
    }

}

extension CameraController: AVCapturePhotoCaptureDelegate {
    
    public func capture(_ captureOutput: AVCapturePhotoOutput, didFinishProcessingPhotoSampleBuffer photoSampleBuffer: CMSampleBuffer?, previewPhotoSampleBuffer: CMSampleBuffer?,
                        resolvedSettings: AVCaptureResolvedPhotoSettings, bracketSettings: AVCaptureBracketedStillImageSettings?, error: Swift.Error?) {
        if let error = error { self.photoCaptureCompletionBlock?(nil, error) }
            
        else if let buffer = photoSampleBuffer, let data = AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer: buffer, previewPhotoSampleBuffer: nil),
            let image = UIImage(data: data) {
            
            if let handler = self.photoCaptureCompletionBlock {
                handler(image, nil)
            }
        } else {
            
            if let handler = self.photoCaptureCompletionBlock {
                handler(nil, CameraControllerError.unknown)
            }
        }
    }
    
}

extension CameraController : AVCaptureFileOutputRecordingDelegate {
    
    func capture(_ captureOutput: AVCaptureFileOutput!, didStartRecordingToOutputFileAt fileURL: URL!, fromConnections connections: [Any]!) {
        print(fileURL)
    }
    
    func capture(_ captureOutput: AVCaptureFileOutput!, didFinishRecordingToOutputFileAt outputFileURL: URL!, fromConnections connections: [Any]!, error: Error!) {
        
        if (error != nil) {
            print("Error recording movie: \(error!.localizedDescription)")
            if let handler = videocompletionHandler {
                
                handler(nil, error)
            }
        } else {
            
            print(outputURL)
//            UISaveVideoAtPathToSavedPhotosAlbum(outputURL.path, nil, nil, nil)
            
            _ = outputURL as URL

            if let handler = videocompletionHandler {
                
                handler(outputURL, nil)
            }
        }
        
        
        outputURL = nil
    }
}

extension CameraController {
    enum CameraControllerError: Swift.Error {
        case captureSessionAlreadyRunning
        case captureSessionIsMissing
        case inputsAreInvalid
        case invalidOperation
        case noCamerasAvailable
        case unknown
    }
    
    public enum CameraPosition {
        case front
        case rear
    }
}

