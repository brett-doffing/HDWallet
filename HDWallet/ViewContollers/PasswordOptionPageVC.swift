// PasswordOptionPageVC.swift

import UIKit

class PasswordOptionPageVC: UIViewController {
    
    let label = UILabel()
    let txtfld1 = UITextField()
    let txtfld2 = UITextField()
    let button = UIButton()
    var recoverWallet: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        NotificationCenter.default.addObserver(self, selector: #selector(notificationChoseToCreateWallet), name: .choseToCreateWallet, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(notificationChoseToRecoverWallet), name: .choseToRecoverWallet, object: nil)
        
        view.backgroundColor = .white
//        txtfld1.delegate = self
        
        setupLayout()
//        txtfld1.becomeFirstResponder()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        txtfld1.becomeFirstResponder()
        
    }
    
    private func setupLayout() {
        label.translatesAutoresizingMaskIntoConstraints = false
        txtfld1.translatesAutoresizingMaskIntoConstraints = false
        txtfld2.translatesAutoresizingMaskIntoConstraints = false
        button.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(label)
        label.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 0).isActive = true
        label.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: 0).isActive = true
        label.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 25).isActive = true
        label.heightAnchor.constraint(equalToConstant: 200)
        label.text = "Skip if you are not using a password for this wallet."
        label.numberOfLines = 2
        label.textColor = .black
        label.font = .systemFont(ofSize: 25)
        label.textAlignment = .center
        
        view.addSubview(txtfld1)
        txtfld1.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 50).isActive = true
        txtfld1.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -50).isActive = true
        txtfld1.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 25).isActive = true
        txtfld1.borderStyle = .roundedRect
        txtfld1.isSecureTextEntry = true
        
        view.addSubview(txtfld2)
        txtfld2.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 50).isActive = true
        txtfld2.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -50).isActive = true
        txtfld2.topAnchor.constraint(equalTo: txtfld1.bottomAnchor, constant: 25).isActive = true
        txtfld2.borderStyle = .roundedRect
        txtfld2.isSecureTextEntry = true
        
        view.addSubview(button)
        button.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 50).isActive = true
        button.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -50).isActive = true
        button.topAnchor.constraint(equalTo: txtfld2.bottomAnchor, constant: 25).isActive = true
        button.heightAnchor.constraint(equalToConstant: 100)
        button.backgroundColor = .black
        #warning("TODO: verify this is set AFTER button press to show this VC")
        if recoverWallet == true {
            button.setTitle("RECOVER", for: .normal)
        } else {
            button.setTitle("CREATE", for: .normal)
        }
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 50)
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        
    }
    
    @objc func buttonTapped() {
        if txtfld1.text == "" && txtfld2.text == "" {
            NotificationCenter.default.post(name: .choseToSkipPassword, object: nil)
        } else if txtfld1.text == txtfld2.text {
            NotificationCenter.default.post(name: .choseToSetPassword, object: nil)
        } else {
            // ALERT
        }
        
    }
    
}

extension PasswordOptionPageVC: UITextFieldDelegate {
    
}
