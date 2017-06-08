//
//  ViewController.swift
//  QR Reader
//
//  Created by Manish Kumar on 07/06/17.
//  Copyright © 2017 appface. All rights reserved.
//

import UIKit
import AVFoundation

protocol BarcodeDelegate {
    func barcodeReaded(barcode: String)
}

class BarcodeViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate,UIWebViewDelegate {
    
    @IBOutlet weak var myIndicator: UIActivityIndicatorView!
    @IBOutlet weak var myWebView: UIWebView!
    @IBOutlet weak var myOutput: UITextView!
    @IBOutlet weak var myOutPutView: UIView!
    @IBOutlet weak var previewView: UIView!
    var delegate: BarcodeDelegate?
    
    var videoCaptureDevice: AVCaptureDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
    var device = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
    var output = AVCaptureMetadataOutput()
    var previewLayer: AVCaptureVideoPreviewLayer?
    
    var captureSession = AVCaptureSession()
    var code: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.clear
        self.setupCamera()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        previewLayer?.position = CGPoint(x: self.previewView.frame.width/2, y: self.previewView.frame.height/2)
        previewLayer?.bounds = previewView.frame
//        print(previewLayer?.metadataOutputRectOfInterest(for: (previewLayer?.frame)!))
    }
    
    private func setupCamera() {
        
        let input = try? AVCaptureDeviceInput(device: videoCaptureDevice)
        
        if self.captureSession.canAddInput(input) {
            self.captureSession.addInput(input)
        }
        
        self.previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        
        if let videoPreviewLayer = self.previewLayer {
            videoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
            videoPreviewLayer.frame = self.previewView.bounds
            previewView.layer.addSublayer(videoPreviewLayer)
        }
        
        let metadataOutput = AVCaptureMetadataOutput()
        if self.captureSession.canAddOutput(metadataOutput) {
            self.captureSession.addOutput(metadataOutput)
            
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [AVMetadataObjectTypeQRCode, AVMetadataObjectTypeEAN13Code]
        } else {
            print("Could not add metadata output")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if (captureSession.isRunning == false) {
            captureSession.startRunning()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if (captureSession.isRunning == true) {
            captureSession.stopRunning()
        }
    }
    
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {
        // This is the delegate'smethod that is called when a code is readed
        for metadata in metadataObjects {
            let readableObject = metadata as! AVMetadataMachineReadableCodeObject
            let code = readableObject.stringValue
            
            
            self.dismiss(animated: true, completion: nil)
            self.delegate?.barcodeReaded(barcode: code!)
//            UIApplication.shared.open(URL(string: code!)!, options: [:], completionHandler: nil)
            myOutput.text = code
            myIndicator.startAnimating()
            if let url = URL(string: code!){
                let request = URLRequest(url: url)
                
                myWebView.loadRequest(request)
                captureSession.stopRunning()
            }

            
            print(code!)
        }
    }
    func webViewDidFinishLoad(_ webView: UIWebView){
      myIndicator.stopAnimating()
    }
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//        .startAnimating()
//        if let url = URL(string: "https://www.apple.com/in"){
//            let request = URLRequest(url: url)
//            
//            myCustomWebView.loadRequest(request)
//            
//        }
//        
//        
//    }
}

