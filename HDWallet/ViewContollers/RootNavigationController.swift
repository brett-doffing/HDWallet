// RootNavigationController.swift

import UIKit

class RootNavigationContoller: UINavigationController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.font: UIFont.bitcoinFontWith(size: 34), NSAttributedString.Key.foregroundColor: UIColor.lightText]
        navigationBar.barStyle = .black
        navigationBar.isTranslucent = false
        navigationBar.tintColor = .white
    }
}
