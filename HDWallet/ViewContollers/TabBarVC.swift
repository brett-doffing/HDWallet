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
        setUpNavAndTabBars()
        
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
    
    private func setUpNavAndTabBars() {
        if UserDefaults.standard.bool(forKey: "testnet") == true {
            tabBar.tintColor = .green
            navigationItem.title = "testnet"
        } else {
            tabBar.tintColor = #colorLiteral(red: 0.9693624377, green: 0.5771938562, blue: 0.1013594046, alpha: 1)
            navigationItem.title = "bitcoin"
        }
        
        let hamburgerButton = UIButton(type: .system)
        hamburgerButton.setImage(UIImage(named: "hamburgerIcon"), for: .normal)
        hamburgerButton.widthAnchor.constraint(equalToConstant: 32.0).isActive = true
        hamburgerButton.heightAnchor.constraint(equalToConstant: 32.0).isActive = true
        hamburgerButton.contentMode = .scaleAspectFit
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: hamburgerButton)
    }
}
