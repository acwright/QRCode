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
    // You must set entitlement (Capabilities tab) to allow camera.
    // Also you must set plist string (see plist)
    
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
        output.setSampleBufferDelegate(self, queue: queue)
        output.alwaysDiscardsLateVideoFrames = true
        
        session.addOutput(output)
        
        //        AVCaptureDevice.requestAccess(for: .video) { (success) in
        //            Swift.print(success)
        //        }
        
        session.startRunning()
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        // This is called repeatedly at the video frame rate! Be careful not to call api here!
        
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
