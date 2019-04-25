// QRImageView.swift

import UIKit

class QRImageView: UIImageView {
    
    var qrString: String?
    
    init(withFrame frame: CGRect, andQRString qrString: String) {
        self.qrString = qrString
        super.init(frame: frame)
        createQRCImage()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func createQRCImage() {
        let data = self.qrString?.data(using: String.Encoding.isoLatin1, allowLossyConversion: false)
        
        let filter = CIFilter(name: "CIQRCodeGenerator")!
        
        filter.setValue(data, forKey: "inputMessage")
        filter.setValue("Q", forKey: "inputCorrectionLevel")
        let qrcodeImage = filter.outputImage!
        
        // Fix Blurr
        let scaleX = self.bounds.size.width / qrcodeImage.extent.size.width
        let scaleY = self.bounds.size.height / qrcodeImage.extent.size.height
        let transformedImage = qrcodeImage.transformed(by: CGAffineTransform(scaleX: scaleX, y: scaleY))
        
        self.image = UIImage(ciImage: transformedImage)
    }
    
}
