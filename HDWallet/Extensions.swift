// Extensions.swift

import UIKit

extension Notification.Name {
    static let scannedQRCode = Notification.Name("scannedQRCode")
    static let toggleLeftSidePanel = Notification.Name("toggleLeftSidePanel")
    static let transactionPosted = Notification.Name("transactionPosted")
}

extension UIFont {
    class func bitcoinFontWith(size: CGFloat ) -> UIFont {
        return  UIFont(name: "Ubuntu-BoldItalic", size: size)!
    }
}

