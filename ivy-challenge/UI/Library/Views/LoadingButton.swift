//
//  LoadingButton.swift
//  ivy-challenge
//
//  Created by Ali Ersöz on 2/24/18.
//  Copyright © 2018 Ali Ersöz. All rights reserved.
//

import Foundation
import UIKit
import SnapKit

final class LoadingButton: UIButton {
    private var spinner = UIActivityIndicatorView()
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        
        setTitleColor(.black, for: .normal)
        
        spinner.color = .black
        addSubview(spinner)
        
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func startLoading() {
        isEnabled = false
        spinner.startAnimating()
        titleLabel?.alpha = 0
    }
    
    func stopLoading() {
        isEnabled = true
        spinner.stopAnimating()
        titleLabel?.alpha = 1
    }
}
