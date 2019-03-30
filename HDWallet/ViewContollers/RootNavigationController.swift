// RootNavigationController.swift

import UIKit

class RootNavigationContoller: UINavigationController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationBar.barStyle = .black
        navigationBar.isTranslucent = false
        navigationBar.tintColor = .white
    }
}
