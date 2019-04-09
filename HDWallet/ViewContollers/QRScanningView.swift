// QRScanningView.swift

import UIKit
import AVFoundation

class QRScanningView: UIView, AVCaptureMetadataOutputObjectsDelegate {
    var captureSession: AVCaptureSession?
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    var qrCodeFrameView: UIView?
    var btcAddrForQRC: String?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func beginScanning() {
        // Get an instance of the AVCaptureDevice class to initialize a device object and provide the video
        // as the media type parameter.
        let captureDevice = AVCaptureDevice.default(for: AVMediaType.video)
        
        // Get an instance of the AVCaptureDeviceInput class using the previous device object.
        let input: AVCaptureDeviceInput
        do {
            input = try AVCaptureDeviceInput(device: captureDevice!)
        } catch {
            print("error AVCaptureDeviceInput")
            return
        }
        
        // Initialize the captureSession object.
        self.captureSession = AVCaptureSession()
        
        if (self.captureSession?.canAddInput(input))! {
            // Set the input device on the capture session.
            self.captureSession?.addInput(input as AVCaptureInput)
        } else {
            print("error canAddInput")
            return;
        }
        
        // Initialize a AVCaptureMetadataOutput object and set it as the output device to the capture session.
        let metadataOutput = AVCaptureMetadataOutput()
        
        if (self.captureSession?.canAddOutput(metadataOutput))! {
            self.captureSession?.addOutput(metadataOutput)
            // Set delegate and use the default dispatch queue to execute the call back
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [AVMetadataObject.ObjectType.qr]
        } else {
            print("error canAddOutput")
            return
        }
        
        // Initialize the video preview layer and add it as a sublayer to the viewPreview view's layer.
        self.videoPreviewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession!)
        self.videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        self.videoPreviewLayer?.frame = self.layer.bounds
        self.layer.addSublayer(self.videoPreviewLayer!)
        
        // Start video capture.
        self.captureSession?.startRunning()
        
        // Initialize QR Code Frame to highlight the QR code
        self.qrCodeFrameView = UIView()
        self.qrCodeFrameView?.layer.borderColor = #colorLiteral(red: 0.9693624377, green: 0.5771938562, blue: 0.1013594046, alpha: 1).cgColor
        self.qrCodeFrameView?.layer.borderWidth = 5
        self.addSubview(self.qrCodeFrameView!)
        self.bringSubviewToFront(self.qrCodeFrameView!)
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        self.captureSession?.stopRunning()
        
        // Check if the metadataObjects array is not nil and it contains at least one object.
        if metadataObjects.count == 0 {
            self.qrCodeFrameView?.frame = CGRect.zero
            return
        }
        
        // Get the metadata object.
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        
        if metadataObj.type == AVMetadataObject.ObjectType.qr {
            // If the found metadata is equal to the QR code metadata then set the bounds
            let barCodeObject = videoPreviewLayer?.transformedMetadataObject(for: metadataObj as AVMetadataMachineReadableCodeObject) as! AVMetadataMachineReadableCodeObject
            qrCodeFrameView?.frame = CGRect(x: barCodeObject.bounds.minX - 15, y: barCodeObject.bounds.minY - 15, width: barCodeObject.bounds.width + 30, height: barCodeObject.bounds.height + 30)
            
            if let qrString = metadataObj.stringValue {
                let userInfo: [String : String] = ["qrString" : qrString]
                NotificationCenter.default.post(name: .scannedQRCode, object: nil, userInfo: userInfo)
            }
        }
    }
}
