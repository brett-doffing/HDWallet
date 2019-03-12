// RecoverOrCreatePageVC.swift

import UIKit

class RecoverOrCreatePageVC: UIViewController {
    
    let createButton = UIButton()
    let recoverButton = UIButton()
    let orLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        setupLayout()
    }
    
    private func setupLayout() {
        createButton.translatesAutoresizingMaskIntoConstraints = false
        recoverButton.translatesAutoresizingMaskIntoConstraints = false
        orLabel.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(orLabel)
        orLabel.widthAnchor.constraint(equalToConstant: 100).isActive = true
        orLabel.heightAnchor.constraint(equalToConstant: 100).isActive = true
        orLabel.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
        orLabel.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor).isActive = true
        orLabel.text = "OR"
        orLabel.textColor = .black
        orLabel.font = orLabel.font.withSize(50)
        orLabel.textAlignment = .center
        
        view.addSubview(createButton)
        createButton.widthAnchor.constraint(equalToConstant: 300).isActive = true
        createButton.heightAnchor.constraint(equalToConstant: 100).isActive = true
        createButton.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
        createButton.bottomAnchor.constraint(equalTo: orLabel.topAnchor, constant: -25).isActive = true
        createButton.backgroundColor = .black
        createButton.setTitle("CREATE", for: .normal)
        createButton.setTitleColor(.white, for: .normal)
        createButton.titleLabel?.font = .systemFont(ofSize: 50)
        createButton.addTarget(self, action: #selector(choseToCreateWallet), for: .touchUpInside)
        
        view.addSubview(recoverButton)
        recoverButton.widthAnchor.constraint(equalToConstant: 300).isActive = true
        recoverButton.heightAnchor.constraint(equalToConstant: 100).isActive = true
        recoverButton.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor).isActive = true
        recoverButton.topAnchor.constraint(equalTo: orLabel.bottomAnchor, constant: 25).isActive = true
        recoverButton.backgroundColor = .black
        recoverButton.setTitle("RECOVER", for: .normal)
        recoverButton.setTitleColor(.white, for: .normal)
        recoverButton.titleLabel?.font = .systemFont(ofSize: 50)
        recoverButton.addTarget(self, action: #selector(choseToRecoverWallet), for: .touchUpInside)
    }
    
    @objc func choseToCreateWallet() {
        NotificationCenter.default.post(name: .choseToCreateWallet, object: nil)
    }

    @objc func choseToRecoverWallet() {
        NotificationCenter.default.post(name: .choseToRecoverWallet, object: nil)
    }
    
}
