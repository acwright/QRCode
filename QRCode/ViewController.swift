//
//  ViewController.swift
//  QRCode
//
//  Created by Aaron Wright on 12/11/18.
//  Copyright © 2018 Aaron Wright. All rights reserved.
//

import Cocoa
import AVFoundation

class ViewController: NSViewController, AVCaptureVideoDataOutputSampleBufferDelegate {

    @IBOutlet var preview: NSView!
    @IBOutlet var output: NSTextField!
    
    var session: AVCaptureSession!
    var queue: DispatchQueue!
    
    // All this code is very suspect. Read documentation and make sure this is not going to leak memory or something!
    
    override func viewDidAppear() {
        super.viewDidAppear()
        
        self.session = AVCaptureSession()
        session.sessionPreset = .low
        
        let device = AVCaptureDevice.default(for: .video)
        let input = try! AVCaptureDeviceInput(device: device!)
        
        session.addInput(input)
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.frame = preview.bounds
        previewLayer.videoGravity = .resizeAspectFill
        
        self.preview.wantsLayer = true
        self.preview.layer?.addSublayer(previewLayer)
        
        self.queue = DispatchQueue(label: "queue", attributes: .concurrent)
        
        let output = AVCaptureVideoDataOutput()
        //output.videoSettings = [kCVPixelBufferPixelFormatTypeKey: kCVPixelFormatType_32BGRA] as [String : Any]
        output.setSampleBufferDelegate(self, queue: queue)
        output.alwaysDiscardsLateVideoFrames = true
        //        AVCaptureDevice.requestAccess(for: .video) { (success) in
        //            Swift.print(success)
        //        }
        session.addOutput(output)
        
        session.startRunning()
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        let context = CIContext()
        let detector = CIDetector(ofType: "CIDetectorTypeQRCode", context: context, options: [:])

        let ciImage = CIImage(cvImageBuffer: CMSampleBufferGetImageBuffer(sampleBuffer)!)
        
        if let features = detector?.features(in: ciImage) {
            guard let feature = features.first as? CIQRCodeFeature else { return }
            guard let message = feature.messageString else { return }
            
            DispatchQueue.main.sync {
                Swift.print(message)
                
                self.output.stringValue = message
            }
        }
    }

}
