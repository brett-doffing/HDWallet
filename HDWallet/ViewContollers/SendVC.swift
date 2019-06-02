// SendVC.swift

import UIKit
import AVFoundation
import CoreData

class SendVC: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    
    var qrScanner: QRScanningView?
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(qrCodeScannedNotification(_:)), name: .scannedQRCode, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        self.qrScanner = QRScanningView(frame: view.bounds)
//        view.addSubview(self.qrScanner!)
//        self.qrScanner?.beginScanning()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if self.qrScanner != nil {
            self.qrScanner?.removeFromSuperview()
            self.qrScanner = nil
        }
    }
    
    @objc func qrCodeScannedNotification(_ notification:Notification) {
        if let userInfo = notification.userInfo as? [String : String], let qrString = userInfo["qrString"] {
            print(qrString)
        }
        UIView.animateKeyframes(withDuration: 0.1, delay: 0.0, options: [.repeat, .autoreverse], animations: {
            UIView.setAnimationRepeatCount(3)
            self.qrScanner?.qrCodeFrameView?.alpha = 0
        }) { (complete) in
            UIView.animate(withDuration: 0.5, animations: {
                self.qrScanner?.frame.origin.y = 1000
            }, completion: { (complete) in
                self.qrScanner?.removeFromSuperview()
                self.qrScanner = nil
            })
        }
    }
    
    deinit {
        print("deinitializing Send VC")
    }
}

extension SendVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            return
        default:
            return
        }
    }
}

extension SendVC: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        
//        switch indexPath.row {
//        case 0:
//            cell.textLabel?.text = ""
//        default:
//            return cell
//        }
        cell.backgroundColor = .clear
        return cell
    }
    
}
