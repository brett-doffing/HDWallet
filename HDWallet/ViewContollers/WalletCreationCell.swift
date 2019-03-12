//
//  WalletCreationCell.swift
//  HDWallet
//

import UIKit

class WalletCreationCell: UICollectionViewCell {
    
    let topView: UIView = {
        let myTopView = UIView()
        myTopView.translatesAutoresizingMaskIntoConstraints = false
        myTopView.backgroundColor = .darkGray
        return myTopView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(topView)
        
        setupLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLayout() {
        topView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 0).isActive = true
        topView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 0).isActive = true
        topView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0).isActive = true
        topView.bottomAnchor.constraint(equalTo: contentView.topAnchor, constant: contentView.frame.height / 2).isActive = true
    }
    
}
