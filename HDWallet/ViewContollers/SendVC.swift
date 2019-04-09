// SendVC.swift

import UIKit
import AVFoundation

class SendVC: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    
    var qrScanner: QRScanningView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(qrCodeScannedNotification(_:)), name: .scannedQRCode, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.qrScanner = QRScanningView(frame: view.bounds)
        view.addSubview(self.qrScanner!)
        self.qrScanner?.beginScanning()
    }
    
    @objc func qrCodeScannedNotification(_ notification:Notification) {
        if let userInfo = notification.userInfo as? [String : String], let qrString = userInfo["qrString"] {
            print(qrString)
        }
        UIView.animateKeyframes(withDuration: 0.1, delay: 0.0, options: [.repeat, .autoreverse], animations: {
            UIView.setAnimationRepeatCount(3)
            self.qrScanner?.qrCodeFrameView?.alpha = 0
        }) { (complete) in
            if complete {
                UIView.animate(withDuration: 0.5, animations: {
                    self.qrScanner?.frame.origin.y = 1000
                }, completion: { (complete) in
                    self.qrScanner?.removeFromSuperview()
                })
            }
        }
    }
}
