// TabBarVC.swift

import UIKit
import SpriteKit

class TabBarVC: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tabBar.barStyle = .black
        tabBar.isTranslucent = false
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.font: UIFont.bitcoinFontWith(size: 10)], for: .normal)
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.font: UIFont.bitcoinFontWith(size: 10)], for: .selected)
        if UserDefaults.standard.bool(forKey: "testnet") == true {
            tabBar.tintColor = .green
        } else {
            tabBar.tintColor = #colorLiteral(red: 0.9693624377, green: 0.5771938562, blue: 0.1013594046, alpha: 1)
            addNavBarImage()
        }
        
        let receiveVC = ReceiveVC()
        receiveVC.tabBarItem = UITabBarItem(title: "Receive", image: UIImage(named: "receiveIcon"), tag: 0)
        let sendVC = SendVC()
        sendVC.view.backgroundColor = .lightGray
        sendVC.tabBarItem = UITabBarItem(title: "Send", image: UIImage(named: "sendIcon"), tag: 1)
        let transactionsVC = TransactionsVC()
        transactionsVC.view.backgroundColor = .darkGray
        transactionsVC.tabBarItem = UITabBarItem(title: "Transactions", image: UIImage(named: "bitcoinIcon"), tag: 2)
        let settingsVC = SettingsVC()
        settingsVC.tabBarItem = UITabBarItem(title: "Settings", image: UIImage(named: "settingsIcon"), tag: 3)
        
        let viewControllerList = [receiveVC, sendVC, transactionsVC, settingsVC]
        self.viewControllers = viewControllerList
    }
    
    private func addNavBarImage() {
        let containerView = UIView(frame: CGRect(x: 0, y: 0, width: 153, height: 32))
        let image = UIImage(named: "BTCLogo")
        let imageView = UIImageView(image: image)
        // Nav bar height is 44, image height is 32, so -6 offset to center
        imageView.frame = CGRect(x: 0, y: -6, width: 153, height: 32)
        containerView.addSubview(imageView)
        navigationItem.titleView = containerView
        
        // add hamburger
        // TODO: Find out how to manage nav bar items stack view
        // https://www.matrixprojects.net/p/uibarbuttonitem-ios11/
        // https://stackoverflow.com/a/46549639/1848601
//        let hamburger = UIBarButtonItem(image: UIImage(named: "hamburgerIcon"), style: .plain, target: self, action: nil)
//        hamburger.tintColor = .white
//        hamburger.imageInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: -50)
//        navigationItem.rightBarButtonItem = hamburger
        
//        for navView in navigationController!.navigationBar.subviews {
//            if navView.isKind(of: UIBarButtonItem.self) || navView.isKind(of: UIView.self) {
//                for ctr in navView.constraints {
//                    if(ctr.firstAttribute == .leading || ctr.secondAttribute == .leading) {
//                        ctr.constant = 0;
//                    } else if(ctr.firstAttribute == .trailing || ctr.secondAttribute == .trailing) {
//                        ctr.constant = 0;
//                    }
//                }
//                for navSubView in navView.subviews {
//                    if navSubView.isKind(of: UIStackView.self) {
//                        for ctr in navSubView.constraints {
//                            if(ctr.firstAttribute == .width || ctr.secondAttribute == .width) {
//                                ctr.constant = 0;
//                            }
//                        }
//                    }
//                }
//            }
//        }
    }
}
