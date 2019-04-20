// RootContainerVC.swift

import UIKit
import QuartzCore

// https://www.raywenderlich.com/299-how-to-create-your-own-slide-out-navigation-panel-in-swift
class RootContainerViewController: UIViewController {
    
    let rootNavigationController = RootNavigationContoller()
    let leftSidePanelVC = LeftSidePanelVC()
    var isLeftPanelExpanded = false
    let centerPanelExpandedOffset: CGFloat = 100
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tabBarVC = TabBarVC()
        self.rootNavigationController.viewControllers = [tabBarVC]
        view.addSubview(self.rootNavigationController.view)
        addChild(self.rootNavigationController)
        self.rootNavigationController.didMove(toParent: self)
        
        self.leftSidePanelVC.rootContainerVC = self
        view.insertSubview(self.leftSidePanelVC.view, at: 0)
        addChild(self.leftSidePanelVC)
        self.leftSidePanelVC.didMove(toParent: self)
        
        NotificationCenter.default.addObserver(self, selector: #selector(toggleLeftSidePanelNotification(_:)), name: .toggleLeftSidePanel, object: nil)
    }
    
    @objc func toggleLeftSidePanelNotification(_ notification: Notification) {
        let shouldExpand = self.isLeftPanelExpanded ? false : true
        self.animateLeftPanel(shouldExpand: shouldExpand)
    }
    
    func animateLeftPanel(shouldExpand: Bool) {
        if shouldExpand {
            self.isLeftPanelExpanded = true
            self.showShadowForCenterViewController(true)
            self.animateCenterPanelXPosition(
                targetPosition: self.rootNavigationController.view.frame.width - self.centerPanelExpandedOffset)
            
        } else {
            animateCenterPanelXPosition(targetPosition: 0) { finished in
                self.isLeftPanelExpanded = false
                self.showShadowForCenterViewController(false)
            }
        }
    }
    
    func animateCenterPanelXPosition(targetPosition: CGFloat, completion: ((Bool) -> Void)? = nil) {
        
        UIView.animate(withDuration: 0.5,
                       delay: 0,
                       usingSpringWithDamping: 0.8,
                       initialSpringVelocity: 0,
                       options: .curveEaseInOut, animations: {
                        self.rootNavigationController.view.frame.origin.x = targetPosition
        }, completion: completion)
    }
    
    func showShadowForCenterViewController(_ shouldShowShadow: Bool) {
        
        if shouldShowShadow {
            self.rootNavigationController.view.layer.shadowOpacity = 0.8
        } else {
            self.rootNavigationController.view.layer.shadowOpacity = 0.0
        }
    }
}
