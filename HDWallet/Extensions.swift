// Extensions.swift

import UIKit

extension Notification.Name {
    static let scannedQRCode = Notification.Name("scannedQRCode")
}

extension UIFont {
    class func bitcoinFontWith(size: CGFloat ) -> UIFont {
        return  UIFont(name: "Ubuntu-BoldItalic", size: size)!
    }
}

