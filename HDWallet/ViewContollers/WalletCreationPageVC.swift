//  WalletCreationPageVC.swift

import UIKit

#warning("TODO: check to see if and when VC's are created or destroyed.")
class WalletCreationPageVC: UIPageViewController, UIPageViewControllerDelegate/*, UIPageViewControllerDataSource*/ {
    
    var pages: [UIViewController] = []
//    let pageControl = UIPageControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        delegate = self
        // not setting the data source removes gestures
        //dataSource = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(notificationChoseToCreateWallet), name: .choseToCreateWallet, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(notificationChoseToRecoverWallet), name: .choseToRecoverWallet, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(notificationChoseToSetPassword), name: .choseToSetPassword, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(notificationChoseToSkipPassword), name: .choseToSkipPassword, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(notificationSetPath), name: .setPath, object: nil)
        
        setupPages()
    }
    
    func setupPages() {
        let initialPage = 0
        
        // setup and add the individual viewControllers to the pageViewController
        let recoverOrCreatePage = RecoverOrCreatePageVC()
        let passwordPage = PasswordOptionPageVC()
        let pathPage = PathsPageTVC()
        let seedWordsPage = SeedWordsPageVC()
        
        pages.append(recoverOrCreatePage)
        pages.append(passwordPage)
        pages.append(pathPage)
        pages.append(seedWordsPage)
        setViewControllers([pages[initialPage]], direction: .forward, animated: true, completion: nil)
        
        // pageControl
//        pageControl.frame = CGRect()
//        pageControl.currentPageIndicatorTintColor = .lightGray
//        pageControl.pageIndicatorTintColor = .black
//        pageControl.numberOfPages = pages.count
//        pageControl.currentPage = initialPage
//        view.addSubview(pageControl)
//
//        pageControl.translatesAutoresizingMaskIntoConstraints = false
//        pageControl.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -10).isActive = true
//        pageControl.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -20).isActive = true
//        pageControl.heightAnchor.constraint(equalToConstant: 20).isActive = true
//        pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func notificationChoseToCreateWallet() {
        setViewControllers([pages[1]], direction: .forward, animated: true, completion: nil)
    }
    
    @objc func notificationChoseToRecoverWallet() {
        guard let nextVC = pages[1] as? PasswordOptionPageVC else { return }
        nextVC.recoverWallet = true
        setViewControllers([pages[1]], direction: .forward, animated: true, completion: nil)
    }
    
    @objc func notificationChoseToSetPassword() {
        setViewControllers([pages[2]], direction: .forward, animated: true, completion: nil)
    }
    
    @objc func notificationChoseToSkipPassword() {
        setViewControllers([pages[2]], direction: .forward, animated: true, completion: nil)
    }
    @objc func notificationSetPath() {
        setViewControllers([pages[3]], direction: .forward, animated: true, completion: nil)
    }
    
//    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
//        if let viewControllerIndex = self.pages.index(of: viewController) {
//            if viewControllerIndex == 0 {
//                // wrap to last page in array
//                return self.pages.last
//            } else {
//                // go to previous page in array
//                return self.pages[viewControllerIndex - 1]
//            }
//        }
//        return nil
//    }
//
//    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
//        if let viewControllerIndex = self.pages.index(of: viewController) {
//            if viewControllerIndex < self.pages.count - 1 {
//                // go to next page in array
//                return self.pages[viewControllerIndex + 1]
//            } else {
//                // wrap to first page in array
//                return self.pages.first
//            }
//        }
//        return nil
//    }
//
//    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
//        // set the pageControl.currentPage to the index of the current viewController in pages
//        if let viewControllers = pageViewController.viewControllers {
//            if let viewControllerIndex = self.pages.index(of: viewControllers[0]) {
//                self.pageControl.currentPage = viewControllerIndex
//            }
//        }
//    }
}

extension Notification.Name {
    static let choseToCreateWallet = Notification.Name("choseToCreateWallet")
    static let choseToRecoverWallet = Notification.Name("choseToRecoverWallet")
    static let choseToSetPassword = Notification.Name("choseToSetPassword")
    static let choseToSkipPassword = Notification.Name("choseToSkipPassword")
    static let setPath = Notification.Name("setPath")
}
